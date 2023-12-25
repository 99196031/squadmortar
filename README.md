# SquadAutoMortars
[![Watch the video](https://img.youtube.com/vi/uF3VQAWmt88/hqdefault.jpg)](https://www.youtube.com/watch?v=uF3VQAWmt88)

## Overview
SquadAutoMortars is a tool designed to enhance your gaming experience in Squad by automating mortar control and providing a synchronized map overlay. This tool is created with the goal of improving mortar adjustments and map coordination.

## Requirements
- Windows operating system

## Features
- **Auto Mortars:**

   Control mortars using OCR for precise adjustments.
  
- **Sync Map:**

   Capture a screenshot of the in-game map and overlay it with the squadmortar map.

- **Quick Adjustments:**

   Swiftly adjust mortars on command.

## Installation
To download and install SquadAutoMortars:
1. Go to [https://github.com/Devil4ngle/squadmortar/releases](https://github.com/Devil4ngle/squadmortar/releases).
2. Download the latest release by clicking on `squadautomortar.zip`.
Note: The release is approximately 300 MB due to included maps.
3. Unzip the downloaded file.
4. Inside the folder, run `squadmortar.exe` while squad is already running.

Note: Don't move `squadmortar.exe` from it's original folder.

## Join Discord
Feel free to join our Discord community for discussions, support, and updates: [SquadAutoMortars Discord](https://discord.gg/Qc5y4satdz).

## EAC Ban Disclaimer
No, the usage of SquadAutoMortars does not violate Easy Anti-Cheat (EAC) policies. The program operates without attaching to or reading memory from the Squad game process. It solely captures screenshots using standard operating system APIs and sends keyboard inputs (a, w, s, d). The code is open source, providing transparency and assurance.

## Supported Sizes
1024x768, 1920x1080, 2560x1440, 3840x1600

## Unsupported Screen Size
If your screen size is not supported, please join our Discord community for assistance: [SquadAutoMortars Discord](https://discord.gg/Qc5y4satdz).


## Credits
This tool is based on the original source code from the Squadmortar website by Miksu. You can find the original source at [https://gitlab.com/squadstrat/squadmortar](https://gitlab.com/squadstrat/squadmortar).

Feel free to explore the code and contribute to the project!

## Development Notes
- To compile the executable for JS, follow these steps:
  - Download [Node.js v18.18.2](https://nodejs.org/download/release/v18.18.2/node-v18.18.2-x64.msi).
  - Run `npm install -g pkg` in the terminal.

- Use `create-nodew-exe` and  `pkg` to create silent versions: 
  
  ```cmd 
  pkg squadMortarServer.js -t=win && create-nodew-exe squadMortarServer.exe squadMortarServerSilent.exe
  ```
- Python for the ImageLayering
   ```cmd 
   python -m PyInstaller --onefile --noconsole --name imageLayeringSilent imageLayering.py
   ```
