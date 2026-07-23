#import "conf.typ": (
  algoBox, colorbox, conf, defiBox, monoFont, posneg, sidenote, theoBox, todo
)
#import "@preview/cetz:0.2.0": canvas, plot
#import "@preview/fancy-units:0.1.1": (
  add-macros, fancy-units-configure, num, qty, unit,
)
#import "@preview/fontawesome:0.6.0": *
#import "@preview/fletcher:0.5.8" as fletcher: diagram, edge, node

#show: conf.with(
  title: "Advanced Internet Technology",
  shortTitle: "AIT",
  authors: (
    (name: "Jonas Schneider"),
  ),
  lang: "en",
  filename: "ait",
  showOutline: true,
)

#let highlight_color = oklch(45.9%, 0.18401346242795294, 25.841300108647328deg);
#let highlight_color_text = white;
#fancy-units-configure(
  per-mode: "slash",
)

#let cord_diagram(
  peers,
  address_space: 0,
  outer_ring: 25mm,
  inner_ring: 20mm,
  finger_bend: +15deg,
  show_fingers: true,
  include_fingers: (),
  highlight_fingers: (),
  highlight_peers: (),
  additional_edges: (),
) = {
  let sorted_peers = peers.sorted()
  let log_addr_space = 0
  let addr_space = 0
  if address_space > 0 {
    log_addr_space = calc.log(address_space)
    assert(type(log_addr_space) == int)
    addr_space = address_space
  } else {
    while addr_space < sorted_peers.last() {
      log_addr_space += 1
      addr_space = calc.pow(2, log_addr_space)
    }
  }
  assert(peers.all(it => it >= 0 and it < addr_space))

  let finger(me, exponent) = {
    let logical_peer = calc.rem(me + calc.pow(2, exponent), addr_space)
    let successor = sorted_peers.find(it => it >= logical_peer)

    if successor == none {
      successor = sorted_peers.first()
    }

    return successor
  }

  let fingers = ()
  for i in range(addr_space) {
    if (peers.contains(i)) {
      let theta1 = (i / addr_space) * 360deg
      for j in range(log_addr_space) {
        if (
          show_fingers
            and (
              include_fingers == ()
                or (
                  type(
                    include_fingers.at(0) == array
                      and include_fingers.contains((i, j)),
                  )
                    or include_fingers == (i, j)
                )
            )
        ) {
          let peer = finger(i, j)
          fingers.insert(fingers.len(), (i, peer))
        }
      }
    }
  }

  let calc_peer_pos(peer) = {
    let theta = (peer / addr_space) * 360deg
    let x = inner_ring * calc.sin(theta)
    let y = inner_ring * calc.cos(theta)
    return (x, y)
  }

  return diagram(
    node(
      (0mm, 0mm),
      name: <origin>,
      circle(radius: outer_ring),
    ),
    for i in range(addr_space) {
      let theta1 = (((i) / addr_space) * 360deg)
      if peers.contains(i) {
        let (x1, y1) = calc_peer_pos(i)
        if (
          (type(highlight_peers) == array and highlight_peers.contains(i))
            or highlight_peers == i
        ) {
          node(
            (x1, y1),
            text(fill: highlight_color, align(center)[#(i)]),
            snap: 1,
          )
        } else {
          node(
            (x1, y1),
            align(center)[#(i)],
            snap: 1,
          )
        }
      }
      edge(
        (rel: (theta1, outer_ring - 2mm), to: <origin>),
        (rel: (theta1, outer_ring), to: <origin>),
      )
    },
    for (i, peer) in fingers {
      let (x1, y1) = calc_peer_pos(i)
      let (x2, y2) = calc_peer_pos(peer)
      if highlight_fingers.contains((i, peer)) {
        edge(
          (x1, y1),
          (x2, y2),
          "->",
          bend: finger_bend,
          stroke: highlight_color,
        )
      } else {
        edge((x1, y1), (x2, y2), "->", bend: finger_bend)
      }
    },
    if not additional_edges == () and type(additional_edges.at(0)) == array {
      for (i, peer) in additional_edges {
        let pos1 = calc_peer_pos(i)
        let pos2 = calc_peer_pos(peer)
        edge(pos1, pos2, "->", stroke: highlight_color)
      }
    } else if not additional_edges == () {
      let (i, peer) = additional_edges
      let pos1 = calc_peer_pos(i)
      let pos2 = calc_peer_pos(peer)
      edge(pos1, pos2, "->", stroke: highlight_color)
    },
  )
}

= Preface and Prior Knowledge

This Panikzettel ("panic note") is open source at #link("https://github.com/htwr-aachen/panikzettel", `https://github.com/htwr-aachen/panikzettel`).
We encourage any and all contribution from students and official sources. See #link("https://htwr-aachen.de/docs/panikzettel").

As this is a communication systems subject, knowledge of IP, TCP, and UDP is assumed. Take a look over the #link("https://htwr-aachen.de/panikzettel/datkom.pdf")[Datkom] Panikzettel to refresh.
We will structure this Panikzettel along the three major topics: Massively Scalable Systems, Resource-Constrained Systems & Adaptive Communication.

#sidenote(
  title: [Effort of this Panikzettel],
  [This Panikzettel was fun to create, but was also an immense effort, have fun reading it :) PS. Most graphs here are generated on the actual parameters of the graphs],
)

= Massively Scalable Systems

== Peer-to-Peer Systems <chapter:p2p>

Imagine you want to build a system, which operates mainly between peers, such as file sharing, a chat, or something like that.
These systems face challenges with scalability and are susceptible to a single-point of failure in a server-based architecture
which does not seem necessary when we just communicate between another.
Thus, we strive towards a *decentralized self-organizing system* with *decentralized usage of resources*.
The lecture gives @p2p_defi the long definition, of which parts are important (marked bold).

#defiBox(title: "P2P System", [
  P2P is a class of applications that takes advantage of resources –
  storage, cycles, content, human presence – available at the *edge of
  the Internet*.
  Because accessing these decentralized resources means operating in
  an environment of unstable connectivity and unpredictable IP
  addresses, P2P nodes *must operate outside the DNS system* and
  have significant or total *autonomy* from central servers.
]) <p2p_defi>


The essential challenge to solve in P2P systems is the location and search of content. #quote("How do we distribute it and find it later?") With considering our requirements of *scalability*, *robustness* and *consistency*.


