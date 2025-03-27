open Canvas_utils_js

open Canvas_utils
(** [Load] handles the creation of all graphics. *)

val cell_size : int
(** [cell_size] is the width in pixels of an individual cell in the board. *)

val set_fill_style : context2d -> string -> unit
(** [set_fill_style c color] sets fill color to [color] in canvas [c]. Requires:
    [color] is a valid CSS color string. *)

val draw_cell : context2d -> int -> int -> string -> unit
(** [draw_cell c x y color] draws a cell on canvas [c] at the coordinates
    ([x],[y]) with color [color]. Requires: [x >= 0] and [y >= 0] and [color] is
    a valid CSS color string *)

val draw_text : context2d -> int -> int -> string -> unit
(** [draw_text c x y text] draws black text [text], with font size 20px and font
    Arial at ([x],[y]) in the canvas [c]. The x coordinate is padded to the
    right by 10 pixels and y coordinate is padded down by 25 pixels. *)
(* TODO: CHANGE FONT SPEC HERE IF NEEDED *)

val draw_grid_lines : context2d -> int -> int -> unit
(** [draw_grid_lines c rows cols] draws [rows] * [cols] gridlines on [c] with a
    gap of 40 pixels between the lines. Requires: [rows > 0] and [cols > 0] *)

val get_cell_color : Board.cell -> bool -> string
(** [get_cell_color cell game_over] determines the color of [cell] after either
    clicking on it ([game_over] is [false]) or losing the game ([game_over] is
    [true]). If the cell is a mine then it is red (game is lost). Otherwise, the
    cell is white if [game_over = false] or light grey if [game_over = true]. *)

val render_board : context2d -> Board.game_state -> int * int -> unit
(** [render_board ctx state (nrows,ncols)] renders [state.board] onto the canvas
    [ctx]. Draws the number of neighbors when a cell is clicked, draws the cells
    on initialization, and colors the cells before/after they are clicked. Also
    draws the gridlines for [nrows] rows and [ncols] columns *)
