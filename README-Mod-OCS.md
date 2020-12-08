# Modification to integrate OCS OpenShift Container Storage (lite)

Hardware used:
CPU1: Intel® Xeon® CPU E5-1650 v3 @ 3.50GHz (Cores 12)
Memory: 257655 MB
Disk /dev/sda: 480 GB (=> 447 GiB)
Disk /dev/sdb: 480 GB (=> 447 GiB)
Total capacity 894 GiB with 2 Disks

# Modified files
```
# cd ./hetzner-ocp4-ocs4
# vi ansible/roles/openshift-4-cluster/defaults/main.yml
# vi ansible/roles/openshift-4-cluster/tasks/create-vm.yml
# vi ansible/roles/openshift-4-cluster/tasks/create.yml
# vi ansible/roles/openshift-4-cluster/templates/vm.xml.j2
```
Additional information for OCS installation:
https://source.redhat.com/communitiesatredhat/applications/containers-paas-community/blog/container_community_of_practice_blog/ocs_42_in_ocp_4214_upi_installation_in_rhv



# Check and configure local storage disks

```
# for i in {3..5} ; do ssh core@192.168.50.1${i} lsblk | egrep "^vdb.*|vdc.*$" ; done
vdb                          252:16   0    10G  0 disk 
vdc                          252:32   0   100G  0 disk 
vdb                          252:16   0    10G  0 disk 
vdc                          252:32   0   100G  0 disk 
vdb                          252:16   0    10G  0 disk 
vdc                          252:32   0   100G  0 disk
```

# Install Local Storage operator
![47b62b81a20355caca56a1360aa3a417](https://user-images.githubusercontent.com/26382876/101483726-dfd33c00-3958-11eb-8215-cc1f14153e48.png)
![image](https://user-images.githubusercontent.com/26382876/101484540-12316900-395a-11eb-8d48-7a19ac435d8c.png)

```
➜  ~ oc get pod -n openshift-local-storage                                                                                           
NAME                                      READY   STATUS    RESTARTS   AGE
local-storage-operator-56c7f9d6fb-8zndx   1/1     Running   0          12m
```

## Create file and block
```
# cat <<EOF > local-storage-filesystem.yaml 
apiVersion: "local.storage.openshift.io/v1"
kind: "LocalVolume"
metadata:
  name: "local-disks-fs"
  namespace: "openshift-local-storage"
spec:
  nodeSelector:
    nodeSelectorTerms:
    - matchExpressions:
        - key: kubernetes.io/hostname
          operator: In
          values:
          - compute-0
          - compute-1
          - compute-2
  storageClassDevices:
    - storageClassName: "local-sc"
      volumeMode: Filesystem
      devicePaths:
        - /dev/vdb
EOF
```
 
```
# cat <<EOF > local-storage-block.yaml
apiVersion: "local.storage.openshift.io/v1"
kind: "LocalVolume"
metadata:
  name: "local-disks"
  namespace: "openshift-local-storage"
spec:
  nodeSelector:
    nodeSelectorTerms:
    - matchExpressions:
        - key: kubernetes.io/hostname
          operator: In
          values:
          - compute-0
          - compute-1
          - compute-2
  storageClassDevices:
    - storageClassName: "localblock-sc"
      volumeMode: Block
      devicePaths:
        - /dev/vdc
EOF
```

# Create storage classes
```
# oc create -f local-storage-block.yaml
localvolume.local.storage.openshift.io/local-disks created
# oc create -f local-storage-filesystem.yaml 
localvolume.local.storage.openshift.io/local-disks-fs created
```
![image](https://user-images.githubusercontent.com/26382876/101485118-fbd7dd00-395a-11eb-857c-169c665f5d92.png)

# Label nodes
```
oc label node compute-0 "cluster.ocs.openshift.io/openshift-storage=" --overwrite
oc label node compute-0 "topology.rook.io/rack=rack0" --overwrite
oc label node compute-1 "cluster.ocs.openshift.io/openshift-storage=" --overwrite
oc label node compute-1 "topology.rook.io/rack=rack1" --overwrite
oc label node compute-2 "cluster.ocs.openshift.io/openshift-storage=" --overwrite
oc label node compute-2 "topology.rook.io/rack=rack3" --overwrite
```

# Install OCS Operator
![image](https://user-images.githubusercontent.com/26382876/101485266-36417a00-395b-11eb-921a-656f67732160.png)
![image](https://user-images.githubusercontent.com/26382876/101485382-5f620a80-395b-11eb-99ad-6f0bdc7eb572.png)
