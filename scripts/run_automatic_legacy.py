"""Executa o modo automático legado em processo separado.

Autor:
    Paulo Henrique Vieira de Souza <phsouza@cpqd.com.br>
"""

import argparse
import os
import subprocess
import sys
from pathlib import Path


def parse_args():
    """Lê os argumentos de execução do modo automático legado.

    Returns:
        argparse.Namespace: Argumentos informados pela linha de comando.
    """
    parser = argparse.ArgumentParser(
        description="Executa o modo automático legado do Dobot."
    )
    parser.add_argument(
        "--dummy-robot",
        action="store_true",
        help="Executa o automático usando o robô simulado.",
    )
    parser.add_argument(
        "--com-port",
        help="Porta serial do Dobot, por exemplo COM3 ou /dev/ttyUSB0.",
    )

    return parser.parse_args()


def build_legacy_command(args, legacy_script):
    """Monta o comando usado para iniciar o script legado.

    Args:
        args: Argumentos lidos da linha de comando.
        legacy_script: Caminho absoluto do script legado.

    Returns:
        list: Comando pronto para `subprocess.call`.
    """
    command = [sys.executable, str(legacy_script)]

    if args.dummy_robot:
        command.append("--dummy-robot")

    if args.com_port:
        command.extend(["--com-port", args.com_port])

    return command


def build_legacy_environment(legacy_dir, pydobot_dir):
    """Monta o ambiente usado pelo processo legado.

    Args:
        legacy_dir: Diretório que contém os módulos do projeto legado.
        pydobot_dir: Diretório que contém o pacote vendorizado `pydobot`.

    Returns:
        dict: Ambiente com `PYTHONPATH` preparado para os imports legados.
    """
    environment = os.environ.copy()
    python_paths = [
        str(legacy_dir),
        str(pydobot_dir),
    ]
    current_python_path = environment.get("PYTHONPATH")

    if current_python_path:
        python_paths.append(current_python_path)

    environment["PYTHONPATH"] = os.pathsep.join(python_paths)
    return environment


def main():
    """Executa o modo automático legado com diretório de trabalho correto.

    Returns:
        int: Código de saída do processo legado.
    """
    args = parse_args()
    project_root = Path(__file__).resolve().parents[1]
    legacy_dir = (
        project_root
        / "src"
        / "app"
        / "integrations"
        / "dobot"
        / "vendor"
        / "dobot-vision"
    )
    pydobot_dir = (
        project_root
        / "src"
        / "app"
        / "integrations"
        / "dobot"
        / "vendor"
        / "pydobot"
    )
    legacy_script = legacy_dir / "vial_robot.py"
    command = build_legacy_command(args, legacy_script)
    environment = build_legacy_environment(legacy_dir, pydobot_dir)

    return subprocess.call(command, cwd=legacy_dir, env=environment)


if __name__ == "__main__":
    raise SystemExit(main())
