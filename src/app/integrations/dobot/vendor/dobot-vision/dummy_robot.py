# Para quando eu não tiver acesso ao dobot.
class DummyRobot:
	def __init__(self):
		# O robo não começa no (0,0,0)
		self._x = 200
		self._y = -150
		self._z = 0
		self._r = 0
		self._j1 = 0
		self._j2 = 0
		self._j3 = 0
		self._j4 = 0
		self._sucking = False

	def _print_state(self):
		print('Robot State: =====================================')
		print(f'X: {self._x}, Y: {self._y}, Z:{self._z}, R:{self._r}')
		print(f'Sucking: {self._sucking}')
		print('==================================================')

	def pose(self):
		self._print_state()
		return self._x, self._y, self._z, self._r, self._j1, self._j2, self._j3, self._j4

	def move_to(self, x, y, z, r, wait = False):
		self._x = float(x)
		self._y = float(y)
		self._z = float(z)
		self._r = float(r)
		self._print_state()

	def suck(self, enable):
		self._sucking = enable
		self._print_state()

	def wait(self, ms):
		pass

	def is_running(self):
		return False

	def clear_queue(self):
		pass

	def stop(self):
		print("DummyRobot: stop")

	def force_stop(self):
		print("DummyRobot: force_stop")

	def start_queue(self):
		print("DummyRobot: start_queue")

	def close(self):
		pass
