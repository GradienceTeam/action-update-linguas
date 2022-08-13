import os

DESTINATION_PATH = os.environ["INPUT_DESTINATION_PATH"]
INPUT_PO_DIR = os.environ["INPUT_PO_DIR"]

def list_po():
    files = []
    for _, _, filesname in os.walk(INPUT_PO_DIR):
        for file  in filesname:
            if file.endswith(".po"):
                files.append(file.strip(".po"))
    return files
    

with open(f"{DESTINATION_PATH}/LINGUAS", "w") as file:
    po = "\n".join(list_po())
    file.write(po)

