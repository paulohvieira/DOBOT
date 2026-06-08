import cv2 as cv
import numpy as np
from pathlib import Path

dictionary = cv.aruco.getPredefinedDictionary(cv.aruco.DICT_5X5_250)

# Gerar uma quantidade de marcadores
Path.mkdir(Path.joinpath(Path.cwd(),'assets/markers'), parents=True, exist_ok=True)
for i in range(0, 16):
	marker = cv.aruco.generateImageMarker(dictionary, i, 280, borderBits= 1)
	cv.imwrite(f'assets/markers/{i}.png', marker)