# Docker image name or ID
$imageNameOrId = "c5ae0f67376a99d442319a0f033d4943be9d89a75d4e75e3df2b3cecf56ebec0"

# Grabbing the running container ID for the executed image
$containerId = docker ps --filter "ancestor=$imageNameOrId" --format "{{.ID}}"


docker exec -it $containerId bash -c "cd code/python/src && python3 main.py --expname test_experiment --blending_method all --grid_size 8x7"