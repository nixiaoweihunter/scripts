#!/usr/bin/env python
from PIL import Image
import pytesseract
im = Image.open('phototest.tif')
print(pytesseract.image_to_string(im))
