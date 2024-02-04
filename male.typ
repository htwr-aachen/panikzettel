
#import "conf.typ": conf, algoBox, defiBox, theoBox
#import "@preview/cetz:0.2.0": canvas, plot


#show: conf.with(
  title: "Elements of Machine Learning and Data Science",
  shortTitle: "MaLe",
  authors: (
    (name: "Jonas Schneider"),
  ),
  lang: "de",
  filename: "male",
  showOutline: true,
)

= Einleitung und Stochastisches Vorwissen

=== Vorwort

Dieser Panikzettel ist über die neue Vorlesung "Elements of Machine Learning and Data Science", ein Pflichtfach des neuen Informatik Bachelors der RWTH Aachen.

Dieser Panikzettel ist Open Source auf #link("https://git.rwth-aachen.de/jonas.max.schneider/panikzettel", `https://git.rwth-aachen.de/jonas.max.schneider/panikzettel`). Wir freuen uns über Anmerkungen und Verbessungsvorschläge (auch von offiziellen Quellen).

Es ist häufig schwierig, die genauen Themenschwerpunkte der Vorlesung und Prüfung zu erkennen. Hier allerdings besonders, da es die erste Iteration des neuen Fachs ist und keine Altklausuren zu Rate stehen.
Wir werden deshalb einige Zeit (und Feedback von späteren Semestern) brauchen um besser Zusammenfassen zu können.

Da das neue Fach auf Englisch gehalten wird, ist es eine gute Zeit, dies auch für den Panikzettel umzusetzen und eine zusätzliche Englische Version zu erstellen. Dies hier ist die *deutsche* Version, jedoch verwenden wir die englischen Fachwörter um keine Übersetzungsfehler bei uns und euch zu riskieren.

=== Stochastisches Vorwissen

Ein großer Teil der Machine Learning und Data Science Konzepte und Algorithmen beruhen auf Stochastik. Wir werden hier _nicht_ die Grundlagen der Stochastik wiederholen, auch wenn ein kleiner Teil der Vorlesung genau dies tat, sondern auf den eigenen Stochastik Panikzettel #footnote([#link("panikzettel.htwr-aachen.de")]) verweisen.

//TODO: Maybe doch ganz kurz Grundbegriffe erklären? Max 1/2 Seite.

=== Aufteilung
//TODO: Aufteilung überarbeiten

Die Vorlesung wurde von drei verschiedenen Lehrstühlen und Professoren zusammen angeboten und aufgeteilt.
Die Aufteilung dieses Panikzettel orientiert sich ebenfalls an dieser Aufteilung.

- Machine Learning
- Data Science
- Evaluation und AutoML

= Machine Learning

#let Cl = $cal(C)$

//TODO: Themen überblick nur temporär
Themen:
- (Intro)
- Probability Density Estimation
- Linear Discriminants
- Linear Regression
- Logistic Regression
- Support Vector Machines
- (AdaBoost) da nicht behandelt
- Neural Networks

//WARNING: stimmt so nicht (von der Benennung), aber ich möchte grob einen Überblick geben der alle (Classification, Regression, Clustering, etc.) gemeinsam haben (außerhalb vom learning).
Das Grundkonzept des gesamten Machine Learning Bereichs, der in dieser Vorlesung behandelt wird, kümmert sich um _Klassifizierung_, also der Aufteilung in Klassen (z.B. gegeben ein Foto, ist es eine Katze oder ein Hund).

=== Lernformen & Lernziele
Machine Learning Algorithmen lernen mit Trainingsdaten.
Diese können bereits (teilweise) klassifiziert sein (d.h._labeled_), woraus sich somit drei Arten zu lernen ergeben:
- Supervised learning
- Semi-supervised learning
- Unsupervised learning

Wir werden einige Lernziele besprechen, aber es ist gut, sie vorher eingeführt zu haben.

//TODO: Umschreiben/Überprüfen.
#table(
  columns: (auto, 1fr, 1fr),
  rows: 3,
  [], [Discrete Targets], [Continuous targets],
  [Known Targets \ / Supervised Learning],
  [_Classification_ \
    Einteilung in verschiedene (zuvor bekannte) Klassen
  ],
  [Regression \
    Versuchen mittels Funktionen (z.B. lineare) Daten zu beschreiben.
  ],
  [Unknown Targets \ / Unsupervised Learning],
  [Clustering \
    Einteilung unbekannter Datenpunkte in _Clusters_, die stärker untereinander als mit anderen Verbunden sind.
  ],
  [Density estimation \
      Versuchen, eine Wahrscheinlichkeitsverteilung abzubilden von zufälligen samples.
      Anders als bei Regression ist hier die Datenfunktion nicht bekannt / es wurde nicht vorher gelabeled.
  ]
)

Das Ziel wird aber immer sein:
Gegeben Trainingsdaten $cal(D) = {x_1,..., x_n}$ oder mit gegebenenfalls labeln $cal(D) = {(x_1, t_1),..., (x_n, t_1)}$
eine Funktion $y$ zu trainieren, die zu Daten, die nicht im Testset vorkommen, eine Vorhersage treffen kann.

== Probability Density Estimation

Wie wahrscheinlich ist es, dass wir ein $x$ sehen unter der Bedingung, dass wir in der Klasse $cal(C)_k$ sind, also $p(x | cal(C)_k)$.
Diese _likelihood_ ist genau das Gegenteil von dem was wir brauchen: $p(cal(C)_k | x)$.

