import sys
import os
from pathlib import Path


from PySide6.QtCore import QUrl
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine

from app.services.mock_dobot_service import MockDobotService
from app.viewmodels.robot_viewmodel import RobotViewModel
from app.viewmodels.camera_viewmodel import CameraViewModel

def main():
    os.environ.setdefault("QT_IM_MODULE", "qtvirtualkeyboard")
    app = QGuiApplication(sys.argv)

    qml_dir = Path(__file__).resolve().parent / "qml"
    main_qml = qml_dir / "Main.qml"

    robot_service = MockDobotService()
    robot_view_model = RobotViewModel(robot_service)
    camera_view_model = CameraViewModel()

    engine = QQmlApplicationEngine()
    engine.addImportPath(str(qml_dir))
    engine.setInitialProperties({"robotViewModel": robot_view_model,
                                 "cameraViewModel": camera_view_model})
    engine.load(QUrl.fromLocalFile(str(main_qml)))

    if not engine.rootObjects():
        return 1

    return app.exec()


if __name__ == "__main__":
    sys.exit(main())
