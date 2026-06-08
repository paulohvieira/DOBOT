"""ViewModel do fluxo de calibração da câmera.

Autor:
    Paulo Henrique Vieira de Souza <phsouza@cpqd.com.br>
"""

from PySide6.QtCore import QObject, Property, Signal, Slot

from app.services.calibration_service import CalibrationError, CalibrationService
from app.services.settings_service import SettingsService


class CalibrationViewModel(QObject):
    """Controla a captura e persistência da calibração de perspectiva."""

    pointCountChanged = Signal()
    pendingPointChanged = Signal()
    statusChanged = Signal()
    calibrationChanged = Signal()

    def __init__(self, settings_service=None, calibration_service=None):
        """Inicializa o ViewModel de calibração.

        Args:
            settings_service: Serviço usado para carregar e salvar o JSON.
            calibration_service: Serviço usado para calcular a homografia.
        """
        super().__init__()
        self._settings_service = settings_service or SettingsService()
        self._calibration_service = calibration_service or CalibrationService()
        self._image_points = []
        self._world_points = []
        self._pending_image_point = None
        self._status_text = "Selecione um ponto na imagem."

    @Property(int, notify=pointCountChanged)
    def pointCount(self):
        """Retorna a quantidade de pontos adicionados."""
        return len(self._image_points)

    @Property(str, notify=pendingPointChanged)
    def pendingPointText(self):
        """Retorna o ponto de imagem aguardando coordenada real."""
        if self._pending_image_point is None:
            return "Nenhum ponto selecionado"

        pixel_x, pixel_y = self._pending_image_point
        return f"Pixel ({pixel_x:.1f}, {pixel_y:.1f})"

    @Property(str, notify=statusChanged)
    def statusText(self):
        """Retorna a mensagem de orientação do fluxo."""
        return self._status_text

    @Property(str, notify=pointCountChanged)
    def pointsSummary(self):
        """Retorna resumo textual dos pontos já capturados."""
        if not self._image_points:
            return "Nenhum ponto adicionado."

        lines = []

        for index, (image_point, world_point) in enumerate(
            zip(self._image_points, self._world_points),
            start=1,
        ):
            lines.append(
                f"{index}. Pixel ({image_point[0]:.1f}, {image_point[1]:.1f}) "
                f"-> Real ({world_point[0]:.2f}, {world_point[1]:.2f})"
            )

        return "\n".join(lines)

    @Property(bool, notify=pointCountChanged)
    def canSave(self):
        """Indica se já existem pontos suficientes para calcular homografia."""
        return len(self._image_points) >= 4

    @Slot(float, float)
    def selectImagePoint(self, pixel_x, pixel_y):
        """Seleciona o ponto em pixel clicado na imagem.

        Args:
            pixel_x: Coordenada X em pixels.
            pixel_y: Coordenada Y em pixels.
        """
        self._pending_image_point = (float(pixel_x), float(pixel_y))
        self.pendingPointChanged.emit()
        self._set_status("Informe a coordenada real desse ponto.")

    @Slot(float, float, result=bool)
    def addCalibrationPoint(self, world_x, world_y):
        """Adiciona um par pixel/coordenada real ao fluxo.

        Args:
            world_x: Coordenada real X no plano do Dobot.
            world_y: Coordenada real Y no plano do Dobot.

        Returns:
            bool: `True` quando o ponto foi adicionado.
        """
        if self._pending_image_point is None:
            self._set_status("Selecione um ponto na imagem primeiro.")
            return False

        if len(self._image_points) >= 4:
            self._set_status("A calibração já possui quatro pontos.")
            return False

        self._image_points.append(self._pending_image_point)
        self._world_points.append((float(world_x), float(world_y)))
        self._pending_image_point = None
        self.pendingPointChanged.emit()
        self.pointCountChanged.emit()

        if self.canSave:
            self._set_status("Quatro pontos adicionados. Salve a calibração.")
        else:
            self._set_status("Ponto adicionado. Selecione o próximo ponto.")

        return True

    @Slot(result=bool)
    def saveCalibration(self):
        """Calcula e salva a homografia no arquivo de configurações.

        Returns:
            bool: `True` quando a calibração foi salva.
        """
        try:
            homography = self._calibration_service.calculate_homography(
                self._image_points,
                self._world_points,
            )
        except CalibrationError as error:
            self._set_status(str(error))
            return False

        settings = self._settings_service.load()
        settings.camera_calibration.enabled = True
        settings.camera_calibration.image_points = self._serialize_points(
            self._image_points
        )
        settings.camera_calibration.world_points = self._serialize_points(
            self._world_points
        )
        settings.camera_calibration.homography = homography
        self._settings_service.save(settings)
        self.calibrationChanged.emit()
        self._set_status("Calibração salva.")
        return True

    @Slot()
    def reset(self):
        """Limpa os pontos capturados no fluxo atual."""
        self._image_points = []
        self._world_points = []
        self._pending_image_point = None
        self.pendingPointChanged.emit()
        self.pointCountChanged.emit()
        self._set_status("Selecione um ponto na imagem.")

    def _serialize_points(self, points):
        """Converte tuplas de pontos para listas serializáveis em JSON.

        Args:
            points: Sequência de pontos `(x, y)`.

        Returns:
            list: Lista de listas `[x, y]`.
        """
        return [[float(point[0]), float(point[1])] for point in points]

    def _set_status(self, status_text):
        """Atualiza a mensagem de status do fluxo."""
        if self._status_text == status_text:
            return

        self._status_text = status_text
        self.statusChanged.emit()
