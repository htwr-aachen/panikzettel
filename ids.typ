#import "conf.typ": algoBox, colorbox, conf, defiBox, sidenote, theoBox

#show: conf.with(
  title: "Industrial Data Security",
  shortTitle: "IDS",
  authors: (
    (name: "Adrian Groh"),
    (name: "Jonas Schneider"),
  ),
  lang: "en",
  filename: "ids",
  showOutline: true,
)

= Introduction

This Panikzettel is about the new lecture "Industrial Data Security".

This Panikzettel is open source at #link("https://github.com/htwr-aachen/panikzettel", `https://github.com/htwr-aachen/panikzettel`). We welcome comments and suggestions for improvement (also from official sources).

It is often difficult to determine the exact focus of the lecture and the exams, but with this new subject especially since no exams or the like are known yet.
However, we will still focus on important content from the lecture, that was asked, or could be reasonably asked by the exercises.

Primary expectations from reader are content from the mandatory IT-Security lecture, such as the CIA (Confidentiality, Integrity, Availability) Principles, the different attacks on those principles and a basic understanding of the cryptographic building blocks. As with all panikzettels, not everything is covered.

= Industrial Data (ID)

Industrial data cannot be classified into one category, format, or source. Any information / data in an industrial context could be described as _industrial data_ such as:
- Sensor data
- Operational data
- Maintenance data
- Production data
- Supply chain data
- ...

This data is produced by various sources at various stages in a company.
At first data needed to be manually collected (with all the drawbacks of human time, speed and errors), but now only advanced digital acquisition can handle the large volume of data.
For manufacturing industries data is often produced along the products lifecycle as shown in @product_lifecycle. Overarching data (Financials, Product lifecycle data and others) are not listed there, as well as industries outside manufacturing ones.

#figure(
  image("img/ids/product_lifecycle.jpg", width: 50%),
  caption: [
    Product Lifecycle
  ],
)<product_lifecycle>

== IoT sensors:
- large number of wireless sensors, can be placed everywhere
- more data
  - needs to be managed through sampling, compression and edge computing
  - extract insights using statistical and time-series analysis and machine learning

#colorbox(title: [But why is data needed in the first place?], [
  Data can be useful in many scenarios but it is mostly used for *informed decision making*
  - predictive maintenance
  - quality control
  - optimizations
  - innovation
])


== Data Types
To make any analysis of the data possible, we need to classify some form of structures the data can in.

- structured
  - categorial (fixed number of distinct values)
    - nominal (no ordering, e.g. binary)
    - ordinal (values have meaningful order, e.g. high/medium/low)
  - numerical (measurable quantities, mean, mode, variance .. can be computed)
    - discrete (can be counted, e.g. number of production steps)
    - continuous
      - interval (scale of equal sized units with quantifiable difference between units, e.g. temperature, coordinates)
      - ratio (e.g. three times as hot, four times as fast, scale ends at 0)
- unstructured (e.g. image, text)

Even the unstructured examples, share some structure and they would be more fittingly be classified as semi-structured. For the exam take the position, that unstructured is *really* unstructured, you cannot do any word count, any statistics, nothing on unstructured data. For this you would need to do _feature-extraction_ first.

#defiBox(title: [Data Representation], [
  We represent multiple data points (some information) as a _record_. For example, a sensor data measurement + some metadata, which are then grouped into a _dataset_.
  For this there are multiple dataset structures:
  + Set (*most basic*, unordered and treated as a unit)
  + Hierarchies
  + Graphs
  + Arrays / Grid
  + Tables (can be labeled with target and the rest descriptive features)
])

Possible statistics can be different, depending on the datatype, but generally help summarize the data and provide early insights.
#grid(
  columns: (1fr, 1fr),
  gutter: 2em,
  [
    === Categorical Data

    - Count: total number of instances
    - Cardinality: number of unique values
    - Mode: value that appears most frequently
    - Frequency distribution: share of each value as fraction of 1
  ],
  [
    === Numerical Data

    - Min/Max
    - Mean
    - Variance
    - Standard deviation
  ],
)

Data, or rather data streams can have multiple properties, that are needed to know in order to correctly size the data ingestation and processing capabilities. The lecture describes them as the "Vs".

