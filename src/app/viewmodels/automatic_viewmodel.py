"""ViewModel da tela de modo automático.

Autor:
    Paulo Henrique Vieira de Souza <phsouza@cpqd.com.br>
"""

from PySide6.QtCore import QObject, Property, Signal, Slot

from app.services.automatic_mode_service import AutomaticModeState


class AutomaticViewModel(QObject):
    """Expõe o modo automático para a interface QML."""

    stateChanged = Signal()
    messageChanged = Signal()

    def __init__(self, automatic_mode_service):
        """Inicializa o ViewModel do modo automático.

        Args:
            automatic_mode_service: Serviço responsável pelo estado automático.
        """
        super().__init__()
        self._automatic_mode_service = automatic_mode_service

    @Property(str, notify=stateChanged)
    def state(self):
        """Retorna o estado atual do modo automático.

        Returns:
            str: Estado atual serializado para o QML.
        """
        return self._automatic_mode_service.state.value

    @Property(str, notify=stateChanged)
    def stateText(self):
        """Retorna o texto operacional do estado atual.

        Returns:
            str: Texto curto para exibição na HMI.
        """
        labels = {
            AutomaticModeState.STOPPED: "Parado",
            AutomaticModeState.RUNNING: "Em execução",
            AutomaticModeState.BARRIER_STOPPED: "Parado por barreira",
            AutomaticModeState.FAULT: "Falha",
        }

        return labels.get(self._automatic_mode_service.state, "Indefinido")

    @Property(str, notify=messageChanged)
    def message(self):
        """Retorna a mensagem operacional do modo automático.

        Returns:
            str: Mensagem de falha ou orientação.
        """
        return self._automatic_mode_service.last_error

    @Slot(result=bool)
    def start(self):
        """Inicia o modo automático.

        Returns:
            bool: `True` quando o modo automático foi iniciado.
        """
        started = self._automatic_mode_service.start()
        self.stateChanged.emit()
        self.messageChanged.emit()
        return started

    @Slot()
    def stop(self):
        """Para o modo automático."""
        self._automatic_mode_service.stop()
        self.stateChanged.emit()
        self.messageChanged.emit()

    @Slot()
    def notifyBarrierBreached(self):
        """Registra acionamento da barreira virtual."""
        self._automatic_mode_service.notify_barrier_breached()
        self.stateChanged.emit()
        self.messageChanged.emit()

    @Slot(result=bool)
    def clearBarrierStop(self):
        """Libera parada por barreira virtual.

        Returns:
            bool: `True` quando a parada foi liberada.
        """
        cleared = self._automatic_mode_service.clear_barrier_stop()
        self.stateChanged.emit()
        self.messageChanged.emit()
        return cleared
