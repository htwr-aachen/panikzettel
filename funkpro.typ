#import "conf.typ": algoBox, conf, defiBox, posneg, sidenote, theoBox, todo
#import "@preview/cetz:0.2.0": canvas, plot

#show: conf.with(
  title: "Funktionale Programmierung",
  shortTitle: "FunkPro",
  authors: (
    (name: "🌎 Jonas Maximus Schneider"),
    (name: "✨Leo std::vector Werner✨"),
    (name: "🐈‍⬛ Destina Kolac <3"),
    (name: "🦀 Adrian Jakob Groh 🚀"),
    (name: "🍪 Peter (Peti) Wallmeyer :)"),
    (name: "💀 Tore Ulrich Kunze 👹"),
  ),
  lang: "de",
  filename: "funkpro",
  showOutline: true,
)

#let ltes = math.op($subset.eq.sq$)
#let ltesn = math.op($subset.eq.sq.not$)
#let lub = math.op($union.sq$)

= Einleitung und Vorwissen

=== Vorwort

Dieser Panikzettel ist Open Source auf #link("https://git.rwth-aachen.de/jonas.max.schneider/panikzettel", `https://git.rwth-aachen.de/jonas.max.schneider/panikzettel`). Wir freuen uns über Anmerkungen und Verbessungsvorschläge (auch von offiziellen Quellen).

=== Vorwissen
Praktisch keines. Programmierung könnte nicht schaden, aber es wird hier alles von 0 aufgebaut.


= Haskell

Haskell Programmierung ist ein wesentlicher Teil der Vorlesung. Wir trennen zwischen der Auswertungstrategien & Sprachkonstrukte und wesentlichen Funktionen, damit sich ein übersichtlicher Panikzettel ergibt.


=== Typdeklarationen
```hs
-- Dies ist ein Kommentar
square :: Int -> Int -- Also ein Funktion von int zu int
```

=== Funktionsdeklarationen
```hs
square x = x * x
```

=== Auswertungsstrategien
Zu unterscheiden sind _strikte_ Auswertungsstrategien, bei denen immer der innerste Ausdruck als nächstes ausgewertet wird (_innermost evaluation_), und _nicht-strikte_, bei denen der äußerste Ausdruck zuerst evaluiert wird.

Haskell verwendet eine Abwandlung einer _nicht-strikten_ Auswertung, da es Ausdrücke nur einmal auswertet. Diese _leftmost outermost_ evaluation heißt auch _Lazy Evaluation_ (da es immer nur das ausführt was es gerade braucht).

Das Ergebnis ist unabhängig von der Auswertungsstrategie gleich.
Wenn irgendeine Auswertungsstrategie terminiert, terminiert auch die nicht-strikte Auswertung, aber nicht unbedingt die strikte Auswertung.

=== Currying
Statt
```hs
plus :: (Int, Int) -> Int
plus (x,y) = x + y
```

schreibe
```hs
plus :: Int -> Int -> Int
plus x y = x + y
```

Somit erschafft man im Zwischenschritt der Auswertung von `plus 1 2` die Funktion `plus1 y = 1 + y`, da man zuerst eine Funktion von `Int -> Int` zurück gibt.

=== Pattern Matching
Die Argumente auf der linken Seite einer Gleichung können statt Variablen auch _Patterns_ sein.
```hs
und :: Bool -> Bool -> Bool
und True y = y
und False y = False

len :: [a] -> Int
len [] = 0
len (x:xs) = 1 + len xs
```

Die Patterns werden von oben nach unten durchgegangen und die erste passende Gleichung wird angewendet.

=== Lokale Deklarationen
Mit `where` können lokale Deklarationsblöcke erstellt werden.
```hs
roots a b c = ((-b - d)/e, (-b + d)/e)
      where d = sqrt (b*b - 4*a*c)
            e = 2*a
```
== Operatorrangfolge
Welche von den folgenden Operatoren priorisiert wird, kann durch die Bindungspriorität (1-9) festgelegt werden bsp. `infixl 9 %%`.
=== Präfix

Ist das normale z.B. `plus 1 2`, Infixfunktionen können mittels Klammerung als Präfix-Funktionen verwendet werden.
```hs
(+) 1 2 = 1 + 2
```

=== Infix
Analog können Präfix-Funktionen mit Backquotes zu Infix-Operatoren umgewandelt werden.
```hs
15 `mod` 4 = mod 15 4
```

Bei Infix-Operatoren muss allerdings festgelegt werden, zu welcher Seite sie _assoziieren_.
```hs
infixl `divide`
(36 `divide` 6) `divide` 2  -- 3

infixr `divide`
(36 `divide` 6) `divide` 2  -- 12
```

- Der Funktionsraumkonstruktor `->` assoziiert nach rechts.
- Die Funktionasanwendung assoziiert nach links.

#sidenote(title: "Postfix", [gibt es nicht.])

