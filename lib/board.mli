(** [Board] handles all code related to creating and manipulating the
    minesweeper board. *)

type cell = {
  mutable is_revealed : bool;
  mutable is_mine : bool;
  mutable neighboring_mines : int;
  mutable is_flagged : bool; (* Add flagging field *)
}
(** A [cell] that represents an individual cell in a board that can contain a
    mine. Holds information about whether the cell has been revealed
    ([is_revealed]), has a mine ([is_mine]), the number of neighboring mines
    ([neighboring_mines]), and whether it has been flagged as a potential bomb
    carrier ([is_flagged]). *)

type game_state = {
  board : cell array array;
  mutable started : bool;
  mutable game_over : bool;
}
(** [game_state] represents the state of the game. It holds information about
    the board [board] as well as the information about whether the game has
    ended [game_over]. *)

(** A variant type that holds information about the difficulty of the game. It
    can be one of three values: easy, medium, or hard *)
type difficulty =
  | None
  | Easy
  | Medium
  | Hard

val get_difficulty : difficulty -> (int * int) * int
(** [get_difficulty difficulty] returns a tuple, with
    [fst get_difficulty difficulty] containing the dimensions of the board and
    [snd get_difficulty difficulty] containing the number of mines to be placed *)

val create_board : int * int -> cell array array
(** [create_board (nrows, ncols)] returns an empty board with no mines with
    [nrows] rows and [ncols] columns. *)

val place_mines : cell array array -> int -> int -> int -> unit
(** [place_mines board nmines x y] modifies [board] by placing mines in the
    empty [board]. They are placed at random and the number of mines [nmines]
    depends on the size of the board. There cannot be multiple mines in one
    cell. A mine cannot be place in the cell with coordinates ([x],[y])
    Requires: [board] contains no mines and [nmines] correctly corresponds board
    size. *)

val get_neighbors : cell array array -> int -> int -> (int * int) list
(** [get_neighbors board x y] returns a list of the neighbors that do not have
    mines of the cell located at [board.(x).(y)]. Requires:
    [0 <= x < Array.length board.(0)] and [0 <= y < Array.length board]. *)

val count_neighbors : cell array array -> int -> int -> int
(** [count_neighbors board x y] returns the number of neighboring mines that a
    given cell at [board.(x).(y)] has. Requires:
    [0 <= x < Array.length board.(0)] and [0 <= y < Array.length board].

    Example:
    [let board =
    [|
      [|empty; mine; mine|]
      [|empty; empty; empty|]
      [|mine; empty; empty|]
    |]]

    [count_neighbors board 0 0 = 1]; [count_neighbors board 2 2 = 0];
    [count_neighbors board 1 1 = 3] *)

val update_neighbor_counts : cell array array -> unit
(** [update_neighbor_counts board] modifies the neighbor counts of each cell in
    the board [board]. *)

val total_mines : game_state -> int
(** [total_mines state] returns the total number of mines on [state.board]. *)

val initialize_board : (int * int) * int -> game_state
(** [intialize_game board_info] initializes a [game_state] with a board that has
    a size and mine count dependent on [board_info]. Each cell has data on the
    number of neighbors and the game is not over. *)
