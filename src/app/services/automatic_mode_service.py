"""Serviço de controle do modo automático.

Autor:
    Paulo Henrique Vieira de Souza <phsouza@cpqd.com.br>
"""

from enum import StrEnum


class AutomaticModeState(StrEnum):
    """Estados operacionais do modo automático."""

    STOPPED = "stopped"
    RUNNING = "running"
    BARRIER_STOPPED = "barrier_stopped"
    FAULT = "fault"


class AutomaticModeService:
    """Controla o estado inicial do modo automático.

    Esta classe ainda não executa o script legado do modo automático. Ela cria
    uma fronteira estável para a HMI enquanto a lógica de `vial_robot.py` é
    extraída de forma segura.
    """

    def __init__(self):
        """Inicializa o modo automático em estado parado."""
        self._state = AutomaticModeState.STOPPED
        self._last_error = ""

    @property
    def state(self):
        """Retorna o estado atual do modo automático.

        Returns:
            AutomaticModeState: Estado operacional atual.
        """
        return self._state

    @property
    def last_error(self):
        """Retorna a última falha registrada.

        Returns:
            str: Mensagem da última falha, ou texto vazio.
        """
        return self._last_error

    def start(self):
        """Inicia o modo automático.

        Returns:
            bool: `True` quando o modo automático foi iniciado.
        """
        if self._state == AutomaticModeState.BARRIER_STOPPED:
            self._last_error = "Libere a barreira antes de iniciar."
            return False

        self._last_error = ""
        self._state = AutomaticModeState.RUNNING
        return True

    def stop(self):
        """Para o modo automático."""
        self._state = AutomaticModeState.STOPPED
        self._last_error = ""

    def notify_barrier_breached(self):
        """Registra parada causada por acionamento da barreira virtual."""
        self._state = AutomaticModeState.BARRIER_STOPPED
        self._last_error = "Barreira virtual acionada."

    def clear_barrier_stop(self):
        """Libera a parada por barreira virtual e retoma o automático.

        Returns:
            bool: `True` quando a parada por barreira foi liberada.
        """
        if self._state != AutomaticModeState.BARRIER_STOPPED:
            return False

        self._state = AutomaticModeState.RUNNING
        self._last_error = ""
        return True