/*
=== Bindungspriorität
Mit ihr kann festgelegt werden, welcher Operator eine höhere Priorität besitzt.
```hs
(%%) :: Int -> Int -> Int
x %% y = x + y

(@@) :: Int -> Int -> Int
x @@ y = x * y

infixl 9 %%
infixl 8 @@
1 %% 2 @@ 3  -- 9

infixl 8 %%
infixl 9 @@
1 %% 2 @@ 3  -- 7
```
*/

=== Ausdrücke
Dies ist nur eine kleine Auswahl der verfügbaren Ausdrücke in Haskell, für eine ausführlichere Liste, siehe 1.1.2 im Skript.

```hs
-- Listen
[1,2,3] = 1:[2,3] = 1:2:[3] = 1:2:3:[]

-- if then else
if exp1 then exp2 else exp3

-- Guards
maxi (x,y) | x >= y =x
           | otherwise = y

-- let in
roots a b c = let d = sqrt (b*b - 4*a*c)
                  e = 2*a
              in ((-b - d)/e, (-b + d)/e)

-- case of
und x y = case x
            of True -> y
               False -> False

-- lambda Funktionen
plus = \x y -> x + y
plus x = \y -> x + y
```

=== Patterns
Für die Argumente in Funktionsdeklarationen werden sog. _Patterns_ angegeben, mit der die Form der erlaubten Argumente bestimmt wird. Argumente müssen nur solange ausgewertet werden, bis eines der angegebenen Patterns passend ist.

```hs
zeros :: [Int]
zeros = 0 : zeros

f :: [Int] -> [Int] -> [Int]
f [] _ = []
f _ [] = []

f [] zeros -- terminiert, obwohl zeros nicht terminiert
```

Patterns müssen _linear_ sein, d.h. dass keine Variable in einem Pattern mehrfach vorkommen darf.

Das Zeichen `_` ist der Joker-Pattern, der auf jeden Wert passt, aber keine Variable darauf bindet. Daher darf er auch mehrfach in einem Pattern vorkommen.

Mit `@` kann der zu matchende Ausdruck zusätzlich an eine Variable gebunden werden.
```hs
f y@(x : xs) = x : y  -- kopiert das erste Element
```
== Haskell 101

=== Typen
```hs
Int,
Integer, -- (Big Int)
Bool,
Float,
Double,
Char,
a -> b -- Funktionen aller Art
(Int, Int) -- Tupel
[Int] -- Liste von Ints
```

==== Parametrische Polymorphie
Funktionen, die auf Variablen von verschiedenen Typen angewendet werden können
```hs
(++) :: [a] -> [a] -> [a]
[] ++ ys = ys
(x:xs) ++ ys = x:(xs ++ ys)
```

==== Typdefinitionen
```hs
type Position = (Float, Float)
type String = [Char]

data Color = Red | Yellow | Green
data Nats = Zero | Succ Nats
data List a = Nil | Cons a (List a)
```

=== Typklassen
Typen können einen _Kontext_ haben, z.B. `Eq a`.
```hs
(==), (/=) :: Eq a => a -> a -> Bool
```
bedeutet, dass für die Typvariable `a` nur Typen aus der Typklasse `Eq` eingesetzt werden dürfen.

```hs
class Eq where
  (==), (/=) :: a -> a -> Bool
  x /= y = not (x == y) -- wir definieren hier also /=, somit muss a nur noch == selber definieren

instance Eq a => Eq [a] where -- also wenn a zu Eq gehört, tut es auch [a]
  [] == [] = True
  (x:xs) == (y:ys) = x ==y && xs == ys
  _ == _ = False
```

Unter anderem die Klassen `Eq` und `Ord` sind vordefiniert, wobei `Ord` eine _Unterklasse_ von `Eq` ist.
```hs
class Eq a => Ord a where  -- nur wenn a zu Eq gehört, kann a auch zu Ord gehören
(<),(>),(<=),(>=) :: a -> a -> Bool
x < y = x <= y && x /= y
-- ...
```

Um eine Variable einer Datenstruktur auszugeben, brauchen diese eine Implementierung der Methode `show`, welche durch `deriving Show` automatisch erzeugt werden kann. Sonst kann diese wie folgt selbst deklariert werden:
```hs
instance Show a => Show (List a) where -- erneut, wenn a in Show ist, definieren wir hier Show für [a]
  show Nil = "[]"
  show (Cons x xs) = show x ++ " : " ++ show xs
```

== Funktionen höherer Ordnung
Dies sind Funktionen, dessen Argumente oder Resultat ebenfalls Funktionen sind.

Einfach mal runtergerattert.

