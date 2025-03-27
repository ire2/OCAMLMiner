open Js_of_ocaml
include Canvas_utils

type timer_mode =
  | Countdown of int
  | Stopwatch

type timer = {
  mutable timer_interval : Dom_html.timeout_id option;
  time : int ref;
  mode : timer_mode;
}
(* AF: a [timer] is represented by a mutable [timer_interval] field used to
   describe the start time of the timer if in countdown mode, a [time] field to
   represent the current time it is at, and a [mode] field that specifies if it
   is in countdown or stopwatch mode. *)

let create_timer (mode : timer_mode) : timer =
  { timer_interval = None; time = ref 0; mode }

let get_mode (timer : timer) : timer_mode = timer.mode
let get_time (timer : timer) : int = !(timer.time)
let set_time (timer : timer) (value : int) : unit = timer.time := value

let get_timer_message (timer : timer) : string =
  let total_seconds = !(timer.time) in
  let minutes = total_seconds / 60 in
  let seconds = total_seconds mod 60 in
  match timer.mode with
  | Countdown _ -> Printf.sprintf time_countdown_str minutes seconds
  | Stopwatch -> Printf.sprintf time_passed_str_stopwatch minutes seconds

let update_timer_display (timer : timer) : unit =
  let timer_element = Dom_html.getElementById timer_text_id in
  let message = get_timer_message timer in
  timer_element##.textContent := Js.some (Js.string message)

let start_timer (timer : timer) : unit =
  let rec tick () =
    match timer.mode with
    | Countdown _ ->
        if !(timer.time) > 0 then (
          decr timer.time;
          update_timer_display timer;
          timer.timer_interval <-
            Some
              (Dom_html.window##setTimeout
                 (Js.wrap_callback tick) default_milliseconds))
        else Dom_html.window##alert (Js.string times_up_str)
    | Stopwatch ->
        incr timer.time;
        update_timer_display timer;
        timer.timer_interval <-
          Some
            (Dom_html.window##setTimeout
               (Js.wrap_callback tick) default_milliseconds)
  in
  tick ()

let stop_timer (timer : timer) : unit =
  match timer.timer_interval with
  | Some interval -> Dom_html.window##clearTimeout interval
  | None -> ()

let reset_timer (timer : timer) (duration : int) : unit =
  stop_timer timer;
  set_time timer duration;
  update_timer_display timer
