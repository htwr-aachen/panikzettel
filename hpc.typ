#import "conf.typ": conf, algoBox, defiBox, theoBox, sidenote, posneg
#import "@preview/cetz:0.2.0": canvas, plot

// #import "@local/svg-emoji:0.1.0": setup-emoji, github // only if you want to use GH names for emojis

// // first install the emoji hook!
// #show: setup-emoji


#show: conf.with(
  title: "Einführung in High-Performance-Computing",
  shortTitle: "HPC",
  authors: (
    (name: "Jonas Schneider"),
  ),
  lang: "de",
  filename: "hpc",
  showOutline: true,
)

= Einleitung

=== Vorwort

Dieser Panikzettel ist über die Vorlesung "Einführung in High-Performance-Computing".

Dieser Panikzettel ist Open Source auf #link("https://git.rwth-aachen.de/jonas.max.schneider/panikzettel", `https://git.rwth-aachen.de/jonas.max.schneider/panikzettel`). Wir freuen uns über Anmerkungen und Verbessungsvorschläge (auch von offiziellen Quellen).

=== Warum High-Performance-Computing?
Es gibt mehrere Gründe:
- Viele Wissenschaftsfelder benötigen (häufig vor allem Simulationen) viel Rechenleistung und komplexe Algorithmen.
- Aber auch AI Anwendungen benötigen hohe Rechenleistung.
- Parallelprogrammierung wird immer wichtiger und lässt sich auch auf anderen Entwicklungen anwenden (z.B. Spiele).
- Sie sind cool.

=== Rankings verschiedener Supercomputer
Passiert mittels verschiedener _benchmarks_. Der Populärste (nicht unbedingt der aussagekräftigste) ist der _HPL Benchmark_#footnote([#link("https://www.netlib.org/benchmark/hpl/")]). Er wird auch für das berühmte TOP-500 List Ranking benutzt.
Andere benchmarks sind z.B.: "STREAM" für memory performance, HPCG für realistischere memory-intensive computations.

#sidenote(title: [Moore's Law], [
  Transistorzahl pro Chip wächst mit $1,59^("year"-1959)$
  Die Frequenz der Prozessoren nimmt Abwärme bedingt praktisch nichtmehr zu (nur noch ganz langsam), Da aber immer weitere Kerne zu einem Prozessor hinzugefügt werden, steigt die Transistorzahl trotzdem. 
])

== Prozessorarchitektur
High-Performance-Computing ist tief mit den einzelnen Prozessorfunktionalitäten verwurzelt. Deswegen müssen wir die uns hier auch anschauen.

#defiBox(
  title: [_Von Neumann Architecture_],
  [
    - Einheitlicher Speicher (Für Instruktionen und Daten)
    - _Control unit_ holt Instruktionen vom _Memory_
    - _Arithmetic Logic Unit_ (ALU) executes the given instruction on some data.
  ]
)

Heutige Prozessoren sind deutlich komplexer, halten sich aber immer noch an die Architektur. 
Eine CPU besteht aus _control unit_ + _ALU_.
Ein wichtiger Aspekt: Die _memory hierarchy_ (hierzu später im #ref(<memory-hierarchy>)).

Wenn ihr von x86-64(bzw. amd64), risc oder auch arm64 lest ist dies die _instruction set architecture_. Er zeigt welche Funktionen die CPU ausführen kann (also z.B. `ADD`, `Load`, `VFMADD132PD`.

Aufgeilt sind die verschiedenen Instructions sets in _Complex Instruction Set Computer_ (CISC) z.B.`x86-64`. Die Instruktionen haben unterschiedliche Breite und hier können Instruktionen auch gut mal mehrere Unteroperationen ausführen.

und in _Reduced Instruction Set Computers_ (RISC) z.B. `arm`, `risc`. Sehr viele "gleich große" _instructions_.

#defiBox(
  title: "Little vs Big endian",
  [
    / Big endian: *Most* significant bit an der Untersten Adresse
    / Little endian: andersherum...
  ]
)

=== Pipelining

(Grob) während z.B. die _ALU_ gerade eine Multiplikation berechnet, hat die _control unit_ und der Speicher gerade wenig zu tun. Selbst intern in der ALU gibt es mehrere Zonen z.B. für Addieren, Multiplizieren, etc.

Das *_Pipelining_* überlappt mehrere Instruktionen die an getrennte _stations_ ausgeführt werden.
Die Instruktionen dauern natürlich gleich lang, aber sie werden halt nicht *nur* sequenziell abgearbeitet.
Es können auch nur unabhängige Instruktionen gepipelined werden, somit muss zu Out-Of-Order execution gewechselt werden.

#posneg(
  [
    - Höherer _throughput_ (performance)
  ],
  [
    - Die Pipeline muss erstmalig gefüllt sein (_wind up-phase_)
    - Benötigt unabhängige Instruktionen
    - Benötigt _instruction scheduling_ wegen der _Out-Of-Order execution_.
    - Komplexe ISAs können schwierige Instruktionen haben, die die Pipeline aufhalten d.h. _pipeline stalling_. Z.B. Sqrt.
  ]
)

