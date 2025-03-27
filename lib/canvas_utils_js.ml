open Js_of_ocaml
open Canvas_utils

type context2d = Dom_html.canvasRenderingContext2D Js.t
type canvas = Dom_html.canvasElement Js.t
type select = Dom_html.selectElement Js.t
type element = Dom_html.element Js.t
type mouse_event = Dom_html.mouseEvent Js.t
type timeout_id = Dom_html.timeout_id

(** UI Constants *)
let font = Js.string "20px Arial"

(* Helper functions *)

let get_canvas_by_id (id : string) : canvas option =
  Dom_html.getElementById_coerce id Dom_html.CoerceTo.canvas

let get_selector_by_id (id : string) : select option =
  Dom_html.getElementById_coerce id Dom_html.CoerceTo.select

let get_element_by_id (id : string) : element option =
  Dom_html.getElementById_opt id

let set_width width canvas = canvas##set width
let set_height height canvas = canvas##set height
let log_error (msg : string) = Firebug.console##log (Js.string msg)
let get_context (canvas : canvas) : context2d = canvas##getContext Dom_html._2d_
let show_alert (msg : string) = Dom_html.window##alert (Js.string msg)

let log_exception exn =
  let message = Printexc.to_string exn in
  let stack = Js.Unsafe.eval_string "new Error().stack" in
  log_error ("OCaml exception: " ^ message ^ "\n" ^ Js.to_string stack)

let get_mouse_coords (ev : mouse_event) : int * int =
  let x = ev##.offsetX / default_divisor in
  let y = ev##.offsetY / default_divisor in
  (x, y)

let set_timeout (f : unit -> unit) (time : float) : timeout_id =
  Dom_html.window##setTimeout (Js.wrap_callback f) time

let clear_timeout (id : timeout_id) : unit = Dom_html.window##clearTimeout id
let js_true = Js._true
let js_false = Js._false
let canvas = get_canvas_by_id canvas_id
let selector = get_selector_by_id difficulty_id
let restart_btn = get_element_by_id play_id
let icon = get_element_by_id play_id
let minecount_text = get_element_by_id minecount_id
let unrevealed_text = get_element_by_id unrevealed_id
