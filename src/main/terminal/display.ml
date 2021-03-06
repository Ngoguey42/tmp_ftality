(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   display.ml                                         :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: Ngo <ngoguey@student.42.fr>                +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2016/06/03 17:26:03 by Ngo               #+#    #+#             *)
(*   Updated: 2016/06/21 15:43:19 by ngoguey          ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

module Make (Key : Term_intf.Key_intf)
            (KeyPair : Shared_intf.KeyPair_intf
             with type key = Key.t)
            (Graph : Shared_intf.Graph_inst_intf
             with module KP = KeyPair)
            (Algo : Shared_intf.Algo_intf
             with type key = Key.t
             with module KP = KeyPair
             with module G = Graph)
       : Shared_intf.Display_intf =
  struct

    (* type keypair = KeyPair.t *)
    (* type vertex = Graph.V.t *)
    (* type edge = Graph.E.t *)


    (* Internal *)

    (* TODO: remove wait() function  *)
    let wait milli =
      let sec = milli /. 1000. in
      let tm1 = Unix.gettimeofday () in
      while Unix.gettimeofday () -. tm1 < sec do () done

    module Input =
      struct

        (* Key presses detection with `ncurses` using non-blocking `getch()`:
         * When next() detects an input it creates a `key set` with this key,
         *   and opens a `range_millisecf` millisec time frame in which the user
         *   may press new keys that will be added to the set. Each new key
         *   added to the set extend the time frame by `incrrange_millisecf`
         *   milliseconds.
         *)

        (* Key presses detection with `termcap` using non-blocking `input_char`:
         * When next() detects an input it opens a `range_millisecf` millisec
         *   time frame in which the user may press new keys.
         *)

        module KS = KeyPair.Set
        (* TODO: implement clear screan with \012 *)
        type press = Exit | Empty | Set of KS.t

        let range_msf = 150. /. 1000.
        let incrrange_msf = 125. /. 1000.

        let next dat =

          (* `char list` of `stdin` *)
          let read_csi_seq () =
            let rec aux l =
              match input_char stdin with
              | exception End_of_file -> l
              | c when c >= '@' && c <= '~' -> c::l
              | c  -> aux (c::l)
            in
            aux []
            |> List.rev
            |> List.cons '['
          in

          (* `char list` of `stdin` *)
          let read_escape_seq () =
            match input_char stdin with
            | exception End_of_file -> []
            | '[' -> read_csi_seq ()
            | c -> [c]
          in

          (* `press` of `keypair set` *)
          let return_keyset kset =
            if KS.is_empty kset
            then Empty
            else Set kset
          in

          (* 1. scan a given `char` and return or recurse with `key` *)
          let rec build_keyset kset timeout c =
            match c with
            | '\004' ->
               Exit
            | '\027' ->
               begin match read_escape_seq () with
               | [] -> Exit
               | l -> recurse_with_key kset timeout (Key.of_sequence l)
               end
            | c ->
               recurse_with_key kset timeout (Key.of_char c)

          (* 2. from a `key` create a `keypair` and add it to `keypair set` *)
          and recurse_with_key kset timeout k =
            let now = Unix.gettimeofday () in
            match Algo.keypair_of_key dat k with
            | None -> let kp = KeyPair.of_key k in
                      wait_next_char (KS.add kp kset) (now +. incrrange_msf)
            | Some kp -> wait_next_char (KS.add kp kset) (now +. incrrange_msf)

          (* 3. wait for the next char and return or recurse with `char` *)
          and wait_next_char kset timeout =
            let rec aux () =
              let now = Unix.gettimeofday () in
              if now > timeout then
                None
              else match input_char stdin with
                   | exception End_of_file -> aux ()
                   | c -> Some c
            in
            match aux () with
            | None -> return_keyset kset
            | Some c -> build_keyset kset timeout c
          in
          match input_char stdin with
          | exception End_of_file -> Empty
          | c -> build_keyset KS.empty (Unix.gettimeofday () +. range_msf) c

        (* Program main loop *)
        let loop_err algodat_init =
          let rec aux dat =
            match next dat with
            | Empty -> aux dat
            | Exit -> Ok ()
            | Set kset -> match Algo.on_key_press_err dat kset with
                          | Ok (dat', spellcast) ->
                             (* TODO: spellcast *)
                             aux dat'
                          | Error msg -> Error msg
          in
          aux algodat_init
      end

    let init_termcap () =
      (* TODO: check for error exceptions *)
      let terminfo = Unix.tcgetattr Unix.stdin in
      let newterminfo = {terminfo with
                          Unix.c_icanon = false
                        ; Unix.c_vmin = 0
                        ; Unix.c_echo = false
                        ; Unix.c_vtime = 0}
      in
      at_exit (fun _ -> Unix.tcsetattr Unix.stdin Unix.TCSAFLUSH terminfo);
      Ftlog.outnl "Init termcaps";
      Unix.tcsetattr Unix.stdin Unix.TCSAFLUSH newterminfo;
      Ok ()


    (* Exposed *)

    (* let declare_keypair kp = *)
    (*   Ftlog.lvl 8; *)
    (*   Ftlog.outnl "Display.declare_keypair(%s)" *)
    (*                  (KeyPair.to_string kp); *)
    (*   () *)

    (* let declare_vertex v = *)
    (*   Ftlog.lvl 8; *)
    (*   Ftlog.outnl "Display.declare_vertex(%s)" *)
    (*                  (Graph.V.label v |> Graph.Vlabel.to_string); *)
    (*   () *)

    (* let declare_edge e = *)
    (*   Ftlog.lvl 8; *)
    (*   Ftlog.outnl "Display.declare_edge(src:%s label:%s dst:%s)" *)
    (*                  (Graph.E.src e |> Graph.V.label |> Graph.Vlabel.to_string) *)
    (*                  (Graph.E.label e |> Graph.Elabel.to_string) *)
    (*                  (Graph.E.dst e |> Graph.V.label |> Graph.Vlabel.to_string); *)
    (*   () *)

    (* let focus_vertex_err v = *)
    (*   Ftlog.lvl 8; *)
    (*   Graph.V.label v *)
    (*   |> Graph.Vlabel.to_string *)
    (*   |> Ftlog.outnl "Display.focus_vertex_err(%s)"; *)
    (*   Ok () *)

    let run_err () =
      Ftlog.lvl 0;
      Ftlog.outnl "Display.run_err()";
      Ftlog.lvl 2;
      Ftlog.outnl "if stdin open, pass stdin";
      Ftlog.outnl "elseif argv[1] can be open, pass file";
      Ftlog.outnl "else, error print usage";

      Ftlog.outnl "if error in Algo.create_err, exit with message";
      Ftlog.outnl "else continue";
      match Algo.create_err stdin with
      | Error msg -> Error msg
      | Ok dat -> match init_termcap () with
                  | Error msg -> Error msg
                  | Ok _ ->  Input.loop_err dat
  end
