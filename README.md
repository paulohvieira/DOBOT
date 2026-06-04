# DOBOT CPQD

Interface grafica em PySide6/QML para controle e monitoramento de um Dobot
Magician em Raspberry Pi 5.

## Stack

- Python 3
- PySide6
- QML / Qt Quick
- MVVM

## Executar

Ative o ambiente virtual e instale as dependencias:

```powershell
venv\Scripts\Activate.ps1
pip install -r requirements.txt
```

Execute a aplicacao:

```powershell
python src\main.py
```

## Git Flow

O desenvolvimento acontece na branch `dev`. Novas funcionalidades devem sair de
`dev` usando branches `feature/*`.