Somit stellen wir es mit den _a-priori probabilities_ $p(cal(C)_k)$ und Bayes Theorem um:
$ p(cal(C)_k | x) = (p(x | cal(C)_k)p(cal(C)_k))/(p(x)) = (p(x | cal(C)_k)p(cal(C)_k))/(sum_j p(x | cal(C)_j) p(cal(C)_j)) $

Dies ist die _posterior_ Wahrscheinlichkeit, die wir benötigen, um x klassifizieren.

Nun verteilt sich $p(cal(C)_k | x)$ in einer bestimmen Wahrscheinlichkeitsverteilung, die wir aber nicht kennen, die es nun geht zu approximieren.

Gegeben ist eine Reihe von Klassen $Cl_1,... Cl_d$, $d in NN$ (oder $Cl_a, Cl_b$), deren _a-priori_ Wahrscheinlichkeiten und ein Trainingsdatensatz $x_1,...,x_N$, $N in NN$ mit Labeln.

== Parametrische Methoden mittels Gaussian (Normal) Verteilung

Wir nehmen nun an, dass die $p(Cl_k | x)$ nach einer Normal Verteilung $theta_N=(mu, sigma)$ (genauer irgendeiner Verteilung mit Parametern $theta$) verteilt ist. Um hier die Parameter zu bestimmen, benötigen wir erneut die Hilfe von der log-likelihood und der Maximum Likelihood. Wir werden das hier nochmal durchgehen:

Hierfür benötigen wir die Wahrscheinlichkeit $L(theta) = p(cal(X) | theta)$, dass $cal(X)$ von den Parametern $theta$ generiert wurde. Wir wollen $L(theta)$ maximieren. Für einen einzelnen Datenpunk $x_n$ gilt $p(x_n | theta) = 1/(sqrt(2 pi) sigma) exp(-((x_n - mu)^2)/(2 sigma^2))$.

Da alle Variablen i.i.d. (d.h. unabhängig und identisch verteilt) sind, können wir die Wahrscheinlichkeiten summieren: $L(theta)=sum_(n=1)^N p(x_n | theta)$ und das _negative log-likelihood_ bilden $E(theta)= - ln L(theta) = - sum_1^n ln p(x_n | theta)$ (#emoji.warning $ln a*b = ln a + ln b$).

Um nun das Maximum zu berechnen ist nun die Ableitung von $E(theta)$ erforderlich:
$ diff/(diff theta) E(theta) &= - limits(sum_(n=1)^N (1/p(x_n | theta)) dot diff/(diff theta) p(x_n | theta)) \
&= ... = 1/sigma^2 sum_(n=1)^N x_n - N mu =^! 0 \
&<==> hat(mu) = 1/N sum_(n=1)^N x_n and hat(sigma)^2 = 1/N sum_(n=1)^N (x_n - hat(mu)^)^2 $ .

//TODO: Eher nicht mit rein nehmen oder?
Bei Maximum Log-Likelihood Optimierungen wird die Varianz unterschätzt, und muss im Fall der Normalverteilung mit $N/(N-1)$ ausgeglichen werden.

== Histogramme, Kernel Methods & k-Nearest Neighbors

=== Histogramme

Aufteilung der Daten in $N$ Säulen mit breite $Delta_i$. Die Höhe der Säule ist dann $p_i = n_i/(N Delta_i)$, wobei $n_i$ die Anzahl der Beobachteten Ergebnisse in dem Bereich ist.

#grid(
  columns: (1fr, 1fr),
  [#figure(
    image("img/male/kernel-method.png", width: 30%),
    caption: [Kernel Method]
  ) <k-nearest>],
  [#figure(
    image("img/male/k-nearest-neighbors.svg", width: 30%),
    caption: [1-Nearest Neighbors]
  ) <k-nearest>]
)
Gegeben sei eine _probability density function_ (pdf) $p(Cl_k | x)$, die wir erneut approximieren wollen. Wir visualisieren hier mit zwei Dimensionen. Wir können nun $p$ approximieren indem wir uns einen kleinen Bereich $cal(R)$ um die Datenpunkte angucken
und somit ein $P=integral_cal(R) p(y) d y = K/N approx p(x)V $ erhalten, wobei $V$ das Volumen von $cal(R)$ ist und $K$ die Anzahl der Datenpunkte die in $cal(R)$ liegen.

Wir haben somit zwei Möglichkeiten zu approximieren:
/ Kernel Methods: Fixes Volumen $V$, aber mit einer variablen Menge von Punkten $K$ in $cal(R)$
/ K-Nearest Neighbors: Fixe Punktzahl $K$ in $cal(R)$, somit unterschiedlich große Volumen $V$

=== Kernel Methods

Wir bilden einen Kernel $k$ mit $k(u) >= 0$ und $integral k(u) d u = 1$
Hierbei beschreibt $u$ einen Vektor von einem Punkt $x$ zu einem $x_n$.
Das $k$ gewichtet diese Distanz dann.

Somit gilt $K = sum_(n=1)^N k(x - x_n)$ und $p(Cl_k | x) = K/(N V) = 1/N sum_(n=1)^N k(x-x_n)$

Der parzen-window (kernel), indem man einen Würfel der Höhe $h in NN$ um $x$ aufbaut, wäre als Beispiel
$ k = cases(1/(h^D) "if" |u_i| <= 1/2h\, i=1\,...D,
           0 "else") $
