"""Serviço simulado para desenvolvimento sem o Dobot real.

Autor:
    Paulo Henrique Vieira de Souza <phsouza@cpqd.com.br>
"""


class MockDobotService:
    """Simula o serviço do Dobot enquanto o controlador real não está disponível."""

    def __init__(self):
        self._connected = False

    @property
    def connected(self):
        return self._connected

    def connect(self):
        self._connected = True

    def disconnect(self):
        self._connected = False
