@description('The name of the storage account')
param storageAccountName string = 'st${uniqueString(resourceGroup().id)}'

@description('The location for the storage account')
param location string = resourceGroup().location

@description('The SKU for the storage account')
@allowed([
  'Standard_LRS'
  'Standard_GRS'
  'Standard_RAGRS'
  'Premium_LRS'
])
param storageSku string = 'Standard_LRS'

@description('The access tier for the storage account')
@allowed([
  'Hot'
  'Cool'
  'Cold'
  'Archive'
])
param accessTier string = 'Cool'

// Create the storage account
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: storageSku
  }
  kind: 'StorageV2'
  properties: {
    accessTier: accessTier
    allowBlobPublicAccess: false
    minimumTlsVersion: 'TLS1_2'
    supportsHttpsTrafficOnly: true
    encryption: {
      services: {
        blob: {
          enabled: true
        }
      }
      keySource: 'Microsoft.Storage'
    }
  }
}

// Create blob service (this is automatically created but we can reference it)
resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2023-01-01' = {
  parent: storageAccount
  name: 'default'
}

// Create a sample container
resource blobContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-01-01' = {
  parent: blobService
  name: 'data'
  properties: {
    publicAccess: 'None'
  }
}

// Outputs
output storageAccountName string = storageAccount.name
output storageAccountId string = storageAccount.id
output primaryEndpoints object = storageAccount.properties.primaryEndpoints
output containerName string = blobContainer.name
