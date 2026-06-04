from PySide6.QtCore import QObject, Property, Signal, Slot


class RobotViewModel(QObject):
    connectedChanged = Signal()
    statusTextChanged = Signal()

    def __init__(self, robot_service):
        super().__init__()
        self._robot_service = robot_service
        self._status_text = "Desconectado"

    @Property(bool, notify=connectedChanged)
    def connected(self):
        return self._robot_service.connected

    @Property(str, notify=statusTextChanged)
    def statusText(self):
        return self._status_text

    @Slot()
    def connectRobot(self):
        self._robot_service.connect()
        self._set_status_text("Conectado")
        self.connectedChanged.emit()

    @Slot()
    def disconnectRobot(self):
        self._robot_service.disconnect()
        self._set_status_text("Desconectado")
        self.connectedChanged.emit()

    @Slot()
    def toggleConnection(self):
        if self.connected:
            self.disconnectRobot()
        else:
            self.connectRobot()

    def _set_status_text(self, status_text):
        if self._status_text == status_text:
            return

        self._status_text = status_text
        self.statusTextChanged.emit()
