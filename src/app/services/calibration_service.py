"""Serviço de calibração de perspectiva da câmera.

Autor:
    Paulo Henrique Vieira de Souza <phsouza@cpqd.com.br>
"""


class CalibrationError(RuntimeError):
    """Erro lançado quando a calibração não pode ser calculada."""


class CalibrationService:
    """Calcula homografia para mapear pixels em coordenadas reais."""

    def calculate_homography(self, image_points, world_points):
        """Calcula a matriz de homografia a partir de quatro pares de pontos.

        Args:
            image_points: Pontos em pixels na imagem da câmera.
            world_points: Pontos reais correspondentes no plano do Dobot.

        Returns:
            list: Matriz 3x3 serializável para JSON.

        Raises:
            CalibrationError: Quando os pontos são insuficientes ou o OpenCV
                não está disponível.
        """
        if len(image_points) < 4 or len(world_points) < 4:
            raise CalibrationError("Informe quatro pontos de calibração.")

        cv2, numpy = self._load_opencv()
        image_array = numpy.array(image_points[:4], dtype=numpy.float32)
        world_array = numpy.array(world_points[:4], dtype=numpy.float32)
        homography, _ = cv2.findHomography(image_array, world_array)

        if homography is None:
            raise CalibrationError("Não foi possível calcular a homografia.")

        return homography.tolist()

    def map_pixel_to_world(self, pixel_x, pixel_y, homography):
        """Converte um ponto em pixel para coordenada real do plano.

        Args:
            pixel_x: Coordenada horizontal em pixels.
            pixel_y: Coordenada vertical em pixels.
            homography: Matriz 3x3 previamente calculada.

        Returns:
            tuple: Coordenada real `(x, y)`.

        Raises:
            CalibrationError: Quando o OpenCV não está disponível.
        """
        cv2, numpy = self._load_opencv()
        point = numpy.array([[[pixel_x, pixel_y]]], dtype=numpy.float32)
        matrix = numpy.array(homography, dtype=numpy.float32)
        transformed = cv2.perspectiveTransform(point, matrix)
        world_x = float(transformed[0][0][0])
        world_y = float(transformed[0][0][1])

        return world_x, world_y

    def _load_opencv(self):
        """Carrega OpenCV e NumPy somente quando a calibração for usada.

        Returns:
            tuple: Módulos `cv2` e `numpy`.

        Raises:
            CalibrationError: Quando a dependência não foi instalada.
        """
        try:
            import cv2
            import numpy
        except ImportError as error:
            raise CalibrationError(
                "OpenCV não está instalado. Execute: "
                "pip install -r requirements.txt"
            ) from error

        return cv2, numpy
