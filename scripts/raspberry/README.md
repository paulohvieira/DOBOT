# Kiosk na Raspberry Pi

Arquivos para iniciar a HMI DOBOT CPQD automaticamente no login gráfico da Raspberry Pi.

## Caminho esperado

Por padrão, o serviço espera o projeto em:

```bash
$HOME/DOBOT
```

Se usar outro caminho, edite `DOBOT_CPQD_PROJECT_DIR` no arquivo `dobot-cpqd-kiosk.service`.

## Instalação

Execute na Raspberry:

```bash
cd ~/DOBOT
chmod +x scripts/raspberry/start_kiosk.sh
mkdir -p ~/.config/systemd/user
cp scripts/raspberry/dobot-cpqd-kiosk.service ~/.config/systemd/user/
systemctl --user daemon-reload
systemctl --user enable dobot-cpqd-kiosk.service
systemctl --user start dobot-cpqd-kiosk.service
```

## Ver logs

```bash
journalctl --user -u dobot-cpqd-kiosk.service -f
```

## Parar/desabilitar

```bash
systemctl --user stop dobot-cpqd-kiosk.service
systemctl --user disable dobot-cpqd-kiosk.service
```
