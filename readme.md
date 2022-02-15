## The image for cassandra on Kubernetes

**_Authored by: Abhijith Ganesh_**

This was a passion project to spin up a cassandra cluster without any external dependencies provided by other vendors, it is a
sandbox project and heavily inspired by Bitnami's [Cassandra Operator](https://github.com/bitnami/charts/tree/master/bitnami/cassandra).

# Installation process

<hr/>

**Follow the steps exactly, with precision. Donot miss out any steps**

Apply the Persistent Volume Claim first. This will allow the chart to register the PVC accordingly.
You can read about Persistent volumes, statefulsets and other important kubernetes architecture related terms [here](https://kubernetes.io/docs/concepts/storage/persistent-volumes/)

_Statefulsets:_
This provision allows us to establish a stateful workload on Kubernetes, it allows the developer to configure storage provision
according to your hardware, size and helps us define the _reclaim policy_ and other parameters for the various _persistent volumes_. The Persistent volumes can be configured according to the use case.

To apply persistent Volume Claim, you need to run
`kubectl apply -f https://github.com/AbhijithGanesh/helm-cassandra/blob/master/persistentVolumeClaim.yaml`

Following this, you need to add the helm repo locally:
`helm repo add <name> https://abhijithganesh.github.io/helm-cassandra`

The value adds rancher labs `local-path` storage class as for the Persistent Volume, if you intend to
use someother storage class, change the `persistentVolumeClaim.yaml` values. The storage class should accordingly be changed.

To add the `local-path`
run command:
`kubectl apply -f https://raw.githubusercontent.com/rancher/local-path-provisioner/master/deploy/local-path-storage.yaml`

Finally, you can run the helm command to set the cluster up.

`helm install <cluster-name> <name>`

You can get the secrets by running the commands:
`kubectl get secrets`

This will list all your secrets, instead of _cassandra-custom-chart_ replace it with your instance name.

To get username and password run the following commands
`kubectl get secret cassandra-custom-chart -o jsonpath="{.data.cassandra-superuser}"`
`kubectl get secret cassandra-custom-chart -o jsonpath="{.data.cassandra-password}"`

## Parameters that can be updated with Values

### Autoscaling

<hr/>

|**Variable**|**Description**|
|:-------------|:----------------|
|enabled| boolean: _true_ or _false_|
|minReplicas| minimum number of replicas `default`: 1|
|maxReplicas| Maximum number of replicas `default`: 100|
|targetCPUUtilizationPercentage|Target utilization of CPU. `default`: 80|

### Naming

_(Sub directory of metadata, the tree follows this structure: metadata->names)_

<hr/>

|**Variable**|**Description**|
|:-------------|:----------------|
|pod_Name| Names for all pods. `default`: cassandra-pods|
|namespace|Defines Namespace for the pods.|
|service_Name|Defines service name for the pods|

### Persistent Volume

<hr/>

|**Variable**|**Description**|
|:-------------|:----------------|
|name| Defines name for persistent Volume. `default`: _cass-persistent_|
|claimName|Defines claim name for the persistent volume. `default`: _cass-pvc-claim_|

### Statefulset

<hr/>

|**Variable**|**Description**|
|:-------------|:----------------|
|replicas|Boolean variable for enabling replicasets. `default`: _1_|
|prometheusEnabled|Boolean variable for enabling prometheus. `default`: _true_|
|serviceName|Service name for the statefulset. `default`:_cass-stateful-set_|
|listenAddr|Listening address configured for the Cassandra pod. `default`: _auto_|

#### Images

_This is the sub parameter of the stateful set_

|**Variable**|**Description**|
|:-------------|:----------------|
|repository| Defines the repository name `default`: _bitnami/cassandra-exporter_|
|tag| Defines the tag for the image being pulled. `default`: _latest_
|imagepullPolicy|Defines the pull policy (like Always, Never, IfNotPresent) for the metric. `default`: _{}_|

### Metrics

<hr/>

|**Variable**|**Description**|
|:-------------|:----------------|
|enabled| Defines boolean for the metrics service. `default`: _true_|
|namespace|Defines the namespace for the metric. `default`: _{}_|

#### Images

_This is the sub parameter of the metrics_

|**Variable**|**Description**|
|:-------------|:----------------|
|registry| Defines the registry from which the image is pulled. `default`: _true_|
|imagepullPolicy|Defines the pull policy (like Always, Never, IfNotPresent) for the metric. `default`: _{}_|
|repository| Defines the repository name `default`: _bitnami/cassandra-exporter_|
|tag| Defines the tag for the image being pulled. `default`: _latest_
