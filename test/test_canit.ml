Printexc.record_backtrace true

open OUnit2
open QCheck
open Sweeper.Board

let difficulties =
  [
    Sweeper.Board.Easy;
    Sweeper.Board.Medium;
    Sweeper.Board.Hard;
    Sweeper.Board.None;
  ]

let make_total_mines_test difficulty =
  let board_info = Sweeper.Board.get_difficulty difficulty in
  let game = initialize_board board_info in
  let nmines = snd board_info in
  place_mines game.board nmines 0 0;
  match difficulty with
  | Sweeper.Board.Easy ->
      "total mines for easy" >:: fun _ ->
      assert_equal 10 (total_mines game) ~printer:string_of_int
  | Sweeper.Board.Medium ->
      "total mines for medium" >:: fun _ ->
      assert_equal 40 (total_mines game) ~printer:string_of_int
  | Sweeper.Board.Hard ->
      "total mines for hard" >:: fun _ ->
      assert_equal 99 (total_mines game) ~printer:string_of_int
  | Sweeper.Board.None ->
      "total mines for none" >:: fun _ ->
      assert_equal 0 (total_mines game) ~printer:string_of_int

let total_mines_tests = List.map make_total_mines_test difficulties

let string_of_board_info board_info =
  "Board size: \n Rows: "
  ^ (board_info |> fst |> fst |> string_of_int)
  ^ "\n Columns: "
  ^ (board_info |> fst |> snd |> string_of_int)
  ^ "\n Mines: "
  ^ (board_info |> snd |> string_of_int)

let get_difficulty_test =
  "testing the [get_difficulty] function "
  >::: [
         ( "testing that getting the difficulty of Easy returns the correct \
            board information"
         >:: fun _ ->
           assert_equal
             ((8, 10), 10)
             (get_difficulty Easy) ~printer:string_of_board_info );
         ( "testing that getting the difficulty of Medium returns the correct \
            board information"
         >:: fun _ ->
           assert_equal
             ((14, 18), 40)
             (get_difficulty Medium) ~printer:string_of_board_info );
         ( "testing that getting the difficulty of Hard returns the correct \
            board information"
         >:: fun _ ->
           assert_equal
             ((20, 24), 99)
             (get_difficulty Hard) ~printer:string_of_board_info );
         ( "testing that getting the difficulty of None returns the correct \
            board information"
         >:: fun _ ->
           assert_equal
             ((0, 0), 0)
             (get_difficulty None) ~printer:string_of_board_info );
       ]

let string_of_cell x y cell =
  "Cell at (" ^ string_of_int x ^ "," ^ string_of_int y ^ "): \n is_revealed: "
  ^ string_of_bool cell.is_revealed
  ^ "\n is_mine: "
  ^ string_of_bool cell.is_mine
  ^ "\n neighboring_mines: "
  ^ string_of_int cell.neighboring_mines
  ^ "\n is_flagged: "
  ^ string_of_bool cell.is_flagged
  ^ "\n"

let string_of_board_dims dims =
  (dims |> fst |> string_of_int) ^ "x" ^ (dims |> snd |> string_of_int)

let make_create_board_test board_dims =
  "testing that the empty board contains a "
  ^ string_of_board_dims board_dims
  ^ " grid of cells with no mines and no neighbors and they are unrevealed"
  >:: fun _ ->
  let board = create_board board_dims in
  Array.iteri
    (fun i row ->
      Array.iteri
        (fun j cell ->
          assert_equal cell
            {
              is_revealed = false;
              is_mine = false;
              neighboring_mines = 0;
              is_flagged = false;
            }
            ~printer:(string_of_cell j i))
        row)
    board

let create_board_tests =
  difficulties |> List.map get_difficulty |> List.map fst
  |> List.map make_create_board_test

