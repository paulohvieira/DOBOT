"""ViewModel de alarmes e eventos da HMI.

Autor:
    Paulo Henrique Vieira de Souza <phsouza@cpqd.com.br>
"""

from datetime import datetime

from PySide6.QtCore import QObject, Property, Signal, Slot


class AlarmViewModel(QObject):
    """Mantém o histórico operacional exibido na tela de alarmes."""

    alarmsChanged = Signal()
    activeCountChanged = Signal()

    def __init__(self, parent=None):
        """Inicializa o histórico de alarmes em memória.

        Args:
            parent: Objeto Qt pai.
        """
        super().__init__(parent)
        self._alarms = []

    @Property("QVariantList", notify=alarmsChanged)
    def alarms(self):
        """Retorna os alarmes e eventos ordenados do mais recente ao mais antigo.

        Returns:
            list[dict]: Eventos formatados para consumo direto pelo QML.
        """
        return self._alarms

    @Property(int, notify=activeCountChanged)
    def activeCount(self):
        """Retorna a quantidade de alarmes ativos.

        Returns:
            int: Total de alarmes ainda ativos.
        """
        return sum(1 for alarm in self._alarms if alarm["active"])

    @Slot()
    def logBarrierBreached(self):
        """Registra acionamento da barreira virtual."""
        self._add_alarm(
            priority="Alta",
            source="Barreira",
            message="Barreira virtual acionada.",
            state="Ativo",
            active=True,
        )

    @Slot()
    def logBarrierReleased(self):
        """Registra liberação automática da barreira virtual."""
        self._clear_active_barrier_alarms()
        self._add_alarm(
            priority="Info",
            source="Barreira",
            message="Barreira virtual liberada automaticamente.",
            state="Normal",
            active=False,
        )

    def _add_alarm(self, priority, source, message, state, active):
        """Adiciona um evento ao histórico em memória."""
        self._alarms.insert(0, {
            "timestamp": self._timestamp(),
            "priority": priority,
            "source": source,
            "message": message,
            "state": state,
            "active": active,
        })
        self._alarms = self._alarms[:100]
        self.alarmsChanged.emit()
        self.activeCountChanged.emit()

    def _clear_active_barrier_alarms(self):
        """Marca alarmes ativos da barreira como liberados."""
        for alarm in self._alarms:
            if alarm["source"] == "Barreira" and alarm["active"]:
                alarm["active"] = False
                alarm["state"] = "Liberado"

    def _timestamp(self):
        """Formata a data e hora local para exibição na HMI."""
        return datetime.now().strftime("%d/%m/%Y %H:%M:%S")
