docs-terraform: $(TERRAFORM_MODULES)
	@scripts/update-terraform-docs.sh
.PHONY:docs-terraform