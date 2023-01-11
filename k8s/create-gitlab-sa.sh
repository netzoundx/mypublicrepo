#!/bin/bash

echo "Please enter namespace"
read NS
echo "Please enter aws access key"
read AWS_ACCESS_KEY
echo "Please enter aws secret key"
read AWS_SECRET_KEY

sudo kubectl get ns $NS
if [ $? -eq 1 ]; then exit 1; fi

cat > gitlab-sa.yaml <<EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  name: gitlab
  namespace: $NS
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: gitlab-role
  namespace: $NS
rules:
- apiGroups: ["*"]
  resources: ["*"]
  verbs: ["*"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: gitlab-role-binding
  namespace: $NS
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: gitlab-role
subjects:
- kind: ServiceAccount
  name: gitlab
  namespace: $NS
EOF

# Main

cat > gitlab-ecr-cronjob.yaml <<EOF
apiVersion: batch/v1
kind: CronJob
metadata:
  name: hello
spec:
  schedule: "*/5 * * * *"
  jobTemplate:
    spec:
      template:
        spec:
          serviceAccountName: gitlab
          containers:
          - name: alpine-k8s
            image: alpine/k8s:1.26.0
            imagePullPolicy: IfNotPresent
            command:
            - /bin/sh
            - -c
            - date; echo Hello from the Kubernetes cluster
            env:
              - name: AWS_ACCESS_KEY_ID


      
          restartPolicy: OnFailure






EOF












#sudo kubectl apply -f gitlab-sa.yaml

