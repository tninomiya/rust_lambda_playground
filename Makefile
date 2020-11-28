#################
#    GENERAL    #
#################

build:
	cargo build --release --target x86_64-unknown-linux-musl
.PHONY: build

#################
#      SAM      #
#################

STACK_NAME := rust-lambda-sample
TEMPLATE_FILE := template.yml
SAM_FILE := sam_generated.yml
S3_BUCKET := rust-runtime-tninomiya-20201128

deploy: build
	sam package \
		--template-file $(TEMPLATE_FILE) \
		--s3-bucket $(S3_BUCKET) \
		--output-template-file $(SAM_FILE)
	sam deploy \
		--template-file $(SAM_FILE) \
		--stack-name $(STACK_NAME) \
		--capabilities CAPABILITY_IAM
.PHONY: deploy

create-bucket:
	aws s3 mb "s3://$(S3_BUCKET)"
.PHONY: create-bucket

delete:
	aws cloudformation delete-stack --stack-name $(STACK_NAME)
	aws s3 rm "s3://$(S3_BUCKET)" --recursive
	aws s3 rb "s3://$(S3_BUCKET)"
.PHONY: delete



#################
#    AWS CLI    #
#################

FUNCTION := rust-lambda-sample

invoke-function:
	aws lambda invoke \
		--function-name $(FUNCTION) \
		--cli-binary-format raw-in-base64-out \
		--payload '{"firstName":"みんな"}' \
		response.txt
.PHONY: invoke-function
