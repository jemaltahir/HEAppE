####
 oc create secret generic sshagent-keys --from-file=testkey01 --from-file=testkey02
secret/sshagent-keys created

###
oc create configmap heappe-confs \
  --from-file=appsettings.json=DataStagingAPI/appsettings.json \
  --from-file=appsettings-data.json=DataStagingAPI/appsettings-data.json \
  --from-file=seed.njson=RestApi/seed.example.localcomputing.njson \
  --dry-run=client -o yaml | oc apply -f -
