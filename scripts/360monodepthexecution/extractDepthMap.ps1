# Docker image name or ID
$imageNameOrId = "c5ae0f67376a99d442319a0f033d4943be9d89a75d4e75e3df2b3cecf56ebec0"

# Docker container name or ID
$containerNameOrId = docker ps --filter "ancestor=$imageNameOrId" --format "{{.ID}}"

rm C:/Project/AVVR-Pipeline-Internship/edgenet360/Data/Input/depth_e.png
docker cp "$containerNameOrId`:/monodepth/results/test_experiment/000_360monodepth_midas2_frustum.png" "C:/Project/AVVR-Pipeline-Internship/edgenet360/Data/Input/depth_e.png"