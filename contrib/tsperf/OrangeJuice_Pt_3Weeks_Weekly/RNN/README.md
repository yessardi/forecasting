# Implementation submission form

## Submission details

**Submission date**: 12/21/2018

**Benchmark name:** OrangeJuice_Pt_3Weeks_Weekly

**Submitter(s):** Yiyu Chen

**Submitter(s) email:** yiychen@microsoft.com

**Submission name:** RNN

**Submission path:** retail_sales/OrangeJuice_Pt_3Weeks_Weekly/submissions/RNN


## Implementation description

### Modelling approach

In this submission, we implement an Encoder-Decoder Recurrent Neural Network (RNN) model using [Tensorflow](https://www.tensorflow.org/) package. The implementation is heavily referencing the winning solution of the [Web Traffic Time Series Forecasting Kaggle competition](https://www.kaggle.com/c/web-traffic-time-series-forecasting) which is hosted on the Github [here](https://github.com/Arturus/kaggle-web-traffic). For more details about the RNN model and its architecture, please see [here](https://github.com/Arturus/kaggle-web-traffic/blob/master/how_it_works.md#model-core).

### Feature engineering

The following features have been used in the implementation of the forecast method:

- weekly sales of each orange juice in recent weeks.
- series popularity which is defined as the sales median of each time series.
- orange juice price and price ratio. The price ratio is defined as orange juice price divided by the average orange juice price of the store which measures the price competitiveness of a orange juice brand.
- promotion related features: `feat` and `deal`.
- orange juice brand with One Hot Encoding.

All the features are normalized before feeding into the model.

### Hyperparameter tuning

The hyperparameters are tuned with [SMAC package](https://github.com/automl/SMAC3).

### Description of implementation scripts

* `train_score.py`: Python script that trains the model and generates forecast results for each round
* `hyper_parameter_tuning.py`: Python script for hyperparameter tuning.
* `hparams.py`: Python script contains manual selected hyperparameter and the hyperparameter selected by the hyperparameter tuning script.
* `make_features.py`: Python script contains the function for creating the features.
* `rnn_train.py`: Python script contains the function for creating and training the RNN model.
* `rnn_predict.py`: Python script contains the function for making predictions by loading the saved model.
* `utils.py`: Python script contains all the utility functions used across multiple other scripts.

### Steps to reproduce results

0. Follow the instructions [here](#resource-deployment-instructions) to provision a Linux virtual machine and log into the provisioned
VM.

1. Clone the Forecasting repo to the home directory of your machine

   ```bash
   cd ~
   git clone https://github.com/Microsoft/Forecasting.git
   ```
   Use one of the following options to securely connect to the Git repo:
   * [Personal Access Tokens](https://help.github.com/articles/creating-a-personal-access-token-for-the-command-line/)  
   For this method, the clone command becomes
   ```bash
   git clone https://<username>:<personal access token>@github.com/Microsoft/Forecasting.git
   ```
   * [Git Credential Managers](https://github.com/Microsoft/Git-Credential-Manager-for-Windows)
   * [Authenticate with SSH](https://help.github.com/articles/connecting-to-github-with-ssh/)

2. Create a conda environment for running the scripts of data downloading, data preparation, and result evaluation. To do this, you need
to check if conda has been installed by runnning command `conda -V`. If it is installed, you will see the conda version in the terminal. Otherwise, please follow the instructions [here](https://conda.io/docs/user-guide/install/linux.html) to install conda. Then, you can go to `~/Forecasting` directory in the VM and create a conda environment named `tsperf` by

   ```bash
   conda env create --file ./common/conda_dependencies.yml
   ```

   This will create a conda environment with the Python and R packages listed in `conda_dependencies.yml` being installed. The conda
  environment name is also defined in the yml file.

3. Activate the conda environment and download the Orange Juice dataset. Use command `source activate tsperf` to activate the conda environment. Then, download the Orange Juice dataset by running the following command from `~/Forecasting` directory

   ```bash
   Rscript ./retail_sales/OrangeJuice_Pt_3Weeks_Weekly/common/download_data.r
   ```

   This will create a data directory `./retail_sales/OrangeJuice_Pt_3Weeks_Weekly/data` and store the dataset in this directory. The dataset has two csv files - `yx.csv` and `storedemo.csv` which contain the sales information and store demographic information, respectively.

4. From `~/Forecasting` directory, run the following command to generate the training data and testing data for each forecast period:

   ```bash
   python ./retail_sales/OrangeJuice_Pt_3Weeks_Weekly/common/serve_folds.py --test --save
   ```

   This will generate 12 csv files named `train_round_#.csv` and 12 csv files named `test_round_#.csv` in two subfolders `/train` and
   `/test` under the data directory, respectively. After running the above command, you can deactivate the conda environment by running
   `source deactivate`.

5. Make sure Docker is installed
    
   You can check if Docker is installed on your VM by running

   ```bash
   sudo docker -v
   ```
   You will see the Docker version if Docker is installed. If not, you can install it by following the instructions [here](https://docs.docker.com/install/linux/docker-ce/ubuntu/). Note that if you want to execute Docker commands without sudo as a non-root user, you need to create a Unix group and add users to it by following the instructions [here](https://docs.docker.com/install/linux/linux-postinstall/#manage-docker-as-a-non-root-user).  

6. Build a local Docker image by running the following command from `~/Forecasting` directory

   ```bash
   sudo docker build -t rnn_image:v1 ./retail_sales/OrangeJuice_Pt_3Weeks_Weekly/submissions/RNN
   ```

7. Choose a name for a new Docker container (e.g. dcnn_container) and create it using command:   

   ```bash
   sudo docker run -it -v ~/Forecasting:/Forecasting --runtime=nvidia --name rnn_container rnn_image:v1
   ```

   Note that option `-v ~/Forecasting:/Forecasting` allows you to mount `~/Forecasting` folder (the one you cloned) to the container so that you will have
   access to the source code in the container.

8. Inside `/Forecasting` folder, train the model and make predictions by running

   ```bash
   cd /Forecasting
   source ./common/train_score_vm ./retail_sales/OrangeJuice_Pt_3Weeks_Weekly/submissions/RNN Python3
   ```

   This will generate 5 `submission_seed_<seed number>.csv` files in the submission directory, where \<seed number\>
   is between 1 and 5. This command will also output 5 running times of train_score.py. The median of the times
   reported in rows starting with 'real' should be compared against the wallclock time declared in benchmark
   submission. After generating the forecast results, you can exit the Docker container by command `exit`.

9. Activate conda environment again by `source activate tsperf`. Then, evaluate the benchmark quality by running

   ```bash
   source ./common/evaluate ./retail_sales/OrangeJuice_Pt_3Weeks_Weekly/submissions/RNN ./retail_sales/OrangeJuice_Pt_3Weeks_Weekly
   ```

   This command will output 5 benchmark quality values (MAPEs). Their median should be compared against the
   benchmark quality declared in benchmark submission.


## Implementation resources

**Platform:** Azure Cloud

**Resource location:** East US

**Hardware:** Standard NC6 (1 GPU, 6 vCPUs, 56 GB memory, 340 GB temporary storage) Ubuntu Linux VM

**Data storage:** Standard HDD

**Dockerfile:** [retail_sales/OrangeJuice_Pt_3Weeks_Weekly/submissions/RNN/Dockerfile](https://github.com/Microsoft/Forecasting/blob/master/retail_sales/OrangeJuice_Pt_3Weeks_Weekly/submissions/RNN/Dockerfile)

**Key packages/dependencies:**  
  * Python
    - numpy>=1.7.1
    - scikit-learn==0.20.0
    - pandas==0.23.0
    - tensorflow-gpu==1.10
    - smac==0.9.0

## Resource deployment instructions

We use Azure Linux VM to develop the baseline methods. Please follow the instructions below to deploy the resource.
* Azure Linux VM deployment
  - Create an Azure account and log into [Azure portal](portal.azure.com/)
  - Refer to the steps [here](https://docs.microsoft.com/en-us/azure/machine-learning/data-science-virtual-machine/dsvm-ubuntu-intro) to deploy a Data
  Science Virtual Machine for Linux (Ubuntu). Select *NC6* as the virtual machine size.


## Implementation evaluation

**Quality:**

*MAPE run 1: 37.68%*

*MAPE run 2: 37.44%*

*MAPE run 3: 36.95%*

*MAPE run 4: 38.56%*

*MAPE run 5: 37.84%*

*median MAPE: 37.68%*

**Time:**

*run time 1: 667.14 seconds*

*run time 2: 672.98 seconds*

*run time 3: 669.18 seconds*

*run time 4: 666.24 seconds*

*run time 5: 668.99 seconds*

*median run time: 668.99 seconds*

**Cost:** The hourly cost of NC6 Ubuntu Linux VM in East US Azure region is 0.90 USD, based on the price at the submission date. Thus, the total cost is 668.99/3600 $\times$ 0.90 = $0.1672.
