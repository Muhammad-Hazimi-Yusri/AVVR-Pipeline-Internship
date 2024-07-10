# Docker image name or ID
$imageNameOrId = "b5e1aa49a2493fd74215138ef2c747f8d1a6b532616982ebe5a90745d36a2e94"

# Docker container name or ID
$containerNameOrId = docker ps --filter "ancestor=$imageNameOrId" --format "{{.ID}}"
#Stops the container at the end
docker stop $containerNameOrId