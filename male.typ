
#import "conf.typ": conf, algoBox, defiBox, theoBox

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

Es ist häufig schwierig die genauen Themenschwerpunkte der Vorlesung und Prüfung zu erkennen. Hier allerdings besonders, da es die erste Iteration des neuen Fachs ist und keine Altklausuren zu Rate stehen.
Wir werden deshalb einige Zeit (und Feedback von späteren Semestern) brauchen um besser Zusammenfassen zu können.

Da das neue Fach auf Englisch gehalten wird, ist es eine gute Zeit dies auch in den Panikzettel umzusetzen und eine zusätzliche Englische Version zu erstellen. Dies hier ist die *deutsche* Version, jedoch verwenden wir die englischen Fachwörter um keine Übersetzungsfehler bei uns und euch zu riskieren.

=== Stochastische Vorwissen

Ein großer Teil der Machine Learning und Data Science Konzepte und Algorithmen beruhen auf Stochastik. Wir werden hier _nicht_ die Grundlagen der Stochastik wiederholen, auch wenn ein kleiner Teil der Vorlesung genau dies tat, sondern auf den eigenen Stochastik Panikzettel #footnote([#link("panikzettel.htwr-aachen.de")]) verweisen.

//TODO: Maybe doch ganz kurz Grundbegriffe erklären? Max 1/2 Seite.

=== Aufteilung
//TODO: Aufteilung überarbeiten

Die Vorlesung wurde von 3 verschieden Lehrstühlen und Professoren zusammen angeboten und aufgeteilt.
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

//WARNING: stimmt so nicht (von der Bennenung), aber ich möchte grob einen Überblick geben der alle (Classification, Regression, Clustering, etc.) gemeinsam haben (außerhalb vom learning). 
Das Grundkonzept des gesamten Machine Learning Bereichs, der in dieser Vorlesung behandelt wird, kümmert sich um _Klassifizierung_, also der Aufteilung in Klassen (z.B. geben einem Foto, ist es eine Katze oder ein Hund). 

=== Lernformen & Lernziele
Machine Learning Algorithmen lernen mit Trainingsdaten. 
Diese können bereits (teilweise) klassifiziert sein (d.h._labeled_), woraus sich somit 3 Arten zu lernen ergeben:
- Supervised learning 
- Semi-supervised learning
- Unsupervised learning

Wir werden einige Lernziele besprechen, aber es ist gut sie vorher eingeführt zu haben.

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
      Versuchen eine Wahrscheinlichkeitsverteilung abzubilden von zufälligen samples.
      Anders als bei Regression ist hier die Datenfunktion nicht bekannt / es wurde nicht vorher gelabeled.
  ]
)

Das Ziel wird aber immer sein: 
Gegeben Trainigsdaten $cal(D) = {x_1,..., x_n}$ oder mit gegebenenfalls labeln $cal(D) = {(x_1, t_1),..., (x_n, t_1)}$
eine Funktion $y$ zu trainieren, die zu Daten, die nicht im Testset, vorkommen eine Vorhersage treffen kann. 

== Probability Density Estimation

Wie wahrscheinlich ist es, dass wir ein $x$ sehen unter der Bedingung, dass wir in der Klasse $cal(C)_k$ sind, also $p(x | cal(C)_k)$. 
Diese _likelihood_ ist genau das Gegenteil von dem was wir brauchen: $p(cal(C)_k | x)$.

Somit stellen wir es mit den _a-priori probabilities_ $p(cal(C)_k)$ und Bayes Theorem um: 
$ p(cal(C)_k | x) = (p(x | cal(C)_k)p(cal(C)_k))/(p(x)) = (p(x | cal(C)_k)p(cal(C)_k))/(sum_j p(x | cal(C)_j) p(cal(C)_j)) $

Dies ist die _posterior_ Wahrscheinlichkeit, die wir benötigen um x klassifizieren.

Nun verteilt sich $p(cal(C)_k | x)$ in einer bestimmen Wahrscheinlichkeitsverteilung, die wir aber nicht kennen, die es nun geht zu approximieren.

Gegeben ist eine Reihe von Klassen $Cl_1,... Cl_d$, $d in NN$ (oder $Cl_a, Cl_b$), deren _a-priori_ Wahrscheinlichkeiten und einem Trainingsdatensatz $x_1,...,x_N$, $N in NN$ mit Labeln.

== Parametrische Methoden mittels Gaussian (Normal) Verteilung

Wir nehmen nun an, dass die $p(Cl_k | x)$ nach einer Normal Verteilung $theta_N=(mu, sigma)$ (genauer irgendeiner Verteilung mit Parametern $theta$) verteilt ist. Um hier die Parameter zu bestimmen benötigen wir erneut die Hilfe von der log-likehood und der Maximum Likelihood. Wir werden hier das nochmal durchgehen:

Hierfür benötigen wir die Wahrscheinlichkeit $L(theta) = p(cal(X) | theta)$, dass $cal(X)$ von den Parametern $theta$ generiert wurde. Wir wollen $L(theta)$ maximieren. Für einen einzelnen Datenpunk $x_n$ gilt $p(x_n | theta) = 1/(sqrt(2 pi) sigma) exp(-((x_n - mu)^2)/(2 sigma^2))$.

Da alle Variablen i.i.d. (d.h. unabhängig und identisch verteilt) sind können wir die Wahrscheinlichkeiten summieren: $L(theta)=sum_(n=1)^N p(x_n | theta)$ und das _negative log-likelihood_ bilden $E(theta)= - ln L(theta) = - sum_1^n ln p(x_n | theta)$ (#emoji.warning $ln a*b = ln a + ln b$).

Um nun das Maximum zu berechnen ist nun die Ableitung von $E(theta)$ erforderlich: 
$ diff/(diff theta) E(theta) &= - limits(sum_(n=1)^N (1/p(x_n | theta)) dot diff/(diff theta) p(x_n | theta)) \
&= ... = 1/sigma^2 sum_(n=1)^N x_n - N mu =^! 0 \
&<==> accent(mu, hat) = 1/N sum_(n=1)^N x_n and accent(sigma, hat)^2 = 1/N sum_(n=1)^N (x_n - accent(mu, hat)^)^2 $ .

%TODO: Eher nicht mit rein nehmen oder?
Bei Maximum Log-Likelihood Optimierungen wird die Varianz unterschätzt, und muss im Fall der Normalverteilung mit $N/(N-1)$ ausgeglichen werden.

== Histogramme

Aufteilung der Daten in $N$ Säulen mit breite $Delta_i$. Die Höhe der Säule ist dann $p_i = n_i/(N Delta_i)$, wobei $n_i$ die Anzahl der Beobachteten Ergebnisse in dem Bereich ist.

== Kernel Methods


= Data Science

= Evaluation and AutoML/DS
