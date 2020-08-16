# steps:
# get latest task definition
# update image line to new image sha
# register task definition
# update service to new task def with force deployment

echo "Using Variables:"
echo "PROJECT_NAME: ${PROJECT_NAME}"
echo "DOCKER_REGISTRY_URL: ${DOCKER_REGISTRY_URL}"
echo "DOCKER_REPOSITORY: ${DOCKER_REPOSITORY}"

echo "Download last valid definition"

aws ecs describe-task-definition \
    --task-definition ${PROJECT_NAME}-task-definition \
    --output json \
    --query '{containerDefinitions:taskDefinition.containerDefinitions,family:taskDefinition.family,executionRoleArn:taskDefinition.executionRoleArn,volumes:taskDefinition.volumes,placementConstraints:taskDefinition.placementConstraints,memory:taskDefinition.memory}' \
    > task-definition.json

echo "Getting latest image tag"

IMAGE_TAG=$(aws ecr describe-images \
    --repository-name ${DOCKER_REPOSITORY} \
    --query 'reverse(sort_by(imageDetails,& imagePushedAt))[0].imageTags[?@!=`latest`]' \
    --output text)

echo "updating task definition with new image url"

sed -i "s|.*\"image\":.*|\"image\": \"${DOCKER_REGISTRY_URL}/${DOCKER_REPOSITORY}:${IMAGE_TAG}\",|" task-definition.json

echo "registering task definition"

TASK_DEFINITION_ARN=$(aws ecs register-task-definition \
    --cli-input-json file://task-definition.json \
    --query "taskDefinition.taskDefinitionArn" \
    --output text | sed "s|.*/||")

echo "Task Definition ARN: ${TASK_DEFINITION_ARN}"

echo "updating service task definition"

aws ecs update-service \
    --cluster ${PROJECT_NAME}-ecs-cluster \
    --service ${PROJECT_NAME}-ecs_service \
    --task-definition $TASK_DEFINITION_ARN \
    --force-new-deployment \
    --query "service.clusterArn"