Also skaliert 1, falls $x_n$ (in allen Dimensionen) im Würfel liegt und $0$ sonst.

Somit ergibt sich eine probability density estimation von $p(Cl_k | x) approx K/(N V) = 1/(N h^D) sum_(n=1)^N k(x-x_n)$

Populäre kernels sind z.B. auch Gaussian Blurs (Smoothener)

=== k-Nearest Neighbors

Hier setzten wir ein $K in NN$ fest und bestimmen eine Sphäre, die wir brauchen, um die $K$ nächsten Nachbarn zu inkludieren.
Somit gilt immernoch $p(x) approx K / (N V)$.

Die allermeisten _non-parameterized_ probability density estimators haben bestimmte Einstellungen, die für unterschiedliche Ergebnisse sorgt, sogenannte _Hyperparameter_ (z.B. $Delta_i, h, K,$ etc.).

k-NNs können mittels Bayes Decision Theory auch als Klassifizierer dienen. Indem man die class-conditional Verteilung approximiert mit $p(x | C_j) approx K_j/(N_j V)$ und durch die priors $p(C_j) approx N_j/N$ die posteriors $p(C_j | x) approx p(x | C_j)p(C_j) 1/p(x) = K_j/K$

== Mixture Models

In einem Mixture Model wird davon ausgegangen, nach mehreren ($M in NN$) probability distributions verteilt zu sein, die sich addieren. Meist wird die Normalverteilung gewählt.

Also $p( x | theta ) = sum_(j=1)^M p(x|theta_j) p(j)$, wobei $theta = (pi_1, theta_1, ..., pi_1, theta_M)$ alle Parameter bündelt und $p(j)=pi_j$ die priors (also die Anfangsvermutungen des _mixtures components_).

Um hieraus eine formale Wahrscheinlichkeitsverteilung zu erstellen, muss $sum_(j=1)^M pi_j = 1$ und somit $integral p(x|theta)d x = 1$ sein.

Hierfür gibt es kein analytisches Verfahren, die Maximum Log Likelihoods zu finden. Somit bleiben numerische Verfahren (und) iterative Optimierungsverfahren.

=== EM Algorithmus
Der _E-STEP_: $ gamma_j(x_n) <- (pi_j cal(N)(x_n | mu_j, Sigma_j))/(sum_(k=1)^K pi_k cal(N)(x_n | mu_k, Sigma_k)) $
Hier ist $Sigma$ die Kovarianzmatrix.

Der _M-STEP_:
#grid(
  columns: (1fr,1fr),
  $ hat(N) &<- sum_(n=1)^N gamma_j(x_n) \
  hat(pi)_j &<- hat(N)_j/N $,
  $ hat(mu)_j &<- 1/hat(N)_j sum_(n=1)^N gamma_j(x_n)x_n \
  hat(Sigma)_j &<- 1/hat(N)_j sum_(n=1)^N gamma_j(x_n)(x_n - hat(mu)_j)(x_n - hat(mu)_j)^sans(T) $,
)

Der EM Algorithmus muss durch _regularization_ gegen $sigma -> 0$ geschützt werden, weswegen $sigma_min I$ addiert wird #footnote("Der EM Algorithmus wird aus meiner Sicht nicht groß in der Klausur angewandt werden können, Wissensfragen jedoch schon.")

== Linear Discriminants

_Linear Discriminants_ versuchen, ein Gerade $y(x) = w^sans(T) x + w_0$ zu finden, die ein dataset trennt (d.h. $y(x) >= 0 ==> C_1 "sonst" C_2$). Falls dies gelingt, heißt ein dataset _linearly seperable_.

Häufiger wird aber $y(x) = tilde(w)^sans(T) tilde(x) = sum_(i=0)^D w_i x_i$ benutzt, wobei hier $x_0 = 1$ gesetzt ist und der Bias $w_0$ somit verrechnet wird.

Es lassen sich $K in NN$ _linear discriminants_ berechnen und die Klasse $C_k$ genau dann gewählt werden, wenn $y_k (x) > y_j (x)$ für alle $j != k$.

Nun aber zur Optimierungsmethoden dieser $y_k (x)$. Zunächst werden alle $k$ Diskriminanten zusammen gruppiert $tilde(W)=(tilde(w)_1, ..., tilde(w)_K) = mat(w_(10), ..., w_(K 0);
dots.v, dots.down, dots.v;
w_(1D), ..., w_(K D))$, $tilde(X) = vec(x_1^sans(T), dots.v, x_N^sans(T))$ und $Y(tilde(X))=tilde(X)tilde(W)$. Ebenso werden die _target vectors_ (die label) $T = vec(t_1^sans(T), dots.v, t_N^sans(T))$.

Um lernen zu können, definieren wir eine _error function_ (hier _Sum of squares_) $E(W) = 1/2sum_(n=1)^N sum_(k=1)^K (w_k^sans(T)x_n - t_(n k))^2$. Nehmen wir nun im 2-class Fall die Ableitung: $(diff E(w))/(diff w) = ... = w = (X^sans(T)X)^(-1)X^sans(T)t = X^dagger t$ (das $X^dagger$ ist die pseudo-inverse, da X ja singulär seine könnte). Somit erhalten wir eine _closed-form_ Lösung $y(x;w) = w^sans(T) x = t^sans(T) (X^dagger)^sans(T) x$.

