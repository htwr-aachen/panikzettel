#import "conf.typ": algoBox, conf, defiBox, posneg, sidenote, theoBox

#show: conf.with(
  title: "IT-Sicherheit",
  shortTitle: "ITSec",
  authors: (
    (name: "Tore Kunze"),
    (name: "Adrian Groh"),
    (name: "Jonas Schneider"),
  ),
  lang: "de",
  filename: "itsec",
  showOutline: true,
)

= Einleitung

=== Vorwort

#sidenote(
  title: "Warnung",
  [
    Dieser Panikzettel ist noch nicht fertig. Die Zeit (und Motivation) fehlt für uns. Ich verspreche für den 2. Termin ist er fertig.
  ],
)

Dieser Panikzettel ist über die neue Vorlesung "IT-Sicherheit", ein Pflichtfach des neuen Informatik Bachelors der RWTH Aachen.

Dieser Panikzettel ist Open Source auf #link("https://git.rwth-aachen.de/jonas.max.schneider/panikzettel", `https://git.rwth-aachen.de/jonas.max.schneider/panikzettel`). Wir freuen uns über Anmerkungen und Verbessungsvorschläge (auch von offiziellen Quellen).

== Ziele von IT-Sicherheit
IT-Sicherheit beinhaltet Vorbeugung, Erkennung und Verhinderung von Angriffen gegen eines der *CIA*-Ziele.

=== CIA
/ Confidentiality: Nur autorisierte Personen haben *Zugriff* auf ein System
/ Integrity: Nur autorisierte Personen können *Ressourcen* in einem System verändern
/ Availability: Autorisierte Personen können *wie vorgesehen* auf Ressourcen in einem System *zugreifen*

Hierauf folgend kommen einige Beispiele für Angriffe auf eines (oder mehrere) der _CIA_-Ziele.

== Angriffe gegen _Confidentiality_
=== _Eavesdropping_
Beim Transfer vom Daten werden diese abgehört/abgefangen.

=== _Traffic Analysis_
Zeiten und Adressinformationen werden genutzt, um herauszufinden, wer mit wem kommuniziert.

== Angriffe gegen _Integrity_
=== _Modification_
Daten werden beim Transfer abfangen und modifiziert.

=== _Masquerading_
Die Source-Adressinformationen eines Datenpakets werden beim Transfer geändert.

=== _Replay_
Ein Datenpaket wird abgefangen und später (erneut) geschickt.

=== _Repudiation_
Eine Aktion wird geleugnet, z.B. ein spezifisches Datenpaket gesendet zu haben.

== Angriffe gegen _Availability_
=== _Denial of service_
- Ein Webserver wird mit *Fake-Anfragen* geflooded
- Das Signal einer Verbindung wird mit einem *Störsignal* gejammed
- Das *Passwort* eines Nutzers wird *falsch eingegeben*, um den *Account* zu *blockieren*

=== Sonstiges

Es gibt grob zwei Prinzipien beim Design eines Kryptosystems (sei es ein Verschlüsselungsverfahren, ein Protokoll oder eine Anwendung).

/ Kreckhoffs Principle: Ein Kryptosystem sollte sicher sein, selbst wenn alles über das System *außer der/die Schlüssel* bekannt ist.
/ Security by obscurity: Das Gegenstück dazu. Sicherheit durch Geheimhaltung des Designs eines Kryptosystems. (Generell eine schlechtere Methodik, auch wenn sie natürlich kombiniert werden können.)

= _Symmetric Encryption_
Bei _symmetric encryption_ sind die *_encryption_* und *_decryption keys_* *identisch*.

== _Caesar Cipher_
Ersetzt jeden verwendeten Buchstaben, durch den, der $k$ Stellen im Alphabet danach kommt ($k$ ist entsprechend der Schlüssel).

==== Sicherheit des _Caesar Cipher_
Der _Caesar Cipher_ hat nur 25 verschiedene _Keys_ ${1, ..., 25}$ und lässt sich somit *leicht mit _Bruteforce_* knacken. $->$ *schlechte Verschlüsselungsmethode*

=== Bruteforce
Alle möglichen _keys_ werden durchprobiert.

