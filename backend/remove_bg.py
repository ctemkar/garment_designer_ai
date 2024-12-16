from rembg import remove
from PIL import Image
import os

# Input and output paths
# IMPORTANT: Make sure this is inside your 'garment_designer_ai' folder
# And in the images subdirectory
input_path = os.path.join("garment_images", "ka_dress.png")
output_path = os.path.join("images","garment_image1_output.png")

try:
     # Open image
     input_image = Image.open(input_path)

     # Remove background
     output_image = remove(input_image)

     # Save the output image
     output_image.save(output_path)

     print(f"Background removed and image saved to {output_path}")

except FileNotFoundError:
    print("Error: Input file not found")
except Exception as e:
    print(f"An error occurred: {e}")