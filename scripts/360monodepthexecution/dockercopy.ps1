# Docker image name or ID
$imageNameOrId = "b5e1aa49a2493fd74215138ef2c747f8d1a6b532616982ebe5a90745d36a2e94"

# Docker container name or ID
$containerNameOrId = docker ps --filter "ancestor=$imageNameOrId" --format "{{.ID}}"

# Path to the file you want to copy to the container
$localFilePath = "rgb.jpg"

# Destination path inside the container
$containerDestinationPath = "/monodepth/data/erp_00/"
#Delete any existing images from input
docker exec -it $containerNameOrId bash -c 'find $containerDestinationPath -type f \( -name "*.jpg" -o -name "*.png" \) -exec rm -f {} +'

# Copy the file to the Docker container
docker cp "$localFilePath" "$containerNameOrId`:$containerDestinationPath"

cmd /c "echo ../../../data/erp_00/$localFilePath None > erp_00_data.txt"
docker exec -it $containerNameOrId rm /monodepth/data/erp_00_data.txt
docker cp "erp_00_data.txt" "$containerNameOrId`:/monodepth/data/"
rm erp_00_data.txt