```hs
-- Funktionskomposition .
half . square -- erst x*x dann y/2 => (x*x)/2

-- curry und uncurry
-- Mit den Funktionen `curry` und `uncurry` ist es möglich, eine Funktion beliebig als curried oder uncurried Variante zu verwenden.
uncurry (+) (1,2) -- 3

-- Map
map (*2) [1..10] = [2, 4, 6, 8, .., 20] -- wendet eine Funktion auf alle Element einer Liste an

-- filter
filter even [1..10] = [2,4,	.., 10] -- Behält nur die Elemente einer Liste, für die die Funktion true zurückgibt.

-- zipWith
-- Mit zipWith lassen sich zwei Listen mit Anwendung einer Funktion vereinen.
zipWith (+) [1,2] [3,4]  -- [4,6]

-- Fold
-- Mit foldl und foldr können alle Elemente einer Liste auf ein Element "gefaltet" werden, indem sie mit einer Funktion mit dem Accumulator verrechnet werden.

foldr (+) 0 [1..10]  -- 55 (wie sum)

concat :: [[a]] -> [a]
concat = foldr (++) []
```

=== Listenkomprehension
```hs
[ x*x | x <- [1..5], odd x]
```

Listenkokmprehensionen können mit der _Generatorregel_ und der _Einschränkungsregel_ ausgewertet werden.

Ein Generator hat die Form `var <- exp` (z.B. `x <- [1..5]`).
Eine Einschränkung ist dann ein Wahrheitswert z.B. `even x`.

Wir bauen also zuerst alle möglichen Werte mit Generatoren und schränken sie danach ein, um unsere Liste zu fertigen.


== Programmieren mit Lazy Evaluation

```hs
infinity :: Int
infinity = infinity + 1

mult :: Int -> Int -> Int
mult 0 y = 0
mult x y = x * y
```

Die Auswertung von `mult 0 infinity` terminiert mit dem Ergebnis $0$, während `mult infinity 0` nicht terminiert.

Dank lazy evaluation können auch unendliche Datenstrukturen wie die Liste `[5..]` praktisch sein, da diese nur so weit wie nötig ausgewertet werden. Mit der Funktion `take` können z.B. die ersten $n$ Elemente zurückgegeben werden.
```hs
take 2 [5..]  -- [5,6]
```

Mit der Funktion `takeWhile` können solange Werte aus einer Liste genommen werden, wie eine Bedingung erfüllt ist.
```hs
takeWhile (<100) [x^2 | x <- [5..]]  -- [25,36,49,64,81]
```

=== Zyklische Datenobjekte

Datenobjekte, wie `[5,5,5,5,...]`, können effizient abgespeichert werden, indem Zykel genutzt werden. Somit können manche Probleme effizienter gelöst werden (z.B. Hamming, siehe Skript.)

```hs
fives :: [Int]
fives = 5 : fives
```

== Monaden

=== Ein- und Ausgabe mit Monaden
Rein funktionale Programmiersprachen haben keine Seiteneffekte. Diese können aber bei z.B. der Interaktion mit der Umwelt gewünscht sein.

Für Ausgabe kann daher der vordefinierte Datentyp `IO ()` benutzt werden, dessen Werte _Aktionen_ sind. Die Auswertung eines Ausdrucks vom Typ `IO ()` bedeutet dann, dass die Aktion ausgeführt wird.
```hs
putChar :: Char -> IO ()
putChar '!'  -- gibt '!' aus

(>>) :: IO () -> IO () -> IO ()  -- "then", Kombination von Aktionen

putChar 'a' >> putChar 'b'  -- gibt "ab" aus
```

Zur Eingabe wird der Typ `IO a` verwendet, von Aktionen, die jeweils einen Wert von Typ `a` berechnen.
```hs
getChar :: IO Char

return :: a -> IO a

return '!'  -- Aktion, die nichts tut und bei der sich das Zeichen '!' ergibt
```

Mit `>>=` ("bind") kann der von einer Aktion bestimmte Wert von der nächsten Aktion benutzt werden.
```hs
echo :: IO ()
echo getChar >>= putChar
```

Da die Notation teilweise schlecht lesbar ist, wird eine neue Notation mit `do` eingeführt.
```hs
p >>= \x ->
      q >>= \y ->
            r
-- ==
do x <- p
   y <- q
   r
```

=== Programmieren mit Monaden
Monaden können wie folgt definiert werden:
```hs
class Monad m where
  return :: a -> m a
  (>>=) :: m a -> (a -> m b) -> m b
  ...
```

`Monad` ist keine Typklasse, sondern eine _Konstruktorklasse_ (weil `m` ein einstelliger Typkonstruktor ist).

Monaden dienen zur Kapselung von Werten, d.h. in Objekten vom Typ `m a` ist ein Objekt vom Typ `a` gekapselt. Der Typkonstruktor `IO` ist ein Beispiel für eine Monade, d.h. die folgende Instanzdeklaration ist in der Prelude enthalten:
```hs
instance Monad IO where ...
```

Die Funktionen `return` und `>>=` sind Methoden der Klasse `Monad`, müssen also für jede Instanz dieser Klasse implementiert werden. Die `do`-Notation dagegen ist für alle Instanzen der Klasse `Monad` definiert.

