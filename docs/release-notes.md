# RELEASE NOTES

## xxx

### Add possibility to add new worker nodes (#88)

Run playbook:
```
./ansible/add-node.yml
```

Approve pending csr:
```
oc get csr
oc adm certificate approve csr/csr-jjjcb
```



## 2020-04-18

### Use RBAC instead of changing SCC member for NFS provisioner

Instead of 
```
oc adm policy add-scc-to-user hostmount-anyuid \
    -n openshift-nfs-provisioner \
    -z nfs-client-provisioner
```
create a role  and a binding:
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: scc-hostmount-anyuid
  namespace: "openshift-nfs-provisioner"
rules:
- apiGroups:
  - security.openshift.io 
  resourceNames:
  - hostmount-anyuid
  resources:
  - securitycontextconstraints 
  verbs: 
  - use
---
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: sa-to-scc-hostmount-anyuid
  namespace: "openshift-nfs-provisioner"
subjects:
  - kind: ServiceAccount
    name: nfs-client-provisioner
roleRef:
  kind: Role
  name: scc-hostmount-anyuid
  apiGroup: rbac.authorization.k8s.io
```

## 2020-04-01

### Add possibility to add new worker nodes (#88)

Run playbook:
```
./ansible/add-node.yml
```

Approve pending csr:
```
oc get csr
oc adm certificate approve csr/csr-jjjcb
```

### Added letsencrypt_disabled switch

This allows you to disable letsencrypt setup. (Default is enabled letsencrypt.)
>>>>>>> Added possibility to add new worker nodes (#88)

### Update air-gapped docs 

Add `REGISTRY_COMPATIBILITY_SCHEMA1_ENABLED=true` to air-gapped registry. That solve some skopeo copy problemes.

### Support for disabling automatic Let's Encrypt certificates for apps and api

Add varialbe `letsencrypt_disabled: true` to cluster yaml to disable Let's Encrypt certificates. Variable defaults to true.

### Added release notes doc

Just simple doc to track new features and fixes.


