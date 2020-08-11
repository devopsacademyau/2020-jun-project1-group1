# TODO: replace for the script to deploy the ECS
echo "=== 🧯🧯🧯 SIMULATION ==="
echo "SHOULD DEPLOY USING SHA:"
aws ecr describe-images \
    --repository-name ${DOCKER_REPOSITORY} \
    --query 'reverse(sort_by(imageDetails,& imagePushedAt))[0].imageTags[-1]' \
    --output text