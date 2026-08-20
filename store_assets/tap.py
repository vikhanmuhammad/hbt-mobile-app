"""Tap a UI element on an Android emulator by matching its text/content-desc
(substring, case-insensitive). Usage: python tap.py <device-serial> <substring>"""
import subprocess
import sys
import re
import xml.etree.ElementTree as ET

device, needle = sys.argv[1], sys.argv[2].lower()

subprocess.run(["adb", "-s", device, "shell", "uiautomator", "dump", "/sdcard/ui.xml"],
               check=True, capture_output=True)
subprocess.run(["adb", "-s", device, "pull", "/sdcard/ui.xml", "store_assets/_tmp_ui.xml"],
               check=True, capture_output=True)

tree = ET.parse("store_assets/_tmp_ui.xml")
best = None
for node in tree.iter("node"):
    if node.get("clickable") != "true":
        continue
    label = f"{node.get('text') or ''} {node.get('content-desc') or ''}".lower()
    if needle in label:
        best = node
        break

if best is None:
    print(f"NOT FOUND: {needle}")
    sys.exit(1)

nums = [int(n) for n in re.findall(r"-?\d+", best.get("bounds"))]
x = (nums[0] + nums[2]) // 2
y = (nums[1] + nums[3]) // 2
print(f"tapping '{needle}' at ({x},{y})")
subprocess.run(["adb", "-s", device, "shell", "input", "tap", str(x), str(y)], check=True)
