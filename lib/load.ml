open Board
open Js_of_ocaml
open Board
include Canvas_utils
include Canvas_utils_js

let set_fill_style (ctx : context2d) (color : string) =
  ctx##.fillStyle := Js.string color

let draw_cell (ctx : context2d) (x : int) (y : int) (color : string) =
  set_fill_style ctx color;
  ctx##fillRect
    (float_of_int (x * cell_size))
    (float_of_int (y * cell_size))
    (float_of_int cell_size) (float_of_int cell_size)

let get_num_color nmines =
  match nmines with
  | 1 -> "blue"
  | 2 -> "green"
  | 3 -> "red"
  | 4 -> "purple"
  | 5 -> "yellow"
  | 6 -> "orange"
  | 7 -> "pink"
  | _ -> "black"

let draw_text (ctx : context2d) (x : int) (y : int) (text : string) =
  let color =
    match int_of_string_opt text with
    | Some n -> get_num_color n
    | None -> font_style
  in
  set_fill_style ctx color;
  ctx##.font := font;
  ctx##fillText (Js.string text)
    (float_of_int ((x * cell_size) + offset_text_x))
    (float_of_int ((y * cell_size) + offset_text_y))

let draw_grid_lines (ctx : context2d) (rows : int) (cols : int) =
  ctx##.strokeStyle := Js.string line_style;
  for i = 0 to rows do
    let y = float_of_int (i * cell_size) in
    ctx##beginPath;
    ctx##moveTo 0. y;
    ctx##lineTo (float_of_int (cols * cell_size)) y;
    ctx##stroke
  done;
  for j = 0 to cols do
    let x = float_of_int (j * cell_size) in
    ctx##beginPath;
    ctx##moveTo x 0.;
    ctx##lineTo x (float_of_int (rows * cell_size));
    ctx##stroke
  done

let get_cell_color (cell : cell) (game_over : bool) : string =
  if cell.is_revealed then if cell.is_mine then color_mine else color_revealed
  else if game_over && cell.is_mine then color_mine
  else if cell.is_flagged then "#FFFF00"
  else color_unrevealed

let render_board (ctx : context2d) (state : game_state) (nrows, ncols) =
  try
    Array.iteri
      (fun x row ->
        Array.iteri
          (fun y cell ->
            let color = get_cell_color cell state.game_over in
            draw_cell ctx x y color;
            if
              cell.is_revealed && (not cell.is_mine)
              && cell.neighboring_mines > 0
            then draw_text ctx x y (string_of_int cell.neighboring_mines))
          row)
      state.board;
    draw_grid_lines ctx nrows ncols
  with exn -> log_exception exn
