"""Serviço de leitura e escrita das configurações em JSON.

Autor:
    Paulo Henrique Vieira de Souza <phsouza@cpqd.com.br>
"""

import json
import os
from pathlib import Path

from app.models.app_settings import AppSettings


class SettingsService:
    """Persiste configurações da aplicação em arquivo JSON."""

    def __init__(self, settings_path=None):
        environment_path = os.environ.get("DOBOT_CPQD_SETTINGS_PATH")
        self._settings_path = Path(
            settings_path or environment_path or self._default_settings_path()
        )

    @property
    def settings_path(self):
        """Retorna o caminho do arquivo de configurações."""
        return self._settings_path

    def load(self):
        """Carrega as configurações persistidas."""
        if not self._settings_path.exists():
            settings = AppSettings()
            self.save(settings)
            return settings

        with self._settings_path.open("r", encoding="utf-8") as settings_file:
            data = json.load(settings_file)

        return AppSettings.from_dict(data)

    def save(self, settings):
        """Salva as configurações no arquivo JSON."""
        self._settings_path.parent.mkdir(parents=True, exist_ok=True)

        with self._settings_path.open("w", encoding="utf-8") as settings_file:
            json.dump(
                settings.to_dict(),
                settings_file,
                ensure_ascii=False,
                indent=2,
            )

    def _default_settings_path(self):
        if os.name == "nt":
            config_root = (
                os.environ.get("APPDATA")
                or os.environ.get("LOCALAPPDATA")
                or Path.home()
            )
            return Path(config_root) / "dobot-cpqd" / "settings.json"

        config_root = os.environ.get("XDG_CONFIG_HOME")

        if config_root:
            return Path(config_root) / "dobot-cpqd" / "settings.json"

        return Path.home() / ".config" / "dobot-cpqd" / "settings.json"