Um weniger sensitiv gegen _outliers_ zu sein, wird $y$ allerdings meist mit einer Aktivierungsfunktion versehen (ähnlich wie bei NNs) $y(x)=g(w^T x)$.
In der Vorlesung der Logistic-Sigmoid $sigma(x) = 1/(1+e^(-x))$.

_Basis functions_ $phi.alt$ erweitern die $y(x) = w^sans(T) phi.alt(x)$, um nicht linear trennbare Datensätze zu klassifizieren zu können.


== Regressions

// #canvas(length: 1cm, {
//   plot.plot(size: (8, 6),
//     x-tick-step: none,
//     x-ticks: ((-calc.pi, $-pi$), (0, $0$), (calc.pi, $pi$)),
//     y-tick-step: 1,
//     {
//       plot.add(
//         style: style,
//         domain: (-calc.pi, calc.pi), calc.sin)
//     })
// })

Wir haben zwei verschiedene Arten Regression behandelt:
/ Linear Regression: approximieren einer Funktion $h(x) in RR$, gegeben durch label $t_n = h(x) + epsilon$
/ Logistic Regression: approximieren einer diskreten Funktion (hier sind zwar auch nur Datenpunkte gegeben, aber die Funktion ist diskret)

=== Linear Regression
Für linear regression wenden wir die Least Square Regression an.
Wir nehmen als _error function_ erneut die Sum of squares Funktion $E(w)=1/2 sum_(i=1)^N (y(x_n;w) - t-n)^2$.

Kommen also bei dem gleichen $w=(Phi^sans(T)Phi)^(-1)Phi^sans(T)$ an wie bei den Diskriminanten. Allerdings mit $y(x) = w^sans(T) phi.alt(x)$ einer Basis Funktion

Nehmen wir also als Basis Funktion $phi.alt_j(x) = x^j$. Nun ist die Wahl des Polynomgrads ein wichtiger _Hyperparameter_. Jedoch ist mit dieser Error Funktion des _overfitting_ groß, da es die unterliegende $epsilon$ noise modelliert und nicht $h(x)$.

Um dagegen vorzugehen, wird ein _regularizer_ $Omega$ (z.B. $Omega = 1/2||w||^2$) eingesetzt $E(X)=L(w) + lambda Omega(w)$, hierbei ist $L(w)$ der Loss-Term also einfach die vorherige _error function_.

//TODO: Ridge Regression?

=== Logistic Regression

Wir wollen die Class-posteriors $p(Cl_1 | phi.alt)$ modellieren und zwar als _linear discriminant_ $y(phi.alt) = sigma(Cl_1^sans(T) phi.alt)$. Wir gehen also nicht der generativen Modellierung nach (die direkt die posterior Wahrscheinlichkeitsverteilung modellieren will), sondern *nur* der Grenze zwischen den Klassen (_discriminative modelling_) [Note: hierfür sind labels zwangsweise nötig].

Falls ihr gefragt werdet, was die Vorteile sind:
- Effizientere Parameter Nutzung, da weniger Parameter gebraucht werden.

Zudem gibt es noch zwei wichtige Fachwörter:
/ cross-entropy error: $E(w)=-sum_(n=1)^N (t_n ln y_n + (1-t_n) ln (1-y_n))$
/ Softmax Regression: $(exp(a_k))/(sum_(j=1)^K exp(a_j))$ für eine Klasse $k in underline(K)$. (Die beiden Sachen lassen sich auch verbinden :/)

Für die tatsächliche Regression müssen wir wieder auf iterative Methoden zurückgreifen.
In diesem Fall auf _gradient descent_.

==== Gradient Descent

$ w_(k j)^(tau + 1) = w_(k j)^tau - eta lr((diff E(W))/(diff w_(k j)) bar)_(w^tau) ( "fortan" w^(tau + 1) = w^tau - eta Delta E(w)) $

dies ist die (so halb) erste Taylor expansion mit Hyperparameter _learning rate_ $eta$.
Ist die _learning rate_ zu hoch, wird das Optimum "übersprungen", bei zu kleiner Learning Rate dauert es lange und eventuell konvergiert der Gradient zu einem lokalen Minimum.

Die Newton-Raphson Methode (orientiert sich an der zweiten Taylorentwicklung)
verwendet zusätzlich noch ein $H^(-1)=(diff^2 E(w))/(diff w_i diff w_j)$

// Bei der Logistischen Regression versuchen wir die posteriors $p(Cl_k | x)$ durch eine linear discriminant function zu modellieren.

//Zunächst $p(Cl_1 | x) = sigma(a)$ mit $a = ln (p(x | Cl_1)p(Cl_1))/(p(x|Cl_2)p(Cl_2))$ beschreibt der logistic sigmoid eine posterior probability und modellieren so $p(Cl_1 | x) = y(x) = sigma(w^sans(T)x); quad p(C_2|x)=1-p(Cl_1|x)$


=== Support Vector Machines (SVM)

#figure(
  image("img/male/svm.png", height: 3cm),
  caption: [Example of a SVM]
)

Bei Support Vector Machines (SVMs) wird anstatt eine Diskriminante zu verwenden, versucht, zwischen den zwei Cluster eine Safety Zone (d.h. _margin_) aufzubauen und zu maximieren.
Das $y(x)=(t_n ( w^sans(T)x_n + b))$, welches den größten _margin_ $1/2 ||w||^2$ erschafft und $y(x) >= 1$ für alle $n in N$ (d.h. alle Trainingspunkte richtig klassifiziert), gilt als optimiert.

