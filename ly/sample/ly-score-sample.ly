\version "2.16.0"
#(define score-paper-size "letter")
#(define part-paper-size "letter")

\include "ly-score.ly"

#(ly-score:process "sample"
  '()
  '()
  '((sample1 ()))
  '(Parallel
    "Violins"
     violin1
     violin2)
#:include-score? #t)