Natürlich kann code für pipelining optimiert werden. Zum Beispiel können die einzelnen Instruktionen versetzt werden, um mehrere Unabhängige Instruktionen zu haben.


=== Superscalarity

#defiBox(
  title: "Superscalarity",
  [
    Ein Prozessor ist _superscalar_, wenn er dafür gebaut wurde mehrere Instruktionen pro _clock cycle_ auszuführen.
    Es ist eine Form des _instruction level parallelism_. Moderne  Prozessoren sind 3-6 fach _superscalar_.
  ]
)

Auch um das auszunutzen braucht es optimierten code. Z.B. können Abhängigkeiten entfernt werden.

=== SIMD

Ebenfalls ein tolles Thema. 

#defiBox(
  title: "Single Instruction Multiple Data (SIMD)",
  [Mittels spezieller Vector Instruktionen und Registern kann eine Instruktion auf mehreren Daten (einem _vector_) ausgeführt werden,
  daher kommt der Name _Single Instruction Multiple Data_ (SIMD). Die Instruktionen müssen nicht zwangsläufig parallel ausgeführt werden, sind aber transparent für den Nutzer.]
)

Die SIMD instructions für x86-64 werden in folgende _instruction set extensions_ aufgeteilt:
- SSE: 128bit Vector Register
- AVX(2): 256bit Vector Register
- AVX512: 512bit Vector Register

Eine beliebte Technik für SIMD Optimierungen sind die _loop unrollings_.

```c
for(i=0; i<n; i+=4)
{
  C[i] = A[i]+B[i];
  C[i+1] = A[i+1]+B[i+1];
  C[i+2] = A[i+2]+B[i+2];
  C[i+3] = A[i+3]+B[i+3];
}
```
Hier kann dann aber der Compiler leichter sehen: ok diese 4 Operationen können in eine SIMD instruction zusammengefasst werden.
Wir müssen den Compiler entweder mit Flags oder mit z.B. `#pragam omp simd` mittels Directives und OpenMP sagen, das er Vektorisieren soll.

== Memory hierarchy
<memory-hierarchy>

Da der Speicher (DRAM) nicht besonders an Geschwindigkeit zunimmt und 
besonders eine hohe Latenz (schon allein wegen der Entfernung zu CPU) hat,
wurden einige _caches_ eingefügt und eine Hierarchy gebildet, siehe #ref(<fig-memory-hierarchy>).

#figure(
  image("img/hpc/memory-hierarchy.png", height: 12em),
  placement: auto,
  caption: "Memory Hierarchy",
) <fig-memory-hierarchy>

Zu sehen ist, dass Level-1 (L1) cache schneller ist als level Level-2 cache, dafür ist er aber auch wesentlich kleiner 32KB vs 256KB vs 30MB (L3) (unterschiedlich pro Prozessor und Generation).

Ganz so einfach ist es aber nicht.
Am schnellsten sind natürlich die Register, auf denen die Berechnungen laufen. Der L1 cache ist dann aber auch pro Kern private, der (L2) L3 cache wird aber von allen Kernen geteilt.
Die Caches sind meistens mittels _hash-tables_ implementiert, da sie unterschiedliche Adressen in dem Speicher haben: _TAG RAM_ ist die Speicheradresse und _DATA RAM_ die Daten.

Hierbei gibt es zwei Strategien zu cachen:
/ Temporal Locality: Ein Item was gerade referenziert wurde, wird bald bestimmt nochmal verwendet
/ Spacial Locality: Wenn ich `a[0]` vom Memory hole, brauche ich bestimmt auch bald `a[1...]`.

Und auch die Daten im Cache zu ersetzen:
/ LIFO: Last In First Out
/ FIFO: First In First Out
/ Random: ...
/ Most Recently Used: ...
/ Not Recently Used: ...

Cache-Lines kümmern sich hierbei um _spacial locality_. Wenn ich Daten vom Memory oder einem höheren cache hole, hole und cache direkt die nächsten Elemente mit.
Die wird in der mit 64 Byte gemacht.

Die *Access-Time* kann dabei wie folgt berechnet werden: 
$ G(tau, beta) = T_m/T_(a v) = tau/(beta + tau(1 - beta)) $

mit $T_m, T_c$ ist die Access-Time für den Cache/ dem Speicher. $T_(a v)= beta T_c + (1-beta) T_m$ ist die Average Access-Time,
wobei $beta$ die Hit-Rate, also der Anteil der Daten, die durch den Cache bereitgestellt werden. $tau = T_m/T_c$ ist somit der Speedup bei Benutzung des caches.

Wir versuchen natürlich die Cache-Misses zu minimieren. Zum Beispiel mittels _prefetching_, indem wir Daten kontinuierlich vom Speicher holen.


