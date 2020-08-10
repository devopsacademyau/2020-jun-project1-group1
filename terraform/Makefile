##TASKS
init:
	bash -x ../scripts/terraform-auto/init.sh
.PHONY: init


plan:
	bash -x ../scripts/terraform-auto/plan.sh
.PHONY: plan


show:
	bash -x ../scripts/terraform-auto/show.sh
.PHONY: show


apply:
	bash -x ../scripts/terraform-auto/apply.sh
.PHONY: apply


destroy:
	bash -x ../scripts/terraform-auto/destroy.sh
.PHONY: destroy


wipe:
	bash -x ../scripts/terraform-auto/wipe.sh
.PHONY: wipe


all:
	make init
	make plan
	make apply

.PHONY: all

remove:
	make destroy
	make wipe

.PHONY: remove
