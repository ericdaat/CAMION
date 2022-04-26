import numpy as np


class E2SFCA(object):
    def __init__(self, S_j, P_i, D_ij):
        self.D_ij = D_ij
        self.P_i = P_i
        self.S_j = S_j

    def compute_weighted_distances(self, weights):
        catchment_area = weights[-1][0]

        W_ij = np.where(self.D_ij > catchment_area, 0, self.D_ij)

        lower_distance = 0

        for upper_distance, weight in weights:
            W_ij = np.where(
                (W_ij > lower_distance) &
                (W_ij <= upper_distance),
                weight, W_ij
            )
            lower_distance = upper_distance

        return W_ij

    def compute_accessibility_score(self, weights):
        # Compute weighted distances
        W_ij = self.compute_weighted_distances(weights)

        # Compute accessibility
        R_j = self.S_j / np.dot(self.P_i, W_ij)
        R_j = np.nan_to_num(R_j, 0)
        A_i = np.dot(W_ij, R_j.T)

        return A_i
