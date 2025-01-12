# Relazione sul Sottolinguaggio di Haskell Implementato in SML

## Introduzione
In questo progetto, ho implementato un **sottolinguaggio significativo di Haskell** utilizzando Standard ML (SML). L'obiettivo era sviluppare un interprete in grado di valutare espressioni, gestire costrutti funzionali e supportare il **pattern matching** su variabili, interi, booleani e liste.

---

## Struttura del Codice

### 1. Definizione dei Tipi
Abbiamo definito due tipi principali per rappresentare le **espressioni** e i **pattern** del linguaggio:

#### Espressioni (`expr`)
Le espressioni rappresentano i costrutti del linguaggio. Ecco le varianti definite:

- `Int of int`: rappresenta un valore intero.
- `Bool of bool`: rappresenta un valore booleano.
- `Var of string`: rappresenta una variabile.
- `Add of expr * expr`: rappresenta la somma di due espressioni.
- `If of expr * expr * expr`: rappresenta una condizione `if-then-else`.
- `Lambda of string * expr`: rappresenta una funzione anonima.
- `App of expr * expr`: rappresenta l'applicazione di una funzione a un argomento.
- `Let of string * expr * expr`: rappresenta una dichiarazione `let` per definire una variabile locale.
- `Match of expr * (pattern * expr) list`: rappresenta un'espressione di **pattern matching**.
- `List of expr list`: rappresenta una lista.

#### Pattern (`pattern`)
I pattern vengono utilizzati per il **pattern matching**. Ecco le varianti definite:

- `PVar of string`: rappresenta un pattern variabile.
- `PInt of int`: rappresenta un pattern per un valore intero specifico.
- `PBool of bool`: rappresenta un pattern per un valore booleano specifico.
- `PListNil`: rappresenta un pattern per una lista vuota.
- `PListCons of pattern * pattern`: rappresenta un pattern per una lista non vuota (testa e coda).

---

### 2. Funzione `matchPattern`
La funzione `matchPattern` implementa il **pattern matching**. Questa funzione prende in input un ambiente, un pattern e un valore da confrontare. Se il pattern corrisponde al valore, restituisce un nuovo ambiente aggiornato; altrimenti, restituisce `NONE`.

#### Casi Gestiti
- **PVar**: associa una variabile al valore dato.
- **PInt e PBool**: controllano se il valore corrisponde al numero o al booleano specificato.
- **PListNil**: verifica se il valore è una lista vuota.
- **PListCons**: controlla che il valore sia una lista non vuota e applica ricorsivamente il pattern sulla testa e sulla coda.

---

### 3. Funzione `eval`
La funzione `eval` è il cuore dell'interprete. Essa valuta un'espressione in un dato ambiente, producendo un risultato o sollevando un'eccezione in caso di errore.

#### Casi Gestiti
1. **Int e Bool**: restituiscono il valore direttamente.
2. **Var**: cerca il valore della variabile nell'ambiente.
3. **Add**: somma due espressioni intere.
4. **If**: valuta la condizione e seleziona il ramo appropriato.
5. **Lambda e App**: gestiscono funzioni anonime e applicazioni.
6. **Let**: introduce una nuova variabile nell'ambiente.
7. **Match**: applica il pattern matching sull'espressione data.
8. **List**: valuta ogni elemento della lista.

---

## Esempi e Test

### Test 1: Pattern `PVar`
**Descrizione**: Verifica il pattern matching con una variabile.
```sml
val test1 = Match (Int 5, [(PVar "x", Add (Var "x", Int 3))]);
val result1 = eval [] test1; (* Risultato atteso: Int 8 *)
```

### Test 2: Pattern `PListCons`
**Descrizione**: Verifica il pattern matching con una lista non vuota.
```sml
val test2 = Match (List [Int 1, Int 2, Int 3],
                   [(PListCons (PVar "x", PVar "xs"), Add (Var "x", Int 10))]);
val result2 = eval [] test2; (* Risultato atteso: Int 11 *)
```

### Test 3: Pattern `PListNil`
**Descrizione**: Verifica il pattern matching con una lista vuota.
```sml
val test3 = Match (List [], [(PListNil, Int 42), (PVar "x", Int 0)]);
val result3 = eval [] test3; (* Risultato atteso: Int 42 *)
```

### Test 4: Lista non vuota con Match multipli
**Descrizione**: Pattern matching con fallback.
```sml
val test4 = Match (List [Int 7],
                   [(PListCons (PVar "x", PListNil), Add (Var "x", Int 5)),
                    (PListNil, Int 0)]);
val result4 = eval [] test4; (* Risultato atteso: Int 12 *)
```

### Test 5: Uso di Let
**Descrizione**: Definizione di una variabile locale.
```sml
val test5 = Let ("y", Int 3, Add (Var "y", Int 4));
val result5 = eval [] test5; (* Risultato atteso: Int 7 *)
```

### Test 6 e 7: If con condizione vera e falsa
**Descrizione**: Verifica il comportamento di `If` con condizioni diverse.
```sml
val test6 = If (Bool true, Int 10, Int 20);
val result6 = eval [] test6; (* Risultato atteso: Int 10 *)

val test7 = If (Bool false, Int 10, Int 20);
val result7 = eval [] test7; (* Risultato atteso: Int 20 *)
```

### Test 8: Lambda e App
**Descrizione**: Verifica le funzioni anonime.
```sml
val test8 = App (Lambda ("x", Add (Var "x", Int 5)), Int 10);
val result8 = eval [] test8; (* Risultato atteso: Int 15 *)
```

### Test 9: Match complesso con liste
**Descrizione**: Verifica un `Match` con pattern specifici per liste.
```sml
val test9 = Match (List [Int 3, Int 4],
                   [(PListCons (PInt 3, PVar "xs"), Add (Int 1, Int 1)),
                    (PListNil, Int 0)]);
val result9 = eval [] test9; (* Risultato atteso: Int 2 *)
```

---

## Conclusioni
L'interprete sviluppato in SML implementa con successo un sottolinguaggio significativo di Haskell, includendo:

- Pattern matching avanzato.
- Supporto per funzioni anonime e applicazioni.
- Costrutti base come `If`, `Let`, e operazioni su liste.

I test dimostrano la correttezza e la versatilità dell'interprete, rendendolo una base solida per eventuali estensioni future, come l'aggiunta di tuple, tipi opzionali o altre strutture dati.