Hieraus bauen wir uns ein Optimierungsproblem à la Quantitative Methoden (BWL😑).
Wie genau wir dahin kommen, ist für den Panikzettel (und aus meiner Sicht) wenig relevant, doch brauchen wir hierfür _lagrange multiplier_ $lambda, a_n$ für die Primal form.

==== Primal Form
Langrange multipliers $a_0 >= 0$
$ L(w,b,a)=1/2 ||w||^2 - sum_(n=1)^N a_n [t_n(w^sans(T)x_n + b) -1] $

Conditions:
$ a_n &>= 0 \
  t_n(w^sans(T)x_n + b) -1 &>= 0 \
  a_n[t_n(w^sans(T)x_n + b) -1] &= 0 $

Karush-Kuhn-Tucker conditions:
$ lambda &>= 0 \
  f(x) &>= 0 \
  lambda f(x) &= 0 $

Die Intuition aus der Primal Form ist (Gut, dass man sagen muss was die Intuition ist), dass nur manche Datenpunkte (die support vectors (logisch)) die Margins und die Decision Boundary beeinflussen.

*Zeit Komplexität*: $O(D^3)$, also sehr schlecht für höherdimensionale Daten oder wenn man Basis functions benutzen möchte.

==== Dual Form
$L_d(a)=sum_(n=1)^N a_n - 1/2 sum_(n=1)^N sum_(m=1)^N a_n a_m t_n t_m (x^sans(T) x_n)$

mit conditions:
$ a_n &>= 0 quad forall n in underline(N) \
  sum_(n=1)^N a_n t_n &= 0 $

*Zeit Komplexität*: $O(N^3)$, also nichtmehr abhängig von $D$.

Zudem sind die meisten Datenpunkte $a_n = 0$, was also sparse matrix Zeugs ermöglicht (wer HPC kann, weiß, dass das gut zu haben ist).
Ist natürlich immer noch anstrengend für große Datenmengen.

Was ist aber wenn die Daten nicht linear trennbar sind?

Dann lassen sich mit _Soft-Margin SVMs_ die "falschen" Punkte bestrafen, indem Slack Variablen $epsilon_n = |t_n - y(x_n)|$ für alle Trainingspunkte eingefügt werden.
$epsilon_n = 0$ bei Korrektheit und erfährt bis $1$ eine penalty.

Alle Slacks werden dann summiert und mit einem $C$, dem tradeoff Hyperparameter, gewichtet ($1/2 ||w||^2 + C sum_(n=1)^N epsilon_n$).

== Error Funktion Analyse
// TODO: Do
== Neural Nets

//TODO: Überarbeiten

Ein _perceptron_ bekommt eine Menge $D in NN$ Inputs, gewichtet die dann und summiert sie.
Das Ergebnis ist dann $y(x) = sigma(b + sum_(i=1)^D w_i x_i)$, $b$ ist der Bias, $sigma$ ist die _activation function_ (auch hier werden die Gewichte meistens in eine einheitliche Matrix gepackt, weswegen die Formel sich ändern kann). Perceptrons sind also nur generalisierte Lineare Discriminants.

Nun fügen wir mehrere Layers von Perceptrons zusammen und bilden daraus ein _Multi-Layer Perceptron_. Jeder Layer fügt einen _bias_ (z.B 1) hinzu, der dann mit Weights zu jedem Perceptron der Layer verbunden ist.

Die Weights und Biases werden dann durch Backpropagation und Stochastic Gradient Descent trainiert. Auch hier ist die _learning rate_ ein Wichtiger Hyperparameter.

= Data Science

In Data Science sprechen wir über _features_

#figure(
  table(
    columns: (1fr, 1fr, 1fr, 1fr),
    [Name], [Farbe], [Kosten], [Bestseller],
    [Porsche GT], [Red], [5€], [Yes],
    [Fiat 500e], [Blue], [$inf$], [No],
  ),
  caption: [Beispiel Labeled Data]
)<FeatureTable>


In Tabelle #ref(<FeatureTable>) gibt es die Features Name, Farbe, Kosten, Bestseller. Bestseller könnte hier ein _target-feature_ sein, was wir vorhersehen möchten.
Die Reihen sind die _instances_.

Die Datentypen sind ähnlich wie die der Deskriptiven Statistik. Zwei Sachen nur: Nominal sind wie Enums (ungeordnet). Ordinal sind z.B. Sternbewertungen.

/ Visualisierung: Histogramme, Scatter Plots, Box Plots.
/ Correlation: $"Corr"(x,y)="Cov"(x,y)/( sqrt("Var"(X)) dot sqrt("Var"(y))) $
/ Binning: Aufteilen von _continuous features_ zu _categorical features_.\
    Hier gibt es zwei Versionen:
    - Equal Width Binning: z.B. $5$. dann startet der erste Bin bei dem niedrigsten z.B. $[2,7), [7,12),...$
    - Equal Frequency Binning: z.B. $3$ pro Bin. Ist logisch.

== Decision Trees

Ein Decision Tree trennt die Gesamtheit in mehreren Schritten auf und versucht so zu "klassifizieren" bzw. vorherzusagen. Das Target Label steht in den _leaf nodes_. Im generellen versucht man die target labels in den Leaf Nodes zu trennen (z.B. zwischen "Yes" Bestseller oder "No" Bestseller), aber dabei sollte der Baum so klein und unkompliziert wie möglich sein.

