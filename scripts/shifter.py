import sys
from PIL import Image

def shift_360_image(input_path, output_path, shift_percentage):
    # Open the image
    img = Image.open(input_path)
    width, height = img.size
    
    # Calculate shift amount based on percentage
    shift_amount = int(width * (shift_percentage / 100))
    
    # Create a new image with the same size
    shifted_img = Image.new(img.mode, (width, height))
    
    # Copy and paste the shifted portions
    shifted_img.paste(img.crop((0, 0, shift_amount, height)), (width - shift_amount, 0))
    shifted_img.paste(img.crop((shift_amount, 0, width, height)), (0, 0))
    
    # Save the shifted image
    shifted_img.save(output_path)

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python shifter.py <input_image_path> <output_image_path>")
        sys.exit(1)

    input_image = sys.argv[1]
    output_image = sys.argv[2]
    shift_percentage = 25.5  # Adjust this value to get the desired shift (e.g., 25 means 25% of the width)

    shift_360_image(input_image, output_image, shift_percentage)
    print(f"Shifted image saved as {output_image}")