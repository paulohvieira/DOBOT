import cv2 as cv
import numpy as np
from time import time
from typing import Sequence
from util import get_undistorted_frame

class VirtualBarrier:
	def __init__(self, barrier1: cv.typing.MatLike | None = None, barrier2: cv.typing.MatLike | None = None, breached_timeout: float = 10):
		self._barrier1 = barrier1
		self._barrier2 = barrier2
		self.breached_timeout = breached_timeout
		self._breached = False
		self._breached_time = 0
	
	@property
	def breached(self) -> bool:
		if self._breached:
			if self.get_remaining_timeout() == 0:
				self._breached = False
				print('CLEARED')
		return self._breached

	def set_barrier1(self, barrier: cv.typing.MatLike) -> None:
		self._barrier1 = barrier
	
	def set_barrier2(self, barrier: cv.typing.MatLike) -> None:
		self._barrier2 = barrier

	def save_barriers(self, path1: str, path2: str) -> None:
		cv.imwrite(path1, self._barrier1)
		cv.imwrite(path2, self._barrier2)
	
	def load_barriers(self, path1: str, path2: str) -> bool:
		b1 = cv.imread(path1, cv.IMREAD_GRAYSCALE)
		b2 = cv.imread(path2, cv.IMREAD_GRAYSCALE)
		
		if b1 is not None and b2 is not None:
			self._barrier1 = b1
			self._barrier2 = b2
			return True
		return False
	
	def detection_pass(self, contours: Sequence[cv.typing.MatLike], h: int, w: int) -> None:
		barrier1 = self._barrier_for_size(self._barrier1, h, w)
		barrier2 = self._barrier_for_size(self._barrier2, h, w)

		if barrier1 is None or barrier2 is None:
			return

		for cnt in contours:
			mask = np.zeros((h, w), dtype=np.uint8)

			cv.drawContours(mask, [cnt], -1, 255, thickness= cv.FILLED)

			intersect_1 = np.any(cv.bitwise_and(mask, barrier1))
			intersect_2 = np.any(cv.bitwise_and(mask, barrier2))
			if intersect_1 and intersect_2:
				self._breached = True
				self._breached_time = time()
				print('HIT')
				break

	def get_remaining_timeout(self) -> float:
		"""Retorna o número de segundos até a flag de breached for liberada."""
		if not self._breached:
			return 0
		
		timeout = self.breached_timeout - (time() - self._breached_time)
		
		if timeout <= 0:
			return 0
		
		return timeout

	def draw_barriers(self, frame: cv.typing.MatLike) -> cv.typing.MatLike:
		display = frame.copy()
		h, w = display.shape[:2]
		barrier1 = self._barrier_for_size(self._barrier1, h, w)
		barrier2 = self._barrier_for_size(self._barrier2, h, w)

		if barrier1 is not None:
			display[barrier1 > 0] = (0,0,255)   # Barreira vermelha

		if barrier2 is not None:
			display[barrier2 > 0] = (0,255,255) # Barreira amarela
	
		return display

	def _barrier_for_size(self, barrier: cv.typing.MatLike | None, h: int, w: int) -> cv.typing.MatLike | None:
		if barrier is None:
			return None

		if barrier.shape == (h, w):
			return barrier

		return cv.resize(barrier, (w, h), interpolation=cv.INTER_NEAREST)
	
def interactive_select_barriers(cap: cv.VideoCapture, mtx: cv.typing.MatLike, dist: cv.typing.MatLike) -> tuple[bool, cv.typing.MatLike, cv.typing.MatLike]:
	"""Permite que o usuário desenhe as duas barreiras selecionando pontos na imagem.
	
	NOTE: **bloqueia a thread.**"""
	def point_select(event, x, y, flags, param):
		if event == cv.EVENT_LBUTTONDOWN:
			param.append([x, y])
			print(f'Added point ({x}, {y})')

	line1points = []
	line2points = []

	cv.namedWindow('Selecione os pontos da linha')
	cv.setMouseCallback('Selecione os pontos da linha', point_select, line1points)

	drew_line1 = False
	drew_line2 = False
	quit = False

	ret, temp_frame  = get_undistorted_frame(cap, mtx, dist)

	if not ret:
		quit = True

	h, w = temp_frame.shape[:2]

	line1 = np.zeros((h, w), dtype=np.uint8)
	line2 = np.zeros((h, w), dtype=np.uint8)

	# Atualmente o usuário deve clicar nos pontos de referência na ordem definida em objpoints.
	print('Clique nos pontos da linha')
	while not quit and not (drew_line1 and drew_line2):
		ret, frame = get_undistorted_frame(cap, mtx, dist)

		if not ret:
			drew_line1 = False
			drew_line2 = False
			break

		display = frame.copy()

		# Line1
		if len(line1points) == 1:
			display = cv.circle(display, line1points[0], 1, (0, 0, 255), -1)
		
		elif len(line1points) >= 2:
			pts = np.array(line1points, np.int32)
			display = cv.polylines(display, [pts], False, (0, 0, 255), 2)
		
		# Line2
		if len(line2points) == 1:
			display = cv.circle(display, line2points[0], 1, (0, 255, 255), -1)
		
		elif len(line2points) >= 2:
			pts = np.array(line2points, np.int32)
			display = cv.polylines(display, [pts], False, (0, 255, 255), 2)

		cv.imshow('Selecione os pontos da linha', display)

		key = cv.waitKey(10)
		if key == ord('q'):
			drew_line2 = False
			drew_line1 = False
			quit = True
		elif key == ord('d'):
			if not drew_line1:
				if len(line1points) > 1:
					pts = np.array(line1points, np.int32)
					line1 = cv.polylines(line1, [pts], False, 255, 2)
					drew_line1 = True
					cv.setMouseCallback('Selecione os pontos da linha', point_select, line2points)
					print('LINHA2')
			else:
				if len(line2points) > 1:
					pts = np.array(line2points, np.int32)
					line2 = cv.polylines(line2, [pts], False, 255, 2)
					drew_line2 = True


	cv.destroyWindow('Selecione os pontos da linha')
	return (drew_line1 and drew_line2), line1, line2