== _Monoalphabetic Substitution Cipher_
Jeder *Buchstabe* wird durch einen anderen ersetzt gemäß einer *Ersetzungstabelle*.
\ Der _Caesar Cipher_ ist insbesondere ein *Spezialfall* vom *_Monoalphabetic Substitution Cipher_*.

Der key space entspricht nun allen Permutationen der Buchstaben.
\ $->$ *_Bruteforce_* ist *nicht mehr* gut möglich

Durch *_Frequency Analysis_* kann der _Cipher_ leicht geknackt werden.

== _Frequency Analysis_
Für jede Sprache gibt es *relative Häufigkeiten* der Buchstaben, was bei _Ciphern_, die die *Frequenzen* der Buchstaben *erhalten* insbesondere dazu führt, dass diese leicht entziffert werden können.

*_Monoalphabetic Substitution Ciphers_* erhalten insbesondere die Frequenzen und können daher mit _Frequency Analysis_ geknackt werden.

== _Perfect Secrecy_ (Shannon)
*Idee*: Ein _ciphertext_ soll *keine neue Information* über den _plaintext_ preisgeben.

#defiBox(title: "Perfect Secrecy", [
  Ein _encryption scheme_ hat *_perfect secrecy_*, wenn für eine gegebene *Wahrscheinlichkeitsverteilung* Pr *auf dem _plaintext space_* $cal(P)$ mit $"Pr"(P) > 0$ für alle _plaintexts_ $P$ gilt:

  Für jedes $P in cal(P), C in cal(C), K in cal(K)$ *zufällig gleichverteilt* ausgewählt, gilt $"Pr"(P | C) = "Pr"(P)$
])

Um dies zu erreichen muss der *_key space_ mindestens so groß* sein wie der *_ciphertext space_*, dieser wiederum muss *mindestens so groß* sein, wie der *_plaintext space_*:

$|cal(K)| >= |cal(C)| >= |cal(P)|$

=== Shannon's Theorem
#theoBox(title: "Shannon", [
  Sei $|cal(P)| = |cal(K)|$ und $"Pr"(P) > 0$ für alle _plaintexts_.

  Dann hat ein *_encryption scheme_* genau dann *_perfect secrecy_*, wenn gilt:
  + Der _key_ $K$ wird *zufällig gleich verteilt* ausgewählt für jeden _plaintext_ und
  + für jedes $P in cal(P)$ und $C in cal(C)$ gibt es *genau ein $K in cal(K)$* mit $E_K (P) = C$ (_plaintext_ $P$ wird veschlüsselt zu _ciphertext_ $C$)
])

== _One-Time-Pad_ (OTP)
Wähle $cal(P) = cal(C) = cal(K) = {0,1}^n$ für ein $n in NN$.

_Key_ Generierung:
Wähle *zufällig gleichverteilt* ein $K in cal(K)$ für jedes $P in cal(P)$, welches verschlüsselt werden soll

Verschlüsselung: $C = P plus.o K$

Entschlüsselung: $C plus.o K = P plus.o K plus.o K = P$

#theoBox(title: "OTP", [
  Der _One-Time-Pad_ hat _perfect secrecy_.
])

#posneg(
  [
    - *Einfach zu berechnen*
      - Verschlüsselung und Entschlüsselung sind *dieselbe Operation*
      - XOR ist eine *günstige* Rechenoperation
    - *So sicher wie theorethisch möglich*
      - Wenn ein _ciphertext_ gegeben ist, sind alle *_plaintexts_ gleich wahrscheinlich*.
      - Sicherheit *unabhängig* von den *Ressourcen* des Angreifers
  ],
  [
    - *_Key_ muss so lang sein wie _plaintext_*
      - *Unpraktisch* für die meisten Szenarien
      - Trotzdem für diplomatischen und Geheimdienstverkehr benutzt
    - *Garantiert nicht _integrity_*
      - Garantiert nur *_confidentiality_*
      - Angreifer kann leicht den Text *verändern*, ohne dass dies erkannt wird
    - Offensichtlich *nicht* für alle Anwendungen *geeignet*
  ],
)

Moderne _encryption schemes_ haben keine _perfect secrecy_, sind aber _computationally secure_.

