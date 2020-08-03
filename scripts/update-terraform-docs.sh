for d in $(ls -1 terraform/modules);
do

echo "\n"
echo "📦 Generating document for module \e[32m$d\e[0m"

docker-compose run --rm terraform-docs \
    markdown document /modules/$d > terraform/modules/$d/README.md

if [ $? -eq 0 ] ; then
    git add "./terraform/modules/$d/README.md"
    echo "✅ Doc generated and staged"
fi
done