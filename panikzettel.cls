% Additional warnings for deprecated things
\RequirePackage[l2tabu, orthodox]{nag}

\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{panikzettel}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Optional 'english' language option
\newcommand{\InitPanikzettelLanguage}{\PassOptionsToPackage{english,ngerman}{babel}}
\DeclareOption{english}{\renewcommand{\InitPanikzettelLanguage}{\PassOptionsToPackage{english}{babel}}}
\ProcessOptions
\InitPanikzettelLanguage

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Compact scrartcl format
\LoadClass[a4paper,parskip=half-,DIV=15,fontsize=11pt]{scrartcl}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Enable post-90s text processing
\usepackage[utf8]{inputenc}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Typesetting
\usepackage{babel}
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
\usepackage{amsthm}
\usepackage{stmaryrd}
\usepackage{braket}
\usepackage{cool}

\DeclarePairedDelimiter\abs{\lvert}{\rvert}
\DeclarePairedDelimiter\norm{\lVert}{\rVert}
\DeclarePairedDelimiter\floor{\lfloor}{\rfloor}
\DeclarePairedDelimiter\ceil{\lceil}{\rceil}

\DeclareMathOperator{\Exists}{\exists}
\DeclareMathOperator{\Forall}{\forall}
\DeclareMathOperator*{\argmin}{argmin}
\DeclareMathOperator*{\argmax}{argmax}

\newcommand{\natplus}{\mathbb{N}^+}
\newcommand{\nat}{\mathbb{N}}
\newcommand{\rnonneg}{\mathbb{R}^+_0}
\newcommand{\reals}{\mathbb{R}}
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

\usepackage{iflang}
\newcommand{\PanikzettelAlgorithm}{\IfLanguageName{ngerman}{Algorithmus}{Algorithm}}
\newcommand{\PanikzettelTheorem}{\IfLanguageName{ngerman}{Satz}{Theorem}}

\tcbset{boxrule=0pt,toprule=1pt,parbox=false,on line}

\newenvironment{algo}[1]{%
\setlist{nosep,leftmargin=*}%
\begin{tcolorbox}[colback=orange!5!white, colframe=orange!75!black, title={\sffamily \PanikzettelAlgorithm: #1}]
}{%
\end{tcolorbox}}
\newenvironment{theo}[1]{%
\begin{tcolorbox}[colback=bluishgreen!5!white, colframe=bluishgreen!75!black, title={\sffamily \PanikzettelTheorem: #1}]
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
