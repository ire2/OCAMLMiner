#!/bin/bash

# Initial message
echo -e "I am assuming you have the right files. If not, please run the following commands:\n
opam install js_of_ocaml js_of_ocaml-ppx js_of_ocaml-lwt\n"

# Clean the build artifacts
echo -e "\nCleaning...\n"
dune clean

# Build the project
echo -e "\nBuilding...\n"
dune build

# Kill any process using port 8000
PORT=8000
PID=$(lsof -t -i:$PORT)
if [ -n "$PID" ]; then
  echo "Killing process $PID using port $PORT..."
  kill -9 $PID
fi

# Start a local HTTP server in the background
echo "Starting a local HTTP server..."
python3 -m http.server &

# Get the process ID of the HTTP server
SERVER_PID=$!

# Wait for a moment to ensure the server starts
sleep 2

# Open the default web browser to http://[::]:8000/
echo "Opening the default web browser to http://[::]:8000/..."
if command -v xdg-open > /dev/null; then
  xdg-open http://[::]:8000/
elif command -v open > /dev/null; then
  open http://[::]:8000/
elif command -v start > /dev/null; then
  start http://[::]:8000/
else
  echo "Please open your web browser and navigate to http://[::]:8000/"
fi

# Wait for the server process to finish
wait $SERVER_PID