#grid(
  columns: (1fr, 1fr, 1fr),
  rows: (65pt, 72pt, 70pt),
  gutter: 0.5em,
  grid.cell(block(
    height: 100%,
    width: 100%,
    fill: luma(220),
    radius: 3pt,
    inset: 5pt,
    [
      *volume*

      quantity of generated and stored data
    ],
  )),
  grid.cell(block(
    height: 100%,
    width: 100%,
    fill: luma(220),
    radius: 3pt,
    inset: 5pt,
    [
      *velocity*

      speed at which data is generated and processed ],
  )),
  grid.cell(block(
    height: 100%,
    width: 100%,
    fill: luma(220),
    radius: 3pt,
    inset: 5pt,
    [
      *variety*

      type of the data, (structured or unstructured)
    ],
  )),
  grid.cell(block(
    height: 100%,
    width: 100%,
    fill: luma(220),
    radius: 3pt,
    inset: 5pt,
    breakable: false,
    [
      *value*

      benefits and insights derived from collection, processing and analyzing],
  )),
  grid.cell(block(
    height: 100%,
    width: 100%,
    fill: luma(220),
    radius: 3pt,
    inset: 5pt,
    [
      *veracity*

      trustworthiness, accuracy, and reliability],
  )),
  grid.cell(block(
    height: 100%,
    width: 100%,
    fill: luma(220),
    radius: 3pt,
    inset: 5pt,
    [
      *visualization*

      understanding, analysis and decision making],
  )),
  grid.cell(colspan: 3, block(
    height: 100%,
    width: 100%,
    fill: luma(220),
    radius: 3pt,
    inset: 5pt,
    breakable: false,
    [
      *variability*

      Changing of formats, structures, and sources.

      The difference to *variety* should be explainable.
    ],
  )),
)

== Process, Management & Harmonization
The Process of collecting and analyzing data is described by the lecture with:
#block(
  breakable: false,
  grid(
    columns: (1fr, 1fr),
    gutter: 1.5em,
    [
      1. Acquisition: collect data to prepare for analysis
      2. Warehousing: storing data
      3. Mining: extract meaningful data from unstructured data
      4. Cleansing: identify and correct errors
      5. Aggregation: collect and summarize data from multiple sources
    ],
    [
      6. Integration: combine data from different sources
      7. Analysis: inspect data to discover useful information
      8. Modeling: creates mathematical representations of real-world processes
      9. Interpretation: interpret the findings of data analysis and modeling
    ],
  ),
)

After data acquisition, the data has to be managed. Here regulatory things also come into consideration.
First and foremost, _privacy_ when data covers sensitive information (more on this later) but also _security_ to protect data. Of course privacy needs - or overlaps with - security in the areas of _personal identifying information_ (PII). Other consideration in terms of data management are:

- data governance: usability and quality of protected data
- data and information sharing: enhances collaboration
- cost/operational expenditures: cover all expenses for managing, storing, processing and analyzing data
- data ownership: right to control, manage and make decisions regarding pieces of ID

=== Harmonizing Industrial Data
Now the lecture takes a swing into a different direction. Harmonization considers the interoperability of data sources / consumers. The lectures prime example are CAD file formats. Where at the beginning of computer design, each CAD program would have its own proprietary file format. If another program wanted open another's, a translator would be needed. To facilitate a complete exchange $(n*(n-1))/2$ translator are needed.

#sidenote(
  title: [Not really],
  [Since we could have $P_1 -> P_2 -> P_3$ without needing translator $P_1 -> P_3$.

    (The features sets of the programs are not equal, i.e. not always possible)],
)

The solution is a standard data exchange format, that can be used as a "neutral interface".
The following are two example of such _harmonization frameworks_, now in the context of industrial data of sensors and product lifecycles.

1. Standard for the Exchange of Product Model Data (STEP) is a mechanism that can describe product data throughout the life cycle of a product, independent from any particular system using a formal model for data exchange (using EXPRESS language).
  The architecture is shown in @step_architecture.


2. OPC Unified Architecture (OPC UA) unifies data exchange from various data sources (Mostly OT, i.e. sensors, PLCs, ...) in an open source, cross platform and extensible way.
  The data model is a hirachical address space, where semantics of the data can be added as attributes "under" the value.
  A visualization is shown in @opc_ua_architecture and @opc_ua_address_space.


