# Project: Data Warehouse

## Introduction

A music streaming startup, Sparkify, has grown their user base and song database and want to move their processes and data onto the cloud. Their data resides in S3, in a directory of JSON logs on user activity on the app, as well as a directory with JSON metadata on the songs in their app.

As their data engineer, you are tasked with building an ETL pipeline that extracts their data from S3, stages them in Redshift, and transforms data into a set of dimensional tables for their analytics team to continue finding insights into what songs their users are listening to.

![System Architecture for AWS S3 to Redshift ETL](sparkify-s3-to-redshift-etl.png)

## Project Description

In this project, you'll apply what you've learned on data warehouses and AWS to build an ETL pipeline for a database hosted on Redshift. To complete the project, you will need to load data from S3 to staging tables on Redshift and execute SQL statements that create the analytics tables from these staging tables.

## Helpful Hints

- Many of the issues that you may have will come from security. You may not have the right keys, roles, region, etc. defined and as a result you will be denied access. If you are having troubles go back to the various lessons where you set up a Redshift cluster, or implemented a role, created a virtual network, etc. Make sure you can accomplish those tasks there, then they should be easy for you to recreate in this project. You are likely to have fewer issues with security if you implement the role creation, setup of the Redshift cluster, and destruction of it via Infrastructure As Code (IAC).

- Udacity provides a temporary AWS account for you to build the necessary resources for this project. NB This will REPLACE your AWS credentials which are in your .aws folder. PLEASE make sure you copy those first since they will be overwritten. IF you are having difficulty completing the Project in 1 session (there is a time limit), you MAY find it more effective to use your own AWS account. This would avoid the need to validate your session each time you restart on the project. However, that would be your own funds. It is unlikely that would cost you more than a few dollars.

- The starter code that we give you provides a framework for doing this project. The vast majority of your work will be getting the SQL queries part correct. Very few changes will be required to the starter code.

- This is an excellent template that you can take into the work place and use for future ETL jobs that you would do as a Data Engineer. It is well architected (e.g. staging tables for data independence from the logs and the final Sparkify DWH) AND bulk data loads into the Sparkify DWH for high compute performance via SQL from those staging tables.

# Step 1: Deploy AWS Redshift cluster

- Create AWS IAM user `terraform` with attached policy `Administrator Access`. This user is not enabled to access AWS Console. This user will be used to deploy an AWS Redshift cluster with Terraform
- Create Access Key of AWS IAM user `terraform` and store the Access Key ID and Secret Access Key in a safe place
- Add a new profile `datawarehouse` to AWS CLI configuration

```
Add to ~/.aws/config

[profile datawarehouse]
region = us-east-1
output = json

Add to ~/.aws/credentials

[cloud-developer]
aws_access_key_id = <Access Key ID of AWS IAM user terraform>
aws_secret_access_key = <Secret Access Key of AWS IAM user terraform>
```

- Deploy AWS Redshift cluster with Terraform

```
cd terraform
terraform init
terraform validate
terraform plan
terraform apply -auto-approve
```

- Terminate AWS Redshift cluster with Terraform

```
cd terraform
terraform destroy -auto-approve
```

# Step 2: Launch Jupyter Notebook

- Install miniconda

```
brew install cask miniconda
```

- Setup a miniconda environment

```
cd datawarehouse
conda create -n dwh
```

- Activate environment `dwh`

```
conda activate dwh
```

- Deactivate environment

```
conda deactivate
```

- Install Jupyter

```
conda install jupyter
```

- Launch Jupyter

```
jupyter notebook
```

# Step 3: Explore Data Sources

The data source is in S3 bucket `udacity-bend` (Keep in mind that the `udacity-dend` bucket is situated in the `us-west-2` region.):

Song dataset: `s3://udacity-dend/song_data`
Log dataset: `s3://udacity-dend/log_data`

## Song Dataset

The Song Dataset consists of files in JSON format and contains metadata about a song and the artist of that song. The files are partitioned by the first three letters of each song's track ID. For example, here are file paths to two files in this dataset.

```
song_data/A/B/C/TRABCEI128F424C983.json
song_data/A/A/B/TRAABJL12903CDCF1A.json
```

And below is an example of what a single song file, TRAABJL12903CDCF1A.json, looks like.

```
{"num_songs": 1, "artist_id": "ARJIE2Y1187B994AB7", "artist_latitude": null, "artist_longitude": null, "artist_location": "", "artist_name": "Line Renaud", "song_id": "SOUPIRU12A6D4FA1E1", "title": "Der Kleine Dompfaff", "duration": 152.92036, "year": 0}
```

## Log Dataset

The second dataset consists of log files in JSON format and contains activity logs from an imaginary music streaming app. The log files in the dataset you'll be working with are partitioned by year and month. For example, here are file paths to two files in this dataset.

```
log_data/2018/11/2018-11-12-events.json
log_data/2018/11/2018-11-13-events.json
```

And below is an example of what the data in a log file, 2018-11-12-events.json, looks like.

![log_data image](log-data.png)

To properly read log data s3://udacity-dend/log_data, you'll need the following metadata file:

## Log JSON Metadata

The `log_json_path.json` file is used when loading JSON data into Redshift. It specifies the structure of the JSON data so that Redshift can properly parse and load it into the staging tables.

In the context of this project, you will need the `log_json_path.json` file in the COPY command, which is responsible for loading the log data from S3 into the staging tables in Redshift. The `log_json_path.json` file tells Redshift how to interpret the JSON data and extract the relevant fields. This is essential for further processing and transforming the data into the desired analytics tables.

Below is what data is in `log_json_path.json`.

## AWS CLI commands

Use AWS CLI to explore S3 bucket `udacity-bend` and the files in this S3 bucket

```
# list the files from Song Dataset
aws s3 ls --profile datawarehouse s3://udacity-dend/song_data/                              # list prefixes A
aws s3 ls --profile datawarehouse s3://udacity-dend/song_data/A/                            # list prefixes A-Z
aws s3 ls --profile datawarehouse s3://udacity-dend/song_data/A/A/                          # list prefixes A-Z
aws s3 ls --profile datawarehouse s3://udacity-dend/song_data/A/A/A/                        # list the song files in JSON format

# shows the content of one log file from the Song Dataset
aws s3 cp --profile datawarehouse s3://udacity-dend/song_data/A/A/A/TRAAAAK128F9318786.json -

# list the files from Log Dataset
aws s3 ls --profile datawarehouse s3://udacity-dend/log_data/                                     # list prefix 2018
aws s3 ls --profile datawarehouse s3://udacity-dend/log_data/2018/                                # list prefix 11
aws s3 ls --profile datawarehouse s3://udacity-dend/log_data/2018/11/                             # list the log files in JSON Format

# shows the content of one log file from the Log Dataset
aws s3 cp --profile datawarehouse s3://udacity-dend/log_data/2018/11/2018-11-01-events.json -

# show the content Log JSON metadata file
aws s3 cp --profile datawarehouse s3://udacity-dend/log_json_path.json -
```

# Step 4: Create Table Schemas

..
