import pydobot
from dummy_robot import DummyRobot
from serial.tools import list_ports
import pickle

class Robot:
	def __init__(self, bot: pydobot.Dobot):
		self.dobot = bot
		self.down_pos: float = 0
		self.up_pos: float = 0
		self._sucking: bool = False
		self.positions = {}  # Posições pré-programadas
	
	@property
	def sucking(self):
		return self._sucking

	def pose(self):
		return self.dobot.pose()
	
	def move_to(self, x: float, y: float, z: float, r: float, wait: bool = False):
		return self.dobot.move_to(x, y, z, r, wait=wait)
	
	def suck(self, enable: bool):
		self._sucking = enable
		return self.dobot.suck(enable)

	def set_down_pos(self):
		_, _, z, _, _, _, _, _, = self.pose()
		self.down_pos = z
		return z
	
	def set_up_pos(self):
		_, _, z, _, _, _, _, _, = self.pose()
		self.up_pos = z
		return z
	
	def wait(self, ms: float):
		return self.dobot.wait(ms)

	def grab_object(self, x: float, y: float, r: float, wait = False):
		posx, posy, _, _, _, _, _, _, = self.pose()
		# Move para cima.
		self.move_to(posx, posy, self.up_pos, r, wait=wait)
		# Move para a posição
		self.move_to(x, y, self.up_pos, r, wait=wait)
		# Move para baixo
		self.move_to(x, y, self.down_pos, r, wait=wait)
		# Pega
		self.suck(True)
		self.wait(500)
		# Move para cima
		self.move_to(x, y, self.up_pos, r, wait=wait)
	
	def place_down_object(self, x: float, y: float, r: float, wait = False):
		if not self.sucking:
			return
		
		posx, posy, _, _, _, _, _, _, = self.pose()
		# Move para cima.
		self.move_to(posx, posy, self.up_pos, r, wait=wait)
		# Move para a posição
		self.move_to(x, y, self.up_pos, r, wait=wait)
		# Move para baixo
		self.move_to(x, y, self.down_pos, r, wait=wait)
		# Solta
		self.suck(False)
		# Move para cima
		self.move_to(x, y, self.up_pos, r, wait=wait)


	# Mapeia a posição atual do dobot para uma posição em uma malha
	# gridpos é a posição em uma malha discreta.
	# Exemplo: (0, 0)
	#
    #  +--+--+--+--+--+
	#  |  |  |  |  |  |
    #  +--+--+--+--+--+
	#  |  |  |  |  |  |
    #  +--+--+--+--+--+
	#  |  |  |  |  |  |
	#  +--+--+--+--+--+
	#  |  |  |  |  |  |
    #  +--+--+--+--+--+
	#

	def register_position(self, gridpos: tuple[int, int], realpos: tuple[float, float] | None = None) -> None:
		if realpos is None:
			x, y, _, _, _, _, _, _ = self.pose()
			self.positions[gridpos] = (x, y)
		else:
			self.positions[gridpos] = (realpos[0], realpos[1])
	
	def goto_position(self, pos: tuple[int, int], z: float, r: float, wait = False) -> None:
		x, y = self.positions[pos]		
		self.move_to(x, y, z, r, wait=wait)

	def grab_object_at_position(self, pos: tuple[int, int], r: float, wait = False) -> None:
		x, y = self.positions[pos]
		self.grab_object(x, y, r, wait)
	
	def place_down_object_at_position(self, pos: tuple[int, int], r: float, wait = False) -> None:
		x, y = self.positions[pos]
		
		self.place_down_object(x, y, r, wait)

	def save_settings(self) -> bool:
		settings = {
			"positions": self.positions,
			"up_pos": self.up_pos,
			"down_pos": self.down_pos
		}

		try:
			with open('robot_settings.pickle', 'wb') as fp:
				pickle.dump(settings, fp)
			return True
		except:
			return False
	
	def load_settings(self) -> bool:
		try:
			with open('robot_settings.pickle', 'rb') as fp:
				settings = pickle.load(fp)
				self.positions = settings['positions']
				self.up_pos = settings['up_pos']
				self.down_pos = settings['down_pos']
			return True
		except:
			self.positions = {}
			self.up_pos = 0
			self.down_pos = 0
			return False
	def close(self):
		self.dobot.close()
	
	def has_position(self, pos: tuple[int, int]) -> bool:
		return self.positions.__contains__(pos)
	
	def is_running(self):
		return self.dobot.is_running()
	
	def clear_queue(self):
		return self.dobot.clear_queue()
	
	def stop(self):
		return self.dobot.stop()
	
	def force_stop(self):
		return self.dobot.force_stop()
	def start_queue(self):
		return self.dobot.start_queue()

def interactive_choose_port() -> Robot:
	ports = list_ports.comports()
	print("SELECT VALID PORT")
	for i in range(0, len(ports)):
		print(f"{i}: {ports[i].device}")
	idx = int(input("> "))
	port = ports[idx]

	return Robot(pydobot.Dobot(port=port.device, verbose=False))
