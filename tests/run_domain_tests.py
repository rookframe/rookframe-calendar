#!/usr/bin/env python3
"""Run Calendar's pure domain checks; native script errors fail even on exit zero."""
import argparse
from pathlib import Path
import subprocess

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument("--godot", required=True)
args = parser.parse_args()
root = Path(__file__).resolve().parents[1]
result = subprocess.run([args.godot, "--headless", "--path", str(root),
    "--script", "res://tests/calendar_domain.gd"], capture_output=True, text=True, timeout=30)
output = result.stdout + result.stderr
print(output, end="")
raise SystemExit(0 if result.returncode == 0 and "CALENDAR_DOMAIN PASS" in output
    and "ERROR:" not in output else 1)
