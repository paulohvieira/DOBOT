"""Contrato de comunicação com o Dobot Magician.

Autor:
    Paulo Henrique Vieira de Souza <phsouza@cpqd.com.br>
"""

from abc import ABC, abstractmethod


class DobotPort(ABC):
    """Define a interface mínima usada pela aplicação para controlar o Dobot."""

    @property
    @abstractmethod
    def connected(self):
        """Indica se o Dobot está conectado.

        Returns:
            bool: `True` quando existe conexão ativa.
        """

    @abstractmethod
    def connect(self):
        """Conecta ao Dobot."""

    @abstractmethod
    def disconnect(self):
        """Desconecta do Dobot."""

    @abstractmethod
    def get_position(self):
        """Retorna a posição cartesiana atual.

        Returns:
            tuple: Coordenadas `(x, y, z, r)`.
        """

    @abstractmethod
    def move_to(self, x, y, z, r=0.0, wait=False):
        """Move o Dobot para a coordenada informada.

        Args:
            x: Coordenada X.
            y: Coordenada Y.
            z: Coordenada Z.
            r: Rotação da ferramenta.
            wait: Quando `True`, aguarda o término do movimento.
        """