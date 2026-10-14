#!/usr/bin/env python3
"""Builds drag-in model files for Roblox Studio (no Rojo plugin needed).

Output (in studio-import/):
  ReplicatedStorage_Items.rbxmx  -> insert into ReplicatedStorage
  StarterPlayerScripts_Items.rbxmx -> insert into StarterPlayer > StarterPlayerScripts

Requires the Rojo CLI on PATH (or set ROJO=/path/to/rojo).
Run from the repo root:  python3 tools/build-studio-import.py
"""
import json, os, subprocess, tempfile
import xml.etree.ElementTree as ET

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ROJO = os.environ.get("ROJO", "rojo")
OUT = os.path.join(ROOT, "studio-import")

# Each output file = the children of one service in default.project.json.
TARGETS = {
    "ReplicatedStorage_Items.rbxmx": ["ReplicatedStorage"],
    "StarterPlayerScripts_Items.rbxmx": ["StarterPlayer", "StarterPlayerScripts"],
}


def abspaths(node):
    """Make every $path absolute so the temp project can live anywhere."""
    for key, value in node.items():
        if key == "$path":
            node[key] = os.path.join(ROOT, value)
        elif isinstance(value, dict):
            abspaths(value)


def main():
    with open(os.path.join(ROOT, "default.project.json")) as f:
        project = json.load(f)
    os.makedirs(OUT, exist_ok=True)

    for filename, path in TARGETS.items():
        node = project["tree"]
        for name in path:
            node = node[name]
        # Wrap the service's children in a temporary Folder for Rojo.
        tree = {"$className": "Folder"}
        for key, value in node.items():
            if not key.startswith("$"):
                tree[key] = value
        abspaths(tree)

        with tempfile.TemporaryDirectory() as tmp:
            proj_path = os.path.join(tmp, "model.project.json")
            built = os.path.join(tmp, "model.rbxmx")
            with open(proj_path, "w") as f:
                json.dump({"name": "Wrapper", "tree": tree}, f)
            subprocess.run([ROJO, "build", proj_path, "-o", built], check=True)

            # Unwrap: move the Folder's children to the top level of the file.
            xml = ET.parse(built)
            roblox = xml.getroot()
            wrapper = roblox.find("Item")
            children = wrapper.findall("Item")
            roblox.remove(wrapper)
            for child in children:
                roblox.append(child)
            xml.write(os.path.join(OUT, filename), encoding="utf-8", xml_declaration=False)
        print("wrote", os.path.join("studio-import", filename))


if __name__ == "__main__":
    main()
