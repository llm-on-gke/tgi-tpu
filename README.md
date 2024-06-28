# tgi-tpu
Nodepool:

gcloud container node-pools create  tgi-tpu-nodepool \
  --cluster=${CLUSTER_NAME} \
  --machine-type=ct5lp-hightpu-4t \
  --num-nodes=1 \
  --region=${REGION} \
  --node-locations=${LOCATION} \
  --spot

Node taint:
kubectl taint nodes gke-tpu-42370714-8d0f  tpu=present:NoSchedule

create huggingface api token secrets:

export HF_TOKEN=<paste-your-own-token>
kubectl create secret generic huggingface --from-literal="HF_TOKEN=$HF_TOKEN" 

kubectl get secrets/huggingface --template={{.data.HF_TOKEN}} | base64 -d





