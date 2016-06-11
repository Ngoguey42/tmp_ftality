(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   key.ml                                             :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: Ngo <ngoguey@student.42.fr>                +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2016/06/03 16:34:22 by Ngo               #+#    #+#             *)
(*   Updated: 2016/06/10 15:29:24 by ngoguey          ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

type t = {
    id : int
  ; action : string
  }

let default = {id = 0; action = ""}

let of_strings (action, key) =
  Printf.eprintf "\t\tKey.of_string((\"%s\", \"%s\"))\n%!" action key;
  {id = 42; action}

let to_string {action; id} =
  Printf.sprintf "%s:%d" action id

let compare a b =
  compare a.action b.action
  (* a.id - b.id *)

(* TODO: use ncurse or sdl instead? *)
(* Bytes read in terminal are converted to t *)
let of_bytes _ =
  Printf.eprintf "\tKey.of_bytes()\n%!";
  {id = 42; action = ""}