Die Folgenden Gesetze müssen für `return` und `>>=` erfüllt sein, damit ein Typkonstruktor `m` als Monade bezeichnet wird:
1. ```hs p >>= return  =  p```
2. ```hs return x >>= f  =  f x```
3. ```hs p >>= \x -> q >>= \y -> r  =  p >>= \x -> (q >>= \y -> r)```, falls `x` nicht in `r` auftritt

= Denotationelle Semantik funktionaler Programme

Ab hier wird es wesentlich theoretischer. Wir wollen nun versuchen die Semantik von Haskell zu definieren. Hierfür gibt es 3 Arten diese zu definieren:

/ Denotationelle Semantik: Hier weisen wir jedem Ausdruck ein Mathematisches Äquivalent zu, was dieses definiert
/ Operationelle Semantik: Hier abstrahieren wir meist ein Programm und geben einen abstrakten Interpreter an, welcher das Ergebnis festlegt.
/ Axiomatische Semantik: Werden wir nicht behandeln.

PS. die meisten Sprachen geben einfach nur eine Referenz Implementierung eines Compilers.

Wir fangen mit der denotationellen an und werden später auch noch operationelle behandeln.

#let Val = $cal(V)a l$

---

Ziel wird es also sein, eine Funktion $Val("exp")$, die jedem Haskell Ausdruck ein mathematisches Objekt zuordnet. . z.B. wird die Haskell `5` auf die mathematische $5$ abgebildet und
```hs
square :: Int -> Int
square x = x * x
```
auf eine mathematische Funktion, die Zahlen quadriert.
Da es in Haskell aber auch Ausdrücke gibt, die nicht oder nur partiell definiert sind, wie
```hs
non_term :: Int -> Int
non_term x = non_term (x + 1)
```
#let bot = $scripts(bot)$
gibt es auch den undefinierten Wert #bot (bottom).

== Ordnungen

Für die Übertragung brauchen wir Funktionen mit bestimmten Eigenschaften. Hierfür definieren wir uns eine partielle Ordnung, die besagt "wie stark" eine Sache definiert ist.

Eine Ordnung ist, genau das was man vermutet:
- $x <= x$, Reflexivität
- $x <= y and y <= x => x = y$, Antisymmetrie
- $x <= y and y <= z => x < z$, Transitivität

Bei einer partiellen Ordnung müssen aber nicht alle Element miteinander in Relation stehen. Es könnte also sein, dass $x_1 <= x_2 and x_1 <= x_3$ aber $x_2 lt.eq.not x_3 and x_3 lt.eq.not x_2$. $x_2$ und $x_3$ sind also einfach nicht vergleichbar.

Eine Verbund $x_1 <= x_2 <= x_3 <= ..., quad x_1,x_2,x_3,... in D$ heißt _Kette_.

Wir bauen unsere partielle Ordnung auf der Definiertheit der Werte auf und geben ihr das Zeichen $ltes$.

=== Domains

#let True = "True"
#let False = "False"

Für jeden Haskell Typ bauen wir eine eigene Menge von Mathematischen Objekten, genannt _Domains_, sodass jedem Audruck des Typs ein Objekt aus der Domain zugeordnet wird.

Für den Typ Integer wählen wir den _Domain_ $ZZ_bot = {bot_ZZ_bot,0,1,-1,2,-2,...}$ für Booleans $BB_bot = {bot_BB_bot,True,False}$, etc.

Die Struktur eines Domains $D$ wird durch eine partielle Ordnung $ltes_D$ festgelegt, die ihre Elemente danach ordnet, wie "stark sie definiert sind".
$x ltes_D y$ bedeutet also, dass $x$ höchstens so sehr definiert ist wie $y$.

#quote(block: true, [Wieso denn nicht nur ein $bot$?])

Da in Haskell auch korrekt getypte Ausdrücke nicht-terminieren können (so wie in allen Turing-Complete Sprachen), muss die Semantik also auch den Befriff eines undefinierten Wertes für einen Typen wiederspiegeln. Hierfür nehmen wir $bot_D$ für einen Typ $D$. Es gilt für alle  $y in D: quad bot_D ltes_D y$. Für $ZZ_bot$ oder $BB_bot$ scheint das noch nicht besonders praktisch zu sein, aber...

Werte können nicht nur definiert und undefiniert sein, z.B. können Tupel als einzelne Komponenten den undefinierten Wert haben und damit weniger definiert sein, als voll definierte.

$D$ heißt ein Basis-Domain, wenn nur $bot_D$ mit den anderen Element in Relation stehen. Alle anderen sind "gleichwertig" (*nicht gleich* $1 != 2$, aber sie stehen nicht in der Ordnung $1 ltesn 2 or 2 ltesn 1$). Z.B. $BB_bot, ZZ_bot, ...$

#quote(
  block: true,
)[Ja leider _ein_ Domain, genauer _ein Scott-Ershov Domain_ 🤮.] //habe das ein cursiviert weil das war hart verwirred :") (-Marry)"

