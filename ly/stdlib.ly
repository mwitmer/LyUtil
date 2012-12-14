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

growBeamLeft= \override Beam #'grow-direction = #LEFT
growBeamRight= \override Beam #'grow-direction = #RIGHT
revertGrowBeam = \revert Beam #'grow-direction
tempoAdjust = \once \override Score.MetronomeMark #'X-offset = #-3.5
tempoHidden = \once \override Score.MetronomeMark #'transparent = ##t
hideNoteHead = \override NoteHead #'transparent = ##t
dynamicSpanText = #(define-music-function (parser location content) (markup?) #{
  \once \override DynamicTextSpanner #'(bound-details left text) = $content 
#})
spanText = #(define-music-function (parser location content) (markup?) #{
  \once \override TextSpanner #'(bound-details left-broken text) = " "
  \once \override TextSpanner #'(bound-details left text) = $content 
#})
spanEndText = #(define-music-function (parser location content) (markup?) #{
  \once \override TextSpanner #'(bound-details right-broken text) = " "
  \once \override TextSpanner #'(bound-details right text) = $content 
#})
hairpinToBarline = \once \override Hairpin #'to-barline = ##f
#(define-markup-command (sit layout props text) (markup?) (interpret-markup layout props (markup #:italic #:small #:whiteout text)))
#(define-markup-command (it layout props text) (markup?) (interpret-markup layout props (markup #:italic #:whiteout text)))
#(define-markup-command (wobox layout props text) (markup?) (interpret-markup layout props (markup #:box #:whiteout text)))

#(define-markup-command (draw-plus layout props width thickness) (number? number?) 
   (let ((half-width (exact->inexact (/ width 2))))
    (interpret-markup layout props (markup #:postscript (format #f
								"~s setlinewidth
newpath
~s 0.0 moveto
~s 0.0 lineto
stroke
0.0 ~s moveto
0.0 ~s lineto
stroke
" thickness (- half-width) half-width (- half-width) half-width)))))

stemLengths = 
#(define-music-function (parser location lengths) (list?)
  #{ \once \override Stem #'(details beamed-lengths) = $lengths #})

#(define set-paper-staff-size (lambda (pap sz)
  (let ((new-scope (ly:output-def-scope pap)))
    (layout-set-absolute-staff-size-in-module new-scope
      (* sz (eval 'pt new-scope))))))

bottomBarNumbers = #(define-music-function (parser location extra-y-offset) (number?) #{
		     \override Score.BarNumber #'break-visibility = #'#(#f #t #t)
		     \set Score.barNumberVisibility = #(lambda (a b) #t)
		     \set Score.barNumberFormatter = 
		     #(lambda (bar-number measure-position alternative-number extra)
		       (if (= 0 (ly:moment-main measure-position))
			(markup "")
			(markup #:fontsize 3 (number->string bar-number))))
		     \override Score.BarNumber #'self-alignment-X = #CENTER
		     \override Score.BarNumber #'direction = #DOWN
		     \override Score.BarNumber #'outside-staff-priority = ##f
		     \override Score.BarNumber #'extra-offset = $(cons 0 extra-y-offset)
		     #})

#(define (space duration)
  (make-music
   'SkipEvent
   'duration
   duration))

#(define (half-duration duration)
  (ly:make-duration 
   (+ 1 (ly:duration-log duration)) 
   (ly:duration-dot-count duration)
   (car (ly:duration-factor duration))
   (cdr (ly:duration-factor duration))))

bottomBarSpacer = #(define-music-function (parser location duration) (ly:duration?) #{
		    $(space (half-duration duration))
		    \once \override Score.BarLine #'allow-span-bar = ##f 
		    \once \override Score.BarLine #'transparent = ##t
		    \noBreak \bar "|" \noBreak 
		    $(space (half-duration duration)) #})

