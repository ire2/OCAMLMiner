open OUnit2

(* Mocking the Timer module for testing due to errors in Java Script
   Dependencies *)

module MockTimer = struct
  type timer_mode =
    | Countdown of int
    | Stopwatch

  type timer = {
    mutable timer_interval : int option;
    remaining_time : int ref;
    mode : timer_mode;
  }
  [@@ocaml.warning "-69"]

  let create_timer mode =
    { timer_interval = None; remaining_time = ref 0; mode }

  let get_mode timer = timer.mode
  let get_remaining_time timer = !(timer.remaining_time)
  let set_remaining_time timer value = timer.remaining_time := value

  let get_timer_message timer =
    match timer.mode with
    | Countdown _ ->
        Printf.sprintf "Time left: %d seconds" !(timer.remaining_time)
    | Stopwatch ->
        Printf.sprintf "Time passed: %d seconds" !(timer.remaining_time)

  let start_timer timer =
    match get_mode timer with
    | Countdown _ ->
        if get_remaining_time timer > 0 then
          set_remaining_time timer (get_remaining_time timer - 1)
    | Stopwatch -> set_remaining_time timer (get_remaining_time timer + 1)

  let stop_timer timer = timer.timer_interval <- None

  let reset_timer timer duration =
    stop_timer timer;
    set_remaining_time timer duration
end

let test_create_timer _ =
  let timer = MockTimer.create_timer (Countdown 10) in
  assert_equal ~msg:"Timer mode should be Countdown" (MockTimer.Countdown 10)
    (MockTimer.get_mode timer);
  assert_equal ~msg:"Remaining time should be initialized to 0" 0
    (MockTimer.get_remaining_time timer)

let test_get_timer_message _ =
  let timer = MockTimer.create_timer (Countdown 10) in
  MockTimer.set_remaining_time timer 5;
  let message = MockTimer.get_timer_message timer in
  assert_equal ~msg:"Message should reflect remaining time"
    "Time left: 5 seconds" message;

  let timer = MockTimer.create_timer Stopwatch in
  MockTimer.set_remaining_time timer 3;
  let message = MockTimer.get_timer_message timer in
  assert_equal ~msg:"Message should reflect passed time"
    "Time passed: 3 seconds" message

let test_start_timer _ =
  let timer = MockTimer.create_timer (Countdown 5) in
  MockTimer.set_remaining_time timer 5;

  MockTimer.start_timer timer;
  assert_equal ~msg:"Timer should decrement remaining time" 4
    (MockTimer.get_remaining_time timer)

let test_stop_timer _ =
  let timer = MockTimer.create_timer (Countdown 5) in
  MockTimer.set_remaining_time timer 5;
  (* Simulate stopping the timer *)
  MockTimer.stop_timer timer;
  assert_equal ~msg:"Timer should stop without decrementing remaining time" 5
    (MockTimer.get_remaining_time timer)

(* Test reset_timer *)
let test_reset_timer _ =
  let timer = MockTimer.create_timer (Countdown 5) in
  MockTimer.set_remaining_time timer 5;
  MockTimer.reset_timer timer 10;
  assert_equal ~msg:"Timer should reset to new duration" 10
    (MockTimer.get_remaining_time timer)

(* Combine tests into a suite *)
let suite =
  "Timer Logic Tests"
  >::: [
         "test_create_timer" >:: test_create_timer;
         "test_get_timer_message" >:: test_get_timer_message;
         "test_start_timer" >:: test_start_timer;
         "test_stop_timer" >:: test_stop_timer;
         "test_reset_timer" >:: test_reset_timer;
       ]

let () = run_test_tt_main suite
