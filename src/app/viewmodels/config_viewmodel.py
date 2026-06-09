"""ViewModel da tela de configurações.

Autor:
    Paulo Henrique Vieira de Souza <phsouza@cpqd.com.br>
"""

from PySide6.QtCore import QObject, Property, Signal, Slot

from app.models.app_settings import AppSettings
from app.services.settings_service import SettingsService


class ConfigViewModel(QObject):
    """Expõe configurações persistidas para a interface QML."""

    MIN_SCREENSAVER_TIMEOUT_SECONDS = 30
    MAX_SCREENSAVER_TIMEOUT_SECONDS = 300

    zStepChanged = Signal()
    interpolationMinChanged = Signal()
    interpolationMaxChanged = Signal()
    clpEnabledChanged = Signal()
    screensaverTimeoutSecondsChanged = Signal()
    messageChanged = Signal()

    def __init__(self, settings_service=None):
        super().__init__()
        self._settings_service = settings_service or SettingsService()
        self._settings = self._settings_service.load()
        self._message = ""

    @Property(float, notify=zStepChanged)
    def zStep(self):
        return self._settings.motion.z_step

    @zStep.setter
    def zStep(self, value):
        value = max(0.05, float(value))

        if self._settings.motion.z_step == value:
            return

        self._settings.motion.z_step = value
        self.zStepChanged.emit()

    @Property(float, notify=interpolationMinChanged)
    def interpolationMin(self):
        return self._settings.motion.interpolation_min

    @interpolationMin.setter
    def interpolationMin(self, value):
        value = float(value)

        if self._settings.motion.interpolation_min == value:
            return

        self._settings.motion.interpolation_min = value
        self.interpolationMinChanged.emit()

    @Property(float, notify=interpolationMaxChanged)
    def interpolationMax(self):
        return self._settings.motion.interpolation_max

    @interpolationMax.setter
    def interpolationMax(self, value):
        value = float(value)

        if self._settings.motion.interpolation_max == value:
            return

        self._settings.motion.interpolation_max = value
        self.interpolationMaxChanged.emit()

    @Property(bool, notify=clpEnabledChanged)
    def clpEnabled(self):
        return self._settings.integrations.clp_enabled

    @clpEnabled.setter
    def clpEnabled(self, value):
        value = bool(value)

        if self._settings.integrations.clp_enabled == value:
            return

        self._settings.integrations.clp_enabled = value
        self.clpEnabledChanged.emit()

    @Property(int, notify=screensaverTimeoutSecondsChanged)
    def screensaverTimeoutSeconds(self):
        """Retorna o tempo de inatividade para abrir o screensaver."""
        return self._settings.display.screensaver_timeout_seconds

    @screensaverTimeoutSeconds.setter
    def screensaverTimeoutSeconds(self, value):
        value = self._clamp_screensaver_timeout(value)

        if self._settings.display.screensaver_timeout_seconds == value:
            return

        self._settings.display.screensaver_timeout_seconds = value
        self.screensaverTimeoutSecondsChanged.emit()

    @Property(str, notify=messageChanged)
    def message(self):
        return self._message

    @Slot(result=bool)
    def save(self):
        if self.zStep < 0.05:
            self._set_message("O passo do eixo Z deve ser no mínimo 0,05.")
            return False

        if self.interpolationMin >= self.interpolationMax:
            self._set_message(
                "A interpolação mínima deve ser menor que a máxima."
            )
            return False

        self.screensaverTimeoutSeconds = self.screensaverTimeoutSeconds
        self._settings_service.save(self._settings)
        self._set_message("Configurações salvas.")
        return True

    @Slot()
    def reload(self):
        self._settings = self._settings_service.load()
        self.zStepChanged.emit()
        self.interpolationMinChanged.emit()
        self.interpolationMaxChanged.emit()
        self.clpEnabledChanged.emit()
        self.screensaverTimeoutSecondsChanged.emit()
        self._set_message("Configurações recarregadas.")

    def _clamp_screensaver_timeout(self, value):
        """Limita o tempo do screensaver entre 30 e 300 segundos."""
        return min(
            self.MAX_SCREENSAVER_TIMEOUT_SECONDS,
            max(self.MIN_SCREENSAVER_TIMEOUT_SECONDS, int(value)),
        )

    def _set_message(self, message):
        if self._message == message:
            return

        self._message = message
        self.messageChanged.emit()
