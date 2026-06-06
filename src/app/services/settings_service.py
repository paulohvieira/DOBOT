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
        """Carrega as configurações persistidas.

        Caso o arquivo esteja ausente, inválido ou inacessível, cria um novo
        arquivo com valores padrão. Quando o JSON está corrompido, preserva uma
        cópia de backup para inspeção futura.

        Returns:
            AppSettings: Configurações carregadas ou valores padrão recriados.
        """
        if not self._settings_path.exists():
            return self._create_default_settings()

        try:
            with self._settings_path.open("r", encoding="utf-8") as settings_file:
                data = json.load(settings_file)
        except json.JSONDecodeError:
            self._backup_corrupted_settings()
            return self._create_default_settings()
        except OSError:
            return AppSettings()

        return AppSettings.from_dict(data)

    def _create_default_settings(self):
        """Cria, salva e retorna as configurações padrão.

        Returns:
            AppSettings: Configurações padrão da aplicação.
        """
        settings = AppSettings()
        self.save(settings)
        return settings

    def _backup_corrupted_settings(self):
        """Preserva uma cópia do arquivo JSON corrompido.

        O backup usa a extensão `.bak` no mesmo diretório do arquivo original.
        Falhas no backup são ignoradas para não impedir a aplicação de iniciar.
        """
        backup_path = self._settings_path.with_suffix(".json.bak")

        try:
            self._settings_path.replace(backup_path)
        except OSError:
            return

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