#stack(
  dir: ttb,
  spacing: 2em,
  grid(
    columns: (1fr, 1fr, 1fr),
    gutter: 1em,
    [
      #let peers = 8
      #figure(caption: [\ Client-Server], diagram(
        node((1, 0), name: <origin>, move(dx: 1pt, align(center)[🖥️])),
        for θ in range(peers).map(i => i / peers * 360deg) {
          node(
            (rel: (θ, 15mm), to: <origin>),
            inset: 3pt,
            move(dx: 1pt, align(center)[🖥️]),
          )
          edge(<origin>)
        },
      )) <client_server>
    ],
    [
      #let peers = 8
      #figure(caption: [\ Centralized P2P], diagram(
        node((1, 0), name: <origin>, move(dx: 1pt, align(center)[🖥️])),
        for theta in range(peers).map(i => i / peers * 360deg) {
          let pos = (rel: (theta, 15mm), to: <origin>)
          node(
            pos,
            inset: 3pt,
            move(dx: 1pt, align(center)[🖥️]),
          )
          edge(<origin>)
        },
        for i in range(peers) {
          let theta1 = ((i + 1) / peers) * 360deg
          let pos = (rel: (theta1, 15mm), to: <origin>)
          for j in range(i + 1, i + 4) {
            if i != j {
              let theta2 = j / peers * 360deg
              let pos2 = (rel: (theta2, 15mm), to: <origin>)
              if pos != pos2 {
                edge(vertices: (pos, pos2))
              }
            }
          }
        },
      )) <p2p_centralized>
    ],
    [
      #let peers = 8
      #figure(caption: [\ Pure P2P], diagram(
        node((1, 0), name: <origin>),
        for i in range(peers) {
          let theta1 = ((i + 1) / peers) * 360deg
          let pos = (rel: (theta1, 15mm), to: <origin>)
          node(
            pos,
            inset: 3pt,
            move(dx: 1pt, align(center)[🖥️]),
          )
        },
        for i in range(peers) {
          let theta1 = ((i + 1) / peers) * 360deg
          let pos = (rel: (theta1, 15mm), to: <origin>)
          for j in range(peers) {
            if i != j {
              let theta2 = j / peers * 360deg
              let pos2 = (rel: (theta2, 15mm), to: <origin>)
              if pos != pos2 {
                edge(vertices: (pos, pos2))
              }
            }
          }
        },
      )) <p2p_pure>
    ],
  ),
  grid(
    columns: (1fr, 1fr),
    gutter: 1em,
    [
      #let super_peers = 6
      #let inner_offset = 12mm
      #let peers_per_superpeer = 3
      #figure(caption: [\ Hybrid P2P], diagram(
        node((1, 0), name: <origin>),
        for i in range(super_peers) {
          let theta1 = ((i + 1) / super_peers) * 360deg
          let pos = (rel: (theta1, inner_offset), to: <origin>)
          node(
            pos,
            inset: 3pt,
            move(dx: 1pt, align(center)[🖥️]),
          )
        },
        for i in range(super_peers) {
          let theta1 = ((i + 1) / super_peers) * 360deg
          let pos = (rel: (theta1, inner_offset), to: <origin>)
          for j in range(super_peers) {
            if i != j {
              let theta2 = j / super_peers * 360deg
              let pos2 = (rel: (theta2, inner_offset), to: <origin>)
              if pos != pos2 {
                edge(vertices: (pos, pos2))
              }
            }
          }
        },
        for i in range(super_peers) {
          let super_theta1 = ((i + 1) / super_peers) * 360deg
          let super_pos = (rel: (super_theta1, inner_offset), to: <origin>)
          for j in range(peers_per_superpeer) {
            let arc_span = 45deg
            let offset_angle = (
              (j - (peers_per_superpeer - 1) / 2)
                * (arc_span / peers_per_superpeer)
            )
            let theta1 = super_theta1 + offset_angle
            let pos = (rel: (theta1, inner_offset + 10mm), to: <origin>)
            node(
              pos,
              inset: 3pt,
              move(dx: 1pt, text(size: 8pt, align(center)[🖥️])),
            )
            edge(super_pos)
          }
        },
      )) <p2p_hybrid>
    ],
    [
      #figure(caption: [\ Structured P2P], cord_diagram(
        (0, 1, 3, 5, 7),
        outer_ring: 25mm,
        inner_ring: 20mm,
      )) <p2p_structured>
    ],
  ),
)

== Centralized P2P & Napster

The first ideas of a peer-to-peer systems where realized as a centralized type shown in @p2p_centralized. The most prominent example is the Napster file sharing application. Here we have a central _directory service_ which provides coordination of entities. It would for example save that Alice has file `A`. If then Bob wants to retrieve `A`, it would ask the directory which peer has this file, which would give a list of just `[Alice]`. Now if Alice is offline currently, the directory service should organize some sort of replication to combat the total unavailability of the data.
Though the directory service is in itself not much better, than the traditional Client-Server model @client_server shows.

When we look at scalability the worst counts, worst of in this P2P model, is the directory service. Most peers do not need information about other peers, but the central directory service need $O(n)$ state entries for all peers. This makes this *not scalable*. One advantage however is that, if the directory service answers our search, we can just directory contact Alice without extra communication, thus $O(1)$ communication overhead.

== Pure P2P & Gnutella 0.4

When looking at the complete opposite end shown in @p2p_pure or Gnutella 0.4, we see that there is no central server anymore. Here Alice still stores her own file, but when Bob want to retrieve it, he has to ask his neighbors "Requesting `A`". Their neighbors do not know Alice either and send this request to their neighbors.
This is called _flooding_ and it will quickly overload *any* system. To mitigate a complete overload we limit the Request to a specific time to live (default 7), after which it will be just dropped. This means we do not necessarily find `A` if Alice is further than 7 hops away.
Notice however that *each* entity (all are equal) stores constant $O(1)$ information about their peers. But we require up to a $O(n)$ communication overhead before we find Alice (in case an of straight line) which does *not scale* either.

== Hybrid P2P & Gnutella 0.6

Gnutella 0.6 wants to improve the performance and introduced a superpeer type of peer. This are dynamically elected by peers which then just connect to one or more superpeers. When Bob wants to find `A`, he goes to its superpeer. This then does flooding between all superpeers to find it. This improves the method but does not scale either, because there is not organization and load can be very asymmetric. Asymptotic could still be considered $O(1)$ state and $O(n)$ communication overhead because the superpeer network is again a pure P2P.

== Structured P2P & Chord

#let peers = (3, 7, 13, 15)


#let finger_table(peers, me) = {
  let sorted_peers = peers.sorted()
  let log_addr_space = 0
  let addr_space = 0
  while addr_space < sorted_peers.last() {
    log_addr_space += 1
    addr_space = calc.pow(2, log_addr_space)
  }
  assert(peers.all(it => it >= 0 and it < addr_space))

  let finger(me, exponent) = {
    let logical_peer = calc.rem(me + calc.pow(2, exponent), addr_space)
    let successor = sorted_peers.find(it => it >= logical_peer)

    if successor == none {
      successor = sorted_peers.first()
    }

    return successor
  }

  return table(
    columns: (auto, auto),
    table.header([Finger], [Node ID]),
    ..for j in range(log_addr_space) {
      let peer = finger(me, j)
      ([#j], [#peer])
    },
  )
}

#grid(
  columns: (1fr, 1fr),
  [
    Now to the winner a _distributed hash table_.
    We recognize that we need to achieve a nice distribution of our content to the nodes
    and use the help of a hash function ($h$), which does not necessarily be a cryptographically secure hash function, but it *must* map to exactly one ${0,..., 2^m-1}$ large address space.
    Then we lay out this address space as a ring shown and give each peer an ID in this address space e.g. $h("Alice") = 13, h("Bob") = 7, h("Charlie") = 3, h("David") = 15$. The content is then also hashed $h(#raw("A")) = 0$ and saved by Alice on the next clockwise node on the ring of that id $0 -> 3, 4 -> 7, ...$ e.g. Charlie. This results in @dht_1.

    Again Bob wants to find `A`. Currently he only knows it's hash $h(#raw("A"))$, but for routing we need to know the next nodes. Specifically we create a table of the nodes which own the $j+ 2^i$, where $j$ is my ID and $0 <= i <= m$. So with each finger we cover increasing distances, which allows us to have a $O(log n)$ node state.

    Coming back to Bob, who wants to find the owning node of $h(#raw("A") = 0$ and starts with going as far as he can without overshooting so $7->13$ in our case (! he does not know 1 is responsible 0, there could be someone in the middle!), Then we check again, $13$ knows $15$ is closer so $13->15$, and now 15 knows the next node $3$ is responsible and sends this back to Bob. This allows routing in $O(log n)$ steps :D see @dht_2. Then Bob can simply go to the responsible node and retrieve `A` (@dht_3)

    #algoBox(title: [Chord Routing], [
      Go as far as we can in our finger table, without overshooting, and repeat this until the next node is responsible for the searched content.
    ])

    There are a couple of nuances that need to be set out.
  ],
  [
    #figure(
      caption: "DHT 1. Step",

      cord_diagram(
        peers,
        show_fingers: false,
        outer_ring: 20mm,
        inner_ring: 15mm,
        highlight_peers: 3,
      ),
    ) <dht_1>

    #v(2em)

    #figure(
      caption: "Finger Table of peer 7 (Bob)",
      finger_table(peers, 7),
    )

    #v(2em)

    #figure(
      caption: "Chord Routing",

      cord_diagram(
        peers,
        outer_ring: 20mm,
        inner_ring: 15mm,
        highlight_peers: 3,
        highlight_fingers: ((7, 13), (13, 15)),
      ),
    ) <dht_2>

    #figure(
      caption: "Chord Routing",

      cord_diagram(
        peers,
        outer_ring: 20mm,
        inner_ring: 15mm,
        highlight_peers: 1,
        show_fingers: true,
        additional_edges: (7, 3),
      ),
    ) <dht_3>
  ],
)


1. Node Arrival

