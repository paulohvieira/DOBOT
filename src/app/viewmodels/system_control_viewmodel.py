"""ViewModel de controle do sistema operacional.

Autor:
    Paulo Henrique Vieira de Souza <phsouza@cpqd.com.br>
"""

import os
import subprocess

from PySide6.QtCore import QCoreApplication, QObject, Property, Signal, Slot


class SystemControlViewModel(QObject):
    """Expõe ações controladas do sistema operacional para o QML."""

    messageChanged = Signal()

    def __init__(self, parent=None):
        """Inicializa o controle do sistema.

        Args:
            parent: Objeto Qt pai.
        """
        super().__init__(parent)
        self._message = ""

    @Property(str, notify=messageChanged)
    def message(self):
        """Retorna a última mensagem operacional do controle do sistema.

        Returns:
            str: Mensagem curta para exibição na HMI.
        """
        return self._message

    @Slot(result=bool)
    def shutdownSystem(self):
        """Solicita o desligamento do sistema operacional.

        Returns:
            bool: `True` quando o comando de desligamento foi iniciado.
        """
        if os.name != "posix":
            self._set_message(
                "Desligamento do sistema disponível apenas na Raspberry."
            )
            return False

        try:
            subprocess.Popen(
                ["systemctl", "poweroff"],
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
            )
        except OSError as error:
            self._set_message(f"Falha ao solicitar desligamento: {error}")
            return False

        self._set_message("Desligamento solicitado.")
        QCoreApplication.quit()
        return True

    def _set_message(self, message):
        """Atualiza a mensagem operacional emitindo sinal quando necessário."""
        if self._message == message:
            return

        self._message = message
        self.messageChanged.emit()
