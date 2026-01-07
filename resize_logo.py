from PIL import Image
import os
import sys

def add_padding(input_path, output_path, scale_factor=0.65):
    try:
        if not os.path.exists(input_path):
            print(f"Input file not found: {input_path}")
            return

        img = Image.open(input_path).convert("RGBA")
        width, height = img.size
        
        new_width = int(width * scale_factor)
        new_height = int(height * scale_factor)
        
        resized_img = img.resize((new_width, new_height), Image.Resampling.LANCZOS)
        
        # Create new transparent image
        new_img = Image.new("RGBA", (width, height), (255, 255, 255, 0))
        
        # Calculate position to center
        x = (width - new_width) // 2
        y = (height - new_height) // 2
        
        new_img.paste(resized_img, (x, y), resized_img)
        new_img.save(output_path)
        print(f"Successfully created {output_path}")
    except Exception as e:
        print(f"Error: {e}")

input_file = r"d:\transfer\YaNafssi\client\assets\logo.png"
output_file = r"d:\transfer\YaNafssi\client\assets\logo_padded.png"

# Check if PIL is installed
try:
    import PIL
    add_padding(input_file, output_file)
except ImportError:
    print("PIL not installed")
