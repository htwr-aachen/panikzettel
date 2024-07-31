#import "conf.typ": conf, posneg, algoBox, sidenote, defiBox, theoBox
#import "@preview/cetz:0.2.0": canvas, plot


#show: conf.with(
  title: "Mobile Internet Technology",
  shortTitle: "MIT",
  authors: (
    (name: "Adrian Groh"),
  ),
  lang: "de",
  filename: "mit",
  showOutline: true,
)

= Einleitung und Vorwissen

=== Vorwort

This "panic note" is open source at #link("https://git.rwth-aachen.de/jonas.max.schneider/panikzettel", `https://git.rwth-aachen.de/jonas.max.schneider/panikzettel`).

=== Vorwissen

- #link("https://panikzettel.htwr-aachen.de/datcom.pdf")[Datcom]
- #link("https://panikzettel.htwr-aachen.de/bus.pdf")[Bus]

= Physical Layer

Wireless communication has many advantages over wires, but come with many challenges.
- Restricted frequency bands
- Low transmission rates
- High loss rates
- Higher delays/jitter
- Lower security

In radio waves, data is represented physically by electromagnetic waves with an amplitude, frequency and phase.
$
s(t) = A dot sin(2 dot pi dot f dot t + phi) \
A: "Amplitude" \
f: "Frequency [Hz]" \
phi: "Phase"
$
The wavelength is $lambda = c/f$

Since many frequency bands are already reserved for historical reasons, it is hard to get bands for new technologies.

== Representation of Digital Data

=== Signals

Signals can be _discrete_ or _continuous_, see datkom lecture.

=== Modulation

To transmit data over a wave, it has to be _modulated_. This can mean either a change in amplitude, frequency, phase or time, or a combination of them.

==== Amplitude Shift Keying (ASK)
Transmits different amplitudes for `0` and `1`. \
Does not need much bandwidth but is susceptible against distortion.

==== Frequency Shift Keying (FSK)
Modulates the frequency of a wave. Needs higher bandwidth than ASK.

Improvement: Minimum Shift Keying (MSK), does not encode bits but bit transitions, where one of the frequencies is twice the other. Used in GSM in combination with a Gaussian Low-Pass filter (GMSK).

#image("img/mit/msk.png", width: 70%)

==== Phase Shift Keying (PSK)
Modulates the phase of a wave. Is more robust against distortion than ASK.

Improvement: Binary Phase Shift Keying (BPSK), `0` is sine wave, `1` is inverted sine wave. Very robust, but inefficient bandwidth use.

Improvement 2: Quaternary Phase Shift Keying (QPSK), encodes two bits per signal by using four different phases, therefore more efficient than BPSK but less robust.

==== Quadrature Amplitude Modulation (QAM)
Combines amplitude and phase modulation to code $m$ bits using only one signal. There are $2^m$ discrete levels. This is widely used in modern communication.

#image("img/mit/qam.png", width: 30%)

==== Digital Modulation
A periodic signal can be represented as a composition of harmonic signals (fourier transform). This means that an (infinite) amount of signals can be superimposed to create a (near) perfect digital signal. Though, the resulting analog signal requires infinite bandwidth (baseband signal).


#defiBox(title: [Bandwidth], [Width of frequency band needed to represent a signal])

In wireless communication, no baseband signals are allowed. \
To achieve this, _low-pass filters_ are used, to attenuate signal components above a given threshold, to fit baseband signals to a given channel bandwidth.

If analog modulation is necessary, a two-step approach can be used, where first, the signal is modulated digitally and cut off with a low-pass filter and the resulting baseband signal is then shifted to a given carrier frequency $f_c$.

==== Nyquist and Shannon
#let ld = math.op("ld")
#let SNR = math.op("SNR")
#let db = math.op("db")

===== Nyquist Theorem
Relationship between bandwidth and signal rate.

#defiBox(title: [Signal Rate], [Possible number of signal parameter changes per second \ $ S_"max" "[Hz, baud]" = 2 dot B "[Hz]" $ ])

