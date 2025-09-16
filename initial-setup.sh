#! /bin/bash

SUBSCRIPTION_NAME="Visual Studio Professional Subscription"
LOCATION="uksouth"
RESOURCE_GROUP="demo-python-app-rg"

ACR_NAME="bedwdemopythonappacr"
PLAN="bedw-demo-python-app-001-plan"
WEBAPP="bedw-demo-python-app-001" 

# Select the correct Azure subscription and create a resource group
az account set --name "$SUBSCRIPTION_NAME"
az group create --name "$RESOURCE_GROUP" --location $LOCATION

# Create an Azure Container Registry
az acr create --resource-group "$RESOURCE_GROUP" --name $ACR_NAME --sku Standard

# Create an App Service plan
az appservice plan create -g "$RESOURCE_GROUP" -n $PLAN --is-linux --sku B1

# Create Web App
az webapp create -g "$RESOURCE_GROUP" -p $PLAN -n $WEBAPP --runtime "PYTHON:3.12"

# Enable managed identity on the web app
az webapp identity assign -g "$RESOURCE_GROUP" -n $WEBAPP
WEBAPP_PRINCIPAL_ID=$(az webapp identity show -g "$RESOURCE_GROUP" -n $WEBAPP --query principalId -o tsv)

# Grant web app permission to pull from ACR
ACR_ID=$(az acr show -n $ACR_NAME --query id -o tsv)
az role assignment create --assignee $WEBAPP_PRINCIPAL_ID --scope $ACR_ID --role "AcrPull"

# Set container port for Azure to route the traffic
az webapp config appsettings set -g "$RESOURCE_GROUP" -n $WEBAPP --settings WEBSITES_PORT=8000