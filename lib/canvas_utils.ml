(** Constants for Func *)

let default_divisor = 40

let neighbors =
  [ (-1, -1); (-1, 0); (-1, 1); (0, 1); (1, 1); (1, 0); (1, -1); (0, -1) ]

(** UI Constants *)

let cell_size = 40
let color_mine = "#F00"
let color_revealed = "#FFF"
let color_unrevealed = "#CCC"
let font_style = "#000"
let line_style = "#000"
let default_starting_size = 10
let default_mine_starting = 10
let offset_text_x = 10
let offset_text_y = 25

(** Timer Constants *)

let timer_text_id = "timer-text"
let times_up_str = "Time Up!!"
let default_milliseconds = 1000.0

let time_passed_str_stopwatch : (int -> int -> string, unit, string) format =
  "Time passed: %02d:%02d"

let time_countdown_str : (int -> int -> string, unit, string) format =
  "Time left: %02d:%02d"

(* Game Constants *)

let start_id = "start-button"
let play_id = "play-icon"
let minecount_id = "mineCount"
let unrevealed_id = "unrevealedCount"
let difficulty_id = "difficultySelector"
let canvas_id = "my_canvas"
let hint_button_id = "hint-button"
let remaining_flags = ref 0
let remaining_mines = ref 0
let mouse_coords = ref (0, 0)
let unrevealed_cells = ref (0 * 0)
let board_info = ref ((0, 0), 0)

(* Helper functions *)