If you as a new node arrives, get you ID, iterate over the finger table and query the $"id"+2^i$'s responsible node similar to standard id lookup.
For successors of your node contact the first successor from the finger table and use his list.

Then we need to signal nodes which have an invalid finger to our successor to update to us. For this we use the same method but backwards $id - 2^i$. => $O(log^2 n)$

2. Storage & Replication

We can distinguish between _direct storage_ where we store content directly on the responsible node, or an _indirect storage_ where we store at Charlie, that Alice has the content.
Content can be replicated with using multiple hashes, and storing it at each (e.g $h(#raw("A")), h(h(#raw("A"))), h(h(h(#raw("A"))))$. Then when loading choose one to lookup.

3. Node Failure

We do active finger maintenance and periodically check fingers for activity. If a finger is offline, query the alternative like on node arrival.
We also need to keep a list of successors of our node, to mitigate the last step, where a responsible node is unavailable.

4. Node Departure

Is handled either exactly like a failure or with a short notification period, where we notify nodes about our pending departure.

== Graph & Network models

This is the theoretical network science groundwork why the DHT and Chord was designed the way it is.
A graph $G=(V,E)$ contains vertices and edges

We will look at three different graph categories (#link(<chapter:random_graph>, [Random Graphs]), #link(<chapter:small_world>, [Small World Graphs]), #link(<chapter:power_law>, [Power Law Graphs])) and rate them for each $v in V$ mainly using $deg(v)$ i.e. the number of edges which are incident to vertex $v$, the clustering coefficient.

#defiBox(
  title: [Clustering Coefficient],
  [
    $ C(v) := (2 dot e(v))/(deg(v) dot (deg(v) -1) $
    where $e(v) := "the number of connection of v's neighbors with each other"$.
    The clustering coefficient of a graph is the average over all vertices: $ C(G) := (sum_{v in V} C(V))/abs(V) $
  ],
)

Examples:
#let radius = .7em
#grid(
  columns: (1fr, 1fr),
  align: center,
  [
    #figure(
      diagram(
        edge-stroke: 0.07em,
        node(
          (0, 0),
          circle(radius: radius),
        ),
        edge(stroke: highlight_color),
        node(
          (1, 0),
          circle(radius: radius),
        ),
        edge(),
        node(
          (0, 1),
          circle(
            radius: radius,
            inset: 2pt,
            fill: highlight_color,
            stroke: highlight_color_text,
            [#set text(fill: highlight_color_text, size: 15pt); $ v $],
          ),
        ),
        edge((0, 0), (0, 1)),
        edge(),
        node(
          (1, 1),
          circle(radius: radius),
        ),
        edge((0, 0), (1, 1), stroke: highlight_color),
        edge((1, 0), (1, 1), stroke: highlight_color),
      ),
    )
    $
      C(v) & = (2 dot e(v))/(deg(v) dot (deg(v) -1)) \
           & = (2 dot #text(fill: highlight_color, $3$)) / (3 dot 2) = 1
    $
  ],
  [
    #figure(
      diagram(
        edge-stroke: 0.07em,
        node(
          (0, 0),
          circle(radius: radius),
        ),
        edge(stroke: highlight_color),
        node(
          (1, 0),
          circle(radius: radius),
        ),
        edge(),
        node(
          (0, 1),
          circle(
            radius: radius,
            inset: 2pt,
            fill: highlight_color,
            stroke: highlight_color_text,
            [#set text(fill: highlight_color_text, size: 15pt); $ v $],
          ),
        ),
        edge((0, 0), (0, 1)),
        edge(),
        node(
          (1, 1),
          circle(radius: radius),
        ),
        edge((1, 0), (1, 1), stroke: highlight_color),
      ),
    )
    $
      C(v) & = (2 dot e(v))/(deg(v) dot (deg(v) -1)) \
           & = (2 dot #text(fill: highlight_color, $2$)) / (3 dot 2) = 2/3
    $
  ],
)

#defiBox(title: [Path Length], [
  A path is a sequence of $k in NN$ vertices $P(v,w)= (v_1,v_2,...,v_k) in V times V times ... times V$ where $v_1 = v$ and $v_k = w$ such that $(v_i, v_(i+1)) in E$ for $0 <= i <= k-1$.
  - The path length $|P(v,w)| = k-1$ is the number of edges in the path.
  - The distance $d(v,w)$ is the shortest-path $P(v,w)$ with respect to the path length.
])

#defiBox(title: [Graph Diameter], [
  The diameter of a graph $G=(V,E)$ is the farthest distance $d(v,w)$ between any two $v,w in V$
])

Before going further what are we looking for?
We want a small diameter for efficient routing steps but high clustering coefficient, to achieve reliability and stability. We do also need a somewhat balanced node degree.

=== Random Graphs   <chapter:random_graph>

We have the Randomized Network (Erdös-Rényi-Model) in which we choose a graph $g_(n,m) scripts(in)_R G_(n,m)$ out of all Graphs with exactly $n in NN$ vertices and $m in NN$ edges.
#theoBox(title: [Connectedness], [
  With high probability, the graph has a connected component of size $O(n)$ if the average node degree $> O(log n)$.
])
#theoBox(title: [Diameter], [
  If the graph is connected, then with high probability $"Diameter"(g_(n,m)) = O(log n)$.
])

We cannot reasonably generate/choose such a random network, and have to generate it incrementally using the _Gilbert Random Graph_ Model.
For this generate a graph $g_(n,p)$ with a given number of vertices $n in NN$ and a probability $0<=p<=1$ to add an edge between any $(v,w)$ with $v,w in V$.
#theoBox(title: [Clustering Coefficient], [
  $C(g_(n,p)) tilde.eq p$ with high probability.
])
#theoBox(title: [Diameter], [
  If $p > ln n/n$ a graph $g_(n,p)$ will be connected with high probability.
])

=== Power Law / Scale-free Graphs   <chapter:power_law>

Random graph do not provide the necessary goals we want to achieve. They have a good (good *always* means $O(log n)$ here) diameter but do not provide a dense locale structure.

When we look at network in reality, they often provide a so called _power law_ distributed node degree.

#defiBox(title: [Power-Law Distributed Graph], [
  In a power-law / scale-free distributed graph the probability that a node is connected to $k$ is $P(k) ~ k^(-gamma)$.
  This directly translates to the statements *"The rich get richer"* as some nodes (called hubs) have very high and most other have small degree.
  It is called _scale-free_ due to the probability being completely independent of the scale of the system.
])

We see that Internet web pages, Internet backbone structure, cooperation between actors, power grids and more follow a power-law distribution.

#algoBox(title: [_Baranbási-Albert_ Model], [
  1. Start with a small random network $G=(V,E)$
  2. Add a single vertex $G' = (V union {v_"new"}, E)$. Choose $m in NN$ vertices from the probability distribution $Pi_(v) = deg(v) / (sum_(w in V') deg(w))$.

  To recap, the more edges it already has, the more probable new edges are.
])

=== Small World Graphs  <chapter:small_world>

Power-Law networks are great and provide a somewhat dense local structure (even though only the hubs) and a good routing performance. The problem are with the hubs. They have much higher traffic load in a P2P system and are susceptible to targeted attacks. They are however robust against random node failures.

The next graph model are small-world networks, where a dense local structure (e.g. a grid) is used in combination with a few far reaching connections. These connections that make the routing fast.