Hierfür brauchen wir ein paar Metriken (die sollte man wirklich können):
/ Entropy: $H(t) = - sum_(k=1)^K (p(t=k) dot log_2 p(t=k))$. Man sollte hier auf die features und Wahrscheinlichkeiten aufpassen. Beispiel: 2 Blaue, 3 Rote Kugeln $H("Farbe") = -(2/5 log_2 2/5 + 3/5 log_2 3/5) approx 0.97$. \
  Die Minimale Entropie wäre 5 Rote Kugeln $H("Farbe")=0$ und Maximale ist immer die gleichverteilung von allen Möglichen $H("Farbe") = log_2(K)$ wo $K in NN$ die Anzahl der Kugeln ist.
/ Overall Entropy: In einem Decision Tree berechnet die Overall Entropy indem die Anzahl der Sachen im _leaf nodes_.
  Gegebenenfalls betrachten wir nur splits von dem Feature $d$. \
  $H_W = sum_("node" in "leaf_nodes"(d)) ((|"node"|)/N dot H^("node")(t))$
/ Entropy-Information Gain: Ist einfach nur der Unterschied vom Start bis zu einem _leaf node_. \
  $"IG"(d) = H(t) - H^d_W(t)$
/ Entropy-Information Gain Ratio: Hier nehmen wir \
  $"GR(d)" = ("IG"(d)/H(d))$
/ Gini Index: $"Gini"(t) = 1 - sum_(k=1)^K p(t=k)^2$

Warum es die Entropy und den Information Gain gibt sollte klar sein, aber warum brauchen wir den $"GR"$ und $"Gini"$?
- Information Gain Ratio bestraft feature splits die zu große Bäume erschaffen. Selbst wenn die Entropy dadurch sehr gut wird, ist eine Aufteilung von jedem $n in N$ in ein einzelnen _node_ unbrauchbar. Der Information Gain Ratio würde das erkennen.
- Gini berechnet die Verunreinigung. Ist für uns nur bedingt wichtig.

Ein Decision Tree kann (und sollte) bereinigt werden (_pruning_). Dies passiert durch:
/ Pre-pruning: Vorzeitiges Stoppen bei einem Threshold
/ Post-pruning: Wenn in den Child-nodes summiert mehr misclassifications gemacht werden, als zusammen im Parent, lohnen sie sich nicht.

Continuous Werte können mit $< 500$, $>= 500$ in ein Decision Tree eingebaut werden.

==== ID3 Algorithmus

Sehr simple. Versuche den Tree möglichst klein zu halten, also nehme immer ein Leaf Node wenn du nur noch gleiche target labels, keine weiteren features oder einen pre-pruning threshold überschritten hast.
Sonst splitte immer nach dem feature mit dem *höchsten* information gain (nicht doppelt splitten mit dem gleichen feature).

== Clustering

Clustering fällt in die Kategorie des unsupervised learning.

Für clustering müssen wir irgendwie messen, wie weit wir entfernt sind (hier in 2 Dimensionen):
/ Euclidean Distance: $d(x,y) = sqrt((x_1 - y_1)^2 + (x_2 - y_2)^2)$
/ Manhattan: $d(x,y) = |x_1-y_1| + |x_2 - y_2|$
/ Chebychev: $d(x,y) = limits(max)_i (|x_i - y_i|)$
/ Minkowski ($L^p$): $d(x,y) = root(p, limits(sum)_i |x_i - y_i|^p)$

=== k-means

Erzeuge $k in NN$ _centroid_ (zufällig). Weise dann jedem Datenpunkt den nächsten _centroid_ zu. Nehme den Mean (Durchschnitt) aus allen zu einem _centroid_ gehörigen Datenpunkte und setzte den _centroid_ dahin. Weise erneut jedem ...

Es ist garantiert, dass dies irgendwann konvergiert, allerdings hängt das Ergebnis von den Startpositionen der Centroids ab. Ein Problem ist, dass nur "kreisförmige" Cluster gefunden werden können, insbesondere keine komplizierten verschachtelten Formen.

Eine häufige Error Funktion ist Sum-of-Squares: $E(x,C) = sum_(i=1)^k sum_(x_j in C_i) d(x_j, c_i)^2$.

=== k-medoids

Anstatt eigene _centroids_ zu erzeugen nutze manche Datenpunkte (_medoids_).

Weise jedem Datenpunkt einen _medoid_ zu. Falls ein Punkt $x_i$ den Error verringert, tausche ihn mit einem _medoid_.

Die Intuition ist richtig und k-medoids ist komplexer (zeitlich) zu berechnen, aber es ist weniger sensitiv zu outliers, da nicht ein einzelner Punkt den _centroid_ außerhalb vom wirklichen Cluster ziehen kann. In beiden Fällen ist $k$ natürlich ein Hyperparameter.

== Aglomeratives/Dendrogram


Hier wird die Bottom-Up Technik verwendet um zu clustern.

#figure(
  image("img/male/dendrogram.png", height: 5cm),
  caption: [Beispiel eines Dendrogramms]
) <dendrogram>

1. Erstelle cluster $Cl_i$ für jedes $x_i$
2. Berechne zu allen $d(Cl_i, Cl_j)$
3. Merge $min d(Cl_i, Cl_j)$.
4. Schritt 2 bis es nur noch einen Cluster gibt.


