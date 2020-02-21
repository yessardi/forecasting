# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.


# Update conda
conda update conda
# Create conda environment
conda env create -f tools/environment.yml
# Activate conda environment
eval "$(conda shell.bash hook)" && conda activate forecasting_env
# Install forecasting utility library
pip install -e fclib
# Register conda environment in Jupyter
python -m ipykernel install --user --name forecasting_env
