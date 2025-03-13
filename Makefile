# Makefile
# Provides targets for testing this module.
SHELL := /bin/bash
PACKER_FILE ?= local.json
PACKER_VARIABLES := ami_prefix assume_role_arn base_ami instance_type yum_update pre_userdata enable_fips

K8S_VERSION_PARTS := $(subst ., ,$(kubernetes_version))
K8S_VERSION_MINOR := $(word 1,${K8S_VERSION_PARTS}).$(word 2,${K8S_VERSION_PARTS})

assume_role_arn ?= $(TF_VAR_assume_role_arn)

.PHONY: build
build:
	packer build -color=false $(foreach packerVar,$(PACKER_VARIABLES), $(if $($(packerVar)),--var $(packerVar)='$($(packerVar))',)) $(PACKER_FILE)

.PHONY: build_all
build_all: eks_1.30 eks_1.31 fips build

.PHONY: publish
publish:
	packer build -color=false -var 'skip_create_ami=false' $(foreach packerVar,$(PACKER_VARIABLES), $(if $($(packerVar)),--var $(packerVar)='$($(packerVar))',)) $(PACKER_FILE)

.PHONY: publish_all
publish_all: eks_1.30 eks_1.31 fips publish

.PHONY: verify
verify:
	packer validate $(PACKER_FILE)

.PHONY: fips
fips:
	$(MAKE) publish ami_prefix=ss-al2023-fips- enable_fips=1

.PHONY: redeploy
redeploy:
	ansible-playbook playbooks/reconfigure.yml -i inventory/aws_ec2.yml -e target_environment=$(TARGET_ENV) -e region_name=$(REGION_NAME) -e prefix=$(PREFIX)

.PHONY: eks_1.30
eks_1.30:
	$(MAKE) publish kubernetes_version=1.30.0 base_ami=amazon-eks-node-al2023-x86_64-nvidia-1.30-v* ami_prefix=ss-al2023-fips-cis-eks-gpu-node-1.30- enable_fips=1 instance_type=g4dn.xlarge yum_update=false pre_userdata=true
	$(MAKE) publish kubernetes_version=1.30.0 base_ami=amazon-eks-node-al2023-x86_64-standard-1.30-v* ami_prefix=ss-al2023-fips-cis-eks-node-1.30- enable_fips=1 instance_type=t3.large yum_update=false pre_userdata=true	

.PHONY: eks_1.31
eks_1.31:
	$(MAKE) publish kubernetes_version=1.31.0 base_ami=amazon-eks-node-al2023-x86_64-nvidia-1.31-v* ami_prefix=ss-al2023-fips-cis-eks-gpu-node-1.31- enable_fips=1 instance_type=g4dn.xlarge yum_update=false pre_userdata=true
	$(MAKE) publish kubernetes_version=1.31.0 base_ami=amazon-eks-node-al2023-x86_64-standard-1.31-v* ami_prefix=ss-al2023-fips-cis-eks-node-1.31- enable_fips=1 instance_type=t3.large yum_update=false pre_userdata=true