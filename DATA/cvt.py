from operator import mod
import sys
import math
import struct
import os
#from io import BytesIO
from PIL import Image
import matplotlib.pyplot as plt

doscolors = [
    (0x00, 0x00, 0x00),  # 0
    (0x00, 0x00, 0xa8),  # 1
    (0x00, 0xa8, 0x00),  # 2
    (0x00, 0xa8, 0xa8),  # 3
    (0xa8, 0x00, 0x00),  # 4
    (0xa8, 0x00, 0xa8),  # 5
    (0xa8, 0xa8, 0x00),  # 6
    (0xa8, 0xa8, 0xa8),  # 7

    (0x54, 0x54, 0x54),  # 8
    (0x54, 0x54, 0xff),  # 9
    (0x54, 0xff, 0x54),  # 10
    (0x54, 0xff, 0xff),  # 11
    (0xff, 0x54, 0x54),  # 12
    (0xff, 0x54, 0xff),  # 13
    (0xff, 0xff, 0x54),  # 14
    (0xff, 0xff, 0xff),  # 15
]


def color_distance(a, b):
    return math.sqrt((a[0]-b[0])**2 + (a[1]-b[1])**2 + (a[2]-b[2])**2)


def nearest_color(color):
    nearest = 0

    for i in range(len(doscolors)):
        if color_distance(color, doscolors[i]) < color_distance(color, doscolors[nearest]):
            nearest = i

    return nearest


buf = []
src_dir = r'src/'
dst_file = r'imgout.txt'

for imgf in os.listdir(src_dir):
    img = Image.open(os.path.join(src_dir, imgf)).convert("RGB")
    img = img.resize((80, 50))
    w, h = img.size

    for y in range(0, h, 2):
        for x in range(w):
            b = (nearest_color(img.getpixel((x, y))) <<
                 4) | nearest_color(img.getpixel((x, y+1)))
            buf.append(b)
    img.close()

with open(dst_file, "w") as out:
    c = 0
    out.write("DB\t")
    for i in buf:
        si = hex(i).upper().removeprefix('0X')
        if si[0].isalpha():
            si = '0' + si
        si = si + 'H'
        out.write(si)
        c = c + 1
        if mod(c+1, 25) == 0:
            out.write('\nDB\t')
        else:
            out.write(',')
    print(c)