#theoBox(title: [Nyquist Theorem], [$ R_"max" "[bit/s]" = 2 dot B "[Hz]" dot ld(n) "[bit]" $])


===== Shannon Theorem
Which data rate is possible for a given noise level.

#defiBox(title: [Signal-to-noise ratio], [Power of a signal $S$ relative to the power of noise $N$ \ $ SNR = S/N $ \ Usually given in _dezibel_ [dB]: $SNR_db = 10 dot log_10 (S/N)$])

#theoBox(title: [Shannon Theorem], [$ R_"max" "[bit/s]" = B "[Hz]" dot ld(1 + S/N) "[bit]" $ ])

Since in reality, both bandwidth and noise are constraints, the minimum of Nyquist and Shannon theorems gives the maximum achievable data rate.

TODO: example

== Signal generation
Nicht so wichtig glaub ich

== Signal propagation
Received power $P_r$ (in vacuum in a straight line):
$
P_r = P_t dot (lambda / 4 pi d)^2 dot G_r dot G_t \
P_r: "received signal power" \
P_t: "transmitted signal power" \
G_r: "gain of receiver antenna" \
G_t: "gain of transmitter antenna" \
lambda: "wave length of carrier frequency" \
d: "distance between transmitter and receiver"
$

In reality, the received power is proportional to $1/d^alpha$, where $alpha = 2$ in vacuum, $alpha in (2.7; 5)$ in a city and $alpha in (4; 6)$ indoors.

The received power is influenced by
- attenuation
- shadowing
- reflection
- refraction
- scattering
- diffraction

=== Multipath Propagation
Signals often take multiple paths of different length to the same destination, causing the same signal to be received multiple times with a short delay and different signal strengths causing interference.

In mobile communication, channel characteristics change over time, enhancing this effect.

// TODO: copy table from I-57 EDIT: doch nicht

== Multiplexing
A given frequency spectrum is subdivided into multiple sub-channels for simultaneous use.

=== Frequency Multiplex
The spectrum is separated into smaller frequency bands. This does not require any sort of dynamic coordination, but wastes bandwidth if the traffic is distributed unevenly.

Can also be used to allow duplex communication (one sub-band for sending, one for receiving).

=== Time Multiplex
Each sender gets the whole spectrum for a certain timeslot. This requires precise time synchronization between hosts. Guard times are used to avoid overlaps caused by delays because of speed of light.

Can also be used for Duplex communication (Time Division Duplex (TDD)), where downlink and uplink are separated with timeslots.

Can also be combined with Frequency Multiplex.

=== Code Division Multiplex (CDM)
All channels use the same spectrum at once.
Each sender has a unique code (chipping sequence) that the receiver can use to filter out a specific sender.
The used chipping sequences should be orthogonal to each other.

requires perfect synchronization

#image("img/mit/cdm.png", width: 80%)

=== Direct Sequence Spread Spectrum (DSSS)
XOR of the signal with chipping sequence, but the chipping sequence is a pseudo-random number.

Requires precise power control because of near-far problem.

=== Frequency Hopping Spread Spectrum (FHSS)
Carrier Frequency is changed in a sequence determined by a code.

#image("img/mit/fhss.png", width: 80%)

=== Orthogonal Frequency Division Multiplexing (OFDM)
A given bandwidth $b$ is subdivided into $n$ sub-bands on which several narrowband signals are transmitted simultaneously.

The sub-channels are orthogonal, which means that the maximum signal power of one sub-channel is on the same frequency as the minimum of the two neighbor sub-channels.

The sub-streams are merged/separated using Fourier transform, which can be implemented very efficiently with fast Fourier transform (FFT).

This leads to more efficient bandwidth usage than regular FDM.

=== Space Multiplexing
By limiting the transmit power, the range is restricted to only one pair of sender and receiver. Outside of that range, other transmissions on the same frequency are possible.

This is only really useful in combination with other multiplexing methods, as there are typically multiple transmitters within range of one another.

In GSM: cell sizes varying from 100m to 35km

== Coding
#let BER = math.op("BER")

In wireless communication, the Bit Error Rate (BER) is relatively high.

