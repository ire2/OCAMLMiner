open Js_of_ocaml

(** Main module for the Minesweeper game implemented using Js_of_ocaml.

    This module handles the initialization of the game, updating the game state,
    and rendering the game board on an HTML canvas element.

    - Dependencies:
    - Js_of_ocaml: For interacting with the DOM and handling JavaScript events.
    - Sweeper: Custom library for game logic.
    - Board: Custom module for board management in Sweeper Library.
    - Load: Custom module for loading and rendering the game board in Sweeper
      Library.
    - Canvas_utils

    - Global State:
    - [game_state]: Reference to the current state of the game, including the
      board and game over status.
    - [remaining_mines]: Reference to the count of remaining mines.
    - [unrevealed_cells]: Reference to the count of unrevealed cells.

    - Functions:
    - [update_info_boxes ()]: Updates the text boxes displaying the count of
      remaining mines and unrevealed cells.
    - [handle_click ev]: Handles click events on the game board, updating the
      game state and re-rendering the board.
    - [initialize_game ()]: Initializes the game state and counts, and updates
      the info boxes.
    - [main entry point]: Initializes the game, sets up the canvas, and assigns
      the click event handler. *)

open Sweeper
include Board
include Load
include Canvas_utils_js
include Canvas_utils
include Csv_manager

(* Global state *)
let game_state =
  ref ({ board = [||]; started = false; game_over = false } : Board.game_state)

let get_rows () = !board_info |> fst |> fst
let get_cols () = !board_info |> fst |> snd
let timer = ref (Timer.create_timer Timer.Stopwatch)
let current_username : string ref = ref ""
let nmines = ref 0

exception UnknownDifficulty of string

(** [update_timer_display] is a helper function to update timer in session *)
let update_timer_display () = Timer.update_timer_display !timer

(** [start_timer] is a helper function to start timer in session *)
let init_timer () =
  Timer.reset_timer !timer 0;
  Timer.start_timer !timer

(** [update_timer] is a recusive helper function to update timer in session *)
let rec update_timer () =
  update_timer_display ();
  Dom_html.window##setTimeout (Js.wrap_callback update_timer) 1000. |> ignore

(** [get_selected_difficulty ()] retrieves the selected value from the dropdown
    menu with the ID "difficultySelector". It logs the value to the console for
    debugging purposes and returns it as an [option string]. *)
let get_selected_difficulty () =
  match get_selector_by_id difficulty_id with
  | Some dropdown -> (
      match Js.to_string dropdown##.value with
      | "easy" -> Board.Easy
      | "medium" -> Board.Medium
      | "hard" -> Board.Hard
      | "none" -> Board.None
      | _ ->
          log_error "Error: Unknown option selected";
          Board.None)
  | None ->
      log_error "Difficulty selector not found.";
      Board.None

