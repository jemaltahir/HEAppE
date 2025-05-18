#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Function to print status
print_status() {
    echo -e "${YELLOW}[*] $1${NC}"
}

print_success() {
    echo -e "${GREEN}[+] $1${NC}"
}

print_error() {
    echo -e "${RED}[-] $1${NC}"
}

echo -e "${YELLOW}Starting MSSQL deployment test...${NC}"

# Show current namespace
CURRENT_NS=$(oc project -q 2>/dev/null)
if [ -z "$CURRENT_NS" ]; then
    print_error "Could not detect current OpenShift namespace. Are you logged in?"
    exit 1
else
    print_success "Running in OpenShift namespace: $CURRENT_NS"
fi

# Retrieve MSSQL password from secret
print_status "Extracting MSSQL SA password from secret..."
MSSQL_PASSWORD=$(oc get secret mssql-secret -o jsonpath='{.data.MSSQL_SA_PASSWORD}' | base64 -d)
if [ -z "$MSSQL_PASSWORD" ]; then
    print_error "Failed to retrieve MSSQL password from secret"
    exit 1
fi
print_success "Retrieved MSSQL password"

# Test MSSQL PVC
print_status "Testing MSSQL PVC..."
PVC_STATUS=$(oc get pvc mssql-data -o jsonpath='{.status.phase}')
if [ "$PVC_STATUS" == "Bound" ]; then
    print_success "MSSQL PVC is bound"
else
    print_error "MSSQL PVC is not bound. Current status: $PVC_STATUS"
    exit 1
fi

# Test MSSQL Secret
print_status "Testing MSSQL Secret..."
if oc get secret mssql-secret > /dev/null; then
    print_success "MSSQL Secret exists"
else
    print_error "MSSQL Secret does not exist"
    exit 1
fi

# Test MSSQL Deployment
print_status "Testing MSSQL Deployment..."
DEPLOYMENT_STATUS=$(oc get deployment mssql -o jsonpath='{.status.availableReplicas}')
if [ "$DEPLOYMENT_STATUS" == "1" ]; then
    print_success "MSSQL Deployment is running"
else
    print_error "MSSQL Deployment is not running properly"
    exit 1
fi

# Test MSSQL Pod
print_status "Testing MSSQL Pod..."
POD_NAME=$(oc get pods -l app=mssql -o jsonpath="{.items[0].metadata.name}")
POD_STATUS=$(oc get pod "$POD_NAME" -o jsonpath='{.status.phase}')
if [ "$POD_STATUS" == "Running" ]; then
    print_success "MSSQL Pod is running"
else
    print_error "MSSQL Pod is not running properly. Current status: $POD_STATUS"
    exit 1
fi

# Test MSSQL Service
print_status "Testing MSSQL Service..."
if oc get svc mssql > /dev/null; then
    print_success "MSSQL Service exists"
else
    print_error "MSSQL Service does not exist"
    exit 1
fi

# Check for sqlcmd availability
SQLCMD_PATH="/opt/mssql-tools18/bin/sqlcmd"
print_status "Verifying sqlcmd exists in container..."
if ! oc exec "$POD_NAME" -- test -x "$SQLCMD_PATH"; then
    print_error "sqlcmd not found in pod at $SQLCMD_PATH"
    exit 1
fi
print_success "sqlcmd found in pod"

# Test Database Connection
print_status "Testing Database Connection..."
DB_TEST=$(oc exec "$POD_NAME" -- "$SQLCMD_PATH" -S localhost -U sa -P "$MSSQL_PASSWORD" -C -Q "SELECT @@VERSION;" 2>&1)
if [ $? -eq 0 ]; then
    print_success "Database connection successful"
    echo -e "${GREEN}SQL Server Version:${NC}"
    echo "$DB_TEST"
else
    print_error "Database connection failed"
    echo "$DB_TEST"
    exit 1
fi

# Test Database Content
print_status "Testing Database Content..."
DB_DATABASES=$(oc exec "$POD_NAME" -- "$SQLCMD_PATH" -S localhost -U sa -P "$MSSQL_PASSWORD" -C -Q "SELECT name FROM sys.databases;" 2>&1)
if [ $? -eq 0 ]; then
    print_success "Database content check successful"
    echo -e "${GREEN}Available Databases:${NC}"
    echo "$DB_DATABASES"
else
    print_error "Database content check failed"
    echo "$DB_DATABASES"
    exit 1
fi

print_success "MSSQL deployment tests completed successfully!"