#defiBox(title: "Computational Security", [
  Ein _encryption scheme_ heißt *computationally secure*, wenn
  - Alle bekannten Attacken gegen den _cipher_ zu hohen Rechenaufwand haben, um ihn in absehbarer Zeit zu brechen
])

== Attacken gegen Symmetric Encryption

Durch _Eavesdropping_ hat ein Angreifer Zugriff auf den _ciphertext_.

=== Exhaustive Key Search / Brute-Force
Gehe alle möglichen _keys_ ans dem _key space_ durch.

Durchschnittlich muss er dafür $(|K|)/2$ _keys_ ausprobieren.

=== Algebraic attacks
Wenn der Angreifer den _plaintext_ kennt, kann er evtl. ein lineares Gleichungssystem mit den _key bits_ als Unbekannte aufstellen und lösen.

== Stream Ciphers
Bei _OTP_ muss $K$ immer genau die Länge von $P$ haben.

Bei _Stream Ciphers_ ersetzt man $K$ durch einen _pseudo-random bit-generator (PRBG)_, welcher von einem _truly random key_ $K$ geseeded wird, und dann zusammen mit einem _initialization vector (IV)_ für jedes $K$ einen pseudo-random _key_ der passenden Länge generiert.

=== Schwachstellen
Wenn _IV_ für mehrere Verschlüsselungen verwendet wird, kann eine _known-plaintext attack_ durchgeführt werden (*KRACK attack*).

== Block Ciphers
Operieren auf _plaintext_ Blöcken einer bestimmten Größe (_block length $b in NN$)_.

_Plaintext space_ $cal(P) = {0,1}^b$ und _ciphertext space_ $cal(C) = {0,1}^b$

Brauchen typischerweise einen _mode of encryption_, der spezifiziert, wie ein _plaintext_ mit einer Länge über $b$ verschlüsselt wird.

== AES
Der Input läuft dann durch mehrere Runden. In jeder Runde gibt es die Operationen _Substitute Byte (SB)_, _Round Key Addition (KA)_, _Shift Row (SR)_ und _Mix Column (MC)_.

Ich denke nicht, dass man die genaue Funktionsweise für die Klausur auswendig können muss.

== Modes of Encryption

=== Electronic Codebook Mode (ECB)

Teilt einfach den Input in Blöcke der richtigen Länge und fügt falls Nötig am Ende noch ein Padding hinzu.

Problem: Die selben _plaintext_ Blöcke ergeben denselben _ciphertext_, wodurch sich Muster aus dem _plaintext_ im _ciphertext_ wiederfinden lassen. $=>$ sollte nicht benutzt werden

=== Cipher Block Chaining Mode (CBC)
Ähnlich wie ECB, nur dass jeder Block vor der verschlüsselung noch mit dem _ciphertext_ des vorigen Blocks $plus.o$ gerechnet wird (und der erste Block mit einem öffentlichen IV).

Man sollte für jeden _plaintext_ einen neuen IV verwenden, da ein Angreifer ansonsten erkennen kann, ob mehrfach derselbe _plaintext_ verschlüsselt wurde.

Ist anfällig gegen _padding-oracle attacks_. $=>$ sollte auch nicht mehr benutzt werden

=== Counter Mode (CTR)

Bei CTR wird auf den $E_K$ vom ersten Block $"IV" + 1$ auf den zweiten Block $"IV" + 2$ usw. angewendet und dann unabhängig von einander jeder Block mit dem jeweiligen $E_K$ $plus.o$ gerechnet.

Dadurch ist kein Padding notwendig, und Ver- und Entschlüsselung kann parallelisiert werden.

CTR macht also aus einem _block cipher_ einen _stream cipher_.

Die abgewandelte Variante des Galois Counter Mode (GCM) wird in #ref(<gcm>) behandelt.

= Symmetric Integrity Protection

_Modification Detection Code_ (MDC) werden über einen *secure* channel gesendet (die Nachricht nicht). Dann wird die MDC-Funktion auf die Nachricht angewand und geguckt ob MDC gleich ist.

