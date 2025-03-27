# How to Play Minesweeper in OCaml

## Author: Ignacio Estrada Cavero

Computer Science student at the Cornell University. Currently working on a game design project for Advanced Game Design and ML Thesis project in Wine Investment.

**Contact Information:** [ignacioec31@gmail.com](mailto:ignacioec31@gmail.com)

## Overview

This is a simple implementation of the classic Minesweeper game in OCaml. The game is rendered in a browser using JavaScript compiled from OCaml code. The game logic is implemented in OCaml, and the rendering is done using local HTML and JavaScript. The point of the project is to showcase OCaml’s capabilities and how it can be used to build web applications, outside of its regular use in backend development.

## Prerequisites

Ensure you have the following installed:

- **OCaml**: for compiling the code.
- **Dune**: OCaml’s build system.
- **Js_of_ocaml**: for compiling OCaml to JavaScript.
- **Python** (optional): to run a local server for viewing the game in a browser.

## Project Structure

```
project-root/
│
├── lib/
|   ├── dune
│   ├── board.ml              # Board logic
│   ├── load.ml               # Rendering and drawing
│   ├── canvas_utils_js.ml    # JS Utils in OCaml
│   ├── canvas_utils.ml       # Reused Utils Functions
│   ├── csv_manager.ml        # SQL Database Manager 
│   ├── timer.ml              # Timer logic
|
|── test/
|   |── dune
|   |── test_canit.ml   # Test suite file
│
├── main.ml             # Main game logic
│
├── index.html          # HTML for displaying the game
│
├── dune                # Dune build configuration
├── dune-project        # Dune project descriptor
```

## How to Build & Run the Game

### 1. **Navigate to the Project Root**

Go to the main directory of the project:
```bash
cd <project-root>
```

### 2. **Build the Project**

Run the following command:
```bash
dune build
```

- This will compile the OCaml code and create the JavaScript output in `_build/default/main.js`.

### 3. **Serve the HTML File**

Use Python to start a local server and view the game in your browser:
```bash
python3 -m http.server
```

- Once the server is running, open a browser and navigate to:

```

  http://localhost:8000
```

- Locate `index.html` in the browser to load the game.

### 4. **How to Play**

- Once the game loads, you will see a 10x10 grid of cells.
- **Revealing Cells**: 
  - Click on any cell to reveal it.
  - If the cell contains a mine, you lose, and the game ends.
  - If the cell is empty or displays a number, the game continues.

## Troubleshooting

- If nothing appears on the screen:
  - Ensure `dune build` completed without errors.
  - Check the browser’s console for any JavaScript errors.
  - Verify that `main.js` is correctly linked in `index.html`.

