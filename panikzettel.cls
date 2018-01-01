% Additional warnings for deprecated things
\RequirePackage[l2tabu, orthodox]{nag}

\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{panikzettel}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Compact scrartcl format
\LoadClass[a4paper,parskip=half-,DIV=15,fontsize=11pt]{scrartcl}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Enable post-90s text processing
\usepackage[utf8]{inputenc}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Typesetting
\usepackage[english,ngerman]{babel}
\usepackage{microtype}
\usepackage{parskip}
\usepackage{microtype}
\usepackage{csquotes}
\usepackage{booktabs}

\usepackage{lmodern} % upgrade default font
\usepackage[sc]{mathpazo} % pretty font for text

\linespread{1.05} % more spacing
\setkomafont{disposition}{\fontseries{sbc}\sffamily}

\usepackage{enumitem}
\setlist{nosep}

\makeatletter
% Re-enable paragraph spacing in minipages;
% we choose something smaller than what is used outside of minipages.
\newcommand{\@minipagerestore}{\setlength{\parskip}{0.8\medskipamount}}
\makeatother

% More nested sections
\DeclareNewSectionCommand[
  style=section,
  counterwithin=subsubsection,
  font=\normalsize,
  afterskip=1.5ex plus .2ex,
  beforeskip=-3.25ex plus -1ex minus -.2ex,
  indent=0pt,
  level=4,
  tocstyle=section,
  toclevel=4,
  tocindent=10em,
  tocnumwidth=5em
]{subsubsubsection}
\setcounter{secnumdepth}{\subsubsubsectionnumdepth}
\setcounter{tocdepth}{\subsubsubsectiontocdepth}
\RedeclareSectionCommand[
  level=5,
  counterwithin=subsubsubsection,
  toclevel=5,
  tocindent=12em,
  tocnumwidth=6em
]{paragraph}
\RedeclareSectionCommand[
  level=6,
  toclevel=6,
  tocindent=14em,
  tocnumwidth=7em
]{subparagraph}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Utilities
\usepackage{lipsum}

\usepackage[svgnames]{xcolor}
% https://s3.amazonaws.com/edwardtufte.com/colorblind_palette.png
\definecolor{orange}{RGB}{230,159,0}
\definecolor{skyblue}{RGB}{86,180,233}
\definecolor{bluishgreen}{RGB}{0,158,115}
\definecolor{vermillion}{RGB}{213,94,0}
\definecolor{reddishpurple}{RGB}{204,121,167}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Math & Symbols
\usepackage{mathtools}
\usepackage{amssymb}
\usepackage{amsmath}
\usepackage{stmaryrd}
\usepackage{braket}
\usepackage{cool}

\DeclarePairedDelimiter\abs{\lvert}{\rvert}
\DeclarePairedDelimiter\floor{\lfloor}{\rfloor}

\DeclareMathOperator{\Exists}{\exists}
\DeclareMathOperator{\Forall}{\forall}

\newcommand{\natplus}{\mathbb{N}^+}
\newcommand{\nat}{\mathbb{N}}
\newcommand{\rnonneg}{\mathbb{R}^+_0}
\newcommand{\bigo}{\mathcal{O}}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Links and Metadata
\usepackage[
  colorlinks,
  citecolor = DarkGreen,
  linkcolor = DarkBlue,
  urlcolor = DarkGreen
]{hyperref}
\usepackage{bookmark}

\makeatletter
\AtBeginDocument{
  \hypersetup{
    pdftitle = {\@title},
    pdfauthor = {\@author}
  }
}
\makeatother

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Environments
\usepackage{todonotes}

% Just like the 'center' block, but without spacing around it.
\newenvironment{tightcenter}{%
  \setlength\topsep{0pt}
  \setlength\parskip{0pt}
  \begin{center}
}{%
  \end{center}
}

\usepackage{tcolorbox}

%%%%%%%%%%%%%%%%
% Context Blocks

\tcbset{boxrule=0pt,toprule=1pt,parbox=false,on line}

\newenvironment{algo}[1]{%
\setlist{nosep,leftmargin=*}%
\begin{tcolorbox}[colback=orange!5!white, colframe=orange!75!black, title={\sffamily Algorithmus: #1}]
}{%
\end{tcolorbox}}
\newenvironment{theo}[1]{%
\begin{tcolorbox}[colback=bluishgreen!5!white, colframe=bluishgreen!75!black, title={\sffamily Satz: #1}]
}{%
\end{tcolorbox}}
\newenvironment{defi}[1]{%
\begin{tcolorbox}[colback=skyblue!5!white, colframe=skyblue!75!black, title={\sffamily Definition: #1}]
}{%
\end{tcolorbox}}
\newenvironment{bonus}[1]{%
\begin{tcolorbox}[colback=reddishpurple!5!white, colframe=reddishpurple!75!black, title={\sffamily Bonus: #1}]
}{%
\end{tcolorbox}}

%%%%%%%%%%%%%%
% Split Blocks

\newenvironment{halfboxl}{%
\noindent
\begin{minipage}[t]{0.4875\textwidth}
%\vspace{0pt}
%\vspace{\dimexpr\ht\strutbox-\topskip}
}{%
\end{minipage}\hspace{0.025\textwidth}}
\newenvironment{halfboxr}{%
\begin{minipage}[t]{0.4875\textwidth}
\vspace{0pt}
}{%
\end{minipage}\bigbreak}

\newenvironment{thirdboxl}{%
\begin{minipage}[t]{0.3166\textwidth}
}{%
\end{minipage}\hspace{0.025\textwidth}}
\newenvironment{thirdboxm}{%
\begin{minipage}[t]{0.3166\textwidth}
}{%
\end{minipage}\hspace{0.025\textwidth}}
\newenvironment{thirdboxr}{%
\begin{minipage}[t]{0.3166\textwidth}
}{%
\end{minipage}\bigbreak}
