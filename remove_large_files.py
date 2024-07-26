import subprocess
import os

files_to_remove = [
    "Unity/Project/S3A-AcousticRoomModelling-SteamAudio-EdgeNet-Full/Assets/Models/Kitchen_zb_v01.OBJ",
    "Unity/Project/AVVR/Assets/Resources/Demo/KitchenLIDAR-SoundSource/Kitchen-Lidar-mesh-down-texture2.obj",
    "Unity/Project/AVVR/Assets/Resources/Demo/KitchenLIDAR-SoundSource/Kitchen-Lidar-mesh-down-texture.obj",
    "Unity/Project/S3A-AcousticRoomModelling-SteamAudio-EdgeNet-Full/Assets/Models/Courtyard-Lidar-mesh-down-texture.obj",
    "Unity/Project/S3A-AcousticRoomModelling-SteamAudio-EdgeNet-Full/Assets/Models/Kitchen-Lidar-mesh-down-texture.obj",
    "Unity/Project/S3A-AcousticRoomModelling-SteamAudio-EdgeNet-Full/Assets/Models/Kitchen-Lidar-mesh-down-texture2.obj"
]

def run_command(command):
    subprocess.run(command, shell=True, check=True)

# Create a file with paths to remove
with open('files_to_remove.txt', 'w') as f:
    for file in files_to_remove:
        f.write(f"{file}\n")

# Run git filter-repo
run_command('git filter-repo --invert-paths --paths-from-file files_to_remove.txt --force')

# Remove the temporary file
os.remove('files_to_remove.txt')

# Remove the files from the working directory if they exist
for file in files_to_remove:
    if os.path.exists(file):
        os.remove(file)
        print(f"Deleted {file} from the working directory")

print("Large file removal complete. Please push the changes.")