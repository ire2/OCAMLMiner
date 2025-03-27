(** [Timer] module provides functionality for managing timers. *)

(** [timer_mode] represents the mode of the timer.
    - [Countdown] mode with the initial time in seconds
    - [Stopwatch] mode to count elapsed time. *)
type timer_mode =
  | Countdown of int
  | Stopwatch

type timer
(** [timer] represents the state of a timer. *)

val create_timer : timer_mode -> timer
(** [create_timer mode] creates a new timer with the given mode. *)
val get_mode : timer -> timer_mode
(** [get_mode timer] returns the mode of the timer. *)
val get_time : timer -> int
(** [get_time timer] returns the time in seconds. *)
val set_time : timer -> int -> unit
(** [set_time timer value] sets the time to [value]. *)

val get_timer_message : timer -> string
(** [get_timer_message timer] returns a message based on the current mode and
    time. *)
val update_timer_display : timer -> unit
(** [update_timer_display timer] updates the display of the timer based on the
    current mode and time. *)

val start_timer : timer -> unit
(** [start_timer timer] starts the timer based on the current mode ([Countdown]
    or [Stopwatch]). *)

val stop_timer : timer -> unit
(** [stop_timer timer] stops the timer and clears the interval to halt the
    periodic updates. *)

val reset_timer : timer -> int  -> unit
(** [reset_timer timer duration] resets the timer to its initial state. For
    countdown mode, it sets the time to [duration]. *)
