# packer-al2-cis
Provides the base Amazon Linux 2, with CIS related changed, used by CloudOps.
This has been updated to provide the Amazon Linux 2023, with CIS related changed, used by CloudOps.

## Template
This repository is based on `base-template-0.3.0`.

## Makefile Targets
A `Makefile` is included in this repository in order to facilitate the testing process of this module.

To run any target, simply run `make <target>`.

| Target  | Purpose                                                                               |
|---------|---------------------------------------------------------------------------------------|
| build   | Creates the instance, deploy the changes, but does not create an AMI.                 |
| publish | Same as `build`, but creates the AMI within the current AWS profile by default.       |
| verify  | Runs Packer validation against the pipeline deployment.                               |
