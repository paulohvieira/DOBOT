import cv2 as cv
import numpy as np

def px_to_grid(px, H) -> tuple[int, int]:
	pts = np.array([[px]], dtype=np.float32)
	transformed = cv.perspectiveTransform(pts, H)
	x, y = transformed[0][0]
	x = int(round(x))
	y = int(round(y))
	return x, y

def get_undistorted_frame(cap: cv.VideoCapture, mtx: cv.typing.MatLike, dist: cv.typing.MatLike) -> tuple[bool, cv.typing.MatLike]:
	ret, frame = cap.read()

	if not ret:
		print('Failed to get Frame')
		return ret, frame

	h, w = frame.shape[:2]

	newcameramtx, roi = cv.getOptimalNewCameraMatrix(mtx, dist, (w, h), 1, (w, h))

	frame = cv.undistort(frame, mtx, dist, None, newcameramtx)

	x, y, w, h = roi

	frame = frame[y:y+h, x:x+w]
	return True, frame

def str_to_cartesian(txt: str) -> tuple[int, int]:
	components = list(map(int, txt.strip('()').split(',')))
	return components[0], components[1]