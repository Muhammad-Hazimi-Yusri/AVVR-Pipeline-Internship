# Docker image name or ID
$imageNameOrId = "b5e1aa49a2493fd74215138ef2c747f8d1a6b532616982ebe5a90745d36a2e94"

# Docker container name or ID
$containerNameOrId = docker ps --filter "ancestor=$imageNameOrId" --format "{{.ID}}"

rm C:/Project/AV-VR-Internship/edgenet360/Data/Input/depth_e.png
docker cp "$containerNameOrId`:/monodepth/results/test_experiment/000_360monodepth_midas2_frustum.png" "C:/Project/AV-VR-Internship/edgenet360/Data/Input/depth_e.png"