1. Watts-Strogatz Model
  #let peers = 8

  #grid(
    columns: (1fr, 1fr, 1fr),
    [
      #figure(caption: [\ Watts-Strogatz $k=2, p=0$], diagram(
        node((1, 0), name: <origin>),
        for theta in range(peers).map(i => i / peers * 360deg) {
          let pos = (rel: (theta, 15mm), to: <origin>)
          node(
            pos,
            inset: 3pt,
            move(dx: 1pt, circle(radius: 2mm)),
          )
        },
        for i in range(peers) {
          let theta1 = ((i + 1) / peers) * 360deg
          let pos = (rel: (theta1, 15mm), to: <origin>)
          for j in range(i + 1, i + 4) {
            if i != j {
              let theta2 = j / peers * 360deg
              let pos2 = (rel: (theta2, 15mm), to: <origin>)
              if pos != pos2 {
                edge(vertices: (pos, pos2), bend: +15deg)
              }
            }
          }
        },
      )) <watts_strogatz_1>
    ],
    [
      #let reorder = ((1, 3, 1, 6), (5, 6, 5, 0))
      #let calc_peer_pos(peer) = {
        let theta = (peer / peers) * 360deg
        let x = 15mm * calc.sin(theta)
        let y = 15mm * calc.cos(theta)
        return (x, y)
      }
      #figure(caption: [\ Watts-Strogatz $k=2, p=1/8$], diagram(
        node((1, 0), name: <origin>),
        for i in range(peers) {
          let pos = calc_peer_pos(i)
          node(
            pos,
            inset: 3pt,
            move(dx: 1pt, circle(radius: 2mm)),
          )
        },
        for i in range(peers) {
          let pos = calc_peer_pos(i)
          for j in range(i + 1, i + 3) {
            let k = j
            if i == 1 and j == 3 {
              k = 4
            }
            if i == 5 and j == 6 {
              k = 0
            }
            if i != j {
              let pos2 = calc_peer_pos(k)
              edge(vertices: (pos, pos2), bend: -15deg)
            }
          }
        },
      )) <watts_strogatz_2>
    ],
    [
      #let reorder = ((1, 3, 1, 6), (5, 6, 5, 0))
      #let calc_peer_pos(peer) = {
        let theta = (peer / peers) * 360deg
        let x = 15mm * calc.sin(theta)
        let y = 15mm * calc.cos(theta)
        return (x, y)
      }
      #figure(caption: [\ Watts-Strogatz $k=2, p=1/4$], diagram(
        node((1, 0), name: <origin>),
        for i in range(peers) {
          let pos = calc_peer_pos(i)
          node(
            pos,
            inset: 3pt,
            move(dx: 1pt, circle(radius: 2mm)),
          )
        },
        for i in range(peers) {
          let pos = calc_peer_pos(i)
          for j in range(i + 1, i + 3) {
            let k = j
            if i == 1 and j == 3 {
              k = 4
            }
            if i == 5 and j == 6 {
              k = 0
            }
            if i == 5 and j == 7 {
              k = 1
            }
            if i == 6 and j == 7 {
              k = 5
            }
            if i != j {
              let pos2 = calc_peer_pos(k)
              edge(vertices: (pos, pos2), bend: -15deg)
            }
          }
        },
      )) <watts_strogatz_2>
    ],
  )

Form a ring and connect the next $k in NN$ vertices together. Then choose random numbers $0<=x<=1$ and rewire each edge if $x<=p$ to a uniformly random $w scripts(in)_R V$.

2. Kleinbergs Model is similar

//TODO: Graph

Take a fix grid of vertices and *add* (not rewire) a long-distance edge to any $w in V$ with $P(v,w) ~ d_m(v,w)^-alpha$ where $d_m$ is the Manhattan distance (so only along the grid).

#theoBox(title: [Short Paths in Kleinbergs model], [
  The routing algorithm will find 'short' paths if and only if $alpha = d$, where $d$ is the grid dimension
])

== Internet Indirection Infrastructure I3

A P2P system for indirection in the Internet. This allows for mobility, multicast, anycast and more, which all use some sort of indirection.
The system is implemented as an overlay network i.e. on top of IP in between TCP/UDP.

For this we again use a DHT/Chord addressing and routing system. Each node has its i3 id and places a _trigger_ of this id together with a way route to the node (e.g. IP address or DNS entry) in the DHT. As seen in @i3_simple_trigger the sender then can send you content, with just knowing your id and nothing else.
If the sender and receiver are not part of the i3 network, the content is first send to any i3 node (as the gateway), this then looks up the responsible node for id ID and forwards the traffic. We also use caching to alleviate the extra overhead of ID lookup both for the gateway, and the responsible node.

#figure(
  caption: [Simple i3 trigger],
  diagram(
    spacing: 0mm,
    node(
      (0, -1),
      [Sender $S$],
      width: 45mm,
    ),
    edge(<trigger_head>, bend: -15deg, "->", label: [Send]),
    node(
      (1, 0),
      [ID],
      name: <trigger_head>,
      fill: orange,
      shape: rect,
    ),
    node(
      (2, 0),
      [R],
      name: <trigger_end>,
      fill: gray,
      shape: fletcher.shapes.house.with(dir: right, angle: 30deg),
    ),
    node((3, 0), width: 15mm),
    node(
      (4, 1),
      name: <R>,
      [Receiver $R$],
    ),
    edge(
      <trigger_end>,
      <R>,
      bend: +15deg,
      "->",
      label: [Send],
      label-side: left,
    ),
    edge(<R>, <trigger_head>, label: [Insert ID,R], bend: 30deg, "->"),
  ),
) <i3_simple_trigger>

Let's go over all the applications of this infrastructure:

1. Mobility

Each trigger can have multiple ends, when sending to a trigger each end receives the full content.
We can also update the existing ends of a trigger to a new. As such when we move e.g. from Wi-Fi to LTE, we register our new IP address as $R_2$ end end remove $R_1$.

To improve this design further, we can have a short time, where both $R_1$ and $R_2$ are part of the trigger and form a multicast group. The mobile node now has to detect duplicate packets coming over both routes for a short time, after which we remove $R_1$ to fully transition.

2. Multicast

#figure(
  caption: [Multicast i3 trigger],
  diagram(
    spacing: 0mm,
    node(
      (0, -1),
      [Sender $S$],
      width: 45mm,
    ),
    edge(<trigger_head1>, bend: -15deg, "->", label: [Send]),
    node(
      (1, 0),
      [ID],
      name: <trigger_head1>,
      fill: orange,
      shape: rect,
    ),
    node(
      (2, 0),
      [R],
      name: <trigger_end1>,
      fill: gray,
      shape: fletcher.shapes.house.with(dir: right, angle: 30deg),
    ),
    node(
      (1, 1),
      [ID],
      name: <trigger_head2>,
      fill: orange,
      shape: rect,
    ),
    node(
      (2, 1),
      [R],
      name: <trigger_end2>,
      fill: gray,
      shape: fletcher.shapes.house.with(dir: right, angle: 30deg),
    ),
    node((3, 0), width: 15mm),
    node(
      (4, -1),
      name: <R1>,
      [Receiver $R_1$],
    ),
    node(
      (4, 1),
      name: <R2>,
      [Receiver $R_2$],
    ),
    edge(
      <trigger_end2>,
      <R2>,
      bend: +15deg,
      "->",
      label: [Send],
      label-side: left,
    ),
    edge(
      <trigger_end1>,
      <R1>,
      bend: +15deg,
      "->",
      label: [Send],
      label-side: left,
    ),
  ),
) <i3_multicast_trigger>

We solved multicast already as seen in @i3_multicast_trigger. We can improve scalability concerns, due to a single node having to send to all $R$ by implementing another Indirection and let ID send to ID2 which is again multicast

3. Anycast

As a refresher: In anycast, only one of group of nodes should receive our message. Most often the closest one.

In i3 we can realize this using a joint anycast prefix, and a per member postfix. Then the data is forwarded using a longest prefix match, this also enables a more filtered approach and load-balancing and context-aware selction.

4. Network Services


