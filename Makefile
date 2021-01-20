# service - variables
PROJECT			= falcon
ENV				= dev
SERVICE			= web
AWS_REGION		= us-east-1
AWS_ACCOUNT_ID	= 508571872065
URL_API			= elb

image:
	# creando imagen base
	echo $(TOKEN_STATIC)
	@docker build --network host -f docker/base/Dockerfile -t $(REPO_PATH):base .
	@docker build --network host -f docker/ofuscator/Dockerfile -t $(REPO_PATH):ofuscator .

build:
	# compilando codigo
	sed -i 's|http://localhost|'$(URL_API)'|g' app/webapp.js
	@docker run --rm -v $(PWD)/app:/app $(REPO_PATH):ofuscator

release:
	cd terraform/ && terraform init -backend-config="bucket=$(PROJECT)-terraform" -backend-config="key=$(SERVICE)/$(ENV)/terraform.tfstate" -backend-config="region=${AWS_REGION}" && \
	terraform plan \
	  -var 'service=$(SERVICE)' \
	  -var 'project=$(PROJECT)' \
	  -var 'env=$(ENV)'
	terraform apply \
	  -var 'service=$(SERVICE)' \
	  -var 'project=$(PROJECT)' \
	  -var 'env=$(ENV)' \
	-auto-approve 

destroy:
	cd terraform/ && terraform init -backend-config="bucket=$(PROJECT)-terraform" -backend-config="key=$(SERVICE)/$(ENV)/terraform.tfstate" -backend-config="region=${AWS_REGION}" && \
	terraform destroy \
	  -var 'service=$(SERVICE)' \
	  -var 'project=$(PROJECT)' \
	  -var 'env=$(ENV)' \
	-auto-approve
