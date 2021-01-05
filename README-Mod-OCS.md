Issue 1 : After using ansible-playbook ansible/99-destroy-cluster.yml empty following folder -> /var/lib/libvirt/images

# Modification to integrate OCS OpenShift Container Storage (lite)
```
Hardware used:
CPU1: Intel® Xeon® CPU E5-1650 v3 @ 3.50GHz (Cores 12)
Memory: 257655 MB
Disk /dev/sda: 480 GB (=> 447 GiB)
Disk /dev/sdb: 480 GB (=> 447 GiB)
Total capacity 894 GiB with 2 Disks as stripe in LVM
```

# Modified files
```
# cd ./hetzner-ocp4-ocs4
  ansible/roles/openshift-4-cluster/defaults/main.yml
  ansible/roles/openshift-4-cluster/tasks/create-vm.yml
  ansible/roles/openshift-4-cluster/tasks/create.yml
  ansible/roles/openshift-4-cluster/templates/vm.xml.j2
  ansible/roles/openshift-4-cluster/tasks/destroy-vm.yml
```
https://github.com/mschindl/hetzner-ocp4-ocs4/blob/master/ansible/roles/openshift-4-cluster/defaults/main.yml
https://github.com/mschindl/hetzner-ocp4-ocs4/blob/master/ansible/roles/openshift-4-cluster/tasks/create-vm.yml
https://github.com/mschindl/hetzner-ocp4-ocs4/blob/master/ansible/roles/openshift-4-cluster/tasks/create.yml
https://github.com/mschindl/hetzner-ocp4-ocs4/blob/master/ansible/roles/openshift-4-cluster/templates/vm.xml.j2
https://github.com/mschindl/hetzner-ocp4-ocs4/blob/master/ansible/roles/openshift-4-cluster/tasks/destroy-vm.yml

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
# oc create -f ocs/01-local-storage-block.yml
localvolume.local.storage.openshift.io/local-disks created
# oc create -f ocs/02-local-storage-filesystem.yml 
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
```
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
![image](https://user-images.githubusercontent.com/26382876/101627857-4327a180-3a1f-11eb-9ed0-e57199b1f6ad.png)

# Manually expansion with one additional vdisk
Expand virtual machines up to 12 vCPU + 80GB mem in the compute/worker and after that it's allowed to expand  OCS with 100GB disks per worker node.
```
# virsh list --all
setlocale: No such file or directory
 Id   Name                      State
-----------------------------------------
 2    mschindl-ocp4-master-0    running
 3    mschindl-ocp4-master-1    running
 4    mschindl-ocp4-master-2    running
 5    mschindl-ocp4-compute-0   running
 6    mschindl-ocp4-compute-1   running
 7    mschindl-ocp4-compute-2   running

# cd /var/lib/libvirt/images/
# qemu-img create -f qcow2 /var/lib/libvirt/images/mschindl-ocp4-compute-0-ocs-4ex.qcow2 100G
# qemu-img create -f qcow2 /var/lib/libvirt/images/mschindl-ocp4-compute-1-ocs-4ex.qcow2 100G
# qemu-img create -f qcow2 /var/lib/libvirt/images/mschindl-ocp4-compute-2-ocs-4ex.qcow2 100G
Formatting '/var/lib/libvirt/images/mschindl-ocp4-compute-3-ocs-3ex.qcow2', fmt=qcow2 size=107374182400 cluster_size=65536 lazy_refcounts=off refcount_bits=16

# for i in {3..5} ; do ssh core@192.168.50.1${i} lsblk | egrep "^vdb.*|vdc.*$|vdd.*$" ; done

# for i in {3..5} ; do ssh core@192.168.50.1${i} sudo fdisk -l | grep '^Disk /dev/vd[a-z]' ; done
Disk /dev/vda: 120 GiB, 128849018880 bytes, 251658240 sectors
Disk /dev/vdb: 10 GiB, 10737418240 bytes, 20971520 sectors
Disk /dev/vdc: 100 GiB, 107374182400 bytes, 209715200 sectors
Disk /dev/vdd: 100 GiB, 107374182400 bytes, 209715200 sectors

# # virsh attach-disk mschindl-ocp4-compute-0 \
--source /var/lib/libvirt/images/mschindl-ocp4-compute-0-ocs-4ex.qcow2 \
--target vdd \
--persistent \
--subdriver qcow2 \
--driver qemu \
--type disk
  
# virsh attach-disk mschindl-ocp4-compute-1 \
--source /var/lib/libvirt/images/mschindl-ocp4-compute-1-ocs-4ex.qcow2 \
--target vdd \
--persistent \
--subdriver qcow2 \
--driver qemu \
--type disk

# virsh attach-disk mschindl-ocp4-compute-2 \
--source /var/lib/libvirt/images/mschindl-ocp4-compute-2-ocs-4ex.qcow2 \
--target vdd \
--persistent \
--subdriver qcow2 \
--driver qemu \
--type disk

# hetzner-ocp4-ocs4]# ansible-playbook ansible/03-stop-cluster.ym

# virsh edit <vm-compute-0>

  <memory unit='KiB'>83886080</memory>
  <currentMemory unit='KiB'>83886080</currentMemory>

# hetzner-ocp4-ocs4]# ansible-playbook ansible/04-start-cluster.yml
```
