import os
import subprocess

def run_command(command):
    return subprocess.check_output(command, shell=True)

# Get all LFS files
lfs_files = run_command("git lfs ls-files -n").decode('utf-8').strip().split('\n')

for file in lfs_files:
    if file:  # Skip empty lines
        print(f"Processing {file}")
        try:
            # Ensure the directory exists
            os.makedirs(os.path.dirname(file), exist_ok=True)
            
            # Checkout the file to get its content
            run_command(f"git lfs checkout {file}")
            
            # Add the file to Git
            run_command(f"git add -f {file}")
        except subprocess.CalledProcessError as e:
            print(f"Error processing {file}: {e}")

print("Conversion complete. Please commit the changes.")