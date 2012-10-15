\version "2.16.0"

\include "ly-score.ly"
\include "ly-score-instruments.ly"
\include "ly-score-time-sig.ly"

#(ly-score:process 
  "sample" 
  `((title "Sample"))
  `((title "Sample Part"))
  `(("parts" ()))
  '(StaffGroup "Main Score" 
    time-sig
    piano
    percussion
    (violin . "I")
    (violin . "II"))
  #:transpose? #f
  #:include-score? #t
  #:include-parts? #t
  #:score-layout #{ 
  \layout { 
    \timeSigLayout
    \context {
      \StaffGroup
      \accepts TimeSig
    }
} #})
