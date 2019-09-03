#!/usr/bin/env bash
set -e

if [[ -z "${KUBECONFIG}" ]]; then
  echo "Please set KUBECONFIG";
  exit 1;
fi

if [[ ! -f "${KUBECONFIG}" ]] ; then
  echo "KUBECONFIG ($KUBECONFIG) do not exist!"
  exit 1
fi

if [[ $(oc whoami) != "system:admin" ]] ; then
  echo "You have to be system:admin, please change kubeconfig"
  exit 1
fi

set -x 
# Deploy ocs upstream
oc create -f https://raw.githubusercontent.com/rook/rook/master/cluster/examples/kubernetes/ceph/common.yaml
oc create -f https://raw.githubusercontent.com/rook/rook/master/cluster/examples/kubernetes/ceph/operator-openshift.yaml
oc create -f https://raw.githubusercontent.com/rook/rook/master/cluster/examples/kubernetes/ceph/cluster.yaml


# Create a cephfs (FILE) storage class
oc create -f https://raw.githubusercontent.com/rook/rook/master/cluster/examples/kubernetes/ceph/csi/cephfs/storageclass.yaml
# Create a rbd (BLOCK) storage class
oc create -f https://raw.githubusercontent.com/rook/rook/master/cluster/examples/kubernetes/ceph/csi/rbd/storageclass.yaml

echo -n "Wait for services/rook-ceph-mgr-dashboard"
until oc get services/rook-ceph-mgr-dashboard -n rook-ceph 1>>\&1 2>/dev/null; do echo -n ".";sleep 1; done

oc create route passthrough dashboard --service=rook-ceph-mgr-dashboard -n rook-ceph

set +x 
echo "Visit Ceph Mgr dashboard: "
echo "  URL:      https://$(oc get route/dashboard -n rook-ceph -o jsonpath='{.spec.host}')"
echo "  Username: admin "
echo "  Password: $( oc get secrets/rook-ceph-dashboard-password -n rook-ceph  -o jsonpath='{.data.password}' | base64 -d )"




