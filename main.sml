(* Definizione dei tipi per espressioni e pattern *)
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

and pattern =
    PVar of string
  | PInt of int
  | PBool of bool
  | PListNil
  | PListCons of pattern * pattern;

(* Funzione per il pattern matching *)
fun matchPattern env (PVar x) value = SOME ((x, value) :: env)
  | matchPattern env (PInt n1) (Int n2) = 
      if n1 = n2 then SOME env else NONE
  | matchPattern env (PBool b1) (Bool b2) = 
      if b1 = b2 then SOME env else NONE
  | matchPattern env PListNil (List []) = SOME env
  | matchPattern env (PListCons (ph, pt)) (List (x::xs)) = 
      (case matchPattern env ph x of
         SOME env' => matchPattern env' pt (List xs)
       | NONE => NONE)
  | matchPattern _ _ _ = NONE;

(* Funzione di valutazione *)
fun eval env (Int n) = Int n
  | eval env (Bool b) = Bool b
  | eval env (Var x) = 
      (case List.find (fn (y, _) => x = y) env of
         SOME (_, v) => v
       | NONE => raise Fail ("Variable " ^ x ^ " not found"))
  | eval env (Add (e1, e2)) = 
      (case (eval env e1, eval env e2) of
         (Int n1, Int n2) => Int (n1 + n2)
       | _ => raise Fail "Type error in addition")
  | eval env (If (cond, e1, e2)) =
      (case eval env cond of
         Bool true => eval env e1
       | Bool false => eval env e2
       | _ => raise Fail "Type error in if condition")
  | eval env (Lambda (x, body)) = Lambda (x, body)
  | eval env (App (f, arg)) = 
      (case eval env f of
         Lambda (x, body) => eval ((x, eval env arg) :: env) body
       | _ => raise Fail "Type error in application")
  | eval env (Let (x, e1, e2)) =
      let val v = eval env e1
      in eval ((x, v) :: env) e2
      end
  | eval env (Match (e, cases)) =
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
  | eval env (List es) = List (map (eval env) es);

(* Test *)

(* Test 1: Pattern PVar *)
val test1 = Match (Int 5, [(PVar "x", Add (Var "x", Int 3))]); 
val result1 = eval [] test1; (* Risultato atteso: Int 8 *)

(* Test 2: Pattern PListCons *)
val test2 = Match (List [Int 1, Int 2, Int 3], 
                   [(PListCons (PVar "x", PVar "xs"), Add (Var "x", Int 10))]);
val result2 = eval [] test2; (* Risultato atteso: Int 11 *)

(* Test 3: Pattern PListNil *)
val test3 = Match (List [], [(PListNil, Int 42), (PVar "x", Int 0)]);
val result3 = eval [] test3; (* Risultato atteso: Int 42 *)

(* Test 4: Lista non vuota con Match multipli *)
val test4 = Match (List [Int 7], 
                   [(PListCons (PVar "x", PListNil), Add (Var "x", Int 5)),
                    (PListNil, Int 0)]);
val result4 = eval [] test4; (* Risultato atteso: Int 12 *)

(* Test 5: Uso di Let *)
val test5 = Let ("y", Int 3, Add (Var "y", Int 4));
val result5 = eval [] test5; (* Risultato atteso: Int 7 *)

(* Test 6: If con condizione vera *)
val test6 = If (Bool true, Int 10, Int 20);
val result6 = eval [] test6; (* Risultato atteso: Int 10 *)

(* Test 7: If con condizione falsa *)
val test7 = If (Bool false, Int 10, Int 20);
val result7 = eval [] test7; (* Risultato atteso: Int 20 *)

(* Test 8: Lambda e App *)
val test8 = App (Lambda ("x", Add (Var "x", Int 5)), Int 10);
val result8 = eval [] test8; (* Risultato atteso: Int 15 *)

(* Test 9: Match complesso con liste *)
val test9 = Match (List [Int 3, Int 4], 
                   [(PListCons (PInt 3, PVar "xs"), Add (Int 1, Int 1)),
                    (PListNil, Int 0)]);
val result9 = eval [] test9; (* Risultato atteso: Int 2 *)