==== Cache coherence
Wenn mehrere Kerne auf die gleichen Daten zugreifen/schreiben, müssen die einzelnen L1,2,3 caches gelehrt werden, da sonst Inkonsistenzen entstehen können.
Dies passiert entweder durch _Directly based_ indem an einem zentralen Punkt gespeichert wird, oder durch _Snooping_ indem caches untereinander Kommunizieren.


= Basic Optimization

Bei Optimierungen sollte immer nach dem Schema vorgegangen werden:
1. Datenerfassung (_profiling & monitoring_)
2. Datenanalyse (warum ist der Code langsam)
3. Optimierung der _hot spots_
4. Test and Repeat

Versucht nicht ernsthaft zu optimieren ohne _profiling_. Ihr könnt nur schätzen wo die Hotspots sind.

#sidenote(
  title: "Optimierungs Tips by Jonas",
  [
    Ganz grob sollte es bei Optimierungen folgende schritte geben:
    1. Datenstrukturen und Algorithmen. Macht keine Arbeit die auch einfacher ginge. (Das macht meistens den größten speedup aus)
    2. Serial Performance generell.
    3. SIMD und Caching (kleine Tweaks meistens)
    5. Multi-core performance
  ]
)

== Monitoring

_Profiling & Monitoring_ sind essentiell.

/ Event-driven Measurement: Messe immer wenn bestimmte events passieren. (-Overhead bei vielen Events [und schwer zu berechnen])
/ Time-driven Measurement: Messe immer in einem bestimmten Zeitabstand. (+Overhead ist berechenbar, - Wir könnten Events verpassen)

#defiBox(
  title: "Sampling",
  [
    _Interrupting_ einer Applikation um deren Zustand zu erfassen. (_Time-driven_)
  ]
)

#defiBox(
  title: "Instrumentation",
  [
    Einfügen von monitoring in die Applikation.
  ]
)

Instrumentalisierung kann manuell, durch _pre-instrumented libraries_ oder compiler-driven geschehen. 

#defiBox(
  title: "Profiling",
  [
    Erstelle ein "performance profile" von einer bestimmten Instanz. z.B. bei Funktion-Profiling von (manchen oder allen) Funktionen. Enthalten sind z.B. Metriken wie _runtime_, _bytes written_, etc.
  ]
)

#defiBox(
  title: "Tracing",
  [
    ein "Trace" ist eine _time-ordered list_ z.B. über den Programm Zustand. Braucht deutlich mehr Speicher als ein _profile_.
  ]
)

=== Hardware Counters

Die Hardware zählt teilweise selber manche Metriken wie z.B. L1-Hitrate, Bus-Transactions (= cache line transfers), Loads & Stores, etc.

== Obviously

- Tue weniger. Z.B. `break` in loops.
- Weniger teure Operationen. Z.B. Lookup table
- Weniger Speicherverbrauch => Mehr cache hits
- Ausgliedern von (teuren) Berechnungen. \
  Z.B. `a[i]+ a[i]+tmp` in einem loop statt `a[i] = a[i] + s + r*sin(x)`
- Avoid Branches. Branches müssen durch den Prozessor predicted werden (wegen dem prefetching der Instruktionen). Somit kann die CPU auch falsch liegen.
  Zudem verhindert es häufig eine Vektorisierung (also SIMD).
- SIMD nutzen. Hierfür braucht es _aligned_ Daten gleicher Länge (z.B. 4 Byte). Und es hilft wenn sie im speicher an Adresse % (4,8,16) = 0 Adressen liegen.
  Es kommt noch vielmehr dazu und SIMD ist tricky.
- Compiler Optimierungen nutzen: Compiler sind wirklich gut, aber man sollte es ihnen einfach machen.  (`-O3` z.B. aktivieren)
- Avoid Allocation/Deallocation: ... #ref(<data-access-optimization>)

== Daten Optimierung
<data-access-optimization>

#let Ppeak = $P_"peak"$

Speicheroperationen sind sehr häufig der limitierende Faktor. Die Bandwidth (GB/s) und die Latenz des Speichers ist nicht so stark gestiegen wie die Prozessorleistung (selbst mit cache)

#defiBox(
  title: "theoretical peak performance",
  [
    $ Ppeak ["FLOP/s"] = \#"cores" dot "frequency" dot "FP operations"/"cycle" $ #text(0.8em, "wir meinen immer double precision")
  ]
)

#defiBox(
  title: "Machine/Code Balance",
  [
    $ B_m = b_s / Ppeak $
    wobei $B_m$ die Machine Balance ist und $b_s$ die Memory Bandwidth [words/s = 64/8/s = 8byte/s], also das Verhältnis zwischen Speichergeschwindigkeit und Prozessorgeschwindigkeit.

    $ B_c = "data transfers (LOAD, STORE)"/"arithmetic operations" $
    Für einen bestimmten Code abschnitt.
  ]
) <light-speed>
Im STREAM Triad benchmark `for(i=0;i<N;++i){ a[i] = b[i] + s * c[i]; }` $==> 1.5 "Words"/"FLOP"$

