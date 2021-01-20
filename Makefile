# service - variables
PROJECT			= falcon
ENV				= dev
SERVICE			= web
AWS_REGION		= us-east-1
AWS_ACCOUNT_ID	= 508571872065
URL_API			= elb

image:
	# creando imagen base
	@docker build  -f docker/base/Dockerfile -t $(PROJECT)-$(ENV)-$(SERVICE):base .
	@docker build -f docker/ofuscator/Dockerfile -t $(PROJECT)-$(ENV)-$(SERVICE):ofuscator .

build:
	# compilando codigo
	sed -i 's|http://localhost|'$(URL_API)'|g' app/webapp.js
	docker run --rm -v $(PWD)/app:/app $(PROJECT)-$(ENV)-$(SERVICE):ofuscator

release:
	cd terraform/ && terraform init -backend-config="bucket=$(PROJECT)-terraform" -backend-config="key=$(SERVICE)/$(ENV)/terraform.tfstate" -backend-config="region=${AWS_REGION}" && \
	terraform plan \
	  -var 'service=$(SERVICE)' \
	  -var 'project=$(PROJECT)' \
	  -var 'env=$(ENV)' && \
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
	@IDCLOUDFRONT=E12ARKNKLR01ZI ; \
	echo $$IDCLOUDFRONT ; \
	IDINVALIDATE=$$(aws cloudfront create-invalidation --distribution-id $$IDCLOUDFRONT --paths "/*" --region ${AWS_REGION} | jq -r ".Invalidation.Id") ; \
	while [[ "$$(aws cloudfront get-invalidation --id $$IDINVALIDATE --distribution-id $$IDCLOUDFRONT --region ${AWS_REGION} | jq -r '.Invalidation.Status')" != "Completed" ]]; do sleep 2; done
