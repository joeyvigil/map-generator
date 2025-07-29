from PIL import Image, ImageDraw

#path = "F:\\testing\\images\\test3.png"  # new image to create
width, height = 200, 200
img = Image.new("RGB", (width, height), color="#F1F1CC")
img1 = ImageDraw.Draw(img) # Object to draw over main image 

img1.line([(0,100),(200,100)] , fill='blue',width=2,joint='curve') # Horizontal
img1.line([(100,0),(100,200)] , fill='blue',width=2,joint='curve') # Vertical 
# img.save(path)
img.show()