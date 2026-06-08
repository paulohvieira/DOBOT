"""Modelo de configurações persistidas da aplicação.

Autor:
    Paulo Henrique Vieira de Souza <phsouza@cpqd.com.br>
"""

from dataclasses import asdict, dataclass, field


@dataclass
class MotionSettings:
    """Configurações de movimento do Dobot.

    Attributes:
        z_step: Passo mínimo usado para ajuste do eixo Z.
        interpolation_min: Valor mínimo permitido para interpolação do eixo Z.
        interpolation_max: Valor máximo permitido para interpolação do eixo Z.
    """

    z_step: float = 0.05
    interpolation_min: float = 0.0
    interpolation_max: float = 100.0


@dataclass
class CameraCalibrationSettings:
    """Configurações persistidas da calibração da câmera.

    Attributes:
        enabled: Indica se existe calibração válida disponível.
        image_points: Pontos em pixels selecionados na imagem da câmera.
        world_points: Pontos reais correspondentes no plano do Dobot.
        homography: Matriz 3x3 usada para converter pixel em coordenada real.
    """

    enabled: bool = False
    image_points: list = field(default_factory=list)
    world_points: list = field(default_factory=list)
    homography: list = field(default_factory=list)


@dataclass
class IntegrationSettings:
    """Configurações de integrações externas.

    Attributes:
        clp_enabled: Indica se a conexão opcional com o CLP está habilitada.
    """

    clp_enabled: bool = False


@dataclass
class AppSettings:
    """Configurações gerais persistidas da aplicação.

    Attributes:
        schema_version: Versão do esquema de configurações persistidas.
        motion: Configurações de movimento do Dobot.
        camera_calibration: Configurações de calibração da câmera.
        integrations: Configurações de integrações externas.
    """

    schema_version: int = 1
    motion: MotionSettings = field(default_factory=MotionSettings)
    camera_calibration: CameraCalibrationSettings = field(
        default_factory=CameraCalibrationSettings
    )
    integrations: IntegrationSettings = field(default_factory=IntegrationSettings)

    def to_dict(self):
        """Converte as configurações para dicionário serializável."""
        return asdict(self)

    @classmethod
    def from_dict(cls, data):
        """Cria configurações a partir de um dicionário.

        Args:
            data: Dicionário lido do arquivo JSON de configurações.

        Returns:
            AppSettings: Configurações com valores padrão quando algum campo
            não existir no arquivo.
        """
        motion_data = data.get("motion", {})
        calibration_data = data.get("camera_calibration", {})
        integrations_data = data.get("integrations", {})

        return cls(
            schema_version=data.get("schema_version", 1),
            motion=MotionSettings(
                z_step=motion_data.get("z_step", 0.05),
                interpolation_min=motion_data.get("interpolation_min", 0.0),
                interpolation_max=motion_data.get("interpolation_max", 100.0),
            ),
            camera_calibration=CameraCalibrationSettings(
                enabled=calibration_data.get("enabled", False),
                image_points=calibration_data.get("image_points", []),
                world_points=calibration_data.get("world_points", []),
                homography=calibration_data.get("homography", []),
            ),
            integrations=IntegrationSettings(
                clp_enabled=integrations_data.get("clp_enabled", False),
            ),
        )
