## Prerequisites

Ensure you have the following installed:

- **OCaml**: for compiling the code.
- **Dune**: OCaml’s build system.
- **Js_of_ocaml Packages**: for compiling OCaml to JavaScript.
- **Python** (optional): to run a local server for viewing the game in a browser.

```bash
opam install js_of_ocaml js_of_ocaml-ppx js_of_ocaml-lwt
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

## Troubleshooting

- If nothing appears on the screen manually check you have the right dependencies and are using ./bash:
  - Ensure `dune build` completed without errors.
  - Check the browser’s console for any JavaScript errors.
  - Verify that `main.js` is correctly linked in `index.html`.