#figure(
  caption: [Multicast i3 Sender-initiated Network Services],

  pad(bottom: 12pt, grid(
    rows: (auto, auto),
    gutter: 12pt,
    diagram(
      spacing: 0mm,
      node((0, 2), width: 15mm, height: 15mm),
      node(
        (0, 0),
        [Sender $S$],
        width: 45mm,
      ),
      edge(
        <th1>,
        bend: -15deg,
        "->",
        label: [$*_1$],
      ),
      node(
        (1, 1),
        [$"ID"_T$],
        name: <th1>,
        fill: orange,
        shape: rect,
      ),
      node(
        (2, 1),
        [T],
        name: <te2>,
        fill: gray,
        shape: fletcher.shapes.house.with(dir: right, angle: 30deg),
      ),
      edge(
        bend: -15deg,
        "->",
        label: [$*_2$],
      ),
      node(
        (3, -1),
        [Transcoder \ 🖥️],
        name: <transcoder>,
        shape: rect,
      ),
      edge(bend: 20deg, "-|>", label: [$*_3$]),
      node(
        (4, 2),
        [$"ID"_R$],
        name: <th3>,
        fill: orange,
        shape: rect,
      ),
      node(
        (5, 2),
        [R],
        name: <te3>,
        fill: gray,
        shape: fletcher.shapes.house.with(dir: right, angle: 30deg),
      ),
      edge(bend: -30deg, "-|>", label: [$*_4$]),
      node(
        (6, 0),
        [Receiver $R$],
      ),
    ),
    [
      #grid(
        columns: (1fr, 1fr, 1fr, 1fr),
        align: center,
        [
          #set align(center)
          $*_1$ \ #diagram(
            spacing: 0mm,
            node((0, 0), [$"ID"_T$], fill: orange, shape: rect),
            node((1, 0), [$"ID"_R$], fill: gray, shape: rect),
            node(
              (2, 0),
              [data],
              fill: gray,
              shape: fletcher.shapes.house.with(dir: right, angle: 30deg),
            ),
          )],
        [
          #set align(center)
          $*_2$ \
          #diagram(
            spacing: 0mm,
            node((0, 0), [$T$], fill: orange, shape: rect),
            node((1, 0), [$"ID"_R$], fill: gray, shape: rect),
            node(
              (2, 0),
              [data],
              fill: gray,
              shape: fletcher.shapes.house.with(dir: right, angle: 30deg),
            ),
          )],
        [
          #set align(center)
          $*_3$ \
          #diagram(
            spacing: 0mm,
            node((1, 0), [$"ID"_R$], fill: orange, shape: rect),
            node(
              (2, 0),
              [$t("data")$],
              fill: gray,
              shape: fletcher.shapes.house.with(dir: right, angle: 30deg),
            ),
          )],
        [
          #set align(center)
          $*_4$ \ #diagram(spacing: 0mm, node(
            (2, 0),
            [$t("data")$],
            fill: orange,
            shape: fletcher.shapes.house.with(dir: right, angle: 30deg),
          ))],
      )
    ],
  )),
) <i3_service>

We can define "middleware" services which can manipulate the data in-transit either as a sender-initiated or receiver initiated.


#block(breakable: false, [
  For this we define the exact types a trigger can be:
  #grid(
    columns: (1fr, 1fr, 1fr),
    gutter: 5mm,
    [
      #set align(center)
      i3 destination address \
      #diagram(spacing: 0mm, node(
        (0, 0),
        [ID / (IP & Port)],
        fill: gray,
        shape: fletcher.shapes.house.with(dir: right, angle: 30deg),
      ))

      This is the end address, upon receive, the address is removed from the stack, data is processed and send to next node

    ],
    [
      #set align(center)
      i3 stack \
      #diagram(
        spacing: .5mm,
        node(
          (0, 0),
          [IP/Port],
          fill: gray,
          shape: rect,
        ),
        node(
          (1, 0),
          [ID],
          fill: gray,
          shape: fletcher.shapes.house.with(dir: right, angle: 30deg),
        ),
      )
      \

      A sequence of i3 addresses
    ],
    [
      #set align(center)
      i3 trigger \
      #diagram(
        spacing: 0.5mm,
        node(
          (0, 0),
          [ID],
          fill: orange,
          shape: rect,
        ),
        node(
          (1, 0),
          [IP/Port],
          fill: gray,
          shape: rect,
        ),
        node(
          (2, 0),
          [$"ID"_2$],
          fill: gray,
          shape: fletcher.shapes.house.with(dir: right, angle: 30deg),
        ),
      )
      \

      Upon receive, the ID will be replaced by the stack e.g. (IP/Port + $"ID"_2$) and forwarded to the address
    ],
  )])

Server-initiated as shown in @i3_service, Sends the data after a stack of IDs (in this case the transcoder).

In a Receiver-initiated the receiver would place the $"ID"_T$ into his trigger
Which would redirect the traffic first to the transcoder and then to R.
#box(diagram(
  spacing: 0.5mm,
  node(
    (0, 0),
    [$"ID"_R$],
    fill: orange,
    shape: rect,
    height: 6mm,
  ),
  node(
    (1, 0),
    [$"ID"_T$],
    fill: gray,
    shape: rect,
    height: 6mm,
  ),
  node(
    (2, 0),
    [R],
    fill: gray,
    shape: fletcher.shapes.house.with(dir: right, angle: 30deg),
    height: 6mm,
  ),
))

== Bitcoin

#sidenote(title: [Warning], [
  Read this section carefully, to shut down any crypto bro who says it revolutionizes the world
])

A special case of distributed P2P systems are crypto-currencies because even with all that we have a particular problem which is very difficult to solve

#defiBox(title: [Double Spending Problem], [
  It must be impossible to:
  1. Create new currency outside rules
  2. Copy currency after obtaining it
  3. Reuse currency

  Image Eve has 5 Melaniacoins
  The problem is when Eve send Alice and Bob both illegaly 5 Melaniacoins over different links. This illegal transaction can come through if the network is slow between these links, then Alice and Bob both assume they have 5 Melaniacoins.
])

Bitcoin was the first (kinda) cryptocurrency build on a *public append-only distributed ledger* called _blockchain_. Transactions are only considered valid if they are in the longest valid blockchain.

=== Blockchain

