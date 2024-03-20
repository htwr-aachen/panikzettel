#let sansFont = "Latin Modern Sans"
#let conf(
  title: none,
  shortTitle: none,
  authors: (),
  lang: "de",
  filename: "",
  date: none,
  showOutline: true,
  doc,
) = {


  //-------- SETUP --------
  let versionFile = read(filename + ".last-change").split("\n")
  let version = versionFile.at(0)
  let dateString = if date != none {
    date.display("[day].[month].[year]")
  } else {
    versionFile.at(2)
  }

  set document(author: authors.map(auth => auth.name), title: str(title))
  set page(
    numbering: "1",
    header: locate(loc => if loc.page() != 1 [
      #set text(11pt)
      #smallcaps[#if (shortTitle == none) {title} else {shortTitle}]
      #h(1fr) #smallcaps[#dateString]
    ])
  )
  set text(size: 11pt, lang: lang, font: ("Latin Modern"), fallback: true)
  set par(leading: 0.65em, justify: true)
  set block(below: 1.05em)

  show link: it => [
    #text(fill: rgb("#013220"), underline(it))
  ]

  set list()  
  
  // ------ HEADER -------
  set align(center)

  stack(
    spacing: 1cm,
    text(font: "Latin Modern Mono", {
      link("https://panikzettel.htwr-aachen.de")[panikzettel.htwr-aachen.de]
    }),
    text(22pt, font: sansFont, hyphenate: false, strong([#title])),
    text(16pt, version + " | " + dateString),
    {
      let count = authors.len()
      let ncols = calc.min(count, 3)
  
      grid(
        columns: (1fr,) * ncols,
        row-gutter: 24pt,
        ..authors.map(author => [
          #author.name \
        ]),
      )
    }
  )
  
  // ------- Page content --------
  set align(left)

  if showOutline [
    #show outline.entry.where(level: 1): it => [
      #v(8pt)
      #it
    ]
    #show outline.entry.where(level: 2): it => [
      #v(6pt, weak: true) 
      #h(1em * it.level) #it
    ]

    #set text(font: "New Computer Modern", spacing: 105%)
    #outline(indent: 1em, depth: 2)
  ]

  // ------- PAGE setup ---------

  //The 
  set heading(numbering: "1.1")
  show heading: it => {
    set text(font: sansFont, weight: "semibold")
    if (it.level >= 3){
        block(above: 1.2em, below: 0.8em, it.body)
    } else {
        block(above: 1.2em, below: 1.05em, counter(heading).display() + " " + it.body)
    }
  }

  show par: set block(spacing: 1.25em)
  
  doc
}

#let colorbox(
  title: "title",
  bgColor: luma(220),
  strokeColor: luma(70),
  titleTextColor: luma(255),
  textColor: luma(0),
  radius: 3pt,
  width: 100%,
  breakable: false,
  body
) = {

  let titleCell = rect.with(
    inset: 8pt,
    fill: strokeColor,
    width: 100%,
    radius: (top: radius)
  )

  let contentCell = rect.with(
    inset: 8pt,
    fill: bgColor,
    radius: (bottom: radius),
    width: 100%,
  )
  
  return block(
    breakable: breakable,
    grid(
      columns: 1fr,
      rows: (auto, auto),
      titleCell(height: auto)[#text(font: sansFont ,fill: titleTextColor, weight: "semibold")[#title]],
      contentCell(height: auto)[ 
        #set text(textColor)
        #body
      ]
    )
  )
}

#let sidenote(
  title: "title",
  titleTextColor: luma(255),
  textColor: luma(0),
  radius: 3pt,
  width: 100%,
  prefix: "Sidenote: ",
  body) = {
    colorbox(
      title: prefix + title,
      bgColor: rgb(177, 177, 177, 75),
      strokeColor: rgb(55, 55, 55),
    )[#body]
}

#let algoBox(
  title: "title",
  titleTextColor: luma(255),
  textColor: luma(0),
  radius: 3pt,
  width: 100%,
  prefix: "Algorithmus: ",
  body) = {
    colorbox(
      title: prefix + title,
      bgColor: rgb(240, 200, 12, 75),
      strokeColor: rgb(184, 129, 2),
    )[#body]
}

#let theoBox(
  title: "title",
  titleTextColor: luma(255),
  textColor: luma(0),
  radius: 3pt,
  width: 100%,
  prefix: "Satz: ",
  body) = {
    colorbox(
      title: prefix + title,
      bgColor: rgb(40, 173, 23, 75),
      strokeColor: rgb(30, 128, 17),
    )[#body]
}

#let defiBox(
  title: "title",
  titleTextColor: luma(255),
  textColor: luma(0),
  radius: 3pt,
  width: 100%,
  prefix: "Definition: ",
  body) = {
    colorbox(
      title: prefix + title,
      bgColor: rgb(61, 88, 242, 75),
      strokeColor: rgb(9, 74, 143),
    )[#body]
}

#let ComplexityProblem = content => {
  set text(font: "New Computer Modern") 
  smallcaps(content)
}

#let ComplexityClass = content => {
  set text(font: "New Computer Modern Sans") 
  content
}

#let proof(
  title: "",
  body) = [
    _Proof_ #title: 
    #body
    #align(right)[$qed$]
]

#let posneg(
  titlePositive: "Positives (+)",
  titleNegative: "Negatives (-)",
  bodyPositive,
  bodyNegative,
  width: 100%,
  breakable: false
) = { 
  return block(
    radius: 3pt,
    width: width,
    clip: true,
    breakable: breakable,
    table(
      columns: 2,
      stroke: none,
      fill: (col, row) =>
        if row == 0 {
          if col == 0 {rgb(30, 128, 17)} else {
            rgb(200,22, 40)
          }
        } else {
          if col == 0 {rgb(40,173,23,75)} else {rgb(240,22,40,75)}
        },
      block(
        width: width / 2,
        inset: 4pt,
        text(font: sansFont, fill: white, weight: "semibold", [#titlePositive]),
      ),
      block(
        width: width / 2,
        inset: 4pt,
        text(font: sansFont, fill: white, weight: "semibold", [#titleNegative]),
      ),
      block(
        inset: 4pt,
        [#bodyPositive]),
      block(
        inset: 4pt,
        [#bodyNegative])
    )
  ) 
}
