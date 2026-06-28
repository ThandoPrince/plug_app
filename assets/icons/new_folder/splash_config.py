from pathlib import Path

content = """flutter_native_splash:
  color: "#3EC5FF"
  image: assets/icons/plug_icon.png

  android_12:
    color: "#3EC5FF"
    image: assets/icons/plug_icon.png
"""

path = Path("/flutter_native_splash.yaml")
path.write_text(content, encoding="utf-8")

print(f"Created: {path}")