import os
import sys
from pathlib import Path

from PySide6.QtCore import QUrl
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine

from app.qt.activity_monitor import ActivityMonitor
from app.qt.image_provider import ViewModelImageProvider
from app.services.automatic_camera_service import AutomaticCameraService
from app.services.automatic_mode_service import AutomaticModeService
from app.services.mock_dobot_service import MockDobotService
from app.viewmodels.alarm_viewmodel import AlarmViewModel
from app.viewmodels.automatic_camera_viewmodel import AutomaticCameraViewModel
from app.viewmodels.automatic_viewmodel import AutomaticViewModel
from app.viewmodels.robot_viewmodel import RobotViewModel
from app.viewmodels.camera_viewmodel import CameraViewModel
from app.viewmodels.config_viewmodel import ConfigViewModel
from app.viewmodels.system_control_viewmodel import SystemControlViewModel


def is_kiosk_mode_enabled():
    """Verifica se a aplicação deve iniciar em modo kiosk.

    Returns:
        bool: `True` quando `--kiosk` ou `DOBOT_CPQD_KIOSK=1` foi informado.
    """
    return "--kiosk" in sys.argv or os.environ.get("DOBOT_CPQD_KIOSK") == "1"


def main():
    os.environ.setdefault("QT_IM_MODULE", "qtvirtualkeyboard")
    os.environ.setdefault("QT_QUICK_CONTROLS_STYLE", "Material")
    app = QGuiApplication(sys.argv)
    activity_monitor = ActivityMonitor(app)
    app.installEventFilter(activity_monitor)

    qml_dir = Path(__file__).resolve().parent / "qml"
    main_qml = qml_dir / "Main.qml"

    robot_service = MockDobotService()
    robot_view_model = RobotViewModel(robot_service)
    camera_view_model = CameraViewModel()
    config_view_model = ConfigViewModel()
    system_control_view_model = SystemControlViewModel()
    alarm_view_model = AlarmViewModel()
    automatic_mode_service = AutomaticModeService()
    automatic_view_model = AutomaticViewModel(automatic_mode_service)
    automatic_camera_service = AutomaticCameraService()
    automatic_camera_view_model = AutomaticCameraViewModel(
        automatic_camera_service
    )

    engine = QQmlApplicationEngine()
    engine.addImageProvider(
        "automaticCamera",
        ViewModelImageProvider(automatic_camera_view_model),
    )
    engine.addImportPath(str(qml_dir))
    engine.setInitialProperties({
        "robotViewModel": robot_view_model,
        "activityMonitor": activity_monitor,
        "cameraViewModel": camera_view_model,
        "configViewModel": config_view_model,
        "systemControlViewModel": system_control_view_model,
        "alarmViewModel": alarm_view_model,
        "automaticViewModel": automatic_view_model,
        "automaticCameraViewModel": automatic_camera_view_model,
        "kioskMode": is_kiosk_mode_enabled(),
    })
    engine.load(QUrl.fromLocalFile(str(main_qml)))

    if not engine.rootObjects():
        return 1

    return app.exec()


if __name__ == "__main__":
    sys.exit(main())
