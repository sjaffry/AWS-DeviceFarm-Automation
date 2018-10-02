#!/bin/bash
UPLAOD_NAME="test_bundle.zip"
UPLOAD_TYPE="APPIUM_WEB_PYTHON_TEST_PACKAGE"
TEST_TYPE="APPIUM_WEB_PYTHON"

echo ">> Creating project"
PROJECT=$(aws devicefarm create-project --name IAG-POC | grep '\"arn\"' | sed 's/\"arn\": //g' | sed 's/\,//g' | sed 's/\"//g' | tr -d '[:space:]')
echo "Project ARN: $PROJECT"

echo ">> Creating Device Pool"
DEVICE_POOL=$(aws devicefarm create-device-pool --name android-devices --rules file://device-pool-rules.json --project-arn $PROJECT | grep '\"arn\"' | sed 's/\"arn\": //g' | sed 's/\,//g' | sed 's/\"//g' | tr -d '[:space:]')
echo "Device Pool ARN: $DEVICE_POOL"

echo ">> Creating upload"
URL=$(aws devicefarm create-upload --project-arn $PROJECT --name $UPLAOD_NAME --type $UPLOAD_TYPE | grep '\"url\"' | sed 's/\"url\": //g' | sed 's/\"//g' | sed 's/\,//g' | tr -d '[:space:]')
UPLOAD_ARN=$(aws devicefarm list-uploads --arn $PROJECT | grep "946827581022" | grep '\"arn\"' | sed 's/\"arn\": //g' | sed 's/\,//g' | tr -d '[:space:]')
echo "Upload ARN: $UPLOAD_ARN"

echo ">> Uploading package to $URL"
curl --upload-file $UPLAOD_NAME $URL --verbose

echo ">> Creating a new test run"
RUN=$(aws devicefarm schedule-run --name IAG-DEVICE_TESTS-1 --project-arn $PROJECT --device-pool-arn $DEVICE_POOL --test type=$TEST_TYPE,testPackageArn=$UPLOAD_ARN | grep '\"arn\"' | sed 's/\"arn\": //g' | sed 's/\,//g' | sed 's/\"//g' | tr -d '[:space:]')
echo "RUN ARN = $RUN"

RUN_STATUS=$(aws devicefarm get-run --arn $RUN | grep status | sed 's/\,//g' | sed 's/\"//g' | tr -d '[:space:]')
while [  "$RUN_STATUS" != "status:COMPLETED" ] 
do
    echo "Waiting for test run to complete. $RUN_STATUS"
    sleep 10
    RUN_STATUS=$(aws devicefarm get-run --arn $RUN | grep status | sed 's/\,//g' | sed 's/\"//g' | tr -d '[:space:]')
done

echo $RUN_STATUS
echo ">> Now that tests have all completed, cleaning up.."

echo ">> Deleting test run"
aws devicefarm delete-run --arn $RUN

echo ">> Deleting upload"
aws devicefarm delete-upload --arn $UPLOAD_ARN

echo ">> Deleting device pool"
aws devicefarm delete-device-pool --arn $DEVICE_POOL

echo ">> Deleting project"
aws devicefarm delete-project --arn $PROJECT