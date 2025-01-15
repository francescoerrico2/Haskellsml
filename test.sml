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



