\version "2.16.0"

timeSigLayout = \layout {
  \context {
    \name TimeSig
    \type "Engraver_group"
    \consists "Time_signature_engraver"
    \consists "Axis_group_engraver"
    \override TimeSignature #'style = #'numbered
    \override TimeSignature #'break-align-symbol = ##f
    \override TimeSignature #'font-size = #4
    \override TimeSignature #'X-offset = #ly:self-alignment-interface::x-aligned-on-self
    \override TimeSignature #'self-alignment-X = #CENTER
    \override TimeSignature #'after-line-breaking = #shift-right-at-line-begin
    \alias Staff
  }
}

#(define (time-sig-creator instrument folder number transpose? is-full-score?)
   #{ \new TimeSig \keepWithTag #'score $(ly-score:include folder "time_signature") #})

\addCustomInstrumentDefinition #"time-sig" #'() #`((staff-generator . ,time-sig-creator) (skip-part? . #t))
