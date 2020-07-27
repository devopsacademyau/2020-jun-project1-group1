TERRAFORM_DOCS_VERSION=0.10.0-rc.1

for d in $(ls -1 terraform/modules);
do

docker run \
    -v $(pwd)/terraform/modules/$d:/module \
    quay.io/terraform-docs/terraform-docs:$TERRAFORM_DOCS_VERSION markdown document /module > terraform/modules/$d/README.md

if [ $? -eq 0 ] ; then
    git add "./terraform/modules/$d/README.md"
fi
done