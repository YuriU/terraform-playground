# To add EKS configuration
aws eks --region eu-central-1 update-kubeconfig --name TestEKSCluster

# Get current context
kubectl config current-context

# Get all contexts list
kubectl config get-contexts

# Set current context
kubectl config use-context docker-desktop

# Remove context after terrafor destroy
kubectl config delete-context arn:aws:eks:eu-central-1:039810988692:cluster/TestEKSCluster
kubectl config delete-cluster arn:aws:eks:eu-central-1:039810988692:cluster/TestEKSCluster