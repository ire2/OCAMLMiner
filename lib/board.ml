open Canvas_utils
open Canvas_utils_js

type cell = {
  mutable is_revealed : bool;
  mutable is_mine : bool;
  mutable neighboring_mines : int;
  mutable is_flagged : bool;
}

type game_state = {
  board : cell array array;
  mutable started : bool;
  mutable game_over : bool;
}

type difficulty =
  | None
  | Easy
  | Medium
  | Hard

let get_difficulty = function
  | None -> ((0, 0), 0)
  | Easy -> ((8, 10), 10)
  | Medium -> ((14, 18), 40)
  | Hard -> ((20, 24), 99)

let create_board (nrows, ncols) =
  Array.init ncols (fun _ ->
      Array.init nrows (fun _ ->
          {
            is_revealed = false;
            is_mine = false;
            neighboring_mines = 0;
            is_flagged = false;
            (* Initialize flag state *)
          }))

let place_mines board nmines x y =
  let mines_placed = ref 0 in
  while !mines_placed < nmines do
    let col = Random.int (Array.length board.(0)) in
    let row = Random.int (Array.length board) in
    if (not board.(row).(col).is_mine) && x <> col && y <> row then (
      board.(row).(col).is_mine <- true;
      incr mines_placed)
  done

let get_neighbors board x y =
  let directions = neighbors in
  List.fold_left
    (fun acc (dx, dy) ->
      let nx, ny = (x + dx, y + dy) in
      let cell = board.(nx).(ny) in
      if
        nx >= 0
        && nx < Array.length board
        && ny >= 0
        && ny < Array.length board.(0)
        && (not cell.is_mine) && not cell.is_revealed
      then (nx, ny) :: acc
      else acc)
    [] directions

let count_neighbors board x y =
  let directions = neighbors in
  List.fold_left
    (fun acc (dx, dy) ->
      let nx, ny = (x + dx, y + dy) in
      if
        nx >= 0
        && nx < Array.length board
        && ny >= 0
        && ny < Array.length board.(0)
        && board.(nx).(ny).is_mine
      then acc + 1
      else acc)
    0 directions

let update_neighbor_counts board =
  Array.iteri
    (fun x row ->
      Array.iteri
        (fun y cell ->
          if not cell.is_mine then
            cell.neighboring_mines <- count_neighbors board x y)
        row)
    board

let total_mines (state : game_state) =
  Array.fold_left
    (fun acc row ->
      acc
      + Array.fold_left
          (fun row_acc cell -> if cell.is_mine then row_acc + 1 else row_acc)
          0 row)
    0 state.board

let initialize_board board_info =
  let board = create_board (fst board_info) in
  (* place_mines board (snd board_info); update_neighbor_counts board; *)
  { board; game_over = false; started = false }

let print_board board =
  Array.iter
    (fun row ->
      Array.iter
        (fun cell ->
          if cell.is_mine then print_string "M "
          else print_int cell.neighboring_mines;
          print_string " ")
        row;
      print_newline ())
    board