Tupel von Domains sind erneut Domains. $(d_1, ..., d_n) ltes_(D_1 times ... times D_n) (d'_1, ..., d'_n)$ gilt genau dann wenn (gdw) $d_i ltes d'_i$ für alle $1 <= i <= n$ (Zu beachten ist der Typ/Subscript der Relation). Somit ist $(bot_D_1,...,bot_D_n) = bot_(D_1 times ... times D_n)$ das kleinste Element.

Für Funktionen $f,g : D_1 -> D_2$ gilt $f ltes_(D_1 -> D_2) g$ gdw. für alle $d in D_1: f(d) ltes_D_2 g(d)$. $bot_(D_1 -> D_2) = d => bot_D_2$ ist somit das kleinste Element.

#defiBox(
  title: [Extension von Funktionen],
  [Sei $f: A -> B$ eine Funktion. Jede Funktion $f': A_bot -> B$ bezeichnet man als Extension von $f$ wobei $A_bot = A union {bot_A_bot}$ und wobei $f(d) = f'(d)$ für alle $d in A$.],
)

#defiBox(
  title: [Striktheit von Funktionen],
  [Eine Funktion $g: D_1 times ... times D_n -> D$ für Domains $D_1,...,D_n,D$ heißt _strikt_, falls $g(d_1,...,d_n) = bot_D$ für alle $d_1,...,d_n$ gilt, bei denen ein $d_i = bot_D_i$ ist. Ansonsten heißt $g$ _nicht-strikt_.],
)

#defiBox(
  title: [Monotone Funktionen],
  [Seien $ltes_D_1$ und $ltes_D_2$ partielle Ordnungen auf $D_1$ bzw. $D_2$. Eine Funktion $f: D_1 -> D_2$ ist monoton $<=> forall d ltes_D_1 d': f(d) ltes_D_2 f(d')$],
)

#theoBox(
  title: [Aus Striktheit folgt Monotonie],
  [Seien $D_1,...,D_n,D$ Domains, wobei $D_1,...,D_n$ flach sind. Sei $f: D_1 times ... times D_n -> D$ strikt. Dann ist $f$ auch monoton.],
)

Wir definieren für jede Menge $D$ mit p. Ordnung $ltes_D$ den Lift von $D$, $D_bot$ so, dass $bot_D_bot ltes_D_bot d$ kleiner ist als alle $d in D$ (inklusive, des eventuellen Vorherigen $bot_D$). Alle anderen Elemente der Relationen werden beibehalten.

=== Eigenschaften von $ltes$
Dass $ltes$ eine partielle Ordnung ist, ist offensichtlich.

#defiBox(
  title: [Kleinste obere Schranke (Supremum)],
  [Sei $ltes$ eine partielle Ordnung auf einer Menge $D$ und $S$ eine Teilmenge von $D$. Ein Element $d in D$ ist eine _obere Schranke_ von $S$, falls $d' ltes d$ für alle $d' in S$ gilt. Das Element $d$ ist die _kleinste obere Schranke_ (oder "Supremum"), falls darüber hinaus für alle anderen oberen Schranken $e$ der Zusammenhang $d ltes e$ gilt. Wir bezeichnen dieses Element als $lub S$],
)

Aber nicht nur das, für jede Domain $D$:
- Gibt es ein kleinstes Element $bot_D$.
- Jede Kette $S = d_1 ltes d_2 ltes ... ltes d_n in D$ hat ein Supremum $lub S$.
Dank diesen zwei Eigenschaften heißt $ltes_D$ eine vollständige Partielle Ordnung. Dies gilt für Basis-Domains, Tuple-Domains und Funktionsdomains (Satz 2.1.13)


== Fixpunkte


#let ff = math.op([#h(0.1cm) $f$ #h(-0.33cm) $f$ #h(0.1cm)]) // das muss irgendwie schöner gehen
#let lfp = math.op("lfp")

#defiBox(title: [Fixpunkt], [$f$ ist ein Fixpunkt von $ff$ gdw.. $ff (f) = f$])

Der kleinste Fixpunkt (welcher am wenigsten definiert ist) wird als least fixpoint (lfp) bezeichnset.

#theoBox(
  title: [Fixpunktsatz],
  [Sei $ltes$ eine vollständige partielle Ordnung auf $D$ und sei $f : D -> D$ stetig. Dann besitzt $f$ einen kleinsten Fixpunkt und es gilt $lfp f = lub {f^i (bot) | i in NN}$.],
)

Funktionen wie $ff$, die aus Haskell-Ausdrücken gewonnen werden, sind immer stetig.
Insofern ist durch den Fixpunktsatz garantiert, dass ihr kleinster Fixpunkt existiert und durch die kleinste obere Schranke der Kette ${bot,ff(bot),ff^2 (bot),...}$ erhalten werden kann.
Insgesamt fassen wir also in der denotationellen Semantik die Definition einer Funktion als eine _(Fixpunkt)gleichung_ über Funktionen auf. Da hier Gleichungen immer lösbar sind, erhalten wir mindestens eine Funktion als Lösung. Unter allen Lösungen wird dann die kleinste ausgewählt und dem Funktionssymbol als Semantik zugeordnet.

