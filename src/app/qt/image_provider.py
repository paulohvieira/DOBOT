"""Providers de imagem usados pelo QML.

Autor:
    Paulo Henrique Vieira de Souza <phsouza@cpqd.com.br>
"""

from PySide6.QtCore import QSize, Qt
from PySide6.QtGui import QImage
from PySide6.QtQuick import QQuickImageProvider


class ViewModelImageProvider(QQuickImageProvider):
    """Entrega ao QML a imagem atual exposta por um ViewModel."""

    def __init__(self, view_model):
        """Inicializa o provider com uma fonte de imagem.

        Args:
            view_model: Objeto com método `current_frame`.
        """
        super().__init__(QQuickImageProvider.ImageType.Image)
        self._view_model = view_model

    def requestImage(self, image_id, size, requested_size):
        """Retorna a imagem solicitada pelo QML.

        Args:
            image_id: Identificador da imagem solicitado pelo QML.
            size: Tamanho original preenchido para o QML.
            requested_size: Tamanho solicitado pelo componente `Image`.

        Returns:
            QImage: Frame atual ou imagem vazia quando ainda não há frame.
        """
        image = self._view_model.current_frame()

        if image.isNull():
            image = QImage(1, 1, QImage.Format.Format_RGB888)
            image.fill(0)

        if size is not None:
            size.setWidth(image.width())
            size.setHeight(image.height())

        if requested_size and requested_size != QSize():
            return image.scaled(
                requested_size,
                aspectMode=Qt.AspectRatioMode.KeepAspectRatio,
                mode=Qt.TransformationMode.SmoothTransformation,
            )

        return image
