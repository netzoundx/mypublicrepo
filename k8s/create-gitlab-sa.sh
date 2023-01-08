#!/bin/bash

NAMESPACE=$1

sudo kubectl get ns $NAMESPACE
if [ $? -eq 1 ]; then exit 1; fi

cat > gitlab-sa.yaml <<EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  name: gitlab
  namespace: $1
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: gitlab-role
  namespace: $1
rules:
- apiGroups: ["*"]
  resources: ["*"]
  verbs: ["*"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: gitlab-role-binding
  namespace: $1
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: gitlab-role
subjects:
- kind: ServiceAccount
  name: gitlab
  namespace: $1
EOF

sudo kubectl apply -f gitlab-sa.yaml

