(* Le espressioni rappresentano i costrutti del linguaggio*)
datatype expr =
    Int of int
  | Bool of bool
  | Var of string
  | Add of expr * expr
  | If of expr * expr * expr
  | Lambda of string * expr
  | App of expr * expr
  | Let of string * expr * expr
  | Match of expr * (pattern * expr) list
  | List of expr list

(*I pattern vengono utilizzati per il pattern matching. Ecco le varianti definite:*)
and pattern =
    PVar of string
  | PInt of int
  | PBool of bool
  | PListNil
  | PListCons of pattern * pattern;

(* Funzione per il pattern matching: Questa funzione prende in input un ambiente,un pattern e un valore da confrontare. 
 Se il pattern corrisponde al valore,restituisce un nuovo ambiente aggiornato; altrimenti, restituisce NONE*)

fun matchPattern env (PVar x) value = SOME ((x, value) :: env) (* PVar: associa una variabile al valore dato *)
  | matchPattern env (PInt n1) (Int n2) = (*PInt e PBool: controllano se il valore corrisponde al numero o al booleano specificato.*)
      if n1 = n2 then SOME env else NONE
  | matchPattern env (PBool b1) (Bool b2) = 
      if b1 = b2 then SOME env else NONE
  | matchPattern env PListNil (List []) = SOME env (*PListNil: verifica se il valore è una lista vuota.*)
  | matchPattern env (PListCons (ph, pt)) (List (x::xs)) = (*PListCons: controlla che il valore sia una lista non vuota e applica ricorsivamente il pattern sulla testa e sulla coda.*)
      (case matchPattern env ph x of
         SOME env' => matchPattern env' pt (List xs)
       | NONE => NONE)
  | matchPattern _ _ _ = NONE;

(* Valuta un'espressione in un dato ambiente, producendo un risultato o sollevando un'eccezione in caso di errore. *)
fun eval env (Int n) = Int n (*Int e Bool: restituiscono il valore direttamente*)
  | eval env (Bool b) = Bool b
  | eval env (Var x) =  (*Var: cerca il valore della variabile nell'ambiente*)
      (case List.find (fn (y, _) => x = y) env of
         SOME (_, v) => v
       | NONE => raise Fail ("Variable " ^ x ^ " not found"))
  | eval env (Add (e1, e2)) = (* Add: somma due espressioni intere *)
      (case (eval env e1, eval env e2) of
         (Int n1, Int n2) => Int (n1 + n2)
       | _ => raise Fail "Type error in addition")
  | eval env (If (cond, e1, e2)) = (*If: valuta la condizione e seleziona il ramo appropriato*)
      (case eval env cond of
         Bool true => eval env e1
       | Bool false => eval env e2
       | _ => raise Fail "Type error in if condition")
  | eval env (Lambda (x, body)) = Lambda (x, body)
  | eval env (App (f, arg)) = 
      (case eval env f of
         Lambda (x, body) => eval ((x, eval env arg) :: env) body
       | _ => raise Fail "Type error in application")
  | eval env (Let (x, e1, e2)) = (* Let: introduce una nuova variabile nell'ambiente*)
      let val v = eval env e1
      in eval ((x, v) :: env) e2
      end
  | eval env (Match (e, cases)) = (* Match: applica il pattern matching sull'espressione data *)
      let 
          val v = eval env e
          fun tryCases [] = raise Fail "No matching pattern"
            | tryCases ((pat, body) :: rest) =
                (case matchPattern env pat v of
                   SOME newEnv => eval newEnv body
                 | NONE => tryCases rest)
      in
          tryCases cases
      end
  | eval env (List es) = List (map (eval env) es); (*List: valuta ogni elemento della lista.*)
