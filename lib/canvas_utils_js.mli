open Canvas_utils
(** [Canvas_utils_js] contains functions and type aliases for better
    readability; only contains JS OCaml modules *)

type context2d = Js_of_ocaml.Dom_html.canvasRenderingContext2D Js_of_ocaml.Js.t
(** [context2d] represents the 2D rendering context for a canvas element. The
    rendering context provides methods and properties for drawing 2D graphics on
    a canvas element. *)

type canvas = Js_of_ocaml.Dom_html.canvasElement Js_of_ocaml.Js.t
(** [canvas] represents a canvas element in the DOM. A canvas element displays
    graphics via its associated rendering context. *)

type element = Js_of_ocaml.Dom_html.element Js_of_ocaml.Js.t
(** [element] represents a generic HTML element. *)

type select = Js_of_ocaml.Dom_html.selectElement Js_of_ocaml.Js.t
(** [select] represents a selector HTML element *)

type mouse_event = Js_of_ocaml.Dom_html.mouseEvent Js_of_ocaml.Js.t
(** [mouse_event] represents a mouse event in the DOM used for event handling in
    response to user actions. *)

type timeout_id = Js_of_ocaml.Dom_html.timeout_id
(** [timeout_id] represents a timeout ID returned by [set_timeout]. *)

(** UI Constants *)

val font : Js_of_ocaml.Js.js_string Js_of_ocaml.Js.t
(** [font] is the default font used for text rendering. *)

(** Helper functions *)

val get_selector_by_id : string -> select option
(** [get_selector_by_id id] retrieves a select element by its ID [id] if found. *)

val get_canvas_by_id : string -> canvas option
(** [get_canvas_by_id id] retrieves a canvas element by its ID [id] if found. *)

val get_element_by_id : string -> element option
(** [get_element_by_id id] retrieves an element by its ID [id] if found. *)

val log_error : string -> unit
(** [log_error msg] logs an error message [msg] to the console. *)

val get_context : canvas -> context2d
(** [get_context c] retrieves the 2D context of a canvas element [c]. *)

val show_alert : string -> unit
(** [show_alert msg] displays an alert dialog to the user with the message
    [msg]. *)

val get_mouse_coords : mouse_event -> int * int
(** [get_mouse_coords ev] retrieves the mouse coordinates from a mouse event
    [ev]. *)

val set_timeout : (unit -> unit) -> float -> Js_of_ocaml.Dom_html.timeout_id
(** [set_timeout f time] sets a timeout to call function [f] after [time]
    milliseconds. *)

val clear_timeout : Js_of_ocaml.Dom_html.timeout_id -> unit
(** [clear_timeout id] clears the timeout specified by [id]. *)

val js_true : bool Js_of_ocaml.Js.t
(** [js_true] represents the JavaScript boolean `true`. *)

val js_false : bool Js_of_ocaml.Js.t
(** [js_false] represents the JavaScript boolean `false`. *)

val log_exception : exn -> unit
