from rembg import remove
from PIL import Image
import io
import os

# Input and output paths
input_dir = "garment_images"
output_dir = "images"
input_filename = "ka_dress.png"
output_filename = "garment_image1_output.png"

input_path = os.path.join(input_dir, input_filename)
output_path = os.path.join(output_dir, output_filename)

# Create output directory if it doesn't exist
os.makedirs(output_dir, exist_ok=True)

try:
    # Check if input file exists
    if not os.path.exists(input_path):
        raise FileNotFoundError(f"Input file '{input_path}' not found")

    # Open image
    input_image = Image.open(input_path)

    # Convert image to byte array
    img_byte_arr = io.BytesIO()
    input_image.save(img_byte_arr, format='PNG')
    img_byte_arr = img_byte_arr.getvalue()

    # Remove background
    output_image_bytes = remove(img_byte_arr)

    # Convert byte array back to image
    output_image = Image.open(io.BytesIO(output_image_bytes))

    # Save the output image
    output_image.save(output_path)

    print(f"Background removed and image saved to {output_path}")

except FileNotFoundError as fnf_error:
    print(fnf_error)
except Exception as e:
    print(f"An error occurred: {e}")