#defiBox(
  title: [Stetigkeit],
  [Sei $ltes_D_1$ vollständig auf $D_1$ und $ltes_D_2$ vollständig auf $D_2$. Eine Funktion $f: D_1 -> D_2$ heißt _stetig_ (_continuous_) gdw.. für jede Kette $S$ von $D_1$ jeweils $f(lub S) = lub {f(d) | d in S}$ ist. Die Menge aller stetigen Funktionen von $D_1$ nach $D_2$ wird mit $chevron.l D_1 -> D_2 chevron.r$ bezeichnet.],
)

#theoBox(
  title: [Stetigkeit und Monotonie],
  [Seien $ltes_D_1$ und $ltes_D_2$ vollständige Ordnungen auf $D_1$ bzw. $D_2$ und sei $f: D_1 -> D_2$ eine Funktion.
    1. $f$ ist stetig gdw. $f$ monoton ist und für jede kette $S$ von $D_1$ gilt $f(lub S) ltes lub f (S)$.
    2. Falls $D_1$ nur endliche Ketten besitzt, dann ist $f$ stetig gdw. $f$ monoton ist.
  ],
)

#sidenote(title: "Relevanz?")[
  Ja leider haben die Übungsblätter einige Aufgaben hierzu enthalten.
]

== Die Haskell Semantik

#let exp = math.underline(math.mono("exp"))
#let var = math.underline(math.mono("var"))
#let constr = math.underline(math.mono("constr"))

=== Einfaches Haskell

Um die Semantik von Haskell zu definieren ist es hilfreich, sich auf das Subset _simple Haskell_ zu konzentrieren und den Rest dann darauf zu reduzieren.

Ein _simple_ Haskell Programm verwendet keine vordefinierten Listen, Typabkürzungen, Typklassen und Pattern matching und ist nur in einer einzigen Deklaration geschrieben.

Es sind somit noch folgende Konstrukte erlaubt:
- var
- Konstante
- Int / Integer
- Float / Double
- Char
- ($exp_1$, ..., $exp_n$), $quad n >= 1$
- if $exp_1$ then $exp_2$ else $exp_3$
- let var = $exp$ in $exp'$
- \var -> exp
- Ein paar vordefinierte Funktionen in der Umgebung $omega$ (z.B. <=, -, $*$)

#sidenote(
  title: "Umgebungen / Environments",
)[Eine Umgebung $rho: sans("Var") -> sans("Dom")$ ist eine Variablenbelegung, genauer eine partielle Funktion, \ die Werte auf ein Domain $sans("Dom")$. $rho$ ist nur für endlich viele Variablen definiert.]

#let free = "free"
Wir brauchen nun noch den Begriff der _freien_ Variablen $free(exp)$, er ordnet jedem _simple Haskell_ Ausdruck eine Menge seiner freien Variablen zu.



Nun zu $Val$. Wir geben das Ergebniss von $Val(exp) = rho...$ an, also der Variablenbelegung in einer Umgebung $rho$.


//TODO: unwichtig? Eher beschreibungen der Environment einbauen?
$
  &Val[|var|] rho &&= rho(var) \
  &Val[|(exp)|] &&= Val[|exp|] \
  &Val[|constr_0|] rho &&= rho(constr_0) "z.B." z in ZZ, b in BB, "etc" \
  &Val[|constr_n |] rho (n > 0) &&= rho(constr_n (d_1..., d_n)) \
  &Val[|(exp_1, ..., exp_n)|] rho &&= (Val[|exp_1|] rho, ..., Val[|exp_n|] rho) \
  &Val[|(exp_1 exp_2)|] &&= f(Val[|exp_2|]), "da" exp_1 "eine Funktion" f "ist" \
  &Val[| "if" exp_1 "then" exp_2 "else" exp_3|] rho &&= cases(
    Val[|exp_2|] & "if" Val[|exp_1|] = "true",
    Val[|exp_3|] & "if" Val[|exp_1|] = "false",
    bot & "else"
  ) \
  &Val[|"let var" = exp "in" exp'|] rho &&= Val[|exp'|] (rho + { var \/ Val[|exp|] rho }) \
  &Val[| \\var -> exp|] &&= f, "mit" f(d) = Val[|exp|] (rho + {var \/ d})
$


== Reduzierung von _Haskell_ zu _Simple Haskell_

Nun müssen wir lediglich für jeden normalen Haskell Ausdruck (mit Pattern-Matching) ein äquivalenten _simple_ Haskell Ausdruck (ohne Pattern-Matching) erzeugen, und schwups haben wir das Ziel.