#grid(
  columns: (1fr, 1fr, 1fr),
  gutter: 1em,
  [#figure(
    placement: auto,
    image(
      "img/ids/step_architecture.png",
    ),
    caption: [STEP Architecture],
  )<step_architecture>],
  [#figure(
    placement: auto,
    image(
      "img/ids/opc_ua.png",
    ),
    caption: [OPC Unified Architecture],
  )<opc_ua_architecture>],
  [#figure(
    placement: auto,
    image(
      width: 70%,
      "img/ids/opc_ua_address_space.png",
    ),
    caption: [OPC UA Address Space],
  )<opc_ua_address_space>],
)

To communicate data with others two primary schemes have been presented
_Data sharing_ along the supply chain makes *specific* data available to the next company in the supply chain.
Whereas _data spaces_ are a group of companies allowing *most* data to be *discoverable and open*. Data ownership and management in data spaces are still at the original owner. As an example the European Product Passport, a product contains only the ID of how to find it in the data space. The data is stored at the company.

= Security Considerations

#text(size: 8pt, [| _This will deviate a bit from the lecturing order_])

At first an explanation on the challenges of securing industrial data. PII Data obviously needs privacy.
The management topics of ownership and provenance (trackable through its lifecycle) are also somewhat security related.
But because of the large scale systems at play, we must secure data across security domains (cross domain security) and in dynamic environments.
Furthermore, we need a fine grained access management where each item must have its own security policy. Because this all is challenging we need to plan this out in a _security plan_.
The complete state, our requirements, blueprints for further enhancements and their timetable and accountability should all be described.
A security plan should be:

- correctness (requirement understandable?)
- consistency (any conflicts?)
- completeness (all possible situations addressed?)
- realism (possible to implement?)
- need (requirements unnecessarily restrictive?)
- verifiability (tests that requirements have been met?)
- traceability (easy re-evaluation for changed requirements?)

In addition a risk assessment - a theoretical overview of sensitive parts of the company - should be done.

+ Identify assets
+ Determine vulnerabilities
+ Estimate likelihood of exploitation
+ Compute expected loss
+ Survey and select new controls
+ Project costs and savings

In the event of a disaster (natural or human) a good recovery plan helps the company to resume normal operations faster if trained. The key metrics are the _Recovery Time Objective_ (RTO) and _Recovery Point Objective_ (RPO), how long to resume normal ops and how far back must be restored to resume normal operations. Backups can be created local to facilitate faster recovery or offsite for more secure and need to be secured equally to the regular data.

Preparation may vary depending on the threat scenario. The three main ones are
+ Natural Disaster
+ Human Error
+ Attack
  + Random
  + Targeted

Harm is a realized threat.

== On data, privacy and security

#text(
  size: 8pt,
  [| _There is no good red line here to follow, if you find one, edit this_],
)

In general there are three states of data

+ Data in use:
  active data under constant change and the *most* difficult to secure since encryption is not possible

+ Data in motion: data that is traversing a network

+ Data at rest: inactive data stored in databases, files,...

Just again to hammer it in:

- Security refers to measures and protocols implemented to protect data from unauthorized access, breaches and cyber threats (confidentiality, integrity, availability)
- Privacy concerns the right of individuals to control their personal information and how it is collected, used and shared (collection, processing and dissemination of personal information)

The overlap is in: protection of (personal) information

Companies must try to protect data because of intrinsic (protect own valuable information, image, costs) and extrinsic objectives (comply with regulation).
Data can be under legal protection in case of
- Copyrights (protect expression of ideas)
- Patents (protect inventions)
- Trade secrets (must be kept secret or legal protections are lost) *most* desired for industrial data

But also data can also be a responsibility in case of General Data Protection Regulation (*GDPR*) which enforces core data protection principles. Regulations define legal boundaries without implementation, but can sometimes define standards as minimums. Standards are then the policies and procedures around the implementation.

== Cloud Computing

This whole topic overlaps with the lecture _Advanced Internet Technology_. There the benefits of cloud computing are better explained.
But security challenges of no transparency, no control over data, and no compliance are easy to see.