#defiBox(
  title: "Lightspeed",
  [
    Erwartete Peak Performance $l = min(1,B_m/B_c)$.
  ]
)
Im STREAM Triad benchmark und dem Intel Xeon E5-2650v4: $0.015 = 1.5% "von" Ppeak$ 

Mit diesen drei Definitionen erzeugen wir uns das *_Roofline Model_*

$ P = Ppeak dot l = min(Ppeak, b_s/B_c) $ ist die maximal erreichbare peak performance

$ I := 1/B_c $ ist die operational intensity.

Das Roofline model ist dann $ P = min (Ppeak, I dot b_s) $

#figure(
  image("img/hpc/roofline-model.png", height: 10em),
  caption: "Roofline Model. Credit: HPC Folien"
) <roofline-model>

Die #ref(<roofline-model>) beschreibt ein Roofline-Model. 
/ Memory-bound Probleme: Der erste Teil der Abbildung. Probleme sind durch die Speichernutzung limitiert. (Häufiger)
/ Compute-bound Probleme: Der zweite Teil. Die Prozessorleistung ist der limitierende Faktor.

Hierbei wird natürlich, bedingt durch den _lightspeed_, nur der langsamste Datenweg modelliert.

== Algorithmen

Wir wenden hier die Big-O Notation an. Die sollte durchaus bekannt sein. #footnote([Sonst guck dir den DSAL Panikzettel an #link("https://panikzettel.htwr-aachen.de/dsal.pdf")]).
Allerdings trennen wir erneut die Speicher und die Compute Zeit (#emoji.warning zuerst kommt arithmetic operations).
Beispiele:
- $O(N)\/O(N)$ wie Vektor addition, SpMV mult., etc. Performance meistens "memory-bound" da der Speicher langsamer ist. Compiler optimiert hier leicht
- $O(N^2)\/O(N^2)$ dense matrix-vector multiply, matrix addition. Schwer zu optimieren
- $O(N^x)\/O(N^2) quad x>2$. dense matrix-matrix Multiplikation. Großes Optimierungspotential. Zunächst mal nicht memory bound.

=== Sparse Matrices
Wenn fast alle Elemente von Vektoren und vor allem Matrizen = 0 sind heißt eine Matrix _sparse_.

Wenn wir eine sparse matrix speichern, können wir dies auszunutzen und nur die $!= 0$ Werte speichern mittels des Compressed Row Storage (CRS) Formates

Als Beispiel $A = mat(
  1.1, 1.2, 0, 0 ;
  0, 2.2, 0, 0 ;
  0, 3.2, 3.3, 0 ;
  0, 0, 0, 4.4
)$ würde man in die Folgenden Arrays kodieren: 

- Row pointer: `A.ptr: int[] = [0,2, 3, 5, 6]` (der letzte gibt das Ende der letzten Reihe an)
- Column index: `A.index: int[] = [0,1, 1, 1,2, 3]`
- Value: `A.value: double[] = [1.1,1.2, 2.2, 3.2,3.3, 4.4]`

Es gibt andere Formate und gute Algorithmen für sparse matrix Operationen.

= Parallelprogrammierung

Es gibt grob zwei Arten der Memory Architektur:
- Distributed: Jeder hat sein eigenes Memory areal (eigenes _address spaces_)
- Shared: Teilen eines _address spaces_
- Hybrid: Eine Kombination aus beiden

#table(
  columns: (auto, 1fr, 1fr),
  [], [Single Instruction], [Multiple Instruction],
  [Single Data], [SISD Serial Execution], [MISD (nicht praktikabel)],
  [Multiple Data], [SIMD], [MIMD (multi processor architecture)],
)

== Limits of scalability

#theoBox(
  title: "Amdahl",
  [
    Part-I
    $ "Speedup" S_p(N) = T(1)/T(N) $
    Hier ist $T(x)$ die Zeit die es braucht um das Programm mit $x$ Prozessoren auszuführen.
    $ "Effizienz" E_p(N) = S_p(N)/N $
    
    Part-II Amdahls Law (*strong scaling*) \
    Amdahl geht von einem perfekt parallelen Teil $p$ und eine nicht parallelisierbaren Teil $s$ aus $s+p=1$

    $ S_p = T(1)/T(N) = T(1)/((s+p/N)dot T(1)) = 1/(s+(1-s)/N) $
  ]
)

Im besten Fall gibt es einen linear speedup. Also falls ich $2$ Prozessoren habe, ist das Programm doppelt so schnell.

Zwei wichtige Punkte zu Amdahl:
- Kein Code ist perfekt parallelisierbar
- Das Workload nimmt höherem $N$ zu. Bzw es bleibt Konstant pro Prozessor. Wir teilen also ein 100000 nicht auf, sondern jeder Prozessor berechnet 100000 Elemente.