_Message Authentication Code_ (MAC) werden mit der Nachricht über den unsicheren Channel gesendet.
Um eine MAC zu erstellen (und zu überprüfen) benötigt man den Key.

== Hash functions

#defiBox(
  title: "Hash Funktion",
  [
    Eine Hash Funktion $h$ muss folgende Eigenschaften aufweisen:
    1. _compression_: $h$ mapped eine Eingabe unbestimmter Länge auf eine *fixe* Länge.
    2. _ease of computation_: Die hash funktion muss effizient berechenbar sein.
  ],
)

Aus der ersten Eigenschaft ergibt sich natürlich, dass es (unendlich viele) Kollisionen geben muss.

#defiBox(
  title: "Cryptographic Hash function",
  [
    / preimage resistance: Gegeben einem $y=h(x)$, aber nicht $x$. Es ist nicht möglich $x'$ zu finden mit $h(x') = y$. Es kann auch $x=x'$ gelten.
    / second preimage resistance: Gegeben einem $x, h(x)$. Es ist nicht möglich ein $x' != x$ zu finden mit $h(x')=h(x)$.
    / collision resistance: Es ist nicht möglich ein $x,x'$ zu finden mit $h(x')=h(x)$.

    #footnote(
      [Alle "nicht möglich" sind natürlich nur _computationally infeasible_],
    )
  ],
)

#theoBox(
  title: "Geltende Implikationen",
  [
    _collision resistant_ $==>$ _second preimage resistant_.

    Alle anderen Implikationen gelten nicht.
  ],
)

Eine _cryptographic hash function_ ist nun eine die alle 3 Eigenschaften erfüllt.

== HMAC

MAC auf Grundlage einer _cryptographic hashs_

$
  "HMAC"_K (M) = h(K xor "opad" || h(K xor "ipad" || M)) quad quad #footnote([$xor$ kommt immer zuerst])
$

_ipad_ und _opad_ sind festgelegt und unterscheiden sich

== CMAC

MAC mittels Symmetrischer Block Verschlüsselung.

$M = M_1 || M_2 || ... || M_n$

1. Fall $||M_n|| = b$ $M_n$ passt genau in einen Block.

  $"CMAC"(M) = K_bold(1) xor M_n xor E_k (M_(n-1) xor E_k (... xor E_k (M_1)))$

2. Fall padde $M_n^'=M_n 1 underbrace(0...0, b - ||M_n|| - 1)$

  $"CMAC"(M) = K_bold(2) xor M_n^' xor E_k (M_(n-1) xor E_k (... xor E_k (M_1)))$

$K_1, K_2$ generieren wir uns aus $K$, aber benötigen unterscheidliche, da sonst $"CMAC"(M) = "CMAC" (M')$ wäre
wenn $M' = M 1 0...0$

=== Replay Protection in MAC & Verschlüsselungsreihenfolge

Um gegen einfach kopieren der Datei mit MAC zu verhindern müssen wir Sachen (wie z.B. timestamp, RNG, SQN) einbauen.
Bei RNG muss Bob zuerst die Zufallszahl senden, die dann mit der $"MAC"_K (M || "RAND")$ mitgeschickt wird.

Man sollte immer erst Verschlüsseln und dann den MAC berechnen, da dann MAC keine sicherheitsrelevanten Informationen enthällt
und man MAC erst überprüfen kann, bevor dem aufwändigeren Entschlüsseln.

== GCM <gcm>

Der GCM Encryption Mode kann beides gleichzeitig.

Wir haben dabei $A_1 || ... || A_m || P_1 || ... || P_n$ $m<n$. Wir wollen $A_i$ integrity protecten und $P_i$ verschlüsseln und integrity protecten.

#figure(
  image("img/itsec/gcm.png", height: 12em),
  caption: [Operationsdiagramm GCM #footnote([Hier wird nur $A_1$ dargestellt, aber bei mehreren $A_i$ werden die nacher äquivalent mit eingebunden])],
)

= Asymmetric Encryption & Signatures

Alles hier beruht darauf einen _public key_ $p_k$ zu haben den jeder kennt (man geht auch davon aus, dass jeden ihn kennt).
Und einen _private key_ $s_k$ den Niemand außer man selber kennt.

== RSA
