from PIL import Image, ImageDraw

def analyze_and_fix():
    img = Image.open('assets/images/logov.jpeg').convert('RGB')
    width, height = img.size
    print(f"Size: {width}x{height}")
    
    # Sample background color (top-left)
    bg_color = img.getpixel((0, 0))
    print(f"Background color: {bg_color}")
    
    # Sample blue color (center-top, inside the blue box)
    # The blue box seems to be centered. Let's sample at 1/4 width, 1/2 height
    blue_color = img.getpixel((width // 4, height // 2))
    print(f"Blue color sample 1: {blue_color}")
    
    # Try another spot just to be sure
    blue_color_2 = img.getpixel((width // 2, height // 4))
    print(f"Blue color sample 2: {blue_color_2}")

    # Use the blue color to fill the background
    # We use floodfill starting from (0,0)
    ImageDraw.floodfill(img, (0, 0), blue_color, thresh=30)
    
    img.save('assets/images/logov_modified.jpeg', 'JPEG', quality=100)
    print("Saved to assets/images/logov_modified.jpeg")

analyze_and_fix()
