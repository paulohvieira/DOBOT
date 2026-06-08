from pymodbus.client import ModbusTcpClient
from enum import IntEnum

class AndonState(IntEnum):
    GREEN = 3
    YELLOW = 2
    RED = 1
    NONE = 0

class Andon():
    def __init__(self, modbus_client: ModbusTcpClient, device_id: int):
        self.modbus_client = modbus_client
        self.state = AndonState.NONE
        self.device_id = device_id
    
    def get_state(self):
        if not self.modbus_client.connect():
            return None

        response = self.modbus_client.read_holding_registers(address=0, count = 1, device_id = self.device_id)
        self.state = self.modbus_client.convert_from_registers(response.registers, self.modbus_client.DATATYPE.INT16, 'little')
        self.modbus_client.close()
        return self.state

    def set_state(self, neostate: AndonState):
        if not self.modbus_client.connect():
            return
        self.state = neostate
        payload = self.modbus_client.convert_to_registers(value=self.state, data_type=self.modbus_client.DATATYPE.INT16, word_order="little")
        self.modbus_client.write_registers(address=0, values=payload, device_id=self.device_id)
        self.modbus_client.close()