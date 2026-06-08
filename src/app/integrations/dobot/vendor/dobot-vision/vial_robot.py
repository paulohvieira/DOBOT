from robot import Robot, interactive_choose_port
from pydobot import Dobot
from dummy_robot import DummyRobot
import time
import threading
from argparse import ArgumentParser
from object_mapper import ObjectMapper
from util import get_undistorted_frame
import cv2 as cv
import numpy as np
from virtual_barrier import VirtualBarrier, interactive_select_barriers
from andon import Andon, AndonState
from pymodbus.client import ModbusTcpClient

running = True

robot = None

stop_begin_event = threading.Event()
stop_end_event = threading.Event()
finished_event = threading.Event()
fire_event = threading.Event()

latest_movement = None

movement_lock = threading.Lock()
stopped = False

def robot_thread():
	global robot, running, stop_begin_event, stop_end_event, latest_movement, movement_lock, stopped
	assert robot is not None

	while running:
		if stop_begin_event.is_set():
			robot.force_stop()
			print('STOPPED.')
			
			stop_end_event.clear()
			stop_begin_event.clear()
			stopped = True

		if stop_end_event.is_set():
			with movement_lock:
				latest_movement = None
			#fire_event.clear()

			#print('Clearing queue...')
			#robot.clear_queue() # Apagar conteúdos da fila
			robot.start_queue() # Continuar com fila.
			
			#print('done. Moving away from camera...')
			#robot.suck(False)   # Desligar sucção
			#x, y, _, r, _, _, _, _ = robot.pose()
			#robot.move_to(x, y, robot.up_pos, r) # Sair da frente da câmera
			
			stop_end_event.clear()
			stopped = False
			print('Done.')

		movement = None

		if fire_event.is_set() and not stopped:
			with movement_lock:
				movement = latest_movement
				latest_movement = None

			if movement is not None and not robot.is_running():
				current_pos = movement['origin']
				target_pos = movement['dest']

				robot.grab_object_at_position(current_pos, 0)
				robot.place_down_object_at_position(target_pos, 0)
				_, _, _, r, _, _, _, _ = robot.pose()
				robot.goto_position((target_pos[0], target_pos[1]), robot.up_pos, r)
			
			if not robot.is_running() and movement is None:
				fire_event.clear()

		time.sleep(0.010)

grid_width = 10
grid_height = 5

def homography_select_points(w, h, cap, mtx, dist) -> tuple[bool, cv.typing.MatLike]:
	def homography_point_select(event, x, y, flags, param):
		if event == cv.EVENT_LBUTTONDOWN:
			param.append([x, y])
			print(f'Added point ({x}, {y}) ({len(param)})')

	imgpoints = []

	hom_mask = np.array([], dtype=np.int8)

	# Pontos na malha
	objpoints = np.array([
		[0      , 0      ],
		[(w - 1), 0      ],
		[(w - 1), (h - 1)],
		[0      , (h - 1)]
	], dtype=np.float32)

	cv.namedWindow('Selecione os quatro pontos da malha')
	cv.setMouseCallback('Selecione os quatro pontos da malha', homography_point_select, imgpoints)

	found_homography = False
	quit = False
	# Atualmente o usuário deve clicar nos pontos de referência na ordem definida em objpoints.
	print('Clique nos quatro pontos da malha')
	while not quit and not found_homography:
		ret, frame = get_undistorted_frame(cap, mtx, dist)

		if not ret:
			found_homography = False
			break

		cv.imshow('Selecione os quatro pontos da malha', frame)
		if len(imgpoints) >= len(objpoints):
			hom_mask, _ = cv.findHomography(np.array(imgpoints, dtype=np.float32), np.array(objpoints, dtype=np.float32))
			found_homography = True
		key = cv.waitKey(10)
		if key == ord('q'):
			found_homography = False
			quit = True

	cv.destroyWindow('Selecione os quatro pontos da malha')
	return found_homography, hom_mask