Bild #ref(<dendrogram>) zeigt die Visualisierung anhand eines Dendrogramm. Ich denke keine Erklärung notwendig.

== DB-Scan

Keine sorge wir sind nicht wieder bei DBIS gelandet.

Zwei Punkte $x_i, x_j$ sind density-connected falls es ein $x_k$ gibt, das mit beiden Verbunden ist. Hieraus werden dann _core-points_ gebildet die mit _MinPts_ Punkten in $epsilon$ Nähe sind.

Core points werden dann zu clustern oder clusters werden um core-points erweitert.

Am Ende lassen sich beliebige Formen clustern, anders als k-means (wird aber häufig wegen Einfachheit genutzt).

== Frequent Itemsets
#let support = math.op("support")
#let supportCount = math.op("support_count")

Notation:
- $I={I_1, ..., I_D}$ sind alle möglichen Items
- $A subset.eq I$ ist dann ein _itemset_ (_transaction_ bei nichtleerem $A$).
- Ein Dataset $X$ ist ein _multiset_ von Transaktionen (mehrere gleiche sind möglich).

Wichtige Metriken sind $support(A) = ("support_count"(A))/(|X|) = (|[T in X | A subset.eq T]|)/(|X|)$

Hierzu ein Beispiel aus der Vorlesung:

$ X &= [{A,B,E}, {C,B}, {A,D}, {A,D,B}] \
  T &= {A,B} subset.eq I $

$supportCount(A)= |[T_1,T_2]| = 2$
$support(A) = 2/4 = 1/2$


Wir sagen nun, $A$ ist ein frequent itemset, falls $support(A) >= "min_sup"$.
Weil es natürlich viel zu viele Kombinationen gibt, betrachten wir nur die Itemsets, für die es keine gleichen Supersets gibt. Also $A$ ist _closed_, falls $support(A) > support(B)$ für alle $B supset A$.

Zwei Algorithmen

== Apriori

1. Candidate Generation. Nutze $L_k$ (Frequent Itemsets der Länge $k$) um die Kandidaten $C_(k+1)$ zu generieren.
2. Pruning Supersets von _infrequent_ Itemsets können nicht _frequent_ sein.
3. Testen.

Was macht ihr aber in der Klausur? Ein Beispiel mit $"min_support" = 2$.

#grid(
  columns: 3,
  gutter: 2em,
  table(
    columns: 2,
    [TID], [Fruits],
    [1], [{Grapes, Apple, Pineapple}],
    [2], [{Orange, Apple, Banana}],
    [3], [{Grapes, Orange, Apple, Banana}],
    [4], [{Orange, Banana}],
    [5], [{Grapes, Apple, Banana}]
  ),
  table(
    columns: 2,
    [Itemsets], [Counts],
    [{Grapes}], [3],
    [{Orange}], [2],
    [{Apple}], [4],
    [{Pineapple}], [1],
    [{Banana}], [4]
  ),
  table(
    columns: 2,
    [Itemsets], [Counts],
    [{Grapes}], [3],
    [{Orange}], [2],
    [{Apple}], [4],
    [{Banana}], [4]
  ),
  table(
    columns: 1,
    [Itemsets],
    [{Grapes, Orange}],
    [{Grapes, Apple}],
    [{Grapes, Banana}],
    [{Orange, Apple}],
    [{Orange, Banana}],
    [{Apple, Banana}],
  ),
  table(
    columns: 2,
    [Itemsets], [Counts],
    [{Grapes, Orange}], [1],
    [{Grapes, Apple}], [3],
    [{Grapes, Banana}], [2],
    [{Orange, Apple}], [2],
    [{Orange, Banana}], [3],
    [{Apple, Banana}], [3]
  ),
  table(
    columns: 2,
    [Itemsets], [Counts],
    [{Grapes, Apple}], [3],
    [{Grapes, Banana}], [2],
    [{Orange, Apple}], [2],
    [{Orange, Banana}], [3],
    [{Apple, Banana}], [3]
  ),
)

Dies ist jeweils eine Iteration. Erst selection, dann pruning dann testing.

== FP-Growth

1. Gehe alle Items $I_1, ..., I_D$ durch und sortiere nach Häufigkeit.
2. Lösche alle _non-frequent_ items.
3. Gehe durch alle Transaktionen und sortiere die Items nach der obigen Häufigkeit.
4. Baue daraus einen FP-Tree.
  1. Starte bei der Gesamtzahl als Wurzel
  2. Gehe die Transaktionen durch und füge sie an den Baum. Notiere die Häufigkeit der Items.
  3. Mine den FP-Tree um die Frequent Items zu bekommen. Hier gibt es Taktik, aber ich würde es raten in der Klausur einfach zu "machen".

Der FP-Tree kann groß werden, aber falls er ins memory passt, sind nur zwei Durchläufen des Datensatzes nötig.

=== Association-Rules
/ Association Rule: $A => B "mit" A subset.eq I, B subset.eq I, A sect B = emptyset$.

$ support(A => B) &= (supportCount(A union B))/(supportCount(emptyset)) \
  "conf"(A => B) &= (supportCount(A union B))/(supportCount(A)) $

$"conf"$ ist die Confidence.

Da es noch mehr dieser Rules als frequent Itemsets gibt, können wir auch hier wieder pruning und redundant rules löschen.