Each block in the blockchain have the following properties:
- ID: hash of this block
- Previous Block Hash: used to link blocks together
- Proof-of-Work: a random nonce to assure ID has $k$ zeros as a prefix of the hash, based on the current threshold $k in NN$
- Transactions: set of transactions in each block.
- Transaction Merkle Tree allows nodes, that trust parts of a transaction, to verify partial transactions without needing the full content (only the partial merkle node suffices for the other transactions)
#algoBox(title: [Merkle Tree], [
  Say you have a very secure hash function $h(x) = (3x+2) mod 8$. Then construct the merkle tree like this and only save the $1$.

  #set align(center)
  #diagram(
    spacing: 1em,
    node-fill: rgb(184, 129, 2),
    node((0, 0), [#set text(fill: white); 1]),
    edge(),
    node((0, 1), [#set text(fill: white); $h(1) = 5$]),
    node((2, 0), [#set text(fill: white); 3]),
    edge(),
    node((2, 1), [#set text(fill: white); 3], shape: rect),
    node((4, 0), [#set text(fill: white); 9]),
    edge(),
    node((4, 1), [#set text(fill: white); 5], shape: rect),
    node((6, 0), [#set text(fill: white); 12]),
    edge(),
    node((6, 1), [#set text(fill: white); 6], shape: rect),
    edge((0, 1), (1, 2)),
    edge((2, 1), (1, 2)),
    node((1, 2), [#set text(fill: white); $h(5+3) = 2$], shape: rect),
    edge((4, 1), (5, 2)),
    edge((6, 1), (5, 2)),
    node((5, 2), [#set text(fill: white); 3], shape: rect),
    edge((1, 2), (3, 3)),
    edge((5, 2), (3, 3)),
    node((3, 3), [#set text(fill: white); 1], shape: rect),
  )
])

We require the hash function to be a cryptographically secure on (see IT-Sec panikzettel)

There are a couple node types:
1. Full nodes verify all blocks and transactions. They must be bootstrapped with the known root blocks hash and an archival node but afterward do not need the full blockchain.
2. Archival nodes save the complete blockchain
3. Backbone nodes are both archival and verifying
4. Miners find new proof-of-works and therefore add new blocks. They pick proposed transactions into new blocks

=== Step by Step Transaction

| this can become somewhat tricky and is not necessary to understand to pass the exam (pass not 1.0 it). We are also more detailed than the lecture here because it aids understanding

//TODO: change to From a user perspective ...
Bitcoins are managed by a wallet software managing a specific _bitcoin address_ (or multiple), which is just a (base58-checksumed typo mitigating representation) of a hash a public key, to which the user has the private key.

The ownership of the bitcoins at that address is enforced with signatures of that private key.

Imagine Alice wants to send Bob $10 bitcoin$.


1. *Creating the transaction*: Alice's wallet software constructs a proposed _transaction_. This transaction is cryptographically signed with her private key and includes
  - *Inputs*: The transaction's inputs reference previous transactions where Alice received bitcoins. These bitcoins are locked in the previous transactions with output scripts, that Alice now needs to unlock to prove she owns them.
  - *Outputs*: Then after unlocking, she is able to create new locks that specify the conditions for spending the bitcoins in the future. In our case, the bitcoins will be lock with Bob's address.

(Do not take the time assertions, e.g. "after" literally here, both inputs, and outputs are both scripts in the same transaction which is proposed as a single unit)

2. *Unlocking* / *Inputs* / _scriptSig_: Let's assume Alice needs to gather enough to pay Bob. Her wallet finds two previous transactions, in one Alice received $5 bitcoin$ (ID `f3`) and $10 bitcoin$ in another (ID `02`). Also assume these were both locked at that time using a standard `P2PKH` output scripts. To unlock them, her wallet creates a corresponding input script (_scriptSig_) for each

  ```
  Push <signature for f3>
  Push <Alices's pubkey>
  ```
  and
  ```
  Push <signature for 02>
  Push <Alics's pubkey>
  ```

  When this new transaction is processed by the network, the provided signature and pubkey will be checked against the conditions of the previous output script to prove Alice's ownership.
  Now Alice has successfully proven her ownership and unlocked them, ready to be locked again by the output scripts.

3. *Locking* / *Ouptuts* / _scriptPubKey_: The bitcoins are now in an unlocked state, ready to be locked again by output scripts:
  - Script to send Bob $10 bitcoin$
  - Transaction fees, say $1 bitcoin$ for the hard work of the miner (as the time of this writing it would be $0.00000224 bitcoin$)
  - Script to return the rest $4 bitcoin$ back to Alice.

  The transaction fee is handled implicitly, simply all not locked bitcoins are the transaction fee at the end.

  The others have to be declared though, for this a couple of output script options are in use

  1. Pay-to-Public-Key-Hash (`P2PKH`) is the standard nowadays which locks the Unspent Transaction Output (UTXO) behind the has of bob's public key.
  ```
  OP_DUB              // Duplicates the public key provided by bob in the intput script
  OP_HASH160          // Hashes that duplicate key
  <pubkeyhash of bob>
  OP_EQUALVERIFY      // Checks if the provided hash matches Bob's public key hash
  OP_CHECKSIG         // Checks if the signature provided by bib is valid for this transaction
  ```

  2. Pay-to-Public-Key (`P2PK`) is not used anymore as a post-quantum mitigation, but locks directly behind Bob's public key.
  ```
    <pubkey of bob>
    OP_CHECKSIG // Checks if the signature provided by bib is valid for this transaction
  ```

  3. Pay-to-Multi-Sig (`P2MS`) is used when more than one signature unlocks the funds.
  4. Pay-to-Script-Hash (`P2SH`) is a more advanced script type that locks the bitcoins not to a public key hash, but to the hash of another script (the redeem script). When the bitcoins are spent, the spender must provide the original script and the inputs that make that script true. This allows for much more complex transaction conditions without cluttering the blockchain with long scripts.
  5. *OP_RETURN* allows for currently 80 bytes of arbitrary data for timestamping and other things (see )

  `P2PKH` is used over `P2PK` since, with throwaway bitcoin addresses the public key of the address of bob is only known after using the funds, where they are already send to another unknown address.

  Again to recap _scriptSig_ (input script) from a new transaction provides the key to unlock a previous _scriptPubKey_ (output) script.
4. Alice sends this complete transaction to the bitcoin networks.
5. Miners pick up this transaction and combine it with multiple other into one a proposed block and via brute force find a proof-of-work such that the block hash starts with $n in NN$ zeros.
6. After a block has been added, wait a few more blocks to be sure there is no fork in the and establish consensus that the transaction is done.

Now Bob is literally a millionaire congrats.

== Cloud

The next three sections concern cloud environments and two mainly cloud applications.

> #quote("What is the cloud anyway?", attribution: [any boomer])

#defiBox(title: "Cloud Computing", [
  Cloud computing is a model for enabling ubiquitous, convenient, on-
  demand network access to a shared pool of configurable computing
  resources (e.g., networks, servers, storage, applications, and services)
  that can be rapidly provisioned and released with minimal management
  effort or service provider interaction.
])

In a nutshell informally it is basically 3-4 (Amazon web services, Google cloud, Microsoft azure, Oracle cloud 🤮) big companies having to much compute resources and making a business out of sharing it while providing additional added value.

For our sakes cloud computing has the following characteristics:
1. Resource pooling: computing resources serve multiple consumers
2. Broad network access: accessible via standard protocols
3. On-demand self-service: automatic provisionment of resources
4. Rapid elasticity: resources can be scaled to demand quickly
5. Measured service: automatic control & optimization of resources via metering capability

Most of the time they operate on a "Pay as much as used" basis and abstract away the underlying infrastructure. For example, you create virtual networks the servers communicate over, regardless whether they are in the same server rack, data-center or country.

Services provided by cloud providers can be in different categories, depending on how much the provider "does for you".

#let stackvis(
  stacks,
  highlight: -1,
) = {
  stack(
    spacing: 1pt,
    for (i, value) in stacks.enumerate() {
      if (type(highlight) == array and i in highlight) or i == highlight {
        box(
          fill: highlight_color,
          inset: 4pt,
          width: 100%,
          radius: 5pt,
          text(size: 10pt, fill: highlight_color_text, value),
        )
      } else {
        box(
          fill: rgb(55, 55, 55),
          inset: 4pt,
          width: 100%,
          radius: 5pt,
          text(size: 10pt, fill: luma(255), value),
        )
      }
    },
  )
}

#let stacks = (
  [Applications],
  [Runtimes],
  [Security &\ Integration],
  [Databases],
  [Operating \ System],
  [Virtualization],
  [Server HW],
  [Storage],
  [Networking],
)

#block(
  breakable: false,
  grid(
    columns: (1fr, 1fr, 1fr, 1fr),
    column-gutter: .5em,
    [
      *Private / \ On-Premise*
      #stackvis(stacks, highlight: range(9))
    ],
    [
      *Infrastructure as \ a Service (IaaS)*
      #stackvis(stacks, highlight: range(-1, 5))
    ],
    [
      *Platform as \ a Service (PaaS)*
      #stackvis(stacks, highlight: -1)
    ],
    [
      *Software as \ a Service (SaaS)*
      #stackvis(stacks)
    ],
  ),
)

#grid(
  columns: (1fr, 1fr),
  column-gutter: .5em,
  box(
    fill: highlight_color,
    inset: 4pt,
    width: 100%,
    radius: 5pt,
    text(size: 10pt, fill: highlight_color_text, [Your problem]),
  ),
  box(
    fill: rgb(55, 55, 55),
    inset: 4pt,
    width: 100%,
    radius: 5pt,
    text(size: 10pt, fill: luma(255), [Cloud providers problem]),
  ),
)

Now we do a quick sidetrack exploration into data-center design of such cloud providers.
#let coreSwitchPat = tiling(size: (5pt, 5pt))[
  #place(line(
    start: (0%, 0%),
    end: (100%, 100%),
    stroke: stroke(thickness: .5pt),
  ))
  #place(line(
    start: (0%, 100%),
    end: (100%, 0%),
    stroke: stroke(thickness: .5pt),
  ))
]

#let coreSwitch(pos, name, showText: false) = {
  return node(
    pos,
    name: name,
    stroke: black,
    fill: coreSwitchPat,
    shape: fletcher.shapes.rect,
    inset: 0pt,
    width: 2em,
    height: 1.5em,
    if showText {
      rect(fill: white, text(size: 5pt, "Core Switch"), inset: 1pt)
    },
  )
}

#let aggrSwitchPat = tiling(size: (5pt, 5pt))[
  #place(line(
    start: (0%, 0%),
    end: (100%, 100%),
    stroke: stroke(thickness: .5pt),
  ))
]

#let aggrSwitch(pos, name, showText: false) = {
  return node(
    pos,
    name: name,
    stroke: black,
    fill: aggrSwitchPat,
    shape: fletcher.shapes.rect,
    inset: 0pt,
    width: if showText { 3em } else { 2em },
    height: 1.5em,
    if showText {
      rect(fill: white, text(size: 5pt, [Aggregation \ Switch]), inset: 1pt)
    },
  )
}

#let edgeSwitch(pos, name, showText: false) = {
  return node(
    pos,
    name: name,
    stroke: black,
    shape: fletcher.shapes.rect,
    width: 2em,
    height: 1.5em,
    if showText { text(size: 5pt, [Core Switch]) },
  )
}

#let serverRack(pos, name, showText: false) = {
  return node(
    pos,
    name: name,
    stroke: black,
    shape: fletcher.shapes.rect,
    width: 2em,
    height: 3em,
    corner-radius: 2pt,
    if showText { text(size: 5pt, [Server \ Rack]) },
  )
}

#grid(
  columns: (1fr, 1.5fr, 1fr),
  column-gutter: 1cm,
  [
    *Three-Tiered Design*

    The traditional topology with hierarchical classes of switches.

    #figure(
      caption: [Three-Tiered Datacenter Design],
      diagram(
        spacing: 5pt,
        node(
          (0, 0),
          name: <router>,
          stroke: black,
          shape: fletcher.shapes.cylinder,
          height: 2em,
          rect(fill: white, text(size: 5pt, [Border \ Router])),
        ),
        coreSwitch((-1, 1), <core0>, showText: true),
        edge(<router>),
        coreSwitch((1, 1), <core1>),
        edge(<router>),
        aggrSwitch((-1, 2), <aggr0>, showText: true),
        edge(<core0>),
        edge(<core1>),
        aggrSwitch((0, 2), <aggr1>),
        edge(<core0>),
        edge(<core1>),
        aggrSwitch((1, 2), <aggr2>),
        edge(<core0>),
        edge(<core1>),
        aggrSwitch((2, 2), <aggr3>),
        edge(<core0>),
        edge(<core1>),
        edgeSwitch((-1.5, 3), <edge0>, showText: true),
        edge(<aggr0>),
        edgeSwitch((-0.5, 3), <edge1>),
        edge(<aggr0>),
        node(
          (.25, 3),
          [...],
        ),
        edgeSwitch((1, 3), <edge2>),
        edge(<aggr3>),
        edgeSwitch((2, 3), <edge3>),
        edge(<aggr3>),
        serverRack((-1.5, 4), <server0>, showText: true),
        edge(<edge0>),
        serverRack((-0.5, 4), <server1>),
        edge(<edge1>),
        serverRack((1, 4), <server2>),
        edge(<edge2>),
        serverRack((2, 4), <server3>),
        edge(<edge3>),
      ),
    )
  ],
  [
    *Fat-Tree*

    Allow easy additions but can result in uneven traffic distribution.
    Fat-Tree is entirely determined by the port count $K in NN$ of the switches.

    $K=24 "ports" -> K^3/4 = 3456 "servers"$

    #figure(
      caption: [Fat-Tree Datacenter Design],

      diagram(
        spacing: 10pt,
        node(
          (0, 0),
          name: <router>,
          stroke: black,
          shape: fletcher.shapes.cylinder,
          height: 2em,
          rect(fill: white, text(size: 5pt, [Border \ Router])),
        ),
        coreSwitch((-1.5, 1), <core0>),
        edge(<router>),
        coreSwitch((-0.5, 1), <core1>),
        edge(<router>),
        coreSwitch((0.5, 1), <core2>),
        edge(<router>),
        coreSwitch((1.5, 1), <core3>),
        edge(<router>),

        aggrSwitch((-2, 2), <edge0>),
        edge(<core0>),
        edge(<core1>),
        edge(<core2>),
        edge(<core3>),
        aggrSwitch((-1, 2), <edge1>),
        edge(<core0>),
        edge(<core1>),
        edge(<core2>),
        edge(<core3>),
        edgeSwitch((-2, 3), <edge2>),
        edge(<edge0>),
        edge(<edge1>),
        edgeSwitch((-1, 3), <edge3>),
        edge(<edge0>),
        edge(<edge1>),
        node(
          outset: 5pt,
          enclose: (<edge0>, <edge3>),
          fill: black.lighten(90%),
          snap: -1,
        ),
        node(
          (0, 2),
          [...],
        ),
        aggrSwitch((2, 2), <edge4>),
        edge(<core0>),
        edge(<core1>),
        edge(<core2>),
        edge(<core3>),
        aggrSwitch((1, 2), <edge5>),
        edge(<core0>),
        edge(<core1>),
        edge(<core2>),
        edge(<core3>),
        edgeSwitch((2, 3), <edge6>),
        edge(<edge4>),
        edge(<edge5>),
        edgeSwitch((1, 3), <edge7>),
        edge(<edge4>),
        edge(<edge5>),
        node(
          outset: 5pt,
          enclose: (<edge4>, <edge7>),
          fill: black.lighten(90%),
          snap: -1,
        ),
        serverRack((-2.5, 4), <server0>),
        edge(<edge2>),
        serverRack((-1.5, 4), <server1>),
        edge(<edge2>),
        node(
          (0, 4),
          [...],
        ),
        serverRack((1.5, 4), <server2>),
        edge(<edge6>),
        serverRack((2.5, 4), <server3>),
        edge(<edge6>),
      ),
    )
  ],
  [
    *Jellyfish*

    Random connections between switches can result in more throughput for less switches.
    There is not really an aggregation or core switch anymore, or any structure.

    #let inner_ring = 12mm
    #let switches = 8
    #let calc_peer_pos(peer) = {
      let theta = (peer / switches) * 360deg
      let x = inner_ring * calc.sin(theta)
      let y = inner_ring * calc.cos(theta)
      return (x, y - 6em)
    }
    #figure(
      caption: [Jellyfish Datacenter Design],

      diagram(
        node(
          (0mm, 0mm),
          name: <router>,
          stroke: black,
          shape: fletcher.shapes.cylinder,
          height: 2em,
          rect(fill: white, text(size: 5pt, [Border \ Router])),
        ),
        node((0mm, -10em), name: <origin>),
        let pos = calc_peer_pos(0),
        coreSwitch(pos, <edge0>),
        let pos = calc_peer_pos(1),
        edgeSwitch(pos, <edge1>),
        let pos = calc_peer_pos(2),
        edgeSwitch(pos, <edge2>),
        let pos = calc_peer_pos(3),
        edgeSwitch(pos, <edge3>),
        let pos = calc_peer_pos(4),
        aggrSwitch(pos, <edge4>),
        let pos = calc_peer_pos(5),
        edgeSwitch(pos, <edge5>),
        let pos = calc_peer_pos(6),
        edgeSwitch(pos, <edge6>),
        let pos = calc_peer_pos(7),
        aggrSwitch(pos, <edge7>),
        edge(<edge0>, <router>),
        edge(<edge0>, <edge7>, bend: 45deg),
        edge(<edge0>, <edge4>),
        edge(<edge3>, <edge6>),
        edge(<edge4>, <edge2>, bend: 25deg),
        edge(<edge6>, <edge7>, bend: -45deg),
        edge(<edge5>, <edge0>, bend: -15deg),

        serverRack((-15mm, -12em), <server0>),
        edge(<edge5>),
        serverRack((-6mm, -12em), <server1>),
        edge(<edge5>),
        serverRack((12mm, -12em), <server2>),
        edge(<edge3>),
        serverRack((3mm, -12em), <server3>),
        edge(<edge3>),
      ),
    )

  ],
)