Casandra is also explained there, the only thing to add, is that because of the hashed node id, data placement is *not controllable* and thus each node has to comply with the security requirements.
However, a possibility is to add yet another layer of indirection and let trusted party determine where items must be stored and have the "insecure" representative node redirect to the target node, where the data can be stored.

#colorbox(
  bgColor: oklch(85%, 0.150, 30deg),
  strokeColor: oklch(50%, 0.150, 30deg),
  title: [Note however],
  [There is currently no panikzettel for AIT.],
)

== Security Approaches

The main security approaches are divided into software based (antivirus, ACM, encryption, ...), hardware based (biometric auth, smart cards, ...) and personal based (user training programs, ...). This lecture is predominantly about software based.

= Object Security

We will finally go on into the actual security measures, at first for objects, files, and specific filetypes.

A _file_ is a collection of related information stored together in a unit (mostly on a filesystem).
Whereas objects are self-contained units of data that encapsulates both the data itself and its metadata and are mostly stored in object storage systems.

We will limit ourselves to the sections on attribute-based encryption, XML, JSON, and a little bit of SenML.

In fine grained access control individual data records are split finer into individual fields. These are encrypted *one key for each field*, services which then need to interact with a set of fields receive then only the keys to exactly these fields.
This can even be made cryptographically secure when combining with attribute based encryption where entities have some attributes and there are policies which determine which set of attributes should allow access to which data items.
Two distinct variants, 1. The ciphertext-policy based, as the name suggests, stores the policies next to the ciphertext and the attributes, on the private key of the entity, 2. Key-Policy does the opposite. In both variants a trusted authority creates the policies, attributes and keys and therefore has complete control over the security.

== XML Security

XML is basic knowledge and not covered here. However, XML has no security considerations build in.
It is only possible to encrypt the whole file, which is not compatible with the fine grained access we need.
_XMLSig_ allows for cryptographically signing parts of the document, the variants are shown in @xml_signature.

#grid(
  columns: (2fr, 1fr),
  block(breakable: false, [
    ```xml
    <lectures>
      <lecture>
        <name>Industrial Network Security</name>
        <term>ws</term>
      </lecture>
      <lecture>
        <name>Industrial Data Security</name>
        <term>ss</term>
      </lecture>
    </lectures>
    ```
  ]),
  [
    The parts to sign are addressed via the XPath.

    For example, `//lecture/name` addresses all name elements

    `//lecture[term="ss"]/name` addresses "Industrial Data Security" one.

    (The `//` means everywhere. See #link("https://www.w3schools.com/xml/xpath_syntax.asp") for syntax)
  ],
)

The XML Signatures should compare the content of the parts not the formatting.
For this *before* creating a signature a canonical XML file is created for which one exact formatting is specified.

#figure(
  placement: auto,
  image("img/ids/xmlsig.png", width: 50%),
  caption: [XML Signature Variants],
)<xml_signature>

XML Encryption works similarly. It also houses Encryption Parameters in the `EncryptedData` element and can also be _enveloping_ or _detached_.

Key Management becomes more important, due to the amount of keys now at use. _XML Key Management Specification_ (XKMS) provides an interface to existing public key infrastructure but
in practice, XML Security struggles with its complexity

== JSON Security

JSON is similar to XML. However it has a standardized format (*NOT* canonical though), but less flexibility with the data types. For JSON security 4 _JOSE_ standard were described
- _JSON Web Signatures_ (JWS)
- _JSON Web Encryption_ (JWE)
- _JSON Web Key_ (JWK)
- _JSON Web Algorithms_ (JWA)

Again we need to do canonicalization before anything. This is even more complex than XML, since JSON is largely unordered. Thus, if asked *JSON* is more work to secure.
Then we define JSONPath. The two example from above would be `$.*.lecture.name` and `$.*.lecture[?(@.term== 'ss')].name`.

== SenML

SenML stands for _Sensor Measurement Lists_ which can include XML or JSON content. SenML supports fine grained symmetric encryption for individual fields (selected with JSONPath), but by always signs the *complete* data item.

== Others

Often time sensor data is send via a pub/sub communication scheme. Here Replay and Suppression are difficult to combat.
Possibilities include timestamps, counter or hashchain for replay, with a fixed transmission schedule for suppression possibly including a heartbeat message.

