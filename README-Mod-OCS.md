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


# Create storage classes
```
# oc create -f ocs/local-storage-block.yml
localvolume.local.storage.openshift.io/local-disks created
# oc create -f ocs/local-storage-filesystem.yml 
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

## Create first cluster service
oc create -f ocs/03-ocs-cluster-service-reduced-res.yml
```
![image](https://user-images.githubusercontent.com/26382876/101491903-9688e980-3964-11eb-858c-b9cb0b4a5ccc.png)
![image](https://user-images.githubusercontent.com/26382876/101492097-d059f000-3964-11eb-8d96-cde534523b20.png)

# Access to Noobaa Management WebUI:

```
Create an OCP group named cluster-admin from the OCP UI or by running the following command:
# oc adm groups new cluster-admins

Bind the group to the cluster-admin role:
 # oc adm policy add-cluster-role-to-group cluster-admin cluster-admins
 
A set of users can be added to the group by running the following command:
# oc adm groups add-users cluster-admins admin user@corp.com

A set of users can be removed from the group by running the following command:
# oc adm groups remove-users cluster-admins [user-name] [user-name] [user-name]...
```
![image](https://user-images.githubusercontent.com/26382876/101500502-db198280-396e-11eb-9bc4-114b95cbb19d.png)

# Looks good ;)
![image](https://user-images.githubusercontent.com/26382876/101627315-761d6580-3a1e-11eb-898e-c0e52d8c2e15.png)
![image](https://user-images.githubusercontent.com/26382876/101627384-95b48e00-3a1e-11eb-9bb8-eee60445a7bb.png)

