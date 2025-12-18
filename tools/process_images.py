from PIL import Image
import os
import sys

def process_images(input_dir, output_dir):
    """
    Example script to process images. 
    Can be used to resize, format convert, or combine into spritesheets.
    """
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)

    for filename in os.listdir(input_dir):
        if filename.lower().endswith(('.png', '.jpg', '.jpeg')):
            img_path = os.path.join(input_dir, filename)
            img = Image.open(img_path)
            
            # Example: Resize to 448 width (screen width) while maintaining aspect ratio
            # base_width = 448
            # w_percent = (base_width / float(img.size[0]))
            # h_size = int((float(img.size[1]) * float(w_percent)))
            # img = img.resize((base_width, h_size), Image.Resampling.LANCZOS)
            
            # For now, just converting/saving
            base_name = os.path.splitext(filename)[0]
            out_path = os.path.join(output_dir, f"{base_name}_processed.png")
            img.save(out_path, "PNG")
            print(f"Processed {filename} -> {out_path}")

if __name__ == "__main__":
    # Usage: python process_images.py input_folder output_folder
    if len(sys.argv) < 3:
        print("Usage: python process_images.py <input_dir> <output_dir>")
    else:
        process_images(sys.argv[1], sys.argv[2])
