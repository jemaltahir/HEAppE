# Deploy to Rahti Openshift

## Requirements

- OpenShift CLI (oc) installed
- Access to an OpenShift cluster

## Components

The deployment consists of the following components:

1. **MSSQL Database**
   - SQL Server 2022 Developer Edition
   - Persistent storage (8Gi)
   - Internal service (ClusterIP)
   - Secure password management using OpenShift secrets

2. **Vault**
   - HashiCorp Vault for secrets management
   - Vault agent for automatic unsealing
   - Internal service (ClusterIP)


## Deployment Steps

1. Create a new OpenShift project:
   ```bash
   oc new-project test-heappe-app --description="Project: project_2001234 Testing HEAppE docker-compose deployment" ...
   ```

### Deployment MSSQL Steps
2. Create the MSSQL secret:
   ```bash
   oc create secret generic mssql-secret --from-literal=MSSQL_SA_PASSWORD="HEAppE@123"
   ```
3. Create the Heappe configmap:
   ```bash
   oc apply -f heappe-config.yaml
   ```

4. Create the MSSQL persistent volume claim:
   ```bash
   oc apply -f mssql-pvc.yaml
   ```

5. Deploy MSSQL:
   ```bash
   oc apply -f mssql-svc.yaml
   oc apply -f mssql-deployment.yaml
   ```

6. Verify the deployment:
   ```bash
   # Check PVC status
   oc get pvc mssql-data

   # Check secret
   oc get secret mssql-secret

   # Check pod status
   oc get pods

   # Check service
   oc get svc mssql
   ```

7. Test database connection:
   ```bash
   # Get the pod name
   POD_NAME=$(oc get pods -l app=mssql -o jsonpath="{.items[0].metadata.name}")

   # Test database connection
   oc exec -it $POD_NAME -- /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "HEAppE@123" -C -Q "SELECT @@VERSION; SELECT name FROM sys.databases;"
   ```

8. Test using the script database connection
   ```
   bash test-mssql.sh
   ```

### Deployment  SSHAgent Steps

4. Create the SSHAgent persistent volume claim:
   ```bash
   oc apply -f sshagent-keys-pvc.yaml
   ```

5. Deploy SSHAgent:
   ```bash
   oc apply -f sshagent-deployment.yaml

   ```