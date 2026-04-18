from PIL import Image, ImageDraw

def analyze_and_fix():
    img = Image.open('assets/images/logov.jpeg').convert('RGB')
    width, height = img.size
    
    # Sample blue color (definitely inside the blue zone)
    # Based on previous run, it's (15, 29, 55)
    blue_color = (15, 29, 55)

    # Use floodfill starting from (0, 0) with a high threshold to consume the anti-aliased white border
    # Thresh 150 should be safe as long as the blue barrier is dark enough.
    # The blue is (15, 29, 55), sum of squares distance to white (255,255,255) is huge.
    # The difference between bg (247,247,247) and blue (15,29,55) is also huge.
    ImageDraw.floodfill(img, (0, 0), blue_color, thresh=150)
    
    # Let's also do the 4 corners just in case they are isolated (unlikely but safe)
    ImageDraw.floodfill(img, (width-1, 0), blue_color, thresh=150)
    ImageDraw.floodfill(img, (0, height-1), blue_color, thresh=150)
    ImageDraw.floodfill(img, (width-1, height-1), blue_color, thresh=150)

    img.save('assets/images/logov.jpeg', 'JPEG', quality=100)
    print("Updated assets/images/logov.jpeg")

analyze_and_fix()
