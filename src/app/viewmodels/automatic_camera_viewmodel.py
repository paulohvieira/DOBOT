"""ViewModel da câmera OpenCV do modo automático.

Autor:
    Paulo Henrique Vieira de Souza <phsouza@cpqd.com.br>
"""

import math
import time

from PySide6.QtCore import QObject, Property, QTimer, Signal, Slot
from PySide6.QtGui import QImage


DEFAULT_BARRIER_RELEASE_TIMEOUT_SECONDS = 10
DEFAULT_RECONNECT_INTERVAL_MS = 1000


class AutomaticCameraViewModel(QObject):
    """Expõe frames OpenCV processados para a interface QML."""

    frameRevisionChanged = Signal()
    runningChanged = Signal()
    barrierBreachedChanged = Signal()
    barrierReleaseCountdownChanged = Signal()
    statusTextChanged = Signal()

    def __init__(
        self,
        automatic_camera_service,
        barrier_release_timeout_seconds=DEFAULT_BARRIER_RELEASE_TIMEOUT_SECONDS,
        parent=None,
    ):
        """Inicializa o ViewModel da câmera automática.

        Args:
            automatic_camera_service: Serviço responsável pela captura OpenCV.
            barrier_release_timeout_seconds: Tempo sem acionamento necessário
                para liberar a barreira automaticamente.
            parent: Objeto Qt pai.
        """
        super().__init__(parent)
        self._automatic_camera_service = automatic_camera_service
        self._barrier_release_timeout_seconds = barrier_release_timeout_seconds
        self._barrier_release_deadline = None
        self._barrier_release_countdown = 0
        self._frame_revision = 0
        self._running = False
        self._preview_requested = False
        self._barrier_breached = False
        self._status_text = "Câmera desconectada."
        self._current_frame = QImage()
        self._timer = QTimer(self)
        self._timer.setInterval(66)
        self._timer.timeout.connect(self._refresh_frame)
        self._reconnect_timer = QTimer(self)
        self._reconnect_timer.setInterval(DEFAULT_RECONNECT_INTERVAL_MS)
        self._reconnect_timer.timeout.connect(self._try_reconnect)

    @Property(int, notify=frameRevisionChanged)
    def frameRevision(self):
        """Retorna a versão do frame atual.

        Returns:
            int: Contador usado pelo QML para recarregar a imagem.
        """
        return self._frame_revision

    @Property(bool, notify=runningChanged)
    def running(self):
        """Informa se a captura OpenCV está ativa.

        Returns:
            bool: `True` quando o preview está rodando.
        """
        return self._running

    @Property(bool, notify=barrierBreachedChanged)
    def barrierBreached(self):
        """Informa se a barreira virtual está acionada.

        Returns:
            bool: `True` quando a barreira foi acionada.
        """
        return self._barrier_breached

    @Property(int, notify=barrierReleaseCountdownChanged)
    def barrierReleaseCountdown(self):
        """Retorna a contagem regressiva para liberação da barreira.

        Returns:
            int: Segundos restantes para liberar a parada por barreira.
        """
        return self._barrier_release_countdown

    @Property(str, notify=statusTextChanged)
    def statusText(self):
        """Retorna o texto de estado do preview OpenCV.

        Returns:
            str: Mensagem curta para exibição na HMI.
        """
        return self._status_text

    def current_frame(self):
        """Retorna o frame atual para o `QQuickImageProvider`.

        Returns:
            QImage: Frame mais recente processado pelo OpenCV.
        """
        return self._current_frame

    @Slot()
    def startPreview(self):
        """Inicia a captura de frames OpenCV."""
        self._preview_requested = True

        if self._running:
            return

        if not self._automatic_camera_service.start():
            self._set_status_text("Câmera desconectada. Tentando reconectar.")
            self._start_reconnect_timer()
            return

        self._start_capture_timer()

    @Slot()
    def stopPreview(self):
        """Para a captura de frames OpenCV e limpa o estado operacional."""
        self._preview_requested = False
        self._reconnect_timer.stop()

        if self._running:
            self._timer.stop()
            self._running = False
            self.runningChanged.emit()

        self._automatic_camera_service.stop()
        self._set_barrier_breached(False)
        self._set_barrier_release_countdown(0)
        self._barrier_release_deadline = None
        self._set_status_text("Câmera desconectada.")

    @Slot()
    def pausePreview(self):
        """Pausa a captura sem limpar barreira ou contagem regressiva."""
        self._preview_requested = False
        self._reconnect_timer.stop()

        if self._running:
            self._timer.stop()
            self._running = False
            self.runningChanged.emit()

        self._automatic_camera_service.stop()
        self._update_paused_countdown()
        self._set_status_text("Câmera desconectada.")

    def _refresh_frame(self):
        """Atualiza o frame usado pelo provider de imagem."""
        frame = self._automatic_camera_service.read_frame()

        if frame.isNull():
            self._timer.stop()
            self._automatic_camera_service.stop()
            self._running = False
            self._update_paused_countdown()
            self._set_status_text("Câmera desconectada. Tentando reconectar.")
            self.runningChanged.emit()
            self._start_reconnect_timer()
            return

        self._current_frame = frame
        self._frame_revision += 1
        self._update_barrier_state(
            self._automatic_camera_service.barrier_breached
        )
        self.frameRevisionChanged.emit()

    def _try_reconnect(self):
        """Tenta restaurar a captura enquanto o preview estiver ativo."""
        if not self._preview_requested or self._running:
            self._reconnect_timer.stop()
            return

        if not self._automatic_camera_service.start():
            self._set_status_text("Câmera desconectada. Tentando reconectar.")
            return

        self._start_capture_timer()

    def _start_capture_timer(self):
        """Marca a camera como conectada e inicia a leitura de frames."""
        self._reconnect_timer.stop()
        self._running = True
        self._set_status_text("Câmera conectada.")
        self.runningChanged.emit()
        self._timer.start()

    def _start_reconnect_timer(self):
        """Agenda tentativas periodicas de reconexao."""
        if self._preview_requested and not self._reconnect_timer.isActive():
            self._reconnect_timer.start()

    def _update_barrier_state(self, current_frame_breached):
        """Atualiza o estado persistido da barreira com timeout regressivo."""
        if current_frame_breached:
            self._barrier_release_deadline = (
                time.monotonic() + self._barrier_release_timeout_seconds
            )
            self._set_barrier_release_countdown(
                self._barrier_release_timeout_seconds
            )
            self._set_barrier_breached(True)
            self._set_status_text("Barreira virtual acionada.")
            return

        if not self._barrier_breached:
            self._barrier_release_deadline = None
            self._set_barrier_release_countdown(0)
            self._set_status_text("Câmera conectada.")
            return

        remaining_seconds = self._remaining_release_seconds()
        self._set_barrier_release_countdown(remaining_seconds)

        if remaining_seconds <= 0:
            self._barrier_release_deadline = None
            self._set_barrier_breached(False)
            self._set_status_text("Câmera conectada.")
            return

        self._set_status_text(
            f"Liberando barreira em {remaining_seconds}s."
        )

    def _remaining_release_seconds(self):
        """Calcula os segundos restantes para liberar a barreira."""
        if self._barrier_release_deadline is None:
            return 0

        remaining = self._barrier_release_deadline - time.monotonic()
        return max(0, math.ceil(remaining))

    def _update_paused_countdown(self):
        """Atualiza a contagem enquanto o preview está pausado."""
        if not self._barrier_breached:
            self._set_barrier_release_countdown(0)
            return

        remaining_seconds = self._remaining_release_seconds()
        self._set_barrier_release_countdown(remaining_seconds)

        if remaining_seconds <= 0:
            self._barrier_release_deadline = None
            self._set_barrier_breached(False)

    def _set_barrier_breached(self, breached):
        """Emite mudança apenas quando o estado da barreira muda."""
        if self._barrier_breached == breached:
            return

        self._barrier_breached = breached
        self.barrierBreachedChanged.emit()

    def _set_barrier_release_countdown(self, countdown):
        """Emite mudança apenas quando a contagem regressiva muda."""
        if self._barrier_release_countdown == countdown:
            return

        self._barrier_release_countdown = countdown
        self.barrierReleaseCountdownChanged.emit()

    def _set_status_text(self, status_text):
        """Emite mudança apenas quando o texto de estado muda."""
        if self._status_text == status_text:
            return

        self._status_text = status_text
        self.statusTextChanged.emit()
