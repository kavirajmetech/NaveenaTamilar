from flask import Flask, request, jsonify
from diffusers import StableDiffusionPipeline
import torch
import uuid

app = Flask(__name__)
pipeline = StableDiffusionPipeline.from_pretrained("CompVis/stable-diffusion-v1-4", torch_dtype=torch.float16)

@app.route('/generate-image', methods=['POST'])
def generate_image():
    data = request.get_json()
    prompt = data['prompt']

    # Generate an image
    image = pipeline(prompt).images[0]
    image_path = f"static/{uuid.uuid4()}.png"
    image.save(image_path)

    return jsonify({"image_url": f"http://localhost:5000/{image_path}"})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