With the Packet Error Probability $P_p = 1 - (1 - BER)^n$, the probability that a packet with a length of $n$ bit contains an error.

This means that for packets of length $12.000 "bit"$ and a $BER$ of $10^(-3)$, almost all frames ($99.999%$) are damaged during transmission.

To deal with this, error correcting codes, like the hamming code, are used.

=== Block Codes
Data is processed in blocks.
Input blocks have size of $k$ bits.
Output FEC-protected blocks have length $n$.

E.g. $(255,247)$ code protects $247$ data bits with $8$ FEC-bits.

Disadvantage: Expensive calculations are necessary in certain time intervals (when a block is full).

=== Convolutional Codes
In addition to $n$ and $k$, a constraint factor $K$ is used that specifies the amount of previous blocks the code is also dependent on.

E.g. for an $(n,k,K)$ code: the $n$-bit long output does not only depend on the $k$ Bits of the current block but also on the previous $K-1$ blocks.

$=> n$ output bits are a function of the last $K dot k$ input bits.

An encoder for this can be represented as a shift register and state diagram or a trellis diagram.

#image("img/mit/shift_register_encoder.png", width: 70%)

==== Correction Capabilities
Hamming distance $d >= 2 dot t + 1$

For a given minimal Hamming distance of a code, it can correct $t$ errors.

TODO: Viterbi Algorithm

= Medium Access Control (MAC)
Very important in wireless networks, as e.g. idle listening wastes huge amount of energy.

Multiplexing is often too inflexible, bandwidth could be used more efficiently if traffic has many bursts.

== CSMA/CD
Carrier Sense Multiple Access / Collision Detection

#image("img/mit/csma_cd.png", width: 70%)

Does not really work in wireless networks because of
- hidden station problem: collisions are not guaranteed to be detected.
- exposed station problem: some situations are detected as collisions where there are none

// TODO: maybe add image from II-7f