#theoBox(
  title: "Gustafson's Law",
  [
    Wir teilen die Arbeit auf die unterschiedlichen Prozessoren auf.
    Erneut gilt $s+p=1$. 

    $ S_p = ((1-p) + N p )/((1-p) + p) = N p + s $

    $ epsilon_p(N) = ((1-p))/N + p $

    Auch bekannt unter "weak-scaling"

    Daraus folgt, das wenn wir $N$ erhöhen, wird der Serial part immer unwichtiger. Und der Speedup geht gegen unendlich (natürlich unrealistisch)
  ]
)

== Multithreading

Hyperthreading ist das wir zwei Control-Units und doppelte Register haben und zwei Threads laufen lassen. Die ALU wird aber geteilt.
Somit wird ein Kern besser ausgenutzt.

== Multi-Core Prozessoren

Ein Prozessor, der mehrere Kerne hat ist ein _Multi-Core Prozessor_. Die Kerne können auch unterschiedlich performant/effizient sein.

Hier muss natürlich auf Memory richtig zugegriffen werden:

/ UMA: Unified Memory Architecture: Nur ein Memory wird via shared bus zugegriffen. Der Bus sollte cross-linken können, sodass mehrere Kerne gleichzeitig zugreifen können.
/ ccNUMA: Memory ist verteilt. Per _interconnect_ kann auf den anderen Memory zugegriffen werden. \
  Meistens liegt ein NUMA node näher ein einem Kern (ist schneller). Die ganze Sache ist aber völlig transparent für den User.

== Network

Bandwidth: $B_"eff" = N/(T_L + N/B)$. $B$ ist die max. Bandwidth, $N$ die Nachrichtenlänge in Bytes und $T_L$ die Latenz.
Die Network performance ist natürlich von der Netzwerktopologie (Bus, Ring, etc.) abhängig.

#figure(
  table(
    columns: 5,
    [Topologie], [Max degree], [Edge connectivity], [Diameter], [Bisection Bandwidth],
    [Bus], [1], [1], [1], [B],
    [Ring], [2], [2], [$floor(N/2)$], [2B],
    [Fully-Connected], [$N-1$], [$N-1$], [$1$], [$B floor(N^2/4)$],
    [Fat-Tree], [depends], [1 w/o redundancy], [$2 dot "level"$], [depends],
    [Mesh], [$2d$], [$d$], [$sum_(i=1)^1 (N_i - 1)$], [$B(product_(i=1)^(d-1) N_i)$]
  ),
  caption: "Topologieübersicht"
)
= Parallelisierungsoptimierungen

/ Concurrency: Ausführung eines Tasks ist nicht fest-gelegt (kann auch gleichzeitig sein). Eigenschaft eines Programms
/ Parallel: Berechnung können simultan geschehen. Eigenschaft einer Maschine.

Unterschied zwischen Prozessen und Threads sollte durch BUS und PSP bekannt sein.


Es gibt verschiedene Wege wie wir parallelisieren können. Auch Bibliotheken (z.B. OpenMP) unterstützen häufig mehrere Wege.
- SPMD: Single Program, Multiple Data
- Loop Parallelism: Wir teilen eine Loop in Teile auf und bearbeiten die in Threads
- Master/Worker: Ein Master vergibt an viele Worker aufgaben
- Fork/Join: Fork do stuff join back

All das waren Support Strukturen. Es gibt aber auch die Algorithmischen Strukturen die auf den Support Strukturen aufbauen.
- Tasking: Wir erschaffen Tasks die dependencies haben können.
- Divide/Conquer: logisch
- Geometric decomposition: ja keine Ahnung.
- Pipeline

=== Geometric decomposition

Wir teilen z.B. ein Bild oder eine Matrix auf. Zumindest solange die Indexe nicht-überlappen. Bzw. sie können überlappen (wie bei Gaussian Blurs) müssen dann aber unabhängig voneinander sein. Z.b. convolutions bei einem convolutional-neural-network


=== Divide&Conquer

Basically Merge-Sort.

#sidenote(title: "Merge-Sort", [
  Bei Merge-Sort lässt sich das _mergen_ der Daten ebenfalls mit Divide&Conquer lösen. Aber beim splitten ist immer darauf zu Achten, dass es meistens einen Punkt gibt, wo ein Serieller Code schneller ist.
  Dort sollte man dan ein Threshold anlegen.
  ])

=== Pipelining

Gleiches Prinzip wie bei Hardware Pipelining, pipelines laufen sequenziell, aber können versetzt gleichzeitig ausgeführt werden.

Bei allen Parallelisierungen müssen wir darauf aufpassen die Berechnung ungefähr gleich zu verteilen, da wir sonst an Effizienz verlieren.
Bei Loop Parallelisierungen z.B. in sparse matrix-vektor Multiplikation, dass in dem erstem Bereich ähnlich viele Non-Zeros wie in allen anderen Bereichen sind. 
OS Jitter ist in diesem Bereich der Begriff, dass das OS natürlich auch aufgaben zu tun hat und unser Programm unterbricht. Minimiere also das OS wenn möglich.
Load Balancing ist ebenfalls möglich per runtime zu machen und dynamisch die Aufgaben zu partitionieren. Wie genau ist für den Panikzettel irrelevant (guckt euch die Folien an)

