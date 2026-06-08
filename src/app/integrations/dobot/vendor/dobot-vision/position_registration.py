from robot import Robot, interactive_choose_port
from dummy_robot import DummyRobot
import pydobot
from util import str_to_cartesian
import argparse

def reg_pos(robot: Robot):
	label = input('Digite as coordenadas da posição\n> ')
	point = None
	try:
		point = str_to_cartesian(label)
	except:
		print('Formato inválido. Use (x, y)')
		return

	print('Mova o braço do dobot para a posição e pressione enter')
	input()
	robot.register_position(point)

def reg_vert_pos(robot: Robot):
	input('Mova o robô para a posição superior e pressione enter.')
	robot.set_up_pos()
	input('Mova o robô para a posição inferior e pressione enter.')
	robot.set_down_pos()

def goto(robot: Robot):
	direc = input('Digite a direção (up, down ou (x, y))')
	x, y, z, r, _, _, _, _ = robot.pose()
	if direc == 'up':
		robot.move_to(x, y, robot.up_pos, r)
		return
	elif direc == 'down':
		robot.move_to(x, y, robot.down_pos, r)
		return
	
	try:
		pos = str_to_cartesian(direc)

		robot.goto_position(pos, z, r)
	except:
		print('Direção inválida.')


def print_robot_positions(robot: Robot):
	for pos in robot.positions.keys():
		real_pos = robot.positions[pos]
		print(f'({pos[0]}, {pos[1]}) -> ({real_pos[0]}, {real_pos[1]})')

	input('Pressione [Return] para continuar.')

def griderino(robot: Robot):
	w = int(input('Largura da malha\n> '))
	h = int(input('Altura da malha\n> '))

	distx = float(input('Distância em milímetros do centro de uma posição para a próxima (horizontal)\n> '))
	disty = float(input('Distância em milímetros do centro de uma posição para a próxima (vertical)\n> '))

	input('Mova o dobot para a posição (0, 0) e pressione [Return]')

	orix, oriy, _, _, _, _, _, _ = robot.pose()

	for y in range(0, h):
		for x in range(0, w):
			robot.register_position((x, y), (orix - (disty * y), oriy + (distx * x)))

if __name__ == '__main__':
	quit = False
	parser = argparse.ArgumentParser()
	parser.add_argument('--dummy-robot', action='store_true')
	parser.add_argument('--com-port')

	args = parser.parse_args()

	robot = None
	if args.dummy_robot:
		robot = Robot(DummyRobot())
	else:
		com_port = args.com_port
		if com_port == None:
			robot = interactive_choose_port()
		else:
			robot = Robot(pydobot.Dobot(com_port))
			
	robot.load_settings()
	
	while not quit:
		print('Calibração de posições')
		print('1: Registrar nova posição')
		print('2: Registrar posições verticais')
		print('3: Ir para posição')
		print('4: Listar Posições')
		print('5: Gerar malha')
		print('6: Gerar malha de exemplo')
		print('7: Salvar e Sair')
		print('=========================')

		op = int(input('> '))

		if op == 1:
			reg_pos(robot)
		elif op == 2:
			reg_vert_pos(robot)
		elif op == 3:
			goto(robot)
		elif op == 4:
			print_robot_positions(robot)
		elif op == 5:
			griderino(robot)
		elif op == 6:
			print('[ATENÇÃO]: Só use esta opção se você planeja não usar o dobot real.')
			w = int(input('W\n> '))
			h = int(input('H\n> '))

			for y in range(0, h):
				for x in range(0, w):
					robot.move_to(x, y, 0, 0)
					robot.register_position((x, y))
		elif op == 7:
			robot.save_settings()
			quit = True
		else:
			print('Opção inválida')

	robot.close()