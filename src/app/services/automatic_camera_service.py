"""Serviço de câmera OpenCV para a visualização do modo automático.

Autor:
    Paulo Henrique Vieira de Souza <phsouza@cpqd.com.br>
"""

from pathlib import Path

import cv2 as cv
import numpy as np
from PySide6.QtGui import QImage


class AutomaticCameraService:
    """Captura frames da câmera e desenha a barreira virtual."""

    def __init__(self, vendor_dir=None, camera_index=0):
        """Inicializa o serviço de câmera do modo automático.

        Args:
            vendor_dir: Diretório que contém os arquivos `line1.png` e
                `line2.png` usados pelo código legado.
            camera_index: Índice da câmera OpenCV.
        """
        self._vendor_dir = (
            Path(vendor_dir) if vendor_dir else self._default_vendor_dir()
        )
        self._camera_index = camera_index
        self._capture = None
        self._barrier_one = self._load_mask("line1.png")
        self._barrier_two = self._load_mask("line2.png")
        self._barrier_breached = False
        self._last_error = ""

    @property
    def barrier_breached(self):
        """Informa se a barreira virtual foi acionada no último frame.

        Returns:
            bool: `True` quando há interseção nas duas linhas da barreira.
        """
        return self._barrier_breached

    @property
    def last_error(self):
        """Retorna a última falha da câmera OpenCV.

        Returns:
            str: Mensagem da última falha, ou texto vazio.
        """
        return self._last_error

    def start(self):
        """Abre a câmera OpenCV.

        Returns:
            bool: `True` quando a câmera foi aberta.
        """
        if self._capture and self._capture.isOpened():
            return True

        self._capture = cv.VideoCapture(self._camera_index)

        if not self._capture.isOpened():
            self._last_error = "Não foi possível abrir a câmera OpenCV."
            self._capture = None
            return False

        self._last_error = ""
        self._capture.set(cv.CAP_PROP_FRAME_WIDTH, 1280)
        self._capture.set(cv.CAP_PROP_FRAME_HEIGHT, 720)
        return True

    def stop(self):
        """Fecha a câmera OpenCV."""
        if self._capture:
            self._capture.release()

        self._capture = None
        self._barrier_breached = False

    def read_frame(self):
        """Captura e processa um frame para exibição no QML.

        Returns:
            QImage: Frame anotado, ou imagem vazia quando a captura falha.
        """
        if not self.start():
            return QImage()

        success, frame = self._capture.read()

        if not success:
            self._last_error = "A câmera não retornou imagem."
            return QImage()

        processed_frame = self._process_frame(frame)
        return self._to_qimage(processed_frame)

    def _process_frame(self, frame):
        """Desenha barreiras e atualiza o estado de acionamento."""
        barrier_one = self._mask_for_frame(self._barrier_one, frame)
        barrier_two = self._mask_for_frame(self._barrier_two, frame)
        object_mask = self._detect_bright_objects(frame)

        self._barrier_breached = bool(
            barrier_one is not None
            and barrier_two is not None
            and np.any(np.logical_and(object_mask, barrier_one))
            and np.any(np.logical_and(object_mask, barrier_two))
        )

        display = frame.copy()
        self._draw_mask(display, barrier_one, (0, 0, 255))
        self._draw_mask(display, barrier_two, (0, 209, 255))

        border_color = (0, 0, 255) if self._barrier_breached else (0, 214, 175)
        cv.rectangle(
            display,
            (0, 0),
            (display.shape[1] - 1, display.shape[0] - 1),
            border_color,
            6,
        )
        return display

    def _detect_bright_objects(self, frame):
        """Detecta objetos claros usando a mesma ideia do legado."""
        gray = cv.cvtColor(frame, cv.COLOR_BGR2GRAY)
        gray = cv.GaussianBlur(gray, (5, 5), 0)
        _, threshold = cv.threshold(gray, 190, 255, cv.THRESH_BINARY)
        return threshold > 0

    def _mask_for_frame(self, mask, frame):
        """Ajusta uma máscara salva para o tamanho do frame atual."""
        if mask is None:
            return None

        frame_height, frame_width = frame.shape[:2]

        if mask.shape == (frame_height, frame_width):
            return mask > 0

        resized = cv.resize(
            mask,
            (frame_width, frame_height),
            interpolation=cv.INTER_NEAREST,
        )
        return resized > 0

    def _draw_mask(self, frame, mask, color):
        """Desenha uma máscara colorida com transparência no frame."""
        if mask is None:
            return

        overlay = frame.copy()
        overlay[mask] = color
        cv.addWeighted(overlay, 0.35, frame, 0.65, 0, frame)

    def _load_mask(self, file_name):
        """Carrega uma máscara de barreira do diretório legado."""
        mask_path = self._vendor_dir / file_name

        if not mask_path.exists():
            return None

        return cv.imread(str(mask_path), cv.IMREAD_GRAYSCALE)

    def _to_qimage(self, frame):
        """Converte um frame BGR do OpenCV para `QImage`."""
        rgb_frame = cv.cvtColor(frame, cv.COLOR_BGR2RGB)
        height, width, channels = rgb_frame.shape
        bytes_per_line = channels * width
        image = QImage(
            rgb_frame.data,
            width,
            height,
            bytes_per_line,
            QImage.Format.Format_RGB888,
        )
        return image.copy()

    def _default_vendor_dir(self):
        """Resolve o diretório do código legado do modo automático."""
        return (
            Path(__file__).resolve().parents[1]
            / "integrations"
            / "dobot"
            / "vendor"
            / "dobot-vision"
        )
