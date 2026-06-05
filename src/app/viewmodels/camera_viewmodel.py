from PySide6.QtCore import QObject, Property, Signal, Slot
from PySide6.QtMultimedia import QMediaDevices


class CameraViewModel(QObject):
    cameraConnectedChanged = Signal()

    def __init__(self):
        super().__init__()
        self._camera_connected = False
        self._media_devices = QMediaDevices()

        self._media_devices.videoInputsChanged.connect(
            self.refreshCameraStatus
        )

        self.refreshCameraStatus()

    @Property(bool, notify=cameraConnectedChanged)
    def cameraConnected(self):
        return self._camera_connected

    @Slot()
    def refreshCameraStatus(self):
        cameras = self._media_devices.videoInputs()
        camera_connected = len(cameras) > 0

        if self._camera_connected == camera_connected:
            return

        self._camera_connected = camera_connected
        self.cameraConnectedChanged.emit()