Now with the data-center designed we can build application that runs on it.
We will see Cassandra as a distributed Database & Map-Reduce for massive distributed computation that can take advantage of the cloud by scaling-out.

#defiBox(title: "Scalability Approaches", [
  1. Scale-Up: Better server to handle more traffic
  2. Scale-Out: More servers to handle more traffic
])

== Cassandra

#theoBox(title: "CAP Theorem (Eric Brewer)", [
  In a distributed system you can only satisfy at most two of the following three properties:
  1. Consistency: all nodes have the same data at any time
  2. Availability: the system is operational at any time
  3. Partition-tolerance: the system continues to operate in spite of network partitions
])

Regular DBMS such as Postgres usually provide strong consistency but are not available when the network partitions.
Cassandra and many such Databases on the other hand only provide a eventual (weak) consistency but high availability i.e. you will not necessarily receive the newest data but always some.

For this, Cassandra again uses a DHT, a so called Cassandra ring and again each instance in the ring is responsible for a part of the address space. However, we store the data at $N-1$ additional nodes to have configurable $N in NN$ replicas of the data.
The biggest difference between this setup and Chord, is that Cassandra is managed by someone and all Cassandra nodes know each other. As such there is no need for the finger routing technique and any onboarding, offboarding logic. Nodes are added and removed manually and they gossip memberships between each other.