Zudem müssen wir uns um synchronization und somit auch um Korrektheit kümmern.

= OpenMP

less goo. OpenMP ist eines der meist genutzten Bibliotheken im HPC Sektor. Sie ermöglicht es (leicht) parallelen C/C++ oder Fortran 77/90/95+? zu implementieren.
Sie läuft hierbei über Direktiven, heißt wir annotieren nur unseren bereits geschriebenen Code und der OpenMP compiler (integriert in alle üblichen mit Flag `-fopenmp` oder `-qopenmp`)
fügt dann den Code ein.

Bei OpenMP Programmierung nehmen wir eine shared-memory Modell an. Alle Kernen greifen also auf einen Memory.

OpenMP start mit einem einzelnen Thread dem _Master Thread_.
Von dem werden mit Parallel Regionen dann weitere Threads gespawnt. Also sehr nach dem Konzept Fork/Join.

Beispiel 

```c
#pragma omp parallel
{
  // parallel stuff
}
```

Die Thread Zahl wird meistens per env variable `OMP_NUM_THREADS` gesetzt.

Oft nutzen wir aber auch Worksharing, also nach dem Konzept Loop-Parallelism:

```c
#pragma omp parallel
#pragma omp for
for(int i=1; i < N; i++){
  a[i] = b[i]+c[i]
}
```
Sei `OMP_NUM_THREADS=4`, $N=100$.

Hier wird das Standardmäßig aufgeteilt in $[0,25), [25,50), [50,75), [75,100)$. Kann aber mit `#pragma omp for schedule([static|dynamic|guided], [chunkSize])` geändert werden.

Die beiden Sachen können auch kombiniert werden:

```c
#pragma omp parallel for
...
```

Für Synchronization stehen auch Direktiven zur Verfügung.

```c
#pragma omp critical
```

Hier darf jeweils nur ein Thread gleichzeitig rein.

```c
#pragma omp barrier
```

Hier warten alle bis alle Threads bei der Barriere angekommen sind.

```c
#pragma omp single/master
```

Wir nur von einem Thread bzw. dem master erledigt.

== Data scoping

Um Korrektheit zu bewahren müssen manche Daten für Threads privat sein, da sie sonst von anderen überschrieben würden.

Das alles ist ganz schön viel wir werden hier nur über ein paar Sachen berichten.
- `shared`: Daten werden über alle threads geteilt, Default für parallel Region. 
- `private`: Daten sind private. D.h. eine neue Instanz wird erstellt für jeden Thread
  - `firstprivate`: Privat, aber vor dem ersten construct werden die Daten kopiert, Default für tasks
  - `lastprivate`: Privat, aber am Ende werden die Daten zurück kopiert.

Loop control vars sind `private`. `i` im Beispiel oben. Statische vars sind `shared`

Falls wir so einen Code hier haben

```c
int i,s = 0
#pragma omp parallel for reduction(+s)
for(i=0; i < 100; i++){
  s = s + a[i]
}
```

Wir summieren also einfach nur `a` auf. Da das aber eigentlich ja schlecht parallelisierbar ist, gibt es die `reduction` clause. 
Hier wird dann für alle Intervalle $[0,25),...$ ein eigenes $s_"priv"$ gemacht, dann $a[0]+...+a[24]$ aufsummiert und dann die 4 $s_"priv"$ summiert.
Dies verhindert, wenn man es richtig anstellt, auch das False-Sharing, also das invalidieren der Caches.

==== Tasking

Zusätzlich zum Worksharing besitzt OpenMP auch Tasking Funktionalitäten.

```c
int main(int argc, char *argv[]){
  #pragma omp parallel
  {
    #pragma omp single
    {
      fib(input)
    }
  }
}
```

```c
int fib(int n){
  if (n < 2) return n;
  int x,y;
  #pragma omp task shared(x) if(n<30)
  {
    x = fib(n-1);
  }

  //hier könnten wir noch einen Task machen, brauchen wir aber nicht, da dieser Task hier auch noch etwas berechnen kann
  y=fib(n-2)
  #pragma omp taskwait
  return x+y
}
```

Das Beispiel sollte verständlich sein. Die erste `parallel` Region machen wir auf, damit die anderen Tasks auf die Threads aufgeteilt werden.
Dabei wird das `if` verwenden um z.B. einen Threshhold zu bauen, ab wann wir seriell arbeiten wollen.
Warum das?
Einen Task zu erstellen ist nicht wenig Arbeit (einige Tausend Instruktionen) noch besser wäre ein `if(n<30) return serialFib(n)` nach dem Rekursionsanker.

Die `taskloop` Direktive teilt eine Loop in tasks auf, also so wie for aber statt threads, tasks.
Ebenfalls gibt auch noch `taskyield`. Der Tasks kann also suspendiert werden.

