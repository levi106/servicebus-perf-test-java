param location string = resourceGroup().location
param servcieBusNamespaceName string = 'sb-${uniqueString(resourceGroup().id)}'
param skuName string = 'Standard'
param vnetName string = 'vnet-${uniqueString(resourceGroup().id)}'
param vnetPrefix string = '172.16.0.0/22'
param subnetName string = 'aks-subnet'
param subnetPrefix string = '172.16.0.0/24'
param clusterName string = 'aks-${uniqueString(resourceGroup().id)}'
param dnsPrefix string = clusterName
param nodeCount int = 3
param nodeVMSize string = 'Standard_D2s_v3'
param nodePoolName string = 'defaultpool'
param kubeVersion string = '1.21.7'
param workspaceName string = 'la-${uniqueString(resourceGroup().id)}'
param applicationInsightsName string = 'ai-${uniqueString(resourceGroup().id)}'

param queueNames array = [
  'servicebusperftestjavaqueue'
]

var deadLetterFirehoseQueueName = 'deadletterfirehose'

resource serviceBusNamespace 'Microsoft.ServiceBus/namespaces@2018-01-01-preview' = {
  name: servcieBusNamespaceName
  location: location
  sku: {
    name: skuName
  }
}

resource deadLetterFirehoseQueue 'Microsoft.ServiceBus/namespaces/queues@2018-01-01-preview' = {
  name: deadLetterFirehoseQueueName
  parent: serviceBusNamespace
  properties: {
    requiresDuplicateDetection: false
    requiresSession: false
    enablePartitioning: false
  }
}

resource queues 'Microsoft.ServiceBus/namespaces/queues@2018-01-01-preview' = [for queueName in queueNames: {
  name: queueName
  parent: serviceBusNamespace
  dependsOn: [
    deadLetterFirehoseQueue
  ]
  properties: {
    forwardDeadLetteredMessagesTo: deadLetterFirehoseQueueName
  }
}]

resource vnet 'Microsoft.Network/virtualNetworks@2019-12-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetPrefix
      ]
    }
    enableVmProtection: false
    enableDdosProtection: false
    subnets: [
      {
        name: subnetName
        properties: {
          addressPrefix: subnetPrefix
        }
      }
    ]
  }
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2019-12-01' existing = {
  parent: vnet
  name: subnetName
}

resource la 'Microsoft.OperationalInsights/workspaces@2020-08-01' = {
  name: workspaceName
  location: location
}

resource aks 'Microsoft.ContainerService/managedClusters@2021-09-01' = {
  name: clusterName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    kubernetesVersion: kubeVersion
    enableRBAC: true
    dnsPrefix: dnsPrefix
    agentPoolProfiles: [
      {
        name: nodePoolName
        count: nodeCount
        mode: 'System'
        vmSize: nodeVMSize
        type: 'VirtualMachineScaleSets'
        osType: 'Linux'
        enableAutoScaling: false
        vnetSubnetID: subnet.id
      }
    ]
    apiServerAccessProfile: {
      enablePrivateCluster: false
    }
    servicePrincipalProfile: {
      clientId: 'msi'
    }
    networkProfile: {
      networkPlugin: 'azure'
      dockerBridgeCidr: '172.17.0.1/16'
      dnsServiceIP: '10.0.0.10'
      serviceCidr: '10.0.0.0/16'
    }
    addonProfiles: {
      omsagent: {
        config: {
          logAnalyticsWorkspaceResourceID: la.id
        }
        enabled: true
      }
    }
  }
}

resource ai 'Microsoft.Insights/components@2020-02-02' = {
  name: applicationInsightsName
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: la.id
  }
}
