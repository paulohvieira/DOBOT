import numpy as np
import cv2 as cv

# Captura de vídeo ###########################################################
cap = cv.VideoCapture(0)

if not cap.isOpened():
	print('Failed to open camera.')
	exit(1)

cap.set(cv.CAP_PROP_FRAME_HEIGHT, 1080)
cap.set(cv.CAP_PROP_FRAME_WIDTH, 1920)

# Calibração de distorção ####################################################
# prepare object points, like (0,0,0), (1,0,0), (2,0,0) ....,(6,5,0)
objp = np.zeros((9*6,3), np.float32)
objp[:,:2] = np.mgrid[0:9,0:6].T.reshape(-1,2)

objpoints = [] # 3d point in real world space
imgpoints = [] # 2d points in image plane

quit = False
calibrated = False

# Variáveis resultado da calibração
mtx = None
dist = None
rvecs = None
tvecs = None


while not quit and not calibrated:
	ret, frame = cap.read()

	if not ret:
		print('Failed to get Frame')
		quit = True
		break

	cv.imshow('CAM', frame)

	gray = cv.cvtColor(frame, cv.COLOR_BGR2GRAY)

	ret, corners = cv.findChessboardCorners(gray, (9, 6), None)

	key = cv.waitKey(10)
	if ret:
		criteria = (cv.TERM_CRITERIA_EPS + cv.TERM_CRITERIA_MAX_ITER, 30, 0.001)
		corners2 = cv.cornerSubPix(gray, corners, (11,11), (-1, -1), criteria)

		frame = cv.drawChessboardCorners(frame, (9, 6), corners2, ret)

		cv.imshow('calibrated', frame)

		if key == ord('a'):
			objpoints.append(objp)
			imgpoints.append(corners2)
		elif key == ord('c') and len(objpoints) > 0:
			ret, mtx, dist, rvecs, tvecs = cv.calibrateCamera(objpoints, imgpoints, gray.shape[::-1], None, None)
			calibrated = ret
			if ret:
				cv.destroyWindow('calibrated')
				np.savez('calibration.npz', mtx=mtx, dist=dist)
	
	if key == ord('q'):
		quit = True
##############################################################################

cv.destroyAllWindows()
cap.release()