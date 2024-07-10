# Docker image name or ID
$imageNameOrId = "b5e1aa49a2493fd74215138ef2c747f8d1a6b532616982ebe5a90745d36a2e94"

# Grabbing the running container ID for the executed image
$containerId = docker ps --filter "ancestor=$imageNameOrId" --format "{{.ID}}"


docker exec -it $containerId bash -c "cd code/python/src && python3 main.py --expname test_experiment --blending_method all --grid_size 8x7"