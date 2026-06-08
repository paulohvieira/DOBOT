import cv2 as cv
import numpy as np
from dummy_robot import DummyRobot
from robot import Robot, interactive_choose_port
from util import px_to_grid, get_undistorted_frame, str_to_cartesian
from position_registration import reg_pos
from object_mapper import ObjectMapper

# Conexão com o robô ##########################################################
use_dobot = True
robot = None
if use_dobot:
	robot = interactive_choose_port()
else:
	robot = Robot(DummyRobot())
##############################################################################

# Calibração de posições #####################################################
quit = False
set_positions = False

if robot.load_settings():
	set_positions = True


while not quit and not set_positions:
	print('Calibração de posições')
	print('1: registrar nova posição')
	print('2: Pronto')
	print('3: Sair')
	print('=========================')

	op = int(input('> '))

	if op == 1:
		reg_pos(robot)
	elif op == 2:
		set_positions = True
	elif op == 3:
		quit = True
	else:
		print('Opção inválida')
##############################################################################

# Captura de vídeo ###########################################################
cap = cv.VideoCapture(0)

if not cap.isOpened():
	print('Failed to open camera.')
	exit(1)

cap.set(cv.CAP_PROP_FRAME_HEIGHT, 1080)
cap.set(cv.CAP_PROP_FRAME_WIDTH, 1920)
exposure = cap.get(cv.CAP_PROP_EXPOSURE)

def set_exposure(cap: cv.VideoCapture, value: float):
	ret = cap.set(cv.CAP_PROP_EXPOSURE, value)

	if ret:
		print(f'Set exposure to {value}.')
	else:
		print('Failed to set exposure.')
##############################################################################

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
	quit = True

##############################################################################

# Homography #################################################################
found_homography = False

# Pontos na imagem
imgpoints = []

def homography_point_select(event, x, y, flags, param):
	global imgpoints
	if event == cv.EVENT_LBUTTONDOWN:
		print(f'Added point ({x}, {y})')
		imgpoints.append([x, y])

grid_width = 10
grid_height = 5

def homography_select_points() -> tuple[bool, cv.typing.MatLike]:
	global imgpoints, grid_height, grid_width

	imgpoints.clear()

	hom_mask = np.array([], dtype=np.int8)

	# Pontos na malha
	objpoints = np.array([
		[0, 0],       
		[(grid_width - 1), 0],     
		[(grid_width - 1), (grid_height - 1)],    
		[0, (grid_height - 1)]
	], dtype=np.float32)

	cv.namedWindow('Selecione os quatro pontos da malha')
	cv.setMouseCallback('Selecione os quatro pontos da malha', homography_point_select)

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

found_homography, hom_mask = homography_select_points()
##############################################################################

robot_z = 0

def mouse_click(event, x, y, flags, param):
	global exposure, robot, hom_mask, found_homography
	if event == cv.EVENT_LBUTTONDOWN:
		if found_homography:
			gridx, gridy = px_to_grid((x, y), hom_mask)
			print(f'Grid: ({gridx}, {gridy})')
	elif event == cv.EVENT_RBUTTONDOWN:
		if found_homography:
			pos = px_to_grid((x, y), hom_mask)
			try:
				robot.goto_position(pos, robot.up_pos, 0)
			except:
				print('Falha ao mover o robô. A posição foi cadastrada?')
	elif event == cv.EVENT_MBUTTONDOWN:
		if found_homography:
			pos = px_to_grid((x, y), hom_mask)
			try:
				if not robot.sucking:
					robot.grab_object_at_position(pos, 0)
				else:
					robot.place_down_object_at_position(pos, 0)
			except:
				print('Falha ao mover o robô. A posição foi cadastrada?')
	elif event == cv.EVENT_MOUSEWHEEL:
		if flags > 0:
			exposure += 0.1
		else:
			exposure -= 0.1
		set_exposure(cap, exposure)

cv.namedWindow('CAM')
cv.setMouseCallback('CAM', mouse_click)

detector_params = cv.aruco.DetectorParameters()
detector_dict = cv.aruco.getPredefinedDictionary(cv.aruco.DICT_5X5_250)
detector = cv.aruco.ArucoDetector(detector_dict, detector_params)
object_mapper = ObjectMapper(grid_width, grid_height)


while not quit:
	ret, frame = get_undistorted_frame(cap, mtx, dist)

	if not ret:
		print('Failed to get Frame')
		break

	#------------------------------------------------------------------------------

	neoframe = frame.copy()
	if found_homography:
		corners, ids, _ = detector.detectMarkers(neoframe)
		#grid = make_object_grid(grid, detector, frame)
		neoframe = cv.aruco.drawDetectedMarkers(neoframe, corners, ids)
	cv.imshow('CAM', neoframe)

	#------------------------------------------------------------------------------
	key = cv.waitKey(10)
	
	if key == ord('q'):
		quit = True
	elif key == ord('j'):
		x, y, robot_z, _, _, _, _, _ = robot.pose()
		robot_z -= 5
		robot.move_to(x, y, robot_z, 0)
	elif key == ord('k'):
		x, y, robot_z, _, _, _, _, _ = robot.pose()
		robot_z += 5
		robot.move_to(x, y, robot_z, 0)
	elif key == ord('s'):
		robot.suck(not robot.sucking)
	elif key == ord('d'):
		z = robot.set_down_pos()
		robot_z = z
		print(f'set down pos {z}')
	elif key == ord('e'):
		z = robot.set_up_pos()
		robot_z = z
		print(f'set up pos {z}')
	elif key == ord('r'):
		reg_pos(robot)
	elif key == ord('g'):
		pos = input('> ')

		try:
			pos = str_to_cartesian(pos)
			if robot.positions.__contains__(pos):
				robot.goto_position(pos, robot.up_pos, 0)
		except:
			print('Posição inválida.')
	elif key == ord('m'):
		orig = input('De\n> ')
		dest = input('Para\n> ')

		try:
			orig = str_to_cartesian(orig)
			dest = str_to_cartesian(dest)
			robot.grab_object_at_position(orig, 0)
			robot.wait(1000)
			robot.place_down_object_at_position(dest, 0)
		except:
			pass
	elif key == ord('w'):
		if not robot.save_settings():
			print('Não foi possível salvar')
	elif key == ord('o'):
		x = float(input('X\n> '))
		y = float(input('Y\n> '))
		z = float(input('Z\n> '))
		robot.move_to(x, y, z, 0)
	elif key == ord('h'):
		found_homography, hom_mask = homography_select_points()
	elif key == ord('c'):
		neoframe = frame.copy()
		corners, ids, _ = detector.detectMarkers(neoframe)
		object_mapper.map_to_grid(corners, ids, hom_mask)
		print(object_mapper.grid)
		print(object_mapper.id_at_pos((3, 1)))
		print(object_mapper.id_pos(2))
		print(object_mapper.id_at_pos((4, 4)))



cv.destroyAllWindows()