Hierfür werden wir Stück für Stück Teilausdrücke mit von uns vordefinierte Funktionen ersetzten, bis keine Regel mehr anwendbar ist. In der Start Environment $omega$ geben wir also nun vordefinierte Funktionen an $w_tr$

/ $mono("bot")$: Simple. $mono("bot") = bot$. Also Undefiniertheit.
/ $mono("isa")_constr (d)$: \
  `true`, falls $d=(constr, d_1, ..., d_n)$. \
  `false` falls $d=(constr', d_1, ..., d_n)$, \
  $bot$ sonst.

/ $mono("argof")_constr (d)$: \
  $(d_1,...d_n)$ falls $d=(constr, d_1, ..., d_n)$, \
  $bot$ sonst
/ $mono("isa")_(n-mono("tuple"))(d)$: \
  `true`, falls $d=(d_1,...,d_n)$, \
  $bot$ sonst.
/ $mono("sel")_(n,i)$: \
  $d_i$, falls $d=(d_1, ..., d_n)$ \
  $bot$ sonst

// #pagebreak()

Und nun die 12 Regeln. Die Regeln sind in keiner definierten Reihenfolge zu machen, einfach wie es passt.
Da es ein Panikzettel ist, weisen wir euch an das Skript, welche bei 2.2.11 die Transformation beschreibt.

/*
1.
```hs
data Nats = Zero | Succ Nats

let isEven Zero = True
    isEven (Succ Zero) = False
    isEven (Succ (Succ n)) = isEven n
in isEven x
```

2.
```hs
append Nil z = z
append (Cons x y) z = Cons x (append y z)
```

*/

1. *Pattern Matching zu `case`* \
/*
```hs
    let isEven = \x ->
      case (x) of
        {Zero -> True;
        (Succ Zero) -> False;
        (Succ (Succ n)) -> isEven n}
  ```
  Wir verwenden nur Lambda Ausdrücke mit einem Argument, die wir zur not verschachteln.

  ```hs
  append =
    \x1 ->
      \x2 -> case (x1, x2) of
        (Nil, z) -> z
        (Cons x y, z) -> Cons x (append y z)

  ```
*/
2. *Multi-Lambda zu Lambda*
3. *Lambda zu `case`*
4. *`case` zu `match`*
Nun müssen wir noch alle `match` Klauseln autstauschen:

5. *`match` von Variablen*
6. *`match` vom Joker Pattern*
7. *`match` von Konstruktoren*
8. *`match` von leeren Tupeln*
9. *`match` von nicht-leeren Tupeln*
10. *Aufteilung von Deklarationen*
11. *Vereinen von Deklarationen*
12. #math.arrow.t Mit mehreren Variablen

Mittels 2.2.12 haben wir gezeigt, dass diese Regln bei einem Korrekt getypten und synataktisch korrekten Programm immer funktionieren und tatsächlich ein _einfaches_ Haskell programm raus kommt.

= Der Lambda-Kalkül

== Lambda-Terme
Die Menge der Lambda-Terme $Lambda$ ist definiert als die kleinste Menge, so dass:
/ $cal(C) subset.eq Lambda$: Konstanten
/ $cal(V) subset.eq Lambda$: Variablen
/ $(t_1, t_2) in Lambda$, falls $t_1, t_2 in Lambda$: $t_1$ wird auf $t_2$ angewendet.
/ $lambda x.t in Lambda$, falls $x in cal(V)$ und $t in Lambda$: Abstraktionen, sie stellen Funktionen dar, die jeden Wert $x$ auf den Wert von $t$ abbilden (vgl. Lambda-Funktionen in Haskell)

Variablen in einem Lambda-Term werden als _frei_ bezeichnet, wenn diese an kein darüber stehendes Lambda gebunden sind (vgl. freie Variablen in Haskell).
- $((t_1 t_2) t_3) => (t_1 t_2 t_3)$
- $lambda x.(x x) => lambda x.x x$
- $lambda x.lambda y.t => lambda x.y.t$

=== Substitution
Bei einer Substitution werden alle freien vorkommen von $x$ durch $t$ ersetzt. Wir schreiben also z.B.$x[x\/t]=t$ (bei Namenskonflikten wird umbenannt). Die Substitution wird dann wie gewohnt rekursiv (z.B. bei Tupeln) weitergeführt.

== Reduktionsregeln

#let Lam = $cal(L)a m$

Es gibt Praktisch 3 _Reduktionsregeln_ für die Semantik von Lambda Kalkülen.

Für alle gilt, sie dürfen auf Teiloperationen angewendet werden:
- $t_1 ->_alpha t_2$, dann $(t_1 r) ->_alpha (t_2 r), (r t_1) ->_alpha (r t_2), lambda y.t_1 ->_alpha lambda y.t_2$ für alle $r in Lambda, y in cal(V)$


=== $alpha$ Reduktion
//TODO: Erklären

$ lambda x.t ->_alpha lambda y.t[x \/ y] $ falls $y in.not free(t)$

=== $beta$ Reduktion
Wir Substituieren einfach $x$ durch $r$ in t.

$ (lambda x.t) r ->_beta t[x \/ r] $

=== $delta$ Reduktion
// TODO: Reduktion

Wenn wir $delta$ Regeln der Form $c t_1 ... t_n -> r$ mit $c in cal(C), t_1,...,t_n, r in Lambda$ haben, die
- keine Freien Variablen haben
- Und keine Regel aus $delta$ in ihrer *linken Seite* enthalten.
- Keine Konflikte enthalten d.h. $c t_1...t_n -> r$, $c t_1 ... t_n -> r'$

Dann ist die $delta$ Reduktion

$ l ->_delta r $ für alle $l -> r in delta$

== Übersetzung von einfachem Haskell in Lambda-Terme
Dies geschieht mit der Funktion $Lam: "Exp" -> Lambda$
$
  &Lam(underline("var")) &&= underline("var") \
  &Lam(c) &&= c \
  &Lam((exp,...,exp_n)) &&= mono("tuple")_n Lam(exp_1 ... Lam(exp_n)) \
  &Lam((exp)) &&= Lam(exp) \
  &Lam((exp_1 exp_2)) &&= (Lam(exp_1) Lam(exp_2)) \
  &Lam(mono("if") exp_1 mono("then") exp_2 mono("else") exp_3) &&= mono("if") Lam(exp_1) Lam(exp_2) Lam(exp_3) \
  &Lam(mono("let") underline("var") = exp mono("in") exp') &&= Lam(exp') [underline("var") slash (mono("fix") (lambda underline("var").Lam(exp)))] \
  &Lam(mono("\\")underline("var") mono("->") exp) &&= lambda underline("var").Lam(exp)
$

= Typüberprüfung und -inferenz

#let mgu = math.op("mgu")
#let cW = $cal(W)$

Bis jetzt wurde bei der Semantik die Typekorrektheit angenommen und nicht überprüft.
Hierfür nehmen wir zunächst eine Typannahme $A_0$, wobei alle vordefinierten Operationen, bereits den *allgemeinsten Zugrundeliegendem Typen* zugewisen haben (z.B. $A_0(42)=mono("Int"), quad A_0(mono("not")) = mono("Bool") -> mono("Bool")$).

Wir müssen nun also noch alle eigens deklarierten Typen inferieren, durch den _Typinferenzalgorithmus_ $cW$.
Er bekommt eine Typannahme $A$ und einen zu überprüfenden Term $t$ und gibt als Ausgabe eine substituierte Typannahme $A'$ und den allgemeinsten Typen für den Term $tau$ zurück.

$
  cW ( A + { c ::forall a_1,...,a_n . tau}, c ) &= (id, tau[a_1\/b_1,...,a_n\/b_n])
$

Das heißt, wenn wir eine Konstante $c$ haben, für die wir bereits den Typen kennen, dann nehmen wir einfach die Identitätsfunktion als Map (da wir sie ja schon haben). Tauschen also praktisch nicht. $b, b_1,..., b_n$ sind einfach neue Variablen.

Beispiele:
- $cW(A_0 + {x :: c}, x) ) = (id, c)$
- $cW(A_0, "not") = (id, "Bool" -> "Bool") wide$ (da not in Haskell vordefiniert ist)