Now to receive a data item we can require a certain level of consistency $R in NN$ and send our request to *any* node in the cluster. Since each nodes knows all others, our requested node will ask the coordinator of the data + some replica nodes *directly*. Now the node waits for $R$ nodes to reply to it and then reply to us the conflict resolved data. Regardless of $R$ the results may be outdated and after replying the requested node will wait for all responses and then initiate a _read repair_.

Writing is very similar, with addition of a _hinted handoff_ incase nodes are unavailable, then further nodes are temporarily used.

Cassandra uses a _bloom filter_ for a fast key exists lookup *in* each instance.
Take $k in NN$ hash functions $h_0, ..., h_k$ each producing outputs of $b in NN$ bits and create a bitmap of size $m := 2^b$.
For example $h_0(x) := (2x + 1) mod 12$ and $h_1(x) := (3x + 2) mod 12$.
If we write a new item $9$ into the bloom filter we set bits $h_0(9) = 7$ and $h_1(9) = 5$ of the bitmap to $1$ and leave the rest as before.
If we want to check if item $5$ is present we read bits $h_0(5) = 11$ and $h_1(5) = 5$. While bit $5$ is set to $1$ in our example, bit $11$ is not and therefore we can be sure, that $5$ is not stored.
The probability of a false positives are $approx (1 - e^((k n)/m))^k$ with $n in NN$ being the number of items stored. An optimal $k$ would be $k = ln 2 dot m/n$.

== Map-Reduce

#theoBox(title: "Amdahls formular", [
  The speedup $S$ of a program of which a portion $0 <= p <= 1$ can be parallelized by $n in NN$ cores is bounded by
  $ S = 1/((1-p)+p/n) $
])

Map-Reduce is a originally google system for massive (20 exabyte/day) computation. The processing is divided into a
1. Map phase: computing an intermediate solution
$ "map"(k_"in", v_"in") -> "List"[<k_"out", v_"intermediate">] $

2. Reduce phase: collecting and combining solution grouped by $k_"out"$
$ "reduce"(k_"out", "List"[v_"intermediate"]) -> "List"[v_"out"] $

It's easy to see that this provides a great parallelization groundwork since in each stage everything is independent and thus scaleable.

MapReduce chunks the to be processed data into _Mappers_ then a _Partitioner_ collects the results and partitions reducer tasks/nodes to produce the final output. In high-performance computation ahmdahls law is only theoretically applicable, because there is much overhead on network communication and data distribution. Communication is limited since each Mapper is isolated from the rest of the system and does not need to communicate other than start and completion.
Data should be distribution equally to the _Mappers_, but that does not necessarily mean each Mapper task takes the same time. For this MapReduce adopts a _Job Tracker_ (Master), _Task Tracker_ (Worker) approach with each worker pulling work from the master when finished.
For map tasks that take exceptionally long we can implement speculative execution where multiple workers receive the same input and the first wins.
The reducers can for example be somewhat equally divided via the usual hash method.
An example of MapReduce can seen in @fig:mapreduce.

#figure(
  caption: [MapReduce Pipeline Example],
  diagram(
    spacing: 10pt,
    node(
      (0, 2),
      name: <input>,
      stroke: black,
      shape: fletcher.shapes.cylinder,
      height: 2em,
      rect(fill: white, text(size: 5pt, [Input])),
    ),

    node(
      (1, 1),
      text(size: 8pt, [Mapper 1: $"map" cases(
          "<apache, 7>",
          "<class, 8>",
          "<track, 6>",
        )$]),
      name: <mapper1>,
      fill: black.lighten(90%),
      corner-radius: 5pt,
      width: 10em,
    ),
    edge(<input>),
    node(
      (1, 2),
      text(size: 8pt, [Mapper 2: $"map" cases(
          "<hadoop, 10>",
          "<class, 10>",
          "<track, 16>",
        )$]),
      name: <mapper2>,
      fill: black.lighten(90%),
      corner-radius: 5pt,
      width: 10em,
    ),
    edge(<input>),
    node(
      (1, 3),
      text(size: 8pt, [Mapper 3: $"map" cases(
          "<apache, 15>",
          "<hadoop, 10>",
        )$]),
      name: <mapper3>,
      fill: black.lighten(90%),
      corner-radius: 5pt,
      width: 10em,
    ),
    edge(<input>),
    node(
      (2, 1),
      name: <reducer1>,
      text(size: 8pt, [Reducer 1: \<apache, (7,15)\>]),
      fill: blue.lighten(90%),
      corner-radius: 5pt,
      width: 12em,
    ),
    edge(<mapper1>, stroke: blue),
    edge(<mapper3>, stroke: blue),
    node(
      (2, 1.7),
      name: <reducer2>,
      text(size: 8pt, [Reducer 2: \<hadoop, (10,10)\>]),
      fill: green.lighten(90%),
      corner-radius: 5pt,
      width: 12em,
    ),
    edge(<mapper2>, stroke: green),
    edge(<mapper3>, stroke: green),
    node(
      (2, 2.25),
      name: <reducer3>,
      text(size: 8pt, [Reducer 3: \<class, (8,10)\>]),
      fill: yellow.lighten(90%),
      corner-radius: 5pt,
      width: 12em,
    ),
    edge(<mapper1>, stroke: yellow),
    edge(<mapper2>, stroke: yellow),
    node(
      (2, 3),
      name: <reducer4>,
      text(size: 8pt, [Reducer 4: \<track, (6,16)\>]),
      fill: red.lighten(90%),
      corner-radius: 5pt,
      width: 12em,
    ),
    edge(<mapper1>, stroke: red),
    edge(<mapper2>, stroke: red),
    node(
      (3, 2),
      text(size: 8pt, [
        Results: \
        \<apache, 22\>\
        \<hadoop, 20\>\
        \<class, 18\>\
        \<track, 22\>
      ]),
      fill: black.lighten(90%),
      corner-radius: 5pt,
      width: 7em,
    ),
    edge(<reducer1>),
    edge(<reducer2>),
    edge(<reducer3>),
    edge(<reducer4>),
  ),
)<fig:mapreduce>

#pagebreak()

= Resource-Constrained Systems & Cyberphysical Systems <chapter:iot>

Since the invention and spread of the internet there is this idea of interconnected everything. This idea is conceptualized into the Internet of Things (IoT) where devices/microcontrollers in "things" are connected to the network. A cyberphysical system is a digital chip i.e. a microcontroller that has influence in the "real" world either by sensors (allowing measurements) and/or by actuators (motors, mosfets, etc.) that allows control over things.

== Energy Consumption

The chips in these IoT devices vary widely between purposes, price, and other factors. But most of them are severely resource constrained.
Either they have little processing power or run on battery power and need to last as long as possible.
The lecture example here are "smart" fire detectors which you do not want to charge too often.

The energy consumption depends in most cases on the following things in order
1. Sending wireless transmissions
  ---

2. Receiving wireless transmissions
  ---

3. CPU computation
  ---

4. RAM
  ---

5. Storage
  ---
  Depends on the type of Storage high speed SSDs can consume up to 10W, HDDs as well, both during full operation. The types of devices we are talking about likeliest only have tiny flash storage inside them.

6. Physical systems
  ---
  This of course heavily depends on the device. A 1 Hz laser smoke detection costs basically no power. Powering a motor does though.


#todo(
  title: "Unfinished Work",
  [
    This Panikzettel is only half finished if I find time again I may continue it.
    Otherwise it is to much work to not upload it anyway.

    If you have some time or want to give others a better time learning, continue it 
    and publish it on #link("https://github.com/htwr-aachen/panikzettel", `https://github.com/htwr-aachen/panikzettel`).

    Even sketches, corrections and bullet points help others!
  ]
)


== In-Network Processing

== Multi-Hop Networks

This chapter is covered in the MIT lecture and it's Panikzettel (#link("https://htwr-aachen.de/panikzettel/mit.pdf")) and not further summarized here.

== IoT

= Adaptive Communication <chapter:adaptive>
