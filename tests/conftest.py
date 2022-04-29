import pytest
import numpy as np


# Declare variables
P_i = np.random.rand(100)
S_j = np.random.rand(10)
D_ij = np.random.randint(low=1, high=100, size=(100, 10))


# Pytest fixtures
@pytest.fixture
def population_locations():
    return P_i


@pytest.fixture
def facilities():
    return S_j


@pytest.fixture
def distance_matrix():
    return D_ij