let make_place_mines_test _ =
  let () = Random.self_init () in
  let rows = 1 + Random.int 51 in
  let cols = 1 + Random.int 51 in
  let x = Random.int cols in
  let y = Random.int rows in
  let n_mines = Random.int (min rows cols) in
  "\nRows: " ^ string_of_int rows ^ "\nColumns: " ^ string_of_int cols ^ "\nX: "
  ^ string_of_int x ^ "\nY: " ^ string_of_int y
  >:: fun _ ->
  let board = create_board (rows, cols) in
  place_mines board n_mines x y;
  let mine_count =
    Array.fold_left
      (fun acc row ->
        acc
        + Array.fold_left
            (fun acc_cell cell ->
              if cell.is_mine then acc_cell + 1 else acc_cell)
            0 row)
      0 board
  in
  assert_equal n_mines mine_count ~printer:string_of_int

let place_mines_test =
  "testing place_mines with random sizes (up to 50) and random x, y \
   coordinates (up to 49)"
  >::: [
         make_place_mines_test ();
         make_place_mines_test ();
         make_place_mines_test ();
         make_place_mines_test ();
         make_place_mines_test ();
         make_place_mines_test ();
         make_place_mines_test ();
         make_place_mines_test ();
         make_place_mines_test ();
         make_place_mines_test ();
         make_place_mines_test ();
         make_place_mines_test ();
         make_place_mines_test ();
         make_place_mines_test ();
         make_place_mines_test ();
         make_place_mines_test ();
         make_place_mines_test ();
         make_place_mines_test ();
         make_place_mines_test ();
         make_place_mines_test ();
       ]

let count_neighbors_test_full =
  "testing that the neighbor count is accurate" >:: fun _ ->
  let board = create_board (5, 5) in
  place_mines board 15 3 3;
  assert_equal true (count_neighbors board 3 3 > 0) ~printer:string_of_bool

let count_neighbors_test_empty =
  "testing that the neighbor count is accurate" >:: fun _ ->
  let board = create_board (5, 5) in
  assert_equal 0 (count_neighbors board 3 3) ~printer:string_of_int

let update_neighbor_counts_test =
  "testing update_neighbor_count function" >:: fun _ ->
  let board_init = create_board (6, 6) in
  let board = create_board (6, 6) in
  update_neighbor_counts board;
  assert_equal board_init board

let print_tuple_list lst =
  List.fold_left
    (fun acc (a, b) ->
      acc ^ "(" ^ string_of_int a ^ ", " ^ string_of_int b ^ "); ")
    "[ " lst
  ^ "]"

let get_neighbors_test =
  QCheck.Test.make ~name:"testing get_neighbors function" ~count:50000
    (QCheck.pair
       (QCheck.int_range 3 100 |> QCheck.set_shrink Shrink.nil)
       (QCheck.int_range 3 100 |> QCheck.set_shrink Shrink.nil))
    (fun (width, height) ->
      let board = create_board (height, width) in
      let x = 1 + Random.int (width - 2) in
      let y = 1 + Random.int (height - 2) in
      let num_mines = 1 + Random.int (max height width) in
      place_mines board num_mines x y;
      let directions =
        [ (-1, -1); (-1, 0); (-1, 1); (0, -1); (0, 1); (1, -1); (1, 0); (1, 1) ]
      in
      let expected_neighbors =
        List.fold_left
          (fun acc (dx, dy) ->
            let nx, ny = (x + dx, y + dy) in
            if
              nx >= 0 && nx < width && ny >= 0 && ny < height
              && (not board.(nx).(ny).is_mine)
              && not board.(nx).(ny).is_revealed
            then (nx, ny) :: acc
            else acc)
          [] directions
      in
      let neighbors = get_neighbors board x y in
      List.sort compare neighbors = List.sort compare expected_neighbors)

let board_test_suite =
  "Board tests"
  >::: List.flatten
         [
           [ get_difficulty_test ];
           total_mines_tests;
           [ place_mines_test ];
           create_board_tests;
           [ count_neighbors_test_full; count_neighbors_test_empty ];
           [ update_neighbor_counts_test ];
         ]

let () = run_test_tt_main board_test_suite
let () = QCheck_runner.run_tests_main [ get_neighbors_test ]
