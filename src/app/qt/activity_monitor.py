"""Monitor global de atividade da interface Qt.

Autor:
    Paulo Henrique Vieira de Souza <phsouza@cpqd.com.br>
"""

from PySide6.QtCore import QObject, QEvent, Signal


class ActivityMonitor(QObject):
    """Emite sinal quando o usuário interage com a aplicação."""

    activityDetected = Signal()

    def __init__(self, parent=None):
        """Inicializa o monitor global de eventos.

        Args:
            parent: Objeto Qt pai.
        """
        super().__init__(parent)
        self._activity_events = {
            QEvent.Type.KeyPress,
            QEvent.Type.MouseButtonPress,
            QEvent.Type.TouchBegin,
            QEvent.Type.Wheel,
        }

    def eventFilter(self, watched, event):
        """Intercepta eventos globais sem bloquear a aplicação.

        Args:
            watched: Objeto observado pelo Qt.
            event: Evento recebido pela aplicação.

        Returns:
            bool: Sempre `False` para permitir o fluxo normal do evento.
        """
        if event.type() in self._activity_events:
            self.activityDetected.emit()

        return False
