exception RuntimeError of string

module StringTable = Hashtbl.Make (String)

type table = {
  header : string list; (* e.g., ["username"; "time"] *)
  rows : (string * string) list; (* (username, time as string) *)
}

let take n lst =
  let rec aux n acc = function
    | [] -> List.rev acc
    | x :: xs -> if n > 0 then aux (n - 1) (x :: acc) xs else List.rev acc
  in
  aux n [] lst

(* Utility function to drop the first n elements of a list *)
let rec drop n lst =
  match lst with
  | [] -> []
  | _ :: xs -> if n > 0 then drop (n - 1) xs else lst

(* Find a variable in the StringTable *)
let find_var table var =
  match StringTable.find_opt table var with
  | Some v -> v
  | None -> raise (RuntimeError ("Variable not found: " ^ var))

(* Save a table to a CSV file *)
let save_table t var f =
  try
    let table = find_var t var in
    let filtered_rows =
      List.filter
        (fun (u, _) -> not (String.starts_with ~prefix:"dummy" u))
        table.rows
    in
    let formatted_rows =
      List.map (fun (username, time) -> [ username; time ]) filtered_rows
    in
    Csv.save f (table.header :: formatted_rows);
    table
  with RuntimeError msg -> raise (RuntimeError msg)

(* Read a table from a CSV file *)
let read_table filename =
  try
    let lines = Csv.load filename in
    match lines with
    | header :: rows ->
        let parsed_rows =
          List.map
            (fun row ->
              match row with
              | [ username; time ] -> (username, time)
              | _ -> raise (RuntimeError "Malformed CSV row"))
            rows
        in
        { header; rows = parsed_rows }
    | [] -> raise (RuntimeError "Empty CSV file")
  with RuntimeError msg -> raise (RuntimeError msg)

(* Compare tables by header and rows *)
let compare_tables t1 t2 = t1.header = t2.header && t1.rows = t2.rows

(* Print a table to the console *)
let print_table table =
  let print_row (username, time) = Printf.printf "%s %s\n" username time in
  Printf.printf "%s\n" (String.concat " " table.header);
  List.iter print_row table.rows

(* Add dummy entries to the table *)
let add_dummy_entries table n =
  let generate_dummy_row index =
    let username = "dummy" ^ string_of_int index in
    let time = string_of_int (index * 1000) in
    (* Example time as a string *)
    (username, time)
  in
  let dummy_rows = List.init n (fun index -> generate_dummy_row index) in
  { table with rows = table.rows @ dummy_rows }

(* Compare times as integers *)
let compare_times (user1, time1_str) (user2, time2_str) =
  let time1 = int_of_string time1_str in
  let time2 = int_of_string time2_str in
  if time1 < time2 then -1
  else if time1 > time2 then 1
  else String.compare user1 user2

(* Get top N users by time, adding dummy rows if needed *)
let get_top_n_users table n =
  Printf.printf "Initial rows: %s\n"
    (String.concat ", "
       (List.map (fun (u, t) -> Printf.sprintf "(%s, %s)" u t) table.rows));

  let sorted_rows = List.rev (List.sort compare_times table.rows) in
  Printf.printf "Sorted rows: %s\n"
    (String.concat ", "
       (List.map (fun (u, t) -> Printf.sprintf "(%s, %s)" u t) sorted_rows));

  let current_count = List.length sorted_rows in
  Printf.printf "Current count: %d, Target count: %d\n" current_count n;

  if current_count >= n then (
    let top_rows = take n sorted_rows in
    Printf.printf "Top rows (no dummy needed): %s\n"
      (String.concat ", "
         (List.map (fun (u, t) -> Printf.sprintf "(%s, %s)" u t) top_rows));
    { table with rows = top_rows })
  else
    let dummy_needed = n - current_count in
    Printf.printf "Adding %d dummy rows\n" dummy_needed;

    let updated_table = add_dummy_entries table dummy_needed in
    Printf.printf "Updated table with dummies: %s\n"
      (String.concat ", "
         (List.map
            (fun (u, t) -> Printf.sprintf "(%s, %s)" u t)
            updated_table.rows));

    let updated_sorted_rows =
      List.rev (List.sort compare_times updated_table.rows)
    in
    Printf.printf "Updated sorted rows: %s\n"
      (String.concat ", "
         (List.map
            (fun (u, t) -> Printf.sprintf "(%s, %s)" u t)
            updated_sorted_rows));

    let top_rows = take n updated_sorted_rows in
    Printf.printf "Final top rows: %s\n"
      (String.concat ", "
         (List.map (fun (u, t) -> Printf.sprintf "(%s, %s)" u t) top_rows));

    { table with rows = top_rows }

(* Function to merge two tables *)
let merge_tables table1 table2 =
  if table1.header <> table2.header then
    raise (RuntimeError "Headers do not match")
  else { table1 with rows = table1.rows @ table2.rows }

let get_user_best_score table username =
  let user_times = List.filter (fun (u, _) -> u = username) table.rows in
  match user_times with
  | [] ->
      Printf.printf "User %s doesn't have a time\n" username;
      None
  | _ ->
      let best_time =
        List.fold_left
          (fun acc (_, time) ->
            let time_int = int_of_string time in
            if time_int < acc then time_int else acc)
          max_int user_times
      in
      Printf.printf "User %s's best time: %d\n" username best_time;
      Some best_time