In general, detecting collisions in wireless networks is hard, because sending and receiving on the same channel is not really possible (can't listen for interference while transmitting).

#image("img/mit/medium_access.png", width: 70%)

== Centralized MAC
A central station defines when a node may have access to the medium.

== Schedule-based MAC
A schedule (either fixed or computed on demand) regulates, which participant may use the medium at which time.

Requires time synchronization

=== Demand Assigned Multiple Access (DAMA)
Sender reserves future time slot, therefore no collisions in the actual transmission possible.

Typically used in satellite links.

In the "ALOHA phase", where time slots are reserved, collisions are still possible.

#image("img/mit/dama.png", width: 70%)

// TODO: maybe add IEEE 802.15.4 (II-31), if relevant in any exercises

== Contention-based protocols
Just hope that having collisions and dealing with them is more efficient than coordinating medium access.

Usually involves randomization.

When a node has a packet to send, it is just sent with the full channel data rate.

The protocol specifies how collisions that appear as soon as two or more nodes are transmitting simultaneously should be detected/avoided and how to recover in case of a collision.

Examples:
- CSMA/CD
- Aloha, Slotted Aloha

=== ALOHA
Just send the data, when no ACK is received before a timeout, data is retransmitted.

$tilde 18%$ efficiency

Variant: Slotted Aloha, have fixed timeslots in which sending is possible, make collisions less likely, $tilde 36%$ efficiency

=== Busy Tone Protocols
Collision avoidance by informing nodes of ongoing transmission (busy tone).

==== Busy Tone Multiple Access (BTMA)
Each station receiving a transmission sends busy tone

==== Receiver initiated BTMA (RI-BTMA)
Only receiver sends busy tone

==== Wireless Collision Detect (WCD)
Two types of busy tones:
- start with BTMA
- after receiver decodes receiver address, "feedback" busy tone is sent, other stations stop "collision detect" busy tone

=== Multiple Access with Collision Avoidance (MACA)
Signaling packets for collision avoidance:
- RTS (request to send), sent before starting the actual transmission
- CTS (clear to send), receiver grants right to send

#image("img/mit/maca.png", width: 70%)

Problem: idle listening necessary, solution: sleep and wake up in synchronized time frames

= Wireless LAN (WiFi)

== Standards

Defined by the IEEE 802.11 standard.

Generation defined by letter at the end, e.g.
- 802.11n (Wi-Fi 4)
- 802.11ac (Wi-Fi 5)
- 802.11ax (Wi-Fi 6)
- 802.11be (Wi-Fi 7)

It runs on layer 1 and 2 of the OSI model (physical layer (channel selection, modulation, error coding), mac layer (access mechanisms, fragmentation, encryption, authentication, ..)).

=== General Structure

1. Infrastructure Network:
  APs are attached to exisiting network, each AP manages communication in its reception range

2. Ad-hoc Network:
  stations can build up an own LAN without APs

3. Mesh Networks: APs are connected with WLAN, not cables


== Technology
#let MHz = math.op("MHz")

=== Original 802.11 standard

==== Frequency Hopping Spread Spectrum (FHSS)

- Uses $79$ different channels with $1 MHz$ bandwidth each
- minimum of $2.5 "hops"/s$
- either 2-GFSK ($1 "MBit"/s$) or 4-GFSK ($2 "MBit"/s$)

==== Direct Sequence Spread Spectrum (DSSS)
- uses either PSK ($1 "MBit"/s$) or QPSK ($2 "MBit"/s$)
- pre-defined chipping sequence

=== 802.11b
Use CCK and a spectrum mask (functionality probably irrelevant) to increase bandwidth

=== 802.11a
Use higher-frequency bands (5GHz) $->$ more channels

=== 802.11g
Builds upon 802.11b, but replaces DSSS/CCK with OFDM

=== 802.11n
- Supports both 2.4 and 5 GHz in the same standard
- small modifications to guard spaces, bandwidth and FEC coding rate to increase data rate
- use multiple input multiple output (MIMO) by using up to 4 antennas

=== 802.11ac
- Up to 8 MIMO streams
- up to 256-QAM
- multi user MIMO (MU-MIMO) in downlink

=== 802.11ax
- up to 1024-QAM
- MU-MIMO in uplink

=== 802.11be
- up to 4096-QAM
- MU-MIMO with 16 streams
- more bands between 1GHz and 7GHz

== Medium Access

One the MAC layer, prioritized time-controlled medium access is used.
The priority is defined through different timing intervals:
- SIFS: highest priority
- PIFS (PCF IFS): medium priority
- DIFS (DCF IFS): lowest priority

#image("img/mit/difs.png", width: 70%)

=== CSMA/CA
- before sending, a station performs carrier sense (CS)
- if medium is idle for at least duration of DIFS, station may send
- otherwise, station waits for DIFS and in addition a randomly chosen backoff time (CA) and continues listening. If medium is occupied during backoff time, timer is stopped and remaining time used in next try

#image("img/mit/difs_example.png", width: 70%)

// TODO: RTS/CTS implementation

=== Quality of Service (QoS)
802.11e defines a CSMA/CA variant that can give priority to real time data.

// TODO: Probably not relevant?

== Frames
// TODO: probably irrelevant, are there exercises/etests for this?

== Management
Things that need to be managed: synchronization, power management, security, ..

=== Synchronization
Possible with Beacons using _Beacon frames_ sent by APs.
// TODO: maybe add image from III-81

=== Power Management
Stations are activated periodically synchronized. transmissions for sleeping stations are buffered at the AP.

=== Roaming and Security
// TODO: Probably not relevant for exam

= Multi-Hop Networks (Routing)
Connect all APs of a WiFi community with a wireless distribution system.

== Mobile Ad-Hoc Network (MANET)
Devices connect directly without the need for an AP, allowing devices to act as a router to extend the network range. The structure of such a network can vary because of mobility.

== Wireless Mesh Network (WMN)
There are routers and APs, but they are connected wireless.

These networks require new routing protocols.

== Traditional Routing Algorithms

=== Distance Vector Routing
Nodes periodically exchange messages with their neighbors containing information about known destinations and their "distance". It has slow convergence, and is therefore inefficient in ad-hoc networks be cause of too many topology changes.

=== Link State
Local knowledge is periodically exchanged with all routes $->$ routers get a complete map of the network. However, it requires frequent flooding of the network to propagate the link state information which is inefficient in ad-hoc networks because of restricted bandwidth.

=== Problems of Traditional Routing Algorithms
- don't account for asymmetric connections
- mesh with very large number of connections causes high computational overhead for calculating the best path
- routing tables shouldn't be updated too often as that uses up energy which is limited for mobile devices
- don't account for high packet loss rates in wireless networks

== Routing Metrics
Measures the usefulness of a path. Measures from wired networks, like hop count, are often not suitable.

=== Expected Transmission Count (ETX)
The expected number of transmissions required to successfully transmit a packet over a link
$
"ETX" = 1 /("FDR" dot "RDR")
$
- $"FDR"$: Formward Delivery Ratio, estimated probability of a packet to successfully reach the destination
- $"RDR"$: Reverse Delivery Ratio, same for other direction

$"ETX"$ of a path: sum of all link $"ETX"$s.

=== Expected Transmission Time (ETT)
Considers differences in packet sizes and data rates in different links.
$
"ETT" = "ETX" dot S/B
$
- $S$: average packet size
- $B$: bandwidth of the link

$"ETT"$ of a path: sum of all link $"ETT"$s.

=== Weighted Cumulataive ETT (WCETT)
Consider $"ETT"$ as well as interference of used links.

// TODO: formula, probably not important

== Routing protocols for multi-hop networks
#image("img/mit/routing.png", width: 70%)

=== Reactive Protocols

==== Dynamic Source Routing (DSR)

- search for a path only if packets are to be sent
- path is searched with flooding (route request packet (RREQ))
- station that receives RREQ for the first time appends its own address and broadcasts it after random delay (to avoid collisions)
- if receiving station is destination, return packet to sender (route reply (RREP))

$=>$ not necessarily same path in both directions

// TODO: add example from IV-21ff, must be shortened, too long

===== Advantages
- no periodic updates needed $=>$ low overhead
- fast route discovery if caching is used
- several redundant paths are found

===== Disadvantage
- high delay before sending a packet
- flooding puts high load on network
- cache pollution
- random delays necessary

==== Ad-hoc On-demand Distance Vector routing (AODV)
Route discovery similar to DSR with some changes:
- RREQ builds up reverse path pointing towards source
- destination can reply without needing second path discovery (AODV assumes symmetric links)
- periodic hello messages to test link availability
- sequence numbers added to RREQ to avoid loops

=== Proactive Protocols

==== Optimized Link State Routing (OLSR)
Instead of broadcasting knowledge about local link costs, only sent them to a reduced number of nodes using _multipoint relays_.

Multipoint relays are chosen as such that every two-hop neighbor of a node $X$ is a one-hop neighbor of at least one multipoint relay of $X$.

Each node periodically transmits its neighbor list, so that every node knows their 2-hop neighbors.

==== Destination Sequenced Distance Vector (DSDV)
- each host manages table which contains the distance (using a metric, e.g. hops) to other hosts
- on changes, routing tables are exchanged (can be done incrementally)
- each node assigns sequence number to own entry which is increased with each exchange
- the routing entries are only updated with neighbors information, if their sequence number is higher than own

This guarantees that updates happen in the correct order and avoids loops.

== Multipath Routing
To increase fault tolerance and throughput, multiple paths can be used simultaneously.
Multiple paths can be found by not discarding duplicates of RREQs.

= From GSM to 5G

== Overview of mobile network generations

=== 1st generation networks
Analog, cellular mobile systems in different countries that were not compatible to each other.

=== 2nd generation (2G)
- digital
- first specification: GSM900 (frequency band around 900MHz)

=== 3rd generation (3G)
- deployment of UMTS networks
- GPRS as enhancement of GSM
- EDGE enhancement of GPRS
- eventually Long Term Evolution (LTE)

=== 4th generation (4G)
- LTE-Advanced (LTE-A, LTE+)
- LTE Advanced Pro (LTE-AP, 4.5G)

=== 5th generation (5G)
- high speed data networks
- can adapt to different usage scenarios

=== 6th generation (6G)
- higher data rates, lower latency, more devices

== GSM
- support for voice and data
- chip-cards for access control and authorization, can be used internationally
- high capacity and reliable at higher movement speeds

=== Cell concept
- Hexagonal cells, size not uniform but depends on environment and expected traffic amount (i.e. more cells in cities)

#image("img/mit/cells.png", width: 70%)

==== Cluster
The whole available bandwidth is distributed to the cells inside a cluster.
- more cells per cluster:
  - less channels per cell, lower system capacity, but less co-channel interference
- less cells per cluster:
  - more channels per cell, higher system capacity, but more co-channel interference

=== Components
- mobile stations (MS)
- base stations (BSC + BTS)
- mobile switching centers (MSC)
- locations registers (HLR + VLR)

=== Subsystems
- radio subsystem (RSS): covers all radio aspects
- network and switching subsystem (NSS)
- operation subsystem (OSS): management of the network

Structure is hierarchical

#image("img/mit/gsm.png", width: 70%)

// TODO: I don't think the details of this are important for the exam

=== Handover
#image("img/mit/handover.png", width: 70%)

// TODO: maybe add GPRS, UMTS, UTRAN if important
// TODO: OVSF?

// TODO: LTE, 5G?

= IP and Mobility

== Variants
- Intra-cell mobility, handled by PHY layer
- inter-cell but intra-network mobility (micro mobility)
  - requires routing updates, IP address can be kept
  - handled within network backbone
- inter-network mobility (macro mobility), IP address change required

== IP and Mobility
- When changing a subnet, the IP address has to be changed (routing of individual IP addresses does not scale well $->$ route subnets)
- DNS not suited to find device at new IP, needs time to adapt

$=>$ mobile devices need to keep thei IP address, no changes in switches and routers should be necessary

== Mobile IP (MIP)
- device keeps original IP address while moving
- when joining a new network, temporarily assign second address in that network

=== Components

==== Mobile Node (MN)
The mobile device e.g. phone

==== Home Agent (HA)
Router in home network of MN
- manages current location of MN and tunnels IP packets there (COA)

==== Foreign Agent (FA)
If mobile node is in foreign network, the "exit" router of that network for the MN

==== Care-of Address (COA)
Address of the MN at the tunnel end-point (see image below)

==== Correspondent Node (CN)
Communication partner of the MN

#image("img/mit/to_mn.png", width: 90%)
#image("img/mit/from_mn.png", width: 90%)

Tunnel uses IP-in-IP-encapsulation

=== Problems
- triangular routing can cause high latencies for high geographic distances
  - can be improved by informing CN about location of MN (route optimization)
- firewalls might discard MIP packets
- TTL not consistent
- privacy, if route optimization is used, CN can learn MNs movements

Many can be fixed with reverse tunneling:
#image("img/mit/mip_reverse.png", width: 90%)

=== IPv6 MIP
IPv6 makes MIP a bit easier, details probably not important

== Host Identity Protocol (HIP)
- HIP replaces the role of IP as identifier
- runs inbetween IP and tranport layer
- identifier stays the same during mobility

Host Identity (HI) is provided by public and private key pair (RSA)

HIP allows for authentication, IPSec is used for encryption

Can be affected by legacy middleboxes😡
Avoid this by encapusating HIP in UDP

== Peer-to-Peer-based Wi-Fi Internet Sharing Architecture (PISA)
- like traditional wifi-sharing, but all traffic is routed to a central "Trust Point" (there can be multiple) via encrypted tunnel
  - provides security and privacy for all parties
  - transparent mobility support

// TODO: MOBIKE?

== Muliplath TCP (MPTCP)
- Allows to use multiple paths over single connection (bind one socket to multiple IP addresses)
  - load balancing
  - redunancy

Middleboxes😡 often drop unknown TCP options, like those used by MPTCP.

== QUIC
- Builds TCP-like transport on top of UDP
  - userspace implementation allows for fast evolution
- connection not bound to IP, but 64-bit connection ID
  - enables mobility
- incorporates TLS 1.3
  - 0-RTT for subsequent connections