Key revocation and rotation (revocation scheme could be to just rotate keys) is a lot of work for limited IoT devices.
We can outsource some of it, by doubly encrypting our data, then let the cloud rotate the outer key.

= Database Security

Industrial data is very often stored in relational databases. Good security is important here

We need to satisfy several requirements most of them self-explanatory:
- *Physical* database integrity & *Availability*
- *Logical* database integrity & *Element* integrity verifies the records are accurate
- *Auditability*
- *User & Access Control*

We concentrate on the access control part. DBMS have several features which allow use to allow users only access to parts.

1. Views are virtual tables that represent the result set of a predefined query. They can be used to implement access control by hiding sensitive columns or rows from unauthorized users, presenting only a subset of the data. However, they offer only *limited isolation* and can introduce a *performance overhead* as the view's query must be executed.

2. These are precompiled sets of SQL statements stored in the database that can be executed as a single unit. By forcing users to interact with the data only through these well-defined interfaces, stored procedures can enforce complex business logic and security rules, preventing arbitrary or malicious queries.

3. The `GRANT` and `REVOKE` SQL commands are the foundation of database access control. They allow administrators to assign or remove specific privileges (like `SELECT`, `INSERT`, `UPDATE`, `DELETE`) on database objects like tables, views, and stored procedures to specific users or roles.

== Statistical Databases

If we only want aggregated / statistical information from our data. We can implement it via a statistical database. We can implement it with the help of views or only allowing aggregate functions. This allows us to do macro-statistics (about collections e.g. count) but only views allow micro-statistics (about individuals without PII).

== Encrypted Query Processing
The mechanisms above provide no protection against a malicious or breached database administrator who has direct access to the stored data.
When eavesdropping the database only data encryption can help. CryptDB tries to process SQL queries directly on this encrypted data.
It uses a trusted proxy that sits between the application and the database. This proxy intercepts queries, translates them to operate on encrypted data, and forwards them to the database.
Both app and database transparently work with each other.

The encryption schemes need to allow for certain operations to allow queries to be processed. The ones discussed are shown in @encryption_schemes.

#figure(
  placement: auto,
  image("img/ids/encryption_schemes.png", width: 60%),
  caption: [Encryption Schemes used in CryptDB],
)<encryption_schemes>

The challenge is that queries are often not known ahead of time. To solve this, CryptDB uses 3 *Onions of encryption* ([RND, DET, JOIN], [RND, OPE, OPE-JOIN], SEARCH or HOM) for each column.
The first two are type independent, the third is either homomorphic Encryption (HOM) in case of a numerical type or SEARCH in case of a string type.
Both are secure enough, such that they don't have an initial random AES encryption. The onions are layers of encryption, first a value would thus be JOIN encrypted then DET encrypted and finally RND encrypted, together with the other onions.

Once a column needs to for example to be used in a `GROUP BY`(DET) The RND layer is removed, never to return. The onions would thus be ([DET, JOIN], [RND, OPE, OPE-JOIN], SEARCH or HOM)
But when just allowing everything to be removed the whole system does not work. Thus, we define a privacy threshold that ensures not to many layers are removed (from differing onions).

== Privacy & Anonymity

Removing personally identifying information (PII) from a dataset is not enough to ensure anonymity, combination of other data can be used for identification of individuals.

- Singling: extract attributes that allow identification of one or more individuals
- Linkability: linking at least two records of a single stakeholder in dataset(s)
- Inference: deducing the value of an attribute from the values of a set of other attributes

We need to distinguish between key attributes (direct identification), quasi-identifiers (linkage), and sensitive attributes what makes the data useful.

== $k$, $p$, $l$, $t$-Anonymity

To ensure anonymity a dataset is $k$-anonymous if the information for each person in a dataset cannot be distinguished from at least $k-1$ individuals whose information also appears.

This can be achieved by replacing quasi-identifiers with less specific values and partitioning ordered-value domains into intervals.
If that causes too much information loss, instead use suppression (removing values, mostly outliers)

To protect against confidential attribute disclosure.
Make sure to have at least $p$ different sensitive values for each $k$-anonymous class.

Ensure that the sensitive attributes within each $k$-anonymous group are \"diverse\" (each equivalence class has at least $l$ _well-represented_ sensitive values)

