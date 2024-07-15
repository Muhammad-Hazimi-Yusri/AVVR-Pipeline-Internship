# Docker image name or ID
$imageNameOrId = "c5ae0f67376a99d442319a0f033d4943be9d89a75d4e75e3df2b3cecf56ebec0"

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