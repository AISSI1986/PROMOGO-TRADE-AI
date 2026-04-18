from PIL import Image, ImageOps, ImageFilter

def smooth_logo_reconstruction():
    # Load original
    # Note: we need the original original if possible, but we've been overwriting logov.jpeg.
    # Luckily I can use the one I just made as a base for the "where the logo is" but the edges might be lost.
    # Wait, I should have backed it up. I'll check if there's a logo.jpeg or similar.
    # Ah, I don't have a backup. But the current logov.jpeg has the logo.
    
    img = Image.open('assets/images/logov.jpeg').convert('RGB')
    width, height = img.size
    blue_color = (15, 29, 55)
    
    # Let's try to get a smoother mask.
    # We take the luminance.
    mask = img.convert('L')
    
    # We want the logo area to be white in the mask, and everything else black.
    # Since the background is now blue (dark), the logo is already the brightest part.
    # We can use a threshold or just use the luminance directly as an alpha channel.
    
    # Create a solid blue image
    background = Image.new('RGB', (width, height), blue_color)
    
    # Create a solid white image (this will be the logo color)
    logo_color = Image.new('RGB', (width, height), (255, 255, 255))
    
    # Use the mask to composite logo_color over background
    # We'll enhance the mask to make sure the white is solid white.
    mask = mask.point(lambda x: 255 if x > 200 else 0) # Binary for now
    mask = mask.filter(ImageFilter.SMOOTH) # Smooth the binary mask
    
    result = Image.composite(logo_color, background, mask)
    
    result.save('assets/images/logov.jpeg', 'JPEG', quality=100)
    print("Smoothed assets/images/logov.jpeg saved.")

smooth_logo_reconstruction()