= MPI

Um nicht nur Kerne eines Prozessors, sondern auch mehrere Prozessoren für Berechnungen zu nutzen müssen wir uns um die Kommunikation zwischen ihnen kümmern.
Message Passing Interface (MPI) ist eine Bibliothek die uns Nachrichtenverkehr zwischen Prozessen ermöglicht. Egal ob die auf dem gleichen Prozessor laufen.

Dies ist für SPMD, Single Program, Multiple Data wichtig. Hier haben wie ein Programm und lassen via mehreren OS Prozessen auf verschiedenen Datenteilen laufen.
Hierbei kommen häufige Nachrichten vor:
- `send(data, destination [id])`: Sende Daten
- `recv(data, src)`: Warte auf und empfange Daten
- `bcast(data, root)`: Broadcast Daten vom Root runter.
- `gather/scatter(data/subdata, subdata/data, root)`: Verteile/Sammle Daten zu subdaten in allen unter Root.

Teil von MPI sind unter anderem:
- Identifiers, also wie die Prozesse heißen.

```c
#include <stdio.h>
#include <mpi.h>

int main(int argc, char **argv) {
  int rank, nprocs;
  
  MPI_Init(&argc, &argv);

  MPI_Comm_rank(MPI_COMM_WORLD, &rank);
  MPI_Comm_size(MPI_COMM_WORLD, &nprocs);

  printf(“Hello, MPI! I am %d of %d\n”,
    rank, nprocs);
  
    MPI_Finalize();
  return 0;
}
```

Das `...Comm...` steht hierbei für Communicator. Ein Communicator teilt die Prozesse ein und verteilt dort Nachrichten. Zwei sind vordefiniert:
- `MPI_COMM_WORLD`: Alle gestarteten Prozesse
- `MPI_COMM_SELF`: Nur der aktuelle Prozess. (für IO Zeugs)


Fehler werden bei MPI mit Rückgabe von `MPI_SUCCESS` bzw genau dann nicht gelabeled.

Eine MPI Nachricht besteht aus:
- Message Content
- Envelope
  - Sender Rank
  - Receiver Rank
  - Tag (Zusatzinfos)
  - Communicator

Die Nachrichten werden in korrekter Reihenfolge übertragen.

Hierfür wird `MPI_Send(buf, count, datatype, dest, tag, comm)` verwendet. Die Datentypen werden mittels eigener Language Bindings eingetragen.
Heißt soviel wie bei `int buf[count]` sagen wir `MPI_INT`.

Für Empfangen `MPI_Recv(buf, count, datatype, src, comm, status)`
`count` ist die Anzahl die `buf` halten kann. Die Tatsächliche Größe kann mittels `MPI_Get_count` abgefragt werden.

Wenn aber beide Prozesse erst Datensenden und dann Austauschen wollen gibt es einen Deadlock.
Hierfür gibt es die `MPI_Sendrecv([send args], [recv args], comm)`.

Oder man verwendet _non-blocking_ message passing mittels `MPI_Isend, MPI_Irecv`. Hierbei ist `status` mit `req` getauscht,
da wir über den Status natürlich erst später Bescheid wissen: `MPI_Wait(MPI_Request *request, MPI_Status *status)`.
Mit `MPI_Waitany/Waitsome/Waitall` lassen sich mehrere _request_ angeben und es wird gewartet bis einer/eine gegebene Anzahl/alle fertig ist/sind.
MIt `MPI_Test` auch any,some and all, lässt sich non-blocking queries ob die Übertragung fertig ist.

Die einzige Synchronizationsmöglichkeit ist `MPI_Barrier(MPI_Comm comm)`.

MPI hat auch eigene Datentypen und implementiert die ganzen Broadcast/Gather/Scatter Sachen, aber das ist zu viel für diesen Panikzettel. Die Basics sind da.

== Hybride Systeme

OS Prozesse sind natürlich etwas aufwendiger und MPI ist ja nur das Message Passing Interface, also die effiziente Ausnutzung der CPU ist nicht dabei.
Hier können wir aber beides MPI und OpenMP verwenden. OpenMP für Multithreaded, SIMD und Cache effiziente Programme und MPI für die Multi-node Nutzung.
Beispiel:

```c
#pragma omp parallel for
for(k = 0; k < N; k++)
{
  // Parallel work done here by OpenMP
  // (e.g. updates over a local stencil)
}

// Halo exchange done by single thread via MPI
MPI_Irecv(halo data from –dir neighbor)
MPI_Isend(data to +dir neighbor)
MPI_Irecv(halo data from +dir neighbor)
MPI_Isend(data to -dir neighbor)
MPI_Waitall();
```


Unter Hybride Systeme versteht man aber genereller die zusammensetzung von mehreren Systemen. Z.B. Auch MPI + CUDA für GPU Programmierung etc.