---

Soweit so gut. Nun zu Lambda Funktionen
1. $
    cW(A, lambda x.t) & = (theta, b theta -> tau) \
                      & "wobei" cW(A + {x :: b}, t) & = (theta, tau)
  $

  Wir finden für $lambda x.t$ zuerst den Typ von $t$ heraus und nehmen dabei an, dass $x$ den Typ $b$ hat (eine Neue Variable).
  Hieraus erhalten wir eine Substitution, in der b aber noch offen ist, also $b theta -> tau$.

  Beispiel:
  - $cW({y :: c}, lambda x . y)$ Zuerst finden wir den Typ von $y$ heraus mit zusätzlicher Typannahme ${x :: d}$.

2. Lambdaanwendungen
$
  cW(A, (t_1 t_2)) & = (theta_1 theta_2 theta_3, b theta_3) \
                   & "wobei" cW(A, t_1) = (theta_1,tau_1) \
                   & "und" cW(A, t_2) = (theta_2, tau_2) \
                   & "und" theta_3 = mgu(tau_1 theta_2, tau_2 -> b)
$

Bei Funktionsanwendungen $t_1 t_2$ berechnen wir zuerst den Typen von $t_1$ und dann mit der Substitution $theta_1$ berechnen wir den Typen von $t_2$. Somit erhalten wir $theta_2$ und zusammen also $tau_1$ und $tau_2$.
Zusammen bilden $tau_1 theta_2$ und $tau_2 -> b$, $theta_3$, also die kombinierte Substitution $(theta_1 theta_2 theta_3, b theta_3)$.

// TODO: Den letzten Absatz neu schreiben. In tatsächlich ansatzweise Verständlich bitte <\3]
