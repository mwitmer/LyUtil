\version "2.16.0"
#(define score-paper-size "letter")
#(define part-paper-size "letter")

\include "ly-score.ly"
\include "ly-score-time-sig.ly"

#(ly-score:process "sample"
  '()
  '()
  '(("sample" ()))
  '(Parallel
    "Violins"
     time-sig
     (violin . 1)
     (violin . 2))
#:include-score? #t
#:score-layout #{ \layout { 
  \timeSigLayout 
  \context {
    \Score
    \accepts TimeSig
  }
} #}
#:part-layout #{ \layout { \timeSigLayout } #})