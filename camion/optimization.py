from abc import ABC

import numpy as np
import scipy


class BaseOptimizer(ABC):
    def __init__(self):
        pass

    def optim_with_linear_programming(self, c, A_ub, b_ub, bounds):
        res = scipy.optimize.linprog(
            c=c,
            A_ub=A_ub,
            b_ub=b_ub,
            bounds=bounds,
            method="revised simplex"
        )

        return res


class RegularOptimizer(BaseOptimizer):
    def __init__(self):
        super().__init__()

    def run_optimization(self, S_j, P_i, W_ij, budget,
                         max_growth, max_decrease=0):
        P_j = np.dot(P_i, W_ij)

        c = W_ij.sum(axis=0) / P_j

        A = [
            list(np.ones(c.shape[1]))
        ]

        # Boundaries
        bounds = [
            [
                s * (1 - max_decrease),  # minimum capacity
                s * (1 + max_growth)     # maximum capacity
            ]
            for s in S_j[0]
        ]

        res = self.optim_with_linear_programming(
            c=-c,
            A_ub=A,
            b_ub=[S_j.sum() + budget],
            bounds=bounds
        )

        S_j_new = res.x

        return S_j_new


class MaxiMinOptimizer(BaseOptimizer):
    def __init__(self):
        super().__init__()

    def run_optimization(self, S_j, P_i, W_ij, budget,
                         max_growth, max_decrease=0):
        P_j = np.dot(P_i, W_ij)

        # Define c
        c = np.hstack([
            np.ones((1, 1)),
            np.zeros((1, S_j.shape[1]))
        ])

        # Constraints for population locations
        A_ub_1 = np.hstack([
            np.ones((P_i.shape[1], 1)),
            - W_ij / P_j
        ])

        b_1 = np.dot(W_ij, (S_j / P_j).T)

        # Constraints due to budget
        A_ub_2 = np.hstack([
            np.zeros((1, 1)),
            np.ones((1, S_j.shape[1]))
        ])

        b_2 = S_j.sum() + budget

        # Boundaries
        S_j_min = S_j * (1 - max_decrease)  # minimum capacity
        S_j_max = S_j * (1 + max_growth)    # maximum capacity

        bounds = np.vstack([
            np.asarray([[None], [None]]).T,  # no boundaries on z
            np.hstack([
                S_j_min.T,
                S_j_max.T
            ])
        ])

        res = self.optim_with_linear_programming(
            c=-c,
            A_ub=np.vstack([A_ub_1, A_ub_2]),
            b_ub=np.vstack([b_1, b_2]),
            bounds=bounds
        )

        S_j_new = res.x[1:]

        return S_j_new
