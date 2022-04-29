import pytest
import numpy as np

from camion import fca


def test_input_variables(population_locations, facilities, distance_matrix):
    assert distance_matrix.shape[0] == population_locations.shape[0]
    assert distance_matrix.shape[1] == facilities.shape[0]


def test_constructor(population_locations, facilities, distance_matrix):
    e2sfca = fca.E2SFCA(
        S_j=facilities,
        P_i=population_locations,
        D_ij=distance_matrix
    )


@pytest.mark.parametrize("weights", [
    [(30, 1), (60, 0.42), (90, 0.09)]
])
def test_weights(population_locations, facilities, distance_matrix, weights):
    e2sfca = fca.E2SFCA(
        S_j=facilities,
        P_i=population_locations,
        D_ij=distance_matrix
    )

    W_ij = e2sfca.compute_weighted_distances(weights)
    weights_values = sorted([w for (d, w) in weights] + [0])

    assert np.min(W_ij) == min(weights_values)
    assert np.max(W_ij) == max(weights_values)
    assert (np.unique(W_ij) == weights_values).all()


@pytest.mark.parametrize("weights", [
    [(30, 1), (60, 0.42), (90, 0.09)],
    [(30, 1), (60, 0.42)]
])
def test_accessibility_score(population_locations, facilities,
                             distance_matrix, weights):
    e2sfca = fca.E2SFCA(
        S_j=facilities,
        P_i=population_locations,
        D_ij=distance_matrix
    )

    A_i = e2sfca.compute_accessibility_score(weights)

    assert A_i.shape == population_locations.shape
    assert np.min(A_i) >= 0
