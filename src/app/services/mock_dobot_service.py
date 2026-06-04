class MockDobotService:
    """Simulates the Dobot service while the real controller is unavailable."""

    def __init__(self):
        self._connected = False

    @property
    def connected(self):
        return self._connected

    def connect(self):
        self._connected = True

    def disconnect(self):
        self._connected = False