> A trend appears in several different groups of
data but disappears or reverses when these
groups are combined

Das ist Simpons-Paradox.

== Sequence Mining

Hierbei gibt es _temporal data_, heißt jede Aktion hat einen Timestamp, eine Case-ID und eine Aktion (z.B. Nutzer 1 registriert sich $t_1$, Nutzer 2 meldet sich an $t_2$, etc...).

Hieraus entstehen cases, $"case" 1= <"Nuzter registriert", ...>$.

Wir brauchen erneut eine Relation, das _containment_ $A subset.sq.eq B$. Wir gucken einfach ob wir die Events von $A$ in $B$ in der *gleichen Reihenfolge*, aber gegebenenfalls mit Lücken, in $B$ finden.

Der Support ist dann wieder gleich definiert: $support(P) = (|[S in X | P subset.sq.eq S]|)/(|X|)$.

=== Apriori-All Algorithmus

Wir brauchen alle _litemsets_ (doofes wort) also alle $cal(L) = {A in I | support(<A>) >= "min_sup"}$

Nun mappen wir _Sequences_ auf die drunterliegenden _litemsets_ um. Beispiel $cal(L) = {{a}, {b}, {c}, {a,b}}$ und die _sequence_ $<{a,c}, {a,b,c}>$ wird zu $<{{a},{c}},{{a},{b},{c},{a,b}>$

Nun erstellen wir wieder die Kandidaten und prunen das Ergebnis.

Dann müssen wir noch testen ob $"min_sup"$ eingehalten wurde.

Wirklich interessante Daten müssen dann mit constraints gefunden werden.

== Time-Series Forecasting

Die Analyse betrachte ich als nicht wirklich relevant und überspringe sie. Falls jemand anders hier eine kleine Zusammenfassung schreibt wäre das vielleicht gut. Nun aber zum _forecasting_

/ Moving Average: Regression der vorherigen aufsummierten Fehler.

== Process-Mining
In Process-Mining geht es erneut um ID-Activity-Timestamp Daten. Wir werden die Event-Daten in 4 Diagrammen modellieren:

=== Directly-Follows Graph (DFG)

Ein DFG ist wirklich trivial. Ein Beispiel in Abbildung #ref(<dfg>).

#figure(
  image("img/male/dfg.png", height: 8em),
  caption: [Beispiel eines DFG]
) <dfg>

Und ja wir verknüpfen bereits dagewesen Knoten miteinander.

=== Petri-Nets

#figure(
  image("img/male/petri-net.png", height: 8em),
  caption: [Beispiel eines Petri-Nets]
) <petri-net>

Ein Petri-Net besteht aus einem Start, einem Endknoten und mehreren Transitions und Places.
Wir fangen beim Start an und legen einen Token hin. Nun gilt dir simple Firing Regel:
Wenn ein Transition alle Inputs erfüllt hat (dort ein Token liegt), dann tut es auf alle Ausgaben ein Token (und löscht die Eingaben).

Soweit so simple.

=== Process-Trees

Im Endeffekt bauen wir Process-Trees aus 4 Komponenten zusammen, die sich jeweils in ein Petri-Net übertragen lassen und wodurch sich jedes Petri-Net in ein Process-Tree umwandeln lässt.

#figure(
  image("img/male/process-tree-definition.png", height: 15em),
  caption: [Definitionskomponenten des Process-Trees]
) <process-tree-definition>

$tau$ ist hier ein "silent skip". 

=== Inductive Mining

Wir wollen nun von einem DFG zu einem Process-Tree. Hierfür müssen wir die Komponenten erkennen. Wir betrachten immer zuerst den ganzen DFG und arbeiten uns dann ins Detail. Die 
Reihenfolge ist hierbei wichtig:
1. _exclusive or_ 
2. _sequence cut_
3. _parallel cut_
4. _redo-loop cut_

== Replay

#let fitness = math.op("fitness")

Wir müssen wie immer auch bei Petri-Nets die Performance messen. Hierfür haben wir den _fitness_ score:

$ fitness(sigma, N) = 1/2 (1 - m/c) + 1/2 (1- r/p) $

/ $sigma$: Der Trace der betrachtet wird (eine Sequence)
/ $N$: Das Netzwerk
/ $p$: Summe produzierte Tokens
/ $c$: Summe konsumierte Token
/ $m$: Missing Tokens immer wenn ein Token für eine Aktivierung fehlt (wir spielen ja ein Trace nach), erschaffen wir eins, aber merken uns die Summe.
/ $r$: Remaining Tokens. Wenn tokens am Enden übrig bleiben.

Dies können wir für einen gesamten Log ebenso machen. Wir merken uns immer die Summe.

Die Nachteile von solchen Token-based Approaches sind:
- Sie brauchen gelabelte Transitions
- Können misleading Resultate erzeugen.

== Sonstiges Data Science Zeugs

Preprocessing ist sehr häufig sehr wichtig. Vor allem bei Big-Data müssen die Datenmengen reduziert werden:
/ Feature Reduction: Autoencoders sind NNs die eine automatische effizientere encoding der Daten machen. Principal Component Analysis kombiniert die features zusammen. \
  Aber auch Feature Selection, also aussortieren unnötiger Features, gehört dazu.
/ Instance Reduction: Sampling (z.B. nehme $N$ zufällige instances)


= Evaluation and AutoML/DS