For $t$-Anonymity quantify the amount of information leakage through data publication.
An equivalence class is said to have $t$-closeness if the distance between the distribution of sensitive attribute in this class and the distribution of the attribute in the whole table is $<= t$ (using earth mover distance)

== Differential Privacy
Even an adversary that knows all but one entry should not be able to determine if that entry was used for calculation or not.

setting:
- Database: composed of individual records
- Curator: aimed to protect individuals' privacy
- Analyst or data user: wishes to perform computations on the database

$ forall K, ("DB1", "DB2") (Pr[K|"DB1"])/(Pr[K|"DB2"]) < e^epsilon $
smaller $epsilon$ leads to better privacy protection

For a statistical function $f$ we need to know the sensitivity of $f$, named $Delta f$. Then we add $K = f("DB") + "Laplace"(delta)$ enough noise $lambda = Delta f / epsilon$ to the function, to ensure privacy.

= Machine Learning

Machine learning models are used to classify data into known categories. Machine Learning is used a lot in industries and can play an important role in the security of such.

Security wise, multiple attacks are possible. We can have _open box_ or _closed box_ attacks (whether the attacker knows the model parameters).

The most important considerations for machine learning models in industrial contexts is safety. Since when a self-driving car does not detect a stop sign: #quote([very bad things can happen. Many people say horrible things can happen]). This is also connected to security, since there are misclassification and unlearning attacks, that will be discussed later on.
Other considerations are fairness, ethics, accountability, explainability, and robustness as well as privacy of the training data and the model.

== Training Data Security & Privacy

We must ensure our training data is accurate and private.

The accuracy consideration stems from training data poisoning attacks. Where an attack can insert (or remove) training data to shift the models classifications. This can either be indiscriminative such that it tries to maximize the overall error. Or targeted to only misclassified a stop sign for example. A third option is a _backdoor_ attack, where for example only a stop sign with a predefined noise can be on demand misclassified.

To mitigate this training data sanitization with respect to outliers, model inspection and sanitization and trigger reconstruction must be used.

Another attack related to training data, is to identify if a model was trained with this data or not, this is called _membership inference_. Countermeasures are similar to the Request & Response section below.

What if we want to train a model with very private data for a lot of people?

For this federated learning is a possibility.
Multiple entities collaborate in solving a machine learning problem under the coordination of a central server or service provider.
Each clients locally trains a model only it's data. Then only the model is sent to the central server, which takes the average over all trained models. This can also be done cryptographically securely with a specialized Secure Multi Party Computation routine - if you know what that is.
The new model parameters are then redistributed to clients for further training round.

There are two variations

#grid(
  columns: (1fr, 1fr, 1fr),
  gutter: 1.5em,
  [
    === Cross Device
    - orchestration server only accesses a sample of clients each round
    - most clients participate once
    - bottleneck: communication
  ],
  [
    === Cross silo
    - clients participate in all rounds
    - clients maintain local state between rounds
    - bottleneck: communication or computation
  ],
  [
    === Peer-to-peer
    - no trusted central entity
    - no central state of model, peers send/receive updates and converge to the solution individually
  ],
)

== Model Privacy

Not only the training data can be private, but also the valuable model.

Models can be extracted, called _model stealing_ by prompting providers repeatedly.
For SVM, make enough requests to discover the decision boundary.
- high-fidelity: extracted model behaves similar to target model
- high-accuracy: extracted model performs task of target model very well

In general assuming a linear classifier with $d$ Dimensions, $d+1$ queries are enough to steal the model.
For neural networks this is more difficult, especially stealing high-fidelity, but high-accuracy easily possible.

Can be somewhat prevented using rate limiting.
Backdoors (intentionally misclassified datapoints) & Watermarks can be used to mark/detect ownership of a model.

== Request and Response Privacy

When overfitting a model on specific datapoints in the training data. It increases the risk of unententional memorization.
For this we again take to differential privacy.

For sensitive requests we can use homomorphic encryption, but this can be prohibitively computationally expensive.

The last section describes prompt-tuning, where general-purpose models are used for very specific tasks. This is done using prompt-tuning which induce the desired behavior to the model.
However, we can backdoor this as well for multiple tasks (_task agnostic_). Furthermore, task-specific trigger reconstruction does not work well. We can search for "exceptional behavior" mitigating this risk a bit.
