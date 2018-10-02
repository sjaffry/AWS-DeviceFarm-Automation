# AWS-DeviceFarm-Automation
AWS CLI based automation for the on-demand creation of a device farm project, a test run and then tear down. Can be run as part of an application testing step of a deployment or build pipeline.

## To-Do
* Add a bash function to remove the boiler plate sed processing at each command
* Genericise more

## Files in the project
* buildspec.yaml - used by AWS CodeBuild
* device-pool-rules.json - configures the types of devices to be included for the test runs (e.g. Manufacturer and Platform)
* execute_tests.sh - main script that stands up a new devicefarm environment, runs the tests and then tears down the environment
