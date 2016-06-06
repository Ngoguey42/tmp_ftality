(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   graph_intf.ml                                      :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2016/06/06 16:33:13 by ngoguey           #+#    #+#             *)
(*   Updated: 2016/06/06 17:22:57 by ngoguey          ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

(* Implementation of graphs matching interfaces from lri's ocamlgraph
 * Aim is to only implement a Digraph+Abstract+Labeled graph
 * http://ocamlgraph.lri.fr/doc/Persistent.S.html
 *)

(* ************************************************************************** *)
(* http://ocamlgraph.lri.fr/doc/Sig.ANY_TYPE.html *************************** *)
module type Any_type_intf =
  sig
    type t
  end


(* ************************************************************************** *)
(* http://ocamlgraph.lri.fr/doc/Sig.ORDERED_TYPE.html *********************** *)
module type Ordered_type_intf =
  sig
    type t
    val compare : t -> t -> int
  end


(* ************************************************************************** *)
(* http://ocamlgraph.lri.fr/doc/Sig.ORDERED_TYPE_DFT.html ******************* *)
module type Ordered_type_dft_intf =
  sig
    include Ordered_type_intf
    val default : t
  end


(* ************************************************************************** *)
(* http://ocamlgraph.lri.fr/doc/Sig.COMPARABLE.html ************************* *)
module type Comparable_intf =
  sig
    type t
    val compare : t -> t -> int
                              (* val hash : t -> int *)
                              (* val equal : t -> t -> bool *)
  end


(* ************************************************************************** *)
(* http://ocamlgraph.lri.fr/doc/Sig.VERTEX.html ***************************** *)
module type Vertex_intf =
  sig
    type t
    include Comparable_intf
            with type t := t

    type label
    val create : label -> t
    val label : t -> label
  end


(* ************************************************************************** *)
(* http://ocamlgraph.lri.fr/doc/Sig.EDGE.html ******************************* *)
module type Edge_intf =
  sig
    type t
    val compare : t -> t -> int

    type vertex
    val src : t -> vertex
    val dst : t -> vertex

    type label
    val create : vertex -> label -> vertex -> t
    val label : t -> label
  end


(* ************************************************************************** *)
(* http://ocamlgraph.lri.fr/doc/Sig.G.html as close as possible ************* *)
module type G_intf =
  sig
    type t
    module V : Vertex_intf
    type vertex = V.t
    module E : Edge_intf
    type edge = E.t
    (* val is_directed : bool *)

    val is_empty : t -> bool
    val nb_vertex : t -> int
    val nb_edges : t -> int
    val out_degree : t -> vertex -> int
    val in_degree : t -> vertex -> int

    (* val mem_vertex : t -> vertex -> bool *)
    (* val mem_edge : t -> vertex -> vertex -> bool *)
    (* val mem_edge_e : t -> edge -> bool *)
    (* val find_edge : t -> vertex -> vertex -> edge *)
    val find_all_edges : t -> vertex -> vertex -> edge list

    val succ : t -> vertex -> vertex list
    val pred : t -> vertex -> vertex list
    val succ_e : t -> vertex -> edge list
    val pred_e : t -> vertex -> edge list

                                     (* val iter_vertex : (vertex -> unit) -> t -> unit *)
                                     (* val fold_vertex : (vertex -> 'a -> 'a) -> t -> 'a -> 'a *)
                                     (* val iter_edges : (vertex -> vertex -> unit) -> t -> unit *)
                                     (* val fold_edges : (vertex -> vertex -> 'a -> 'a) -> t -> 'a -> 'a *)
                                     (* val iter_edges_e : (edge -> unit) -> t -> unit *)
                                     (* val fold_edges_e : (edge -> 'a -> 'a) -> t -> 'a -> 'a *)
                                     (* val map_vertex : (vertex -> vertex) -> t -> t *)

                                     (* val iter_succ : (vertex -> unit) -> t -> vertex -> unit *)
                                     (* val iter_pred : (vertex -> unit) -> t -> vertex -> unit *)
                                     (* val fold_succ : (vertex -> 'a -> 'a) -> t -> vertex -> 'a -> 'a *)
                                     (* val fold_pred : (vertex -> 'a -> 'a) -> t -> vertex -> 'a -> 'a *)

                                     (* val iter_succ_e : (edge -> unit) -> t -> vertex -> unit *)
                                     (* val fold_succ_e : (edge -> 'a -> 'a) -> t -> vertex -> 'a -> 'a *)
                                     (* val iter_pred_e : (edge -> unit) -> t -> vertex -> unit *)
                                     (* val fold_pred_e : (edge -> 'a -> 'a) -> t -> vertex -> 'a -> 'a *)
  end


(* ************************************************************************** *)
(* http://ocamlgraph.lri.fr/doc/Persistent.S.AbstractLabeled.html *********** *)
module type DigraphAbstractLabeled_intf =
  sig
    include G_intf

    val empty : t
    val add_vertex : t -> vertex -> t
    val remove_vertex : t -> vertex -> t
    val add_edge : t -> vertex -> vertex -> t
    val add_edge_e : t -> edge -> t
    val remove_edge : t -> vertex -> vertex -> t
    val remove_edge_e : t -> edge -> t
  end

module type Make_DigraphhAbstractLabeled_intf =
  functor (V : Comparable_intf) ->
  functor (E : Ordered_type_dft_intf) ->
  DigraphAbstractLabeled_intf
  with type V.label = V.t
   and type E.label = E.t