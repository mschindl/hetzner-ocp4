# How to add a node

## Red Het Enterprise Linux CoreOS

Run playbook:
```
./ansible/add-node.yml
```

Approve pending csr:
```
oc get csr
oc adm certificate approve csr/csr-jjjcb
```

