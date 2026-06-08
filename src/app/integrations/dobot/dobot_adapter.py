"""Adapter para uso do Dobot real via biblioteca pydobot vendorizada.

Autor:
    Paulo Henrique Vieira de Souza <phsouza@cpqd.com.br>
"""

from serial.tools import list_ports

from app.integrations.dobot.vendor.pydobot.pydobot import Dobot
from app.ports.dobot_port import DobotPort


class DobotAdapter(DobotPort):
    """Adapta a biblioteca pydobot ao contrato usado pela aplicação."""

    def __init__(self, port=None, verbose=False):
        """Inicializa o adapter do Dobot.

        Args:
            port: Porta serial do Dobot. Quando `None`, tenta detectar a
                primeira porta disponível.
            verbose: Habilita logs da biblioteca pydobot.
        """
        self._port = port
        self._verbose = verbose
        self._device = None

    @property
    def connected(self):
        """Indica se o Dobot está conectado.

        Returns:
            bool: `True` quando o dispositivo foi inicializado.
        """
        return self._device is not None

    def connect(self):
        """Conecta ao Dobot."""
        if self.connected:
            return

        port = self._port or self._detect_port()
        self._device = Dobot(port=port, verbose=self._verbose)

    def disconnect(self):
        """Desconecta do Dobot."""
        if not self.connected:
            return

        self._device.close()
        self._device = None

    def get_position(self):
        """Retorna a posição cartesiana atual.

        Returns:
            tuple: Coordenadas `(x, y, z, r)`.
        """
        self._ensure_connected()
        x, y, z, r, *_ = self._device.pose()

        return x, y, z, r

    def move_to(self, x, y, z, r=0.0, wait=False):
        """Move o Dobot para a coordenada informada.

        Args:
            x: Coordenada X.
            y: Coordenada Y.
            z: Coordenada Z.
            r: Rotação da ferramenta.
            wait: Quando `True`, aguarda o término do movimento.
        """
        self._ensure_connected()
        self._device.move_to(x, y, z, r, wait=wait)

    def _detect_port(self):
        """Detecta a primeira porta serial disponível.

        Returns:
            str: Nome da porta serial.

        Raises:
            RuntimeError: Quando nenhuma porta serial é encontrada.
        """
        ports = list_ports.comports()

        if not ports:
            raise RuntimeError("Nenhuma porta serial encontrada para o Dobot.")

        return ports[0].device

    def _ensure_connected(self):
        """Garante que o Dobot esteja conectado antes de enviar comandos.

        Raises:
            RuntimeError: Quando o Dobot ainda não está conectado.
        """
        if not self.connected:
            raise RuntimeError("Dobot não conectado.")