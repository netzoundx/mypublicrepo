#!/bin/bash

echo "Please enter namespace :"
read NS
echo "Please enter aws access key :"
read AWS_ACCESS_KEY
echo "Please enter aws secret key :"
read AWS_SECRET_KEY
echo "Please enter ECR Registry :"
read REGISTRY
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
  name: gitlab-ecr-cronjob
spec:
  schedule: "*/5 * * * *"
  jobTemplate:
    spec:
      template:
        spec:
          serviceAccountName: gitlab
          restartPolicy: OnFailure
          containers:
          - name: alpine-k8s
            image: alpine/k8s:1.26.0
            imagePullPolicy: IfNotPresent
            command:
            - /bin/sh
            - -c
            - |-
              aws configure set aws_access_key_id $AWS_ACCESS_KEY
              aws configure set aws_secret_access_key $AWS_SECRET_KEY
              TOKEN=$(aws ecr get-login-password --region ap-southeast-1 --profile=paypay-love | cut -d' ' -f6)
              

               



      







EOF



#sudo kubectl apply -f gitlab-sa.yaml

