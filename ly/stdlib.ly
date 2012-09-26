\version "2.16.0"

cvr = { \voiceTwo \change Staff = "piano-right" }
cvl = { \voiceOne \change Staff = "piano-left" }
csr = { \stemDown \change Staff = "piano-right" }
csl = { \stemUp \change Staff = "piano-left" }

showRest = #(define-music-function (parser location duration) (ly:duration?)
       (make-simultaneous-music 
	(list 
	 (multi-measure-rest parser location 
	  (ly:duration-length duration) '())
	 #{ \once \override Rest #'transparent = ##t
	 $(make-music 'RestEvent 'duration duration) #})))



tempoAdjust = \once \override Score.MetronomeMark #'X-offset = #-3.5
tempoHidden = \once \override Score.MetronomeMark #'transparent = ##t
hideNoteHead = \override NoteHead #'transparent = ##t
dynamicSpanText = #(define-music-function (parser location content) (markup?) #{
  \once \override DynamicTextSpanner #'(bound-details left text) = $content 
#})
spanText = #(define-music-function (parser location content) (markup?) #{
  \once \override TextSpanner #'(bound-details left text) = $content 
#})
spanEndText = #(define-music-function (parser location content) (markup?) #{
  \once \override TextSpanner #'(bound-details right text) = $content 
#})
hairpinToBarline = \once \override Hairpin #'to-barline = ##f
#(define-markup-command (sit layout props text) (markup?) (interpret-markup layout props (markup #:italic #:small #:whiteout text)))
#(define-markup-command (it layout props text) (markup?) (interpret-markup layout props (markup #:italic #:whiteout text)))
#(define-markup-command (wobox layout props text) (markup?) (interpret-markup layout props (markup #:box #:whiteout text)))

stemLengths = 
#(define-music-function (parser location lengths) (list?)
  #{ \once \override Stem #'(details beamed-lengths) = $lengths #})

#(define set-paper-staff-size (lambda (pap sz)
  (let ((new-scope (ly:output-def-scope pap)))
    (layout-set-absolute-staff-size-in-module new-scope
      (* sz (eval 'pt new-scope))))))

#(define set-color (lambda (color)
                     #{
                     #}))
