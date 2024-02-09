#import "conf.typ": conf, algoBox, defiBox, theoBox, posneg

#show: conf.with(
  title: "IT-Sicherheit",
  shortTitle: "ITSec",
  authors: (
    (name: "Tore Kunze"),
  ),
  lang: "de",
  filename: "itsec",
  showOutline: true,
)

= Einleitung

=== Vorwort

Dieser Panikzettel ist über die neue Vorlesung "IT-Sicherheit", ein Pflichtfach des neuen Informatik Bachelors der RWTH Aachen.

Dieser Panikzettel ist Open Source auf #link("https://git.rwth-aachen.de/jonas.max.schneider/panikzettel", `https://git.rwth-aachen.de/jonas.max.schneider/panikzettel`). Wir freuen uns über Anmerkungen und Verbessungsvorschläge (auch von offiziellen Quellen). 

== Ziele von IT-Sicherheit
IT-Sicherheit beinhaltet, Vorbeugung, Erkennung und Verhinderung gegen Angriffe gegen eines der *CIA*-Ziele.

=== CIA
/ Confidentiality: Nur autorisierte Personen haben *Zugriff* auf ein System
/ Integrity: Nur autorisierte Personen können *Ressourcen* in einem System verändern
/ Availability: Autorisierte Personen können *wie vorgesehen* auf Ressourcen in einem System *zugreifen*

Hierauf folgend kommen einige Beispiele für angriffe auf eines (oder mehreren) der _CIA_-Ziele.

== Angriffe gegen _Confidentiality_
=== _Eavesdropping_
Beim Transfer vom Daten werden diese abgehört/abgefangen.

=== _Traffic Analysis_
Zeiten und Adressinformationen werden genutzt um herauszufinden, wer mit wem kommuniziert.

== Angriffe gegen _Integrity_
=== _Modification_
Daten werden beim Transfer abfangen und modifiziert.

=== _Masquerading_
Die Source-Adressinformationen eines Datenpakets werden beim Transfer geändert.

=== _Replay_
Ein Datenpaket wird abgefangen und später geschickt.

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
/ Security by obscurity: Das Gegenstück dazu. Sicherheit durch Geheimhaltung des Designs eines Kryptosystems. (Im generellen eine Schlechtere Methodik, auch wenn sie natürlich kombiniert werden können).

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

#defiBox(title: "Perfect Secrecy",[
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
    - *_Key_ muss so lange sein wie _plaintext_*
      - *Unpraktisch* für die meisten Szenarien
      - Trotzdem für diplomatischen und Geheimdienstverkehr
    - *Garantiert nicht _integrity_*
      - Garantiert nur *_confidentiality_*
      - Angreifer kann leicht den Text *verändern*, ohne dass dies erkannt wird
    - Offensichtlich *nicht* für alle Anwendungen *geeignet*
  ]
)