def vision_thread():
	global running, latest_movement, movement_lock, stop_begin_event, stop_end_event, stopped, mdb_client

	andon = Andon(mdb_client, 1)
	andon.set_state(AndonState.GREEN)
	# Obter imagem
	cap = cv.VideoCapture(0)

	if not cap.isOpened():
		print('Failed to open camera.')
		running = False
		return

	cap.set(cv.CAP_PROP_FRAME_HEIGHT, 1080)
	cap.set(cv.CAP_PROP_FRAME_WIDTH, 1920)

	# Calibração de distorção ####################################################
	# Variáveis resultado da calibração
	mtx = None
	dist = None
	
	try:
		with np.load('calibration.npz') as data:
			print(data)
			mtx = data['mtx']
			dist = data['dist']
	except:
		print ('Calibração não encontrada')
		running = False
		return
	


	hom_mask = None
	try:
		with np.load('homography.npz') as data:
			print(data)
			hom_mask = data['hom_mask']
	except:
		found_homography, hom_mask = homography_select_points(grid_width, grid_height, cap, mtx, dist)

		if not found_homography:
			running = False
			return

		np.savez('homography.npz', hom_mask=hom_mask)

	assert hom_mask is not None
	barrier = VirtualBarrier(breached_timeout=10)

	if not barrier.load_barriers('line1.png', 'line2.png'):
		ret, line1, line2 = interactive_select_barriers(cap, mtx, dist)

		if not ret:
			print('LINHAS FALHARAM')
			running = False
			return
	
		barrier.set_barrier1(line1)
		barrier.set_barrier2(line2)

		barrier.save_barriers('line1.png', 'line2.png')

	detector_params = cv.aruco.DetectorParameters()
	detector_dict = cv.aruco.getPredefinedDictionary(cv.aruco.DICT_5X5_250)
	detector = cv.aruco.ArucoDetector(detector_dict, detector_params)
	obj_mapper = ObjectMapper(grid_width, grid_height)

	state = 0
	target_positions = {
		0: {
			7: (8, 2),
			8: (4, 1),
			11: (2, 0)
		},
		1: {
			7: (0, 2),
			8: (4, 3),
			11: (9,1)
		}
	}

	normal_colour = AndonState.GREEN

	while running:
		ret, frame = get_undistorted_frame(cap, mtx, dist)
		if not ret:
			break
		# Montar mapa
		corners, ids, _ = detector.detectMarkers(frame)
		obj_mapper.map_to_grid(corners, ids, hom_mask)
		
		gray = cv.cvtColor(frame, cv.COLOR_BGR2GRAY)

		gray = cv.GaussianBlur(gray, (5, 5), 0)

		#edges = cv.Canny(gray, 60, 110 )
		_, edges = cv.threshold(gray, 190, 255, cv.THRESH_BINARY)
		#_, edges = cv.threshold(gray, 0, 255, cv.THRESH_BINARY + cv.THRESH_OTSU)
		contours, _ = cv.findContours(edges, cv.RETR_EXTERNAL, cv.CHAIN_APPROX_SIMPLE)

		bh, bw = gray.shape
		barrier.detection_pass(contours, bh, bw)

		if barrier.breached:
			if not stopped:
				stop_begin_event.set()
				andon.set_state(AndonState.RED)
		else:
			if andon.state != normal_colour:
				andon.set_state(normal_colour)
			if stopped:
				stop_end_event.set()

		display = frame.copy()

		display = barrier.draw_barriers(display)

		sh, sw = frame.shape[:2]
		shapes = np.zeros((sh, sw, 3), dtype=np.uint8)
		shapes = cv.drawContours(shapes, contours, -1, (255, 255, 255), thickness=cv.FILLED)
		shapes = barrier.draw_barriers(shapes)

		display = cv.rectangle(display, (0, 0), (display.shape[1], display.shape[0]), (0, 0, 255) if barrier.breached else (0, 255, 0), 5)
		cv.imshow('CAM', cv.aruco.drawDetectedMarkers(display, corners, ids))
		cv.imshow('BARRIER', shapes)

		# Máquina de estado:
		#  Estado 0: Lista de objetos que pertencem a certas posições
		#  Estado 1: Lista de objetos que pertencem a outras posições

		# Para cada objeto
		# Se ele não estiver em sua posição e sua posição for livre, mova-o para a posição
		# Se todos os objetos estiverem em suas posições, espere um tempo e altere para o outro estado

		# Só detectamos tubos se o dobot não estiver ocupado.

		if not fire_event.is_set() and not stopped:
			with movement_lock:
				if latest_movement is None:
					advance_state = True

					none_found = True
					for id in target_positions[state].keys():
						#print(f'Buscando frasco {id}...')

						current_pos = obj_mapper.id_pos(id)
						target_pos = target_positions[state][id]
						if current_pos is None:
							#print(f'frasco {id} não encontrado.')
							continue

						none_found = False
						print(f'frasco {id} encontrado na posição ({current_pos[0]}, {current_pos[1]})')

						if current_pos[0] == target_pos[0] and current_pos[1] == target_pos[1]:
							print(f'O frasco {id} já está na posição correta.')
							continue
							

						print('Verificando se o robô possui as posições cadastradas...')
						if not robot.has_position(current_pos) or not robot.has_position(target_pos):
							print(f'O Robô não tem as coordenadas cadastradas.')
							advance_state = False
							continue

						print(f'Verificando disponibilidade da posição ({target_pos[0]}, {target_pos[1]})...')
						idat = obj_mapper.id_at_pos(target_pos)
						if not (idat is None):
							print(f'O frasco {idat} ocupa a posição do frasco {id}.')
							advance_state = False
							continue

						latest_movement = {
							'origin': current_pos,
							'dest': target_pos
						}
						advance_state = False
						fire_event.set()

						# Movemos algo, então o frame não serve mais
						break

					if none_found:
						normal_colour = AndonState.YELLOW
					else:
						normal_colour = AndonState.GREEN

					if advance_state:
						state = (state + 1) % len(target_positions)

		key = cv.waitKey(10)

		if key == ord('q'):
			running = False
		if key == ord('x'):
			stop_begin_event.set()
		if key == ord('c') and stopped:
			stop_end_event.set()


# Conectar com dobot
parser = ArgumentParser(prog='Vial Robot', description='Move frascos de um lado para o outro.')
parser.add_argument('--dummy-robot', action='store_true')
parser.add_argument('--com-port')

args = parser.parse_args()

if args.dummy_robot:
	robot = Robot(DummyRobot())
else:
	if not (args.com_port is None):
		robot = Robot(Dobot(args.com_port))
	else:
		robot = interactive_choose_port()

# Obter posições
if not robot.load_settings():
	print('O robô não possui posições cadastradas.')
	exit(1)

mdb_client = ModbusTcpClient(host='192.168.15.1', port=502)

r_thread = threading.Thread(target=robot_thread)
v_thread = threading.Thread(target=vision_thread)

r_thread.start()
v_thread.start()

r_thread.join()
v_thread.join()


robot.close()
