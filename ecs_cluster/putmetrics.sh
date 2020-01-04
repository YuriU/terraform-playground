# TODO: Script that
aws cloudwatch put-metric-data --metric-name MyTestMetric --namespace TEST/ECS --storage-resolution 1 --unit Count --value 30 --dimensions ServiceName=apache