from typing import Sequence

import cv2 as cv
import time
from util import px_to_grid

class ObjectMapper():
	def __init__(self, w: int, h: int):
		self.w = w
		self.h = h
		self.grid = {}

	# Formato da malha
	# {
	#    (x, y): {id, last_seen}
	# }
	# last_seen é o instante que o objeto foi visto pela última vez.
	# A detecção de marcadores não é perfeita e costuma piscar.
	# Então só considero que um objeto sumiu se desaparecer por x segundos.
	def map_to_grid(self, corners: Sequence[cv.typing.MatLike], ids: cv.typing.MatLike, H: cv.typing.MatLike):
		self.trim_stale_ids(2)

		for i, marker in enumerate(corners):
			c1, c2, c3, c4 = marker[0]
			# Calcula o centroide do marcador.
			cx = int((c1[0] + c2[0] + c3[0] + c4[0]) / 4.0)
			cy = int((c1[1] + c2[1] + c3[1] + c4[1]) / 4.0)

			gridpos = px_to_grid((cx, cy), H)
			if gridpos[0] >= 0 and gridpos[0] < self.w and gridpos[1] >= 0 and gridpos[1] < self.h:
				self.grid[gridpos] = {'id': int(ids[i][0]), 'last_seen': time.time()}
	
	def clear_grid(self):
		self.grid = {}
	
	def trim_stale_ids(self, seconds: float):
		now = time.time()

		keys_to_delete = []
		for key in self.grid:
			if now - self.grid[key]['last_seen'] > seconds:
				keys_to_delete.append(key)
		
		for key in keys_to_delete:
			self.grid.pop(key, None)
	
	def id_at_pos(self, point: tuple[int, int]) -> int | None:
		"""Retorna o id na posição especificada. None se a posição estiver vazia."""
		if not self.grid.__contains__(point):
			return None
		
		return self.grid[point]['id']

	def id_pos(self, id: int) -> tuple[int, int] | None:
		"""Retorna a posição do id especificado. None se o id não foi encontrado."""
		for key in self.grid.keys():
			value = self.grid[key]
			if value['id'] == id:
				return key
		
		return None

	

