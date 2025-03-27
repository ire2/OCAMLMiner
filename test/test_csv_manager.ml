open OUnit2
open Sweeper.Csv_manager

(* Test for find_var function *)
let test_find_var _ =
  (* Prepare a string table with sample data *)
  let table1 =
    {
      header = [ "username"; "time" ];
      rows = [ ("user1", "1000"); ("user2", "2000") ];
    }
  in
  let table2 =
    {
      header = [ "username"; "time" ];
      rows = [ ("userA", "3000"); ("userB", "4000") ];
    }
  in
  let string_table = StringTable.create 10 in
  StringTable.add string_table "table1" table1;
  StringTable.add string_table "table2" table2;

  (* Test case: Successful retrieval of table1 *)
  let retrieved_table1 = find_var string_table "table1" in
  assert_equal ~msg:"Table1 should be retrieved correctly" table1
    retrieved_table1;

  (* Test case: Successful retrieval of table2 *)
  let retrieved_table2 = find_var string_table "table2" in
  assert_equal ~msg:"Table2 should be retrieved correctly" table2
    retrieved_table2;

  (* Test case: Variable not found *)
  assert_raises (RuntimeError "Variable not found: table3") (fun () ->
      find_var string_table "table3")

(* Test for save_table and read_table functions *)
let test_save_and_read_table _ =
  (* Prepare a sample table *)
  let table =
    {
      header = [ "username"; "time" ];
      rows = [ ("user1", "1000"); ("user2", "2000") ];
    }
  in
  let string_table = StringTable.create 10 in
  StringTable.add string_table "table1" table;

  (* Ensure the test_output directory exists *)
  if not (Sys.file_exists "test_output") then Unix.mkdir "test_output" 0o755;

  (* Test case: Save table to a file *)
  let filename = "test_output/test_table.csv" in
  let saved_table = save_table string_table "table1" filename in
  assert_equal ~msg:"Saved table should match the original table" table
    saved_table;

  (* Test case: Read the saved table and verify its content *)
  let read_table_result = read_table filename in
  assert_equal ~msg:"Read table should match the saved table" table
    read_table_result

(* Test for adding dummy entries *)
let test_add_dummy_entries _ =
  (* Prepare a sample table *)
  let table =
    { header = [ "username"; "time" ]; rows = [ ("user1", "1000") ] }
  in
  let table_with_dummies = add_dummy_entries table 3 in
  let expected_rows =
    [
      ("user1", "1000"); ("dummy0", "0"); ("dummy1", "1000"); ("dummy2", "2000");
    ]
  in
  let expected_table =
    { header = [ "username"; "time" ]; rows = expected_rows }
  in

  (* Print both tables for debugging purposes *)
  Printf.printf "Table with dummies:\n";
  print_table table_with_dummies;
  Printf.printf "Expected Table with dummies:\n";
  print_table expected_table;

  (* Verify the modified table matches the expected table *)
  assert_equal ~msg:"Table with dummy entries should match the expected table"
    expected_table table_with_dummies

(* Test for getting top N users *)
let test_get_top_n_users _ =
  let table =
    {
      header = [ "username"; "time" ];
      rows = [ ("user1", "1000"); ("user2", "2000"); ("user3", "3000") ];
    }
  in

  (* Case 1: Get top 2 users *)
  let top_2_users = get_top_n_users table 2 in
  let expected_top_2 =
    {
      header = [ "username"; "time" ];
      rows = [ ("user3", "3000"); ("user2", "2000") ];
    }
  in
  assert_equal ~msg:"Top 2 users mismatch" expected_top_2 top_2_users;

  (* Case 2: Request more users than available, requiring dummy rows *)
  let top_5_users = get_top_n_users table 5 in
  let expected_top_5 =
    {
      header = [ "username"; "time" ];
      rows =
        [
          ("user3", "3000");
          ("user2", "2000");
          ("user1", "1000");
          ("dummy1", "1000");
          ("dummy0", "0");
        ];
    }
  in
  assert_equal ~msg:"Top 5 users with dummy rows mismatch" expected_top_5
    top_5_users

let test_merge_tables _ =
  let table1 =
    {
      header = [ "username"; "time" ];
      rows = [ ("user1", "1000"); ("user2", "2000") ];
    }
  in
  let table2 =
    {
      header = [ "username"; "time" ];
      rows = [ ("user3", "3000"); ("user4", "4000") ];
    }
  in
  let merged_table = merge_tables table1 table2 in
  let expected_table =
    {
      header = [ "username"; "time" ];
      rows =
        [
          ("user1", "1000");
          ("user2", "2000");
          ("user3", "3000");
          ("user4", "4000");
        ];
    }
  in
  assert_equal ~msg:"Merged table should match expected result" expected_table
    merged_table

let test_get_user_best_score _ =
  let table =
    {
      header = [ "username"; "time" ];
      rows =
        [
          ("user1", "1000");
          ("user2", "2000");
          ("user1", "800");
          ("user3", "3000");
        ];
    }
  in

  (* Case 1: User with multiple scores *)
  let best_score_user1 = get_user_best_score table "user1" in
  assert_equal ~msg:"User1's best time should be 800" (Some 800)
    best_score_user1;

  (* Case 2: User with a single score *)
  let best_score_user3 = get_user_best_score table "user3" in
  assert_equal ~msg:"User3's best time should be 3000" (Some 3000)
    best_score_user3;

  (* Case 3: User not in the list *)
  let best_score_user4 = get_user_best_score table "user4" in
  assert_equal ~msg:"User4 should not have a time" None best_score_user4

(* Test for take function *)
let test_take _ =
  assert_equal ~msg:"Take 3 from list" [ 1; 2; 3 ] (take 3 [ 1; 2; 3; 4; 5 ]);
  assert_equal ~msg:"Take 0 from list" [] (take 0 [ 1; 2; 3; 4; 5 ]);
  assert_equal ~msg:"Take more than list length" [ 1; 2; 3; 4; 5 ]
    (take 10 [ 1; 2; 3; 4; 5 ])

(* Test for drop function *)
let test_drop _ =
  assert_equal ~msg:"Drop 3 from list" [ 4; 5 ] (drop 3 [ 1; 2; 3; 4; 5 ]);
  assert_equal ~msg:"Drop 0 from list" [ 1; 2; 3; 4; 5 ]
    (drop 0 [ 1; 2; 3; 4; 5 ]);
  assert_equal ~msg:"Drop more than list length" [] (drop 10 [ 1; 2; 3; 4; 5 ])

(* Test suite *)
let suite =
  "CSV Utilities Test Suite"
  >::: [
         "test_find_var" >:: test_find_var;
         "test_save_and_read_table" >:: test_save_and_read_table;
         "test_add_dummy_entries" >:: test_add_dummy_entries;
         "test_get_top_n_users" >:: test_get_top_n_users;
         "test_take" >:: test_take;
         "test_drop" >:: test_drop;
         "test_merge_tables" >:: test_merge_tables;
         "test_get_user_best_score" >:: test_get_user_best_score;
       ]

(* Run the test suite *)
let () = run_test_tt_main suite
