export PROJECT=diesel-patrol-382622 #northam-ce-mlai-tpu if spot is out of stock
export ZONE=us-west4-a #us-west1-c in northam-ce-mlai-tpu if spot is out of stock
export CLUSTER_VERSION="1.29.4-gke.1043002"
export MACHINE_TYPE="ct5lp-hightpu-4t"
export TPU_TOPOLOGY="4x4"
export CLUSTER_NAME="tpuv5e-gke-$TPU_TOPOLOGY-$USER"
export NUM_NODES=4
export NODEPOOL_NAME="tpu-v5e-$TPU_TOPOLOGY-$NUM_NODES-node"

gcloud config set project $PROJECT
gcloud config set compute/zone $ZONE

#Follow the guide here to setup kubectl locally
#https://cloud.google.com/kubernetes-engine/docs/how-to/cluster-access-for-kubectl#gcloud

# Export your path to your kubectl command
export PATH=$PATH:/usr/local/share/google-cloud-sdk/bin

# Create your GKE standard cluster
gcloud container clusters create $CLUSTER_NAME --zone=$ZONE \
--project=$PROJECT --cluster-version=$CLUSTER_VERSION

# Create a nodepool. Choose --spot if you have preemptible quota
gcloud container node-pools create $NODEPOOL_NAME \
    --zone=$ZONE \
    --project=$PROJECT \
    --cluster=$CLUSTER_NAME \
    --node-locations=$ZONE \
    --machine-type=$MACHINE_TYPE \
    --tpu-topology=$TPU_TOPOLOGY \
    --num-nodes=$NUM_NODES \
    --spot # remove if using on-demand

# Set the kubectl context to the created cluster
gcloud container clusters get-credentials $CLUSTER_NAME \
    --zone=$ZONE \
    --project=$PROJECT

# View the current context to confirm the correct cluster is being used
kubectl config current-context

# Test available chips
kubectl create -f yaml/available-chips-singlehost.yaml
kubectl create -f yaml/available-chips-2x4.yaml


# enable multislice
kubectl apply --server-side -f https://github.com/kubernetes-sigs/jobset/releases/download/v0.2.1/manifests.yaml
kubectl apply -f yaml/4x4jobset.yaml
kubectl apply -f yaml/2x2jobset.yaml
kubectl get jobsets
kubectl logs multislice-job-slice-0-0-zkkdf -f
kubectl logs multislice-job-8chips-slice-0-0-4wn5r -f

kubectl logs multislice-job-2x2-slice-0-0-k2cwx -f

# Check pods are starting
kubectl get pods

# Check the logs
kubectl logs tpu-job-jax-v5e -f

# Create a training job
kubectl create -f yaml/singlehost-train.yaml

# Check the logs
kubectl logs tpu-singletrain-jax-v5e -f