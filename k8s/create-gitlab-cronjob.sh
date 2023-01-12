#!/bin/bash

echo "Please enter namespace :"
read NS
echo "Please enter aws access key :"
read AWS_ACCESS_KEY
echo "Please enter aws secret key :"
read AWS_SECRET_KEY
echo "Please enter ECR Registry :"
read REGISTRY
echo "Please enter pull secret name :"
read SECRET_NAME

# Namespace Validate
sudo kubectl get ns $NS
if [ $? -eq 1 ]; then exit 1; fi

# Main 
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
cat <<\EOF > gitlab-ecr-cronjob.yaml
apiVersion: batch/v1beta1
kind: CronJob
metadata:
  name: gitlab-ecr-cronjob
spec:
  schedule: "*/4 * * * *"
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
            envFrom:
            - secretRef:
                name: ecr-generic-secret
            command:
            - /bin/sh
            - -c
            - |-
              aws configure set aws_access_key_id $ACCESS_KEY
              aws configure set aws_secret_access_key $SECRET_KEY
              TOKEN=$(aws ecr get-login-password --region ap-southeast-1 | cut -d' ' -f6)
              kubectl -n $NAMESPACE delete secret $SECRET --ignore-not-found
              kubectl -n $NAMESPACE create secret docker-registry $SECRET \
                --docker-server=$REGISTRY \
                --docker-username=AWS \
                --docker-password=$TOKEN
EOF
# Create Secret for ECR
sudo kubectl -n $NS create secret generic ecr-generic-secret --from-literal=ACCESS_KEY=$AWS_ACCESS_KEY \
       --from-literal=SECRET_KEY=$AWS_SECRET_KEY \
       --from-literal=NAMESPACE=$NS \
       --from-literal=REGISTRY=$REGISTRY \
       --from-literal=SECRET=$SECRET_NAME 
sleep 1
# Create Gitlab account and Cronjob
sudo kubectl -n $NS apply -f gitlab-sa.yaml
sudo kubectl -n $NS apply -f gitlab-ecr-cronjob.yaml





