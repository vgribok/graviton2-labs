---
title: "Prerequisites"
date: 2020-04-10T11:14:49-06:00
weight: 20
---

1. In your Cloud 9 environment, clone the Git repo:
```
git clone https://git-codecommit.us-east-1.amazonaws.com/v1/repos/graviton2-labs
cd graviton2-labs
```

2. Upgrade AWS CLI according to guidance in [AWS documentation](https://docs.aws.amazon.com/cli/latest/userguide/install-linux.html).

```bash
sudo pip install --upgrade awscli && hash -r
```

3.  Install jq, envsubst (from GNU gettext utilities) and bash-completion

```bash
sudo yum -y install jq gettext bash-completion moreutils
```

4. Install mysql client and libraries

```bash
sudo yum -y localinstall https://dev.mysql.com/get/mysql80-community-release-el7-3.noarch.rpm
sudo yum -y install mysql-community-client mysql-community-libs
```


5.  Install the required Kubernetes tools for interacting with the EKS cluster.


```bash
sudo curl --silent --location -o /usr/local/bin/kubectl \
   https://amazon-eks.s3.us-west-2.amazonaws.com/1.17.11/2020-09-18/bin/linux/amd64/kubectl

sudo chmod +x /usr/local/bin/kubectl

kubectl completion bash >>  ~/.bash_completion
. /etc/profile.d/bash_completion.sh
. ~/.bash_completion
```

6. Set account and region environmental variables

```bash
export ACCOUNT_ID=$(aws sts get-caller-identity --output text --query Account)
export AWS_REGION=$(curl -s 169.254.169.254/latest/dynamic/instance-identity/document | jq -r '.region')
echo "export ACCOUNT_ID=${ACCOUNT_ID}" | tee -a ~/.bash_profile
echo "export AWS_REGION=${AWS_REGION}" | tee -a ~/.bash_profile
aws configure set default.region ${AWS_REGION}
aws configure set default.account ${ACCOUNT_ID}
aws configure get default.region
aws configure get default.account
```

7. Prepare AWS CDK 

```bash 
python3 -m venv .venv
source .venv/bin/activate
pip install --upgrade aws-cdk.core
pip install -r requirements.txt
cdk bootstrap aws://$ACCOUNT_ID/$AWS_REGION 
cdk synth 
cdk ls 
```