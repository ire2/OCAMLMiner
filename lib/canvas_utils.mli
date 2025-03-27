(** [Canvas_utils] contains functions and type aliases for better readability *)

(** Constants for Func *)

val default_divisor : int
(** [default_divisor] is the default divisor used for mouse event coordinates. *)

val neighbors : (int * int) list
(** [neighbors] is a list of relative coordinates for the neighbors of a cell in
    the grid. *)

(** UI Constants *)

val cell_size : int
(** [cell_size] is the width in pixels of an individual cell in the grid. *)

val color_mine : string
(** [color_mine] is the color used to represent mines in the grid. *)

val color_revealed : string
(** [color_revealed] is the color used to represent revealed cells in the grid. *)

val color_unrevealed : string
(** [color_unrevealed] is the color used to represent unrevealed cells in the
    grid. *)

val font_style : string
(** [font_style] is the color used for text rendering. *)

val line_style : string
(** [line_style] is the color used for grid lines. *)

val default_starting_size : int
(** [default_starting_size] is the default size of the grid in [Board]. *)

val default_mine_starting : int
(** [default_mine_starting] is the default number of mines in [Board]. *)

val offset_text_x : int
(** [offset_text_x] is the horizontal offset used for text positioning within a
    cell. *)

val offset_text_y : int
(** [offset_text_y] is the vertical offset used for text positioning within a
    cell. *)

(** Timer Constants *)

val timer_text_id : string
(** [timer_text_id] is the ID of the element used to display timer text. *)

val times_up_str : string
(** [times_up_str] is the message displayed when the timer reaches zero. *)

val default_milliseconds : float
(** [default_milliseconds] is the default time in milliseconds used in [Timer]. *)

val time_passed_str_stopwatch : (int -> int -> string, unit, string) format
(** [time_passed_str_stopwatch] is the message displayed for the stopwatch mode
    in [Timer]. *)

val time_countdown_str : (int -> int -> string, unit, string) format
(** [time_countdown_str] is the message displayed for the countdown mode in
    [Timer]. *)

(* Game Constants *)

val hint_button_id : string
(** [hint_button_id] is the ID of the button used to display a hint. *)

val start_id : string
(** [start_id] is the ID of the button used to start the game. *)

val play_id : string
(** [play_id] is the ID of the icon used to play the game. *)

val minecount_id : string
(** [minecount_id] is the ID of the element used to display the number of mines
    remaining. *)

val unrevealed_id : string
(** [unrevealed_id] is the ID of the element used to display the number of
    unrevealed cells remaining. *)

val difficulty_id : string
(** [difficulty_id] is the ID of the select element used to select the game
    difficulty. *)

val canvas_id : string
(** [canvas_id] is the ID of the canvas element used to render the game board. *)

val remaining_flags : int ref
(** [remaining_flags] is the number of flags remaining to be placed on the grid. *)

val remaining_mines : int ref
(** [remaining_mines] is the number of mines remaining to be placed on the grid. *)

val mouse_coords : (int * int) ref
(** [mouse_coords] is the current mouse coordinates. *)

val unrevealed_cells : int ref
(** [unrevealed_cells] is the number of unrevealed cells remaining on the grid. *)

val board_info : ((int * int) * int) ref
(** [board_info] is the information about the current game board. *)
