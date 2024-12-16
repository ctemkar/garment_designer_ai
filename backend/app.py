from flask import Flask, request, jsonify
from rembg import remove
from PIL import Image, ImageOps
import io
import os
import numpy as np

app = Flask(__name__)

@app.route('/remove_background', methods=['POST'])
def remove_background():
    try:
        if 'image' not in request.files:
            return jsonify({'error': 'No image file provided'}), 400

        image_file = request.files['image']
        image = Image.open(io.BytesIO(image_file.read()))

        output_image = remove(image)

        # Convert to numpy array
        image_np = np.array(output_image.convert("RGBA"))

        # Create mask of pixels that should be removed based on low intensity
        alpha = image_np[:,:,3]
        mask = (np.mean(image_np[:,:,:3], axis=2) < 70)
        alpha[mask] = 0

        # Create the output image
        output_image = Image.fromarray(np.concatenate((image_np[:,:,:3], alpha[:,:,np.newaxis]), axis=2).astype(np.uint8))


        # Save the result in memory
        image_output_buffer = io.BytesIO()
        output_image.save(image_output_buffer, format="PNG")
        image_output_buffer.seek(0)

        # Read the bytes to send
        image_bytes = image_output_buffer.read()

        return jsonify({'image_data': image_bytes.decode('latin-1')})

    except Exception as e:
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    app.run(debug=True)