MPI kann verschiedene Thread Unterstützungen. `MPI_THREAD_SINGLE/FUNNELD` (nur einer/der master kann), `MPI_THREAD_SERIALIZED` (nur einer gleichzeitig), `MPI_THREAD_MULTIPLE`(alle)

= Accelerators

Werden immer Populärer (denke ich). Hierunter zählen auch GPUs (genauer General Purpose GPUs (GPGPUs)) aber auch FPGAS oder Intel Xeon PHI coprozessoren.

=== Ganz schneller GPU Überblick

lets go.

Eine GPU hat im Vergleich zu einer CPU viel viel mehr Kerne, die (teilweise) exakt gleichzeitig laufen, aber deutlich weniger können und meist langsamer sind.

> Wie ist eine GPU aufgebaut?

GPUs operieren nach dem Prinzip SIMT, Single Instruktion, Multiple Threads. Also mehrere Threads laufen einem Gemeinsamen Program Counter hinterher.

Es werden 32 Threads zu einem _WARP_ zusammengefasst. Die Laufen 100% Parallel ein Programm ab. Die ThreadID (ein index 0-31) wird hierbei als Index für Kalkulationen genommen.
Beispiel `a[threadIdx.x] = b[threadIdx.x] + c[threadIdx.x]`. Bei Branches werden manche Threads pausiert, falls die Bedingung da gerade nicht stimmt (ineffektiv)

Mehrere Warps wird dann zu einer Gruppe Threads (einer Thread Group) zusammengefügt. Der Warp Scheduler kann einzelne Warps dann auf einer Streaming Multiprocessor (SM) ausführen.

Diese Gruppen werden dann erneut gruppiert zu einem Grid (da teilweise mehrdimensional). Die werden dann auf der gesamten GPU ausgeführt, die aus mehreren SMs besteht, die wiederum aus vielen Kernen besteht.

Das war viel.

Wir programmieren das ganze entweder speziell für die GPU mittels OpenCL oder noch spezieller mit CUDA für NVIDIA GPGPUs oder mittels OpenMP offloading
und der OpenMP compiler macht das für uns (teilweise natürlich ineffizienter). `#pragma omp target`

Vorteil von Accelerators sind häufig die schnelleren und optimierteren Speichergeschwindigkeiten. Neue GPUs nutzen z.B. Hight-Bandwidth-Memory HBM das um einiges Schneller ist als
gewöhnlicher DRAM.

GPUs sind bei sehr vielen mit Lineare Algebra und somit auch KI echt schnell. Bei allem mit vielen Branches aber nicht (da sie keine Branch prediction haben, sondern dann ein Teil der GPU wartet).

Allerdings muss man bei GPUs darauf achten wann, welche und wie viele Daten von der CPU zur GPU übertragen werden, da die PCIe Connection vergleichsweise langsam ist.
Es gibt aber auch distributed memory Konzepte, die aber natürlich nicht immer optimal sind.

`#pragma omp map(to:a[0:n]) / #pragma omp map(from:a[0:n]) / #pragma omp map(tofrom:a[0:n])` Bei `to` wird es vor Anfang des Codeblocks zur Graphik Karte kopiert.
Bei `from` wird es am Ende auf den CPU speicher kopiert, bei to from beides einfach.

OpenMPs tasks können auch auf die GPUs warten mittels `depends()` z.B. `#pragma omp target map(...) nowait depends(out:gpu_data)`.

> Auf was außer _branching_ sollte man noch achten bei GPUs?

Coalescing. Eine GPU greift mit einer Art cache-line von 128Byte auf den Speicher zu. Wir sollten also darauf achten keine "Lücken" im speicher zu haben.

statt `struct {x,y}[]`, wo wir nur die `x` Koordinate brauchen, sollten wir lieber nur `struct{x[], y[]}` oder so nehmen.


= Energieeffizienz

Computer können nur begrenzt effizient sein. 

#theoBox(
  title: "Thermodynamische Limits eines NAND Gates",
  [
     $ E = ln(2) dot k dot T $
     wobei $k=1.3806504 24 ∗ 10−23 J/K$ die Bolzmann Konstante ist. Und T die Temperatur (Kelvin).
     
     Ist nur gut zu wissen.
  ]
)

CPU braucht Strom:
$ P = V dot I = C V^2 f $
Wobei $V$ die Spannung ist, $f$ die Frequenz, $I$ die Stromstärke, $C$ die Elektrische Kapazität.

Um eine höhere Frequenz zu erreichen, braucht die CPU eine höhere Spannung (also quadratisch mehr Power).

Ein Prozessor kann in unterschiedlichen Zuständen sein:
- P State: Unterschiedliche Leistung/Geschwindigkeit aber alle voll Funktional. (Und nichtmehr ganz akkurat)
- C State:
  - C0 CPU macht gerade etwas
  - C1 CPU ist IDLE: Clock wird nicht weitergegeben
  - C2 Stop Clock
  - C3, C4 Deep Sleep


Es lohnt sich also schnelle Programme zu schreiben, die die gesamte CPU ausnutzten.
