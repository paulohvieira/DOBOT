"""Modelo de configurações persistidas da aplicação.

Autor:
    Paulo Henrique Vieira de Souza <phsouza@cpqd.com.br>
"""

from dataclasses import asdict, dataclass, field


@dataclass
class MotionSettings:
    """Configurações de movimento do Dobot."""

    z_step: float = 0.05
    interpolation_min: float = 0.0
    interpolation_max: float = 100.0


@dataclass
class IntegrationSettings:
    """Configurações de integrações externas."""

    clp_enabled: bool = False


@dataclass
class AppSettings:
    """Configurações gerais persistidas da aplicação."""

    schema_version: int = 1
    motion: MotionSettings = field(default_factory=MotionSettings)
    integrations: IntegrationSettings = field(default_factory=IntegrationSettings)

    def to_dict(self):
        """Converte as configurações para dicionário serializável."""
        return asdict(self)

    @classmethod
    def from_dict(cls, data):
        """Cria configurações a partir de um dicionário."""
        motion_data = data.get("motion", {})
        integrations_data = data.get("integrations", {})

        return cls(
            schema_version=data.get("schema_version", 1),
            motion=MotionSettings(
                z_step=motion_data.get("z_step", 0.05),
                interpolation_min=motion_data.get("interpolation_min", 0.0),
                interpolation_max=motion_data.get("interpolation_max", 100.0),
            ),
            integrations=IntegrationSettings(
                clp_enabled=integrations_data.get("clp_enabled", False),
            ),
        )