(** [update_info_boxes ()] updates the text content of the HTML elements with
    IDs "mineCount" and "unrevealedCount" to display the current number of
    remaining mines and unrevealed cells, respectively. It retrieves the
    elements using [Dom_html.getElementById] and sets their text content using
    [##.textContent := Js.some (Js.string ...)]. The values are formatted as
    strings with appropriate labels. *)
let update_info_boxes () =
  let mine_count_box = Dom_html.getElementById minecount_id in
  let unrevealed_count_box = Dom_html.getElementById unrevealed_id in
  mine_count_box##.textContent
  := Js.some (Js.string ("Flags Remaining: " ^ string_of_int !remaining_flags));
  unrevealed_count_box##.textContent
  := Js.some
       (Js.string ("Unrevealed Cells: " ^ string_of_int !unrevealed_cells))

(** [initialize_game ()] initializes the game state by setting up the initial
    board, updating the game state, and initializing the remaining mines and
    unrevealed cells. It also updates the information boxes to reflect the
    current game state. *)
let initialize_game () =
  let initial_state = Board.initialize_board !board_info in
  game_state := initial_state;
  nmines := snd !board_info;
  remaining_mines := Board.total_mines initial_state;
  unrevealed_cells := get_rows () * get_cols ();
  update_info_boxes ()

let reveal_cells x y tot =
  let state = !game_state in
  let board = state.board in
  let rows = get_rows () in
  let cols = get_cols () in
  let directions =
    [ (-1, -1); (-1, 0); (-1, 1); (0, -1); (0, 1); (1, -1); (1, 0); (1, 1) ]
  in

  let in_bounds x y = x >= 0 && y >= 0 && x < cols && y < rows in

  let rec reveal x y tot =
    if not (in_bounds x y) then tot
    else
      let cell = board.(x).(y) in
      if cell.is_revealed || cell.is_flagged || cell.is_mine then tot
      else begin
        cell.is_revealed <- true;
        let new_tot = tot + 1 in
        (match get_canvas_by_id "my_canvas" with
        | Some canvas ->
            let ctx = get_context canvas in
            Load.render_board ctx state (fst !board_info);
            update_info_boxes ()
        | None -> log_error "Canvas not found");
        if cell.neighboring_mines = 0 then
          List.fold_left
            (fun acc (dx, dy) -> reveal (x + dx) (y + dy) acc)
            new_tot directions
        else new_tot
      end
  in
  reveal x y tot

(** [reveal_all_tiles ()] reveals all the tiles on the board. This function is
    utilized for UI testing. *)
let reveal_all_tiles () =
  let state = !game_state in
  Array.iter
    (fun row -> Array.iter (fun cell -> cell.is_revealed <- true) row)
    state.board;
  match get_canvas_by_id canvas_id with
  | Some canvas ->
      let ctx = get_context canvas in
      Load.render_board ctx state (fst !board_info);
      update_info_boxes ()
  | None -> log_error "Canvas not found"

(** [unreveal_all_tiles ()] unreveals all the tiles on the board. This function
    is utilized for UI testing. Func should not be used by player. *)
let unreveal_all_tiles () =
  let state = !game_state in
  Array.iter
    (fun row -> Array.iter (fun cell -> cell.is_revealed <- false) row)
    state.board;
  match get_canvas_by_id canvas_id with
  | Some canvas ->
      let ctx = get_context canvas in
      Load.render_board ctx state (fst !board_info);
      update_info_boxes ()
  | None -> log_error "Canvas not found"

let reveal_mines () =
  let state = !game_state in
  Array.iter
    (fun row ->
      Array.iter
        (fun cell ->
          if (not cell.is_revealed) && cell.is_mine then
            cell.is_revealed <- true)
        row)
    state.board;
  match get_canvas_by_id canvas_id with
  | Some canvas ->
      let ctx = get_context canvas in
      Load.render_board ctx state (fst !board_info);
      update_info_boxes ()
  | None -> log_error "Canvas not found"

let win state =
  reveal_all_tiles ();
  state.game_over <- true;
  Timer.stop_timer !timer;
  let time = Timer.get_time !timer in
  show_alert
    (Printf.sprintf "You win! All cells revealed!Time: %i seconds" time)

let lose state =
  state.game_over <- true;
  Timer.stop_timer !timer;
  show_alert "Game Over! You clicked on a mine."

(** [handle_click ev] handles a click event [ev] on the game board. It updates
    the game state based on the click position and renders the updated board.

    - If the game is over, it returns [js_false].
    - Otherwise, it calculates the cell coordinates from the click position.
    - If the clicked cell is within the board boundaries and not already
      revealed:
    - It reveals the cell.
    - Decreases the count of unrevealed cells.
    - If the cell is a mine, it sets the game over state and alerts the user.
    - If all non-mine cells are revealed, it alerts the user of a win.

    @param ev The click event to handle.
    @return [js_true] if the click was handled, [js_false] if the game is over. *)
let handle_click (ev : mouse_event) =
  let state = !game_state in

  if state.game_over then js_false
  else
    let x, y = !mouse_coords in

    if x < get_cols () && y < get_rows () then (
      if not state.started then (
        place_mines state.board (snd !board_info) x y;
        update_neighbor_counts state.board;
        state.started <- true)
      else ();

      let cell = state.board.(x).(y) in
      if (not cell.is_revealed) && not cell.is_flagged then (
        if cell.is_mine then lose state
        else if !unrevealed_cells > 1 then (
          log_error "unrevealed cells is greater than mines";
          log_error ("nmines: " ^ string_of_int !nmines);
          log_error ("unrevealed cells: " ^ string_of_int !unrevealed_cells);
          let num_revealed = reveal_cells x y 0 in
          unrevealed_cells := !unrevealed_cells - num_revealed)
        else (
          log_error "unrevealed cells are less than mines";
          log_error ("nmines: " ^ string_of_int !nmines);
          log_error ("unrevealed cells: " ^ string_of_int !unrevealed_cells);
          win state);

        match get_canvas_by_id canvas_id with
        | Some canvas ->
            let ctx = get_context canvas in
            Load.render_board ctx state (fst !board_info);
            update_info_boxes ()
        | None -> log_error "Canvas not found");
      js_true)
    else js_false

let flag_cell cell state =
  if !remaining_flags <= 0 then js_false
  else (
    (cell.is_flagged <- true;
     decr unrevealed_cells;
     log_error ("unrevealed cells: " ^ string_of_int !unrevealed_cells);
     decr remaining_flags;
     if !unrevealed_cells = 0 then
       show_alert "All cells have been revealed! You win!";
     match get_canvas_by_id "my_canvas" with
     | Some canvas ->
         let ctx = get_context canvas in
         Load.render_board ctx state (fst !board_info);
         update_info_boxes ()
     | None -> log_error "Canvas not found");
    js_true)

let unflag_cell cell state =
  (cell.is_flagged <- false;
   incr unrevealed_cells;
   incr remaining_flags;
   match get_canvas_by_id "my_canvas" with
   | Some canvas ->
       let ctx = get_context canvas in
       Load.render_board ctx state (fst !board_info);
       update_info_boxes ()
   | None -> log_error "Canvas not found");
  js_true

let quit_server () =
  show_alert ("Bye Bye" ^ !current_username);
  exit 0

let remove_all_flags () =
  let state = !game_state in
  Array.iter
    (fun row -> Array.iter (fun cell -> cell.is_flagged <- false) row)
    state.board;
  match get_canvas_by_id canvas_id with
  | Some canvas ->
      let ctx = get_context canvas in
      Load.render_board ctx state (fst !board_info);
      update_info_boxes ()
  | None -> log_error "Canvas not found"

let toggle_flag cell state =
  if (not cell.is_revealed) && not cell.is_flagged then flag_cell cell state
  else if (not cell.is_revealed) && cell.is_flagged then unflag_cell cell state
  else js_false

let handle_mousemove event =
  mouse_coords := get_mouse_coords event;
  js_true

let key_pressed ev =
  match Js.Optdef.to_option ev##.key with
  | Some key ->
      if Js.to_string key = "f" || Js.to_string key = "F" then
        let x, y = !mouse_coords in
        let state = !game_state in
        let cell = state.board.(x).(y) in
        if x < get_cols () && y < get_rows () then toggle_flag cell state
        else js_false
      else if Js.to_string key = "r" || Js.to_string key = "R" then (
        reveal_all_tiles ();
        js_true)
      else if Js.to_string key = "m" || Js.to_string key = "M" then (
        reveal_mines ();
        js_true)
      else if Js.to_string key = "u" || Js.to_string key = "U" then (
        unreveal_all_tiles ();
        js_true)
      else if Js.to_string key = "h" || Js.to_string key = "H" then (
        remove_all_flags ();
        js_true)
      else if Js.to_string key = "q" || Js.to_string key = "Q" then (
        ignore (quit_server ());
        js_true)
      else (
        log_error "Unhandled key pressed";
        js_false)
  | None ->
      log_error "Key not found";
      js_false

let start_game () =
  board_info := () |> get_selected_difficulty |> Board.get_difficulty;
  remaining_flags := snd !board_info;
  unrevealed_cells := get_rows () * get_cols ();
  if get_selected_difficulty () <> Board.None then (
    log_error "it is not equal";
    init_timer ();
    match get_canvas_by_id canvas_id with
    | Some canvas ->
        canvas##.width := get_cols () * 40;
        canvas##.height := get_rows () * 40;
        let ctx = get_context canvas in
        Random.self_init ();
        initialize_game ();
        Load.render_board ctx !game_state (fst !board_info);
        canvas##.onclick := Dom_html.handler handle_click;
        canvas##.onmousemove := Dom_html.handler handle_mousemove;
        Dom_html.window##.onkeypress := Dom_html.handler key_pressed
    | None -> log_error "Canvas not found")
  else show_alert "Please select a difficulty level"

let dummy_users = ref []

let generate_dummy_users n =
  let rec aux acc n =
    if n = 0 then acc
    else
      let username = "dummy" ^ string_of_int n in
      let time = string_of_int (120 + Random.int 60) in
      aux ((username, time) :: acc) (n - 1)
  in
  aux [] n

let to_string table =
  List.fold_left
    (fun acc (username, time) -> acc ^ username ^ ": " ^ time ^ " seconds\n")
    "" table.rows

let print_top_users () =
  let table = read_table "scores.csv" in
  let top_users = get_top_n_users table 10 in
  dummy_users := generate_dummy_users (10 - List.length top_users.rows);
  let final_users = { top_users with rows = top_users.rows @ !dummy_users } in
  show_alert (to_string final_users)

let hide_top_users () =
  match get_element_by_id "top-users" with
  | Some element -> element##.style##.display := Js.string "none"
  | None -> log_error "Top users element not found"

let display_top_users () =
  let table = read_table "scores.csv" in
  let top_users = get_top_n_users table 10 in
  dummy_users := generate_dummy_users (10 - List.length top_users.rows);
  let final_users = { top_users with rows = top_users.rows @ !dummy_users } in
  match get_element_by_id "top-users-list" with
  | Some element ->
      let user_list =
        List.map (fun (u, t) -> u ^ ": " ^ t ^ " seconds") final_users.rows
      in
      element##.textContent :=
        Js.some (Js.string (String.concat "\n" user_list))
  | None -> log_error "Top users list element not found"

let process_board_rows board =
  let rows = get_rows () in
  let cols = get_cols () in
  let rec find_safe_cell row_index col_index =
    if row_index >= rows then None
    else if col_index >= cols then find_safe_cell (row_index + 1) 0
    else
      let cell = board.(row_index).(col_index) in
      if (not cell.is_revealed) && not cell.is_mine then Easy
      else find_safe_cell row_index (col_index + 1)
  in
  find_safe_cell 0 0

let reveal_hint () =
  match !game_state with
  | { board; _ } -> (
      match process_board_rows board with
      | _ ->
          let cell = board.(0).(0) in
          if not cell.is_revealed then (
            cell.is_revealed <- true;
            (* Optionally decrement unrevealed_cells here *)
            match get_canvas_by_id canvas_id with
            | Some canvas ->
                let ctx = get_context canvas in
                Load.render_board ctx !game_state (fst !board_info);
                update_info_boxes ()
            | None -> log_error "Canvas not found"))

let initialize_hint_button () =
  match get_element_by_id hint_button_id with
  | Some button ->
      button##.onclick :=
        Dom_html.handler (fun _ ->
            reveal_hint ();
            Js._true)
  | None -> log_error "Hint button not found"

let set_welcome_message username =
  hide_top_users ();
  match get_element_by_id "welcome-message" with
  | Some element -> (
      (* Set the welcome message *)
      element##.textContent := Js.some (Js.string (username ^ " is playing"));

      (* Hide the user input element *)
      (match get_element_by_id "userInput" with
      | Some user_input -> user_input##.style##.display := Js.string "none"
      | None -> log_error "User input element not found");

      (* Show the difficulty selection element *)
      match get_element_by_id "difficulty" with
      | Some difficulty -> difficulty##.style##.display := Js.string "block"
      | None -> log_error "Difficulty element not found")
  | None -> log_error "Welcome message element not found"

let display_info_box () =
  match get_element_by_id "info" with
  | Some info -> info##.style##.display := Js.string "block"
  | None -> log_error "Info element not found"

(* Enable the game controls *)
let enable_game () =
  match get_element_by_id start_id with
  | Some btn -> (
      match get_element_by_id play_id with
      | Some icon ->
          btn##.onclick :=
            Dom_html.handler (fun _ ->
                icon##.className := Js.string "ri-restart-line";
                display_info_box ();
                start_game ();
                update_timer ();
                if get_selected_difficulty () <> Board.None then (
                  log_error "it is not equal";
                  Js._true)
                else Js._true)
          (* Properly closed the handler block *)
      | None ->
          log_error ("No icon found\n" ^ "Please Check the imeages repo")
          (* Properly closed the inner match *))
  | None ->
      log_error ("No start button was found \n" ^ "Please Check the Index.html")
(* Properly closed the outer match *)

let display_top_console () =
  let table = read_table "scores.csv" in
  let top_users = get_top_n_users table 10 in
  dummy_users := generate_dummy_users (10 - List.length top_users.rows);
  let final_users = { top_users with rows = top_users.rows @ !dummy_users } in
  let user_list =
    List.map (fun (u, t) -> u ^ ": " ^ t ^ " seconds") final_users.rows
  in
  print_endline "Top users:";
  List.iter print_endline user_list

let initialize_dropdown_listener () =
  match get_selector_by_id difficulty_id with
  | Some dropdown ->
      dropdown##.onchange :=
        Dom_html.handler (fun _ ->
            display_info_box ();
            start_game ();
            update_timer ();
            if get_selected_difficulty () <> Board.None then (
              log_error "it is not equal";
              Js._true)
            else Js._true)
  | None ->
      log_error
        ("Error: Difficulty selector not found \n"
       ^ "\n Pleaase check Main.ml \n")

let logout () =
  current_username := "";
  remaining_flags := 0;
  unrevealed_cells := 0;
  game_state := { board = [||]; started = false; game_over = false };
  timer := Timer.create_timer Timer.Stopwatch;

  (match get_element_by_id "game-controls" with
  | Some game_controls -> game_controls##.style##.display := Js.string "none"
  | None -> log_error "Game\n   controls element not found");

  (* Show the user input element *)
  (match get_element_by_id "userInput" with
  | Some input_element -> input_element##.style##.display := Js.string "block"
  | None -> log_error "User input element not found");

  (* Clear the welcome message *)
  (match get_element_by_id "welcome-message" with
  | Some element -> element##.textContent := Js.some (Js.string "")
  | None -> log_error "Welcome message element not found");

  show_alert "You have been logged out."

(* Main entry point *)
let () =
  match get_element_by_id "submit-username" with
  | Some btn -> (
      match get_element_by_id "username" with
      | Some element -> (
          match Js.Opt.to_option (Dom_html.CoerceTo.input element) with
          | Some input ->
              btn##.onclick :=
                Dom_html.handler (fun _ ->
                    let username = Js.to_string input##.value in
                    if String.length username > 0 then (
                      log_error ("Username entered: " ^ username);
                      current_username := username;
                      (* print_top_users (); *)
                      (* Set the welcome message *)
                      set_welcome_message username;

                      enable_game ();

                      show_alert
                        ("Welcome to minesweeper, " ^ username ^ "!\n" ^ "\n"
                       ^ "\nClick on cells to reveal them.\n"
                       ^ "They are labelled with the number of adjacent mines \
                          that cell has.\n"
                       ^ " If you think a cell has a mine, hover your mouse \
                          over it and click \"F\" on the keyboard to flag a \
                          cell.\n"
                       ^ "You can unflag that cell by clicking \"F\" again. If \
                          you click a bomb, you lose!\n");

                      initialize_dropdown_listener ();

                      Js._true)
                    else (
                      show_alert "Please enter a valid username!";
                      Js._false))
          | None ->
              log_error "Element with ID 'username' is not an input element")
      | None -> log_error "No element found with ID 'username'")
  | None -> log_error "No submit button found"

(* match get_element_by_id "logout-button" with | Some btn -> btn##.onclick :=
   Dom_html.handler (fun _ -> logout (); Js._true) | None -> log_error "No
   logout button found") *)
