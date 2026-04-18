from PIL import Image, ImageDraw

def reconstruct_logo():
    # Load original (we might have modified it, let's use the backup if we had one, 
    # but we can try to find the white logo in the modified one since we didn't touch it)
    img = Image.open('assets/images/logov.jpeg').convert('RGB')
    width, height = img.size
    
    blue_color = (15, 29, 55)
    
    # Create a New Solid Blue Image
    new_img = Image.new('RGB', (width, height), blue_color)
    
    # Define a bounding box for the logo to avoid picking up any background artifacts
    # The logo is centered. Let's say 20% to 80% range.
    logo_margin = width * 0.15
    
    pixels = img.load()
    new_pixels = new_img.load()
    
    for y in range(height):
        for x in range(width):
            r, g, b = pixels[x, y]
            # If the pixel is very bright (white logo)
            # AND it's not at the very edge (where the background was)
            if r > 200 and g > 200 and b > 200:
                if x > logo_margin and x < width - logo_margin and y > logo_margin and y < height - logo_margin:
                    new_pixels[x, y] = (r, g, b)
    
    # Save the result
    new_img.save('assets/images/logov.jpeg', 'JPEG', quality=100)
    print("Reconstructed assets/images/logov.jpeg with solid blue background.")

reconstruct_logo()
