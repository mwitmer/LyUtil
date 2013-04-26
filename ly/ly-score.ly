%%%% -*- Mode: Scheme -*-

\version "2.16.0"
\include "articulate.ly"

#(use-modules (ice-9 format))

#(define-markup-command (mainfont layout props text) (markup?) 
   (interpret-markup layout props (markup text)))

#(define-markup-command (secondaryfont layout props text) (markup?) 
n   (interpret-markup layout props (markup text)))

partBreak = \tag #'part {\pageBreak}
noPartBreak = \tag #'part {\noPageBreak}

#(define (set-paper-staff-size pap sz)
   (let ((new-scope (ly:output-def-scope pap)))
     (layout-set-absolute-staff-size-in-module 
      new-scope
      (* sz (eval 'pt new-scope)))))

#(define (ly-score:alist->module alist) 
   (let ((mod (make-module))) 
     (map (lambda (list-el) 
	    (module-define! mod (car list-el) (cadr list-el))) alist) 
     mod))

#(define ly-score:part-header (make-fluid))

#(define (ly-score:create-file key)
   (format #t "Creating missing file: ~a.\n" key)
   (let ((newfile (open-file key "w")))
     (display "" newfile)
     (close-port newfile)))

#(define (ly-score:include folder file)
   (if (ly:moment? folder)
       #{ \mark \markup Tacet  #}
       (let* ((key (format #f "~a/~a.ly" folder file)))
	 (begin (if (not (file-exists? key))
		    (ly-score:create-file key))
		(with-fluids ((current-folder folder)) 
		  #{ \include $key #})))))

#(define (ly-score:tacet-staff)
  #{
  \new Staff \with  { \remove "Staff_symbol_engraver" } {
    \override Staff.TimeSignature #'transparent = ##t
    \override Staff.InstrumentName #'transparent = ##t
    \override Staff.Clef #'transparent = ##t
    {s8^\markup \secondaryfont Tacet}
  }
  #})

#(define current-folder (make-fluid))

#(define* (ly-score:time-signature folder #:optional (is-full-score? #t)) 
  #{
  \new Staff \with { 
    \override VerticalAxisGroup #'remove-empty = ##t 
    \override VerticalAxisGroup #'remove-first = ##t 
  } 
  {
   $(if is-full-score? 
	#{ \keepWithTag #'score $(ly-score:include folder "time_signature") #}
	#{ \keepWithTag #'part $(ly-score:include folder "time_signature") #})
  }
#})

#(define* (get-music-from-file file-name folder is-full-score? #:optional number)
   (let* ((no-part-music 
	   (ly-score:include folder 
			     (format #f "~a~a" file-name (if number number "")))))
     (if is-full-score?  
	 #{ \keepWithTag #'score \killCues $no-part-music #} 
	 #{ \keepWithTag #'part $no-part-music #})))

#(define (format-instrument-with-number instrument number)
  (cond
   ((pair? number)
    #{ \markup \secondaryfont { $instrument $(format #f "~a~a~a~a" " " (car number) ", " (cdr number)) }  #}) 
   (number #{ \markup \secondaryfont { $instrument $(format #f "~a~a" " " number) }  #}) 
   (else #{ \markup \secondaryfont $instrument #})))

#(define* (create-with-clause instrument-definition #:optional number)
  (let ((basic-instrument-name (assq-ref instrument-definition 'instrumentName))
	(basic-short-instrument-name (assq-ref instrument-definition 'shortInstrumentName)))
   #{ \with {
        instrumentName = 
		       $(format-instrument-with-number basic-instrument-name number)
        shortInstrumentName = 
	$(format-instrument-with-number basic-short-instrument-name number)
        midiInstrument = $(assq-ref instrument-definition 'midiInstrument)
      } 
    #}))

#(define* (get-staff-name file-name #:optional number)
   (format #f "~a~a" file-name (if number number "")))

#(define (create-part prefix head instrument-def movements number paper layout) 
   (if (not (assq-ref instrument-def 'skip-part?))
       (let* ((key (assq-ref instrument-def 'key))
	      (key-with-number (format #f "~a~a" key (if number number "")))
	      (filename (format #f "~a-~a" prefix key-with-number))
	      (head-module (ly-score:alist->module head)))
	 (module-define! head-module 'instrument 
			 (format-instrument-with-number (assq-ref instrument-def 'instrumentName) number))
	 (with-fluids ((ly-score:part-header head-module))
	   (let* ((book #{ \book { \paper { $paper } } #} )
		  (scores 
		   (map (lambda (el)
			  (ly-score:make-score 
			   (car el) (cadr el) 
			   `(Parallel ,key-with-number ,(if number (cons key number) key)) #f #t layout #f))
			(reverse movements))))
	     (map (lambda (score) (ly:book-add-score! book score)) scores)
	     (ly:book-set-header! book (fluid-ref ly-score:part-header))
	     (ly:book-process book paper layout filename))))))

#(define* (staff-creator instrument-definition-or-name folder number transpose? is-full-score? 
			#:key no-with-clause? drum-staff? dynamic-staff?)
   (let* ((instrument-definition 
	   (if (list? instrument-definition-or-name) 
	       instrument-definition-or-name 
	       (assoc-ref custom-instrument-definitions (symbol->string instrument-definition-or-name))))
	  (file-name (assq-ref instrument-definition 'key))
	  (staff-name (get-staff-name file-name number))
	  (transposition (assq-ref instrument-definition 'instrumentTransposition))
	  (music (if (pair? number)
		     #{ \partcombine 
			$(get-music-from-file file-name folder is-full-score? (car number))
			$(get-music-from-file file-name folder is-full-score? (cdr number)) #}
		     (get-music-from-file file-name folder is-full-score? number))))
     (if (= (ly:moment-main-numerator (ly:music-length music)) 0) #{ #}
	 (let ((music (if dynamic-staff? music
			  #{
			    {
			     \clef $(if (and transpose? (assq-ref instrument-definition 'transposed-clef))
					(assq-ref instrument-definition 'transposed-clef)
					(assq-ref instrument-definition 'clef))
			     \compressFullBarRests 
			     $(if (and transpose? transposition)
				  (ly:music-transpose music transposition)
				  music)
			     } 
			    #})))
	   (cond
	    (drum-staff?
	     #{
	       \new DrumStaff = $staff-name \with { $(if (and is-full-score? (not no-with-clause?)) 
							 (create-with-clause instrument-definition number)) } 
	       $music
	       #}) 
	    (dynamic-staff? #{ \new Dynamics = $staff-name $music #})
	    (else #{
		    \new Staff = $staff-name \with { $(if (and is-full-score? (not no-with-clause?)) 
							  (create-with-clause instrument-definition number)) } $music
		    #}))))))

#(define (drum-staff-creator instrument-definition-or-name folder number transpose? is-full-score?)
   (staff-creator instrument-definition-or-name folder number transpose? is-full-score? #:drum-staff? #t))

#(define (piano-staff-creator instrument-definition-name folder number transpose? is-full-score?)
   (let* ((instrument-definition 
	   (assoc-ref custom-instrument-definitions (symbol->string instrument-definition-name)))
	  (left-definition (assq-ref instrument-definition 'left-definition))
	  (right-definition (assq-ref instrument-definition 'right-definition))
	  (dynamic-definition (assq-ref instrument-definition 'dynamic-definition))
	  (staff-name (get-staff-name (assq-ref instrument-definition 'key) number))
	  (left-staff 
	   (staff-creator left-definition folder number transpose? is-full-score? #:no-with-clause? #t))
	  (right-staff 
	   (staff-creator right-definition folder number transpose? is-full-score? #:no-with-clause? #t))
	  (dynamic-staff 
	   (staff-creator dynamic-definition folder number transpose? is-full-score? #:no-with-clause? #t #:dynamic-staff? #t)))

     (if (and
	  (= (ly:moment-main-numerator (ly:music-length right-staff)) 0)
	  (= (ly:moment-main-numerator (ly:music-length left-staff)) 0)) #{ #}
	  #{
	    \new PianoStaff = $staff-name \with { $(create-with-clause instrument-definition number) } 
	    {
	     <<
	     $right-staff
	     $dynamic-staff
	     $left-staff
	     >>
	     } #})))
       
#(define (create-instrument-staff instrument folder number transpose? is-full-score?)
   (let ((instrument-def (assoc-ref custom-instrument-definitions (symbol->string instrument))))
     ((assq-ref instrument-def 'staff-generator) instrument folder number transpose? is-full-score?)))

#(define (bass-clef-instrument properties)
   (append '((clefGlyph . "clefs.F") (middleCPosition . 6) (clefPosition . 2)) properties))

#(define (treble-clef-instrument properties)
   (append '((clefGlyph . "clefs.G") (middleCPosition . -6) (clefPosition . -2)) properties))

#(define (ly-score:make-music instruments folder is-transposed? is-full-score?)
   (let ((music (ly-score:make-parallel-staves (cddr instruments) folder is-transposed? is-full-score?)))
     (if (eq? (car instruments) 'Parallel) music 
	 (context-spec-music music (car instruments) (cadr instruments)))))

#(define (ly-score:make-parallel-staves instruments folder is-transposed? is-full-score?)
   (make-simultaneous-music 
    (filter 
     (lambda (el) (not (null? el)))
     (map 
      (lambda (instrument)
	(cond
	 ((ly:music? instrument)
	  instrument)
	 ((list? instrument) 
	  (ly-score:make-music instrument folder is-transposed? is-full-score?))
	 ((pair? instrument) 
	  (create-instrument-staff (car instrument) folder (cdr instrument) is-transposed? is-full-score?))
	 (else (create-instrument-staff instrument folder #f is-transposed? is-full-score?))))
	  instruments))))

#(define (ly-score:make-metered-music folder instruments is-full-score? is-transposed?)
   (let* ((my-time-signature (ly-score:time-signature folder is-full-score?))
	  (my-music-timeless (ly-score:make-music instruments folder is-transposed? is-full-score?))
	  (my-length (ly:music-length my-time-signature))
	  (my-music-with-time 
           (if (and (= (ly:moment-main-numerator (ly:music-length my-music-timeless)) 0) (not is-full-score?))
	       (ly-score:tacet-staff) my-music-timeless))
	  (my-music (make-simultaneous-music (list my-time-signature my-music-with-time))))
     my-music))

#(define (ly-score:make-score folder header instruments is-full-score? is-transposed? layout include-midi?) 
   (if (not (file-exists? folder))
       (begin
	 (format #t "Creating directory: ~a\n" folder)
	 (mkdir folder)))
   (let* ((my-music (ly-score:make-metered-music folder instruments is-full-score? is-transposed?))
	  (my-midi (ly:output-def-clone #{ \midi {} #}))
	  (my-score #{ \score { $my-music } #}))
     (if include-midi? (ly:score-add-output-def! my-score my-midi))
     (ly:score-set-header! my-score (ly-score:alist->module header))
     (ly:score-add-output-def! my-score (ly:output-def-clone layout))
     my-score))

#(define (ly-score:process-part prefix head movements instrument default-layout default-paper part-overrides)
   (let ((find-override (lambda (key instr default)
				   (let ((override 
					  (if
					   (assoc-ref part-overrides instr)
					   (assoc-ref (assoc-ref part-overrides instr) key)
					   #f)))
				     (if override (begin
						    (format #t "Using override for ~a ~a.\n" key instrument)
						    override) 
					 (begin
					   (format #t "Using default for ~a ~a.\n" key instrument)
					   default))))))
    (if (list? instrument)
	(for-each 
	 (lambda (instr) 
	   (ly-score:process-part prefix head movements instr default-layout default-paper part-overrides)) 
	 (cddr instrument))
	(if (pair? instrument)
	    (let ((instrument-def (assoc-ref custom-instrument-definitions (symbol->string (car instrument)))))
	      (if (pair? (cdr instrument))
		  (map 
		   (lambda (number) 
		     (create-part prefix head instrument-def (reverse movements) number 
				  (find-override 'paper (cons (car instrument) number) default-paper) 
				  (find-override 'layout (cons (car instrument) number) default-layout)))
		   (list (cadr instrument) (cddr instrument)))
		  (create-part prefix head instrument-def (reverse movements) (cdr instrument) 
			       (find-override 'paper instrument default-paper) 
			       (find-override 'layout instrument default-layout))))
	    (let ((instrument-def (assoc-ref custom-instrument-definitions (symbol->string instrument))))
	      (create-part prefix head instrument-def (reverse movements) #f 
			   (find-override 'paper instrument default-paper) 
			   (find-override 'layout instrument default-layout)))))))

#(define ignore-cues? (make-fluid))

#(define* (ly-score:process prefix scorehead parthead movements instruments 
			    #:key transpose? include-parts? include-score? include-midi?
			    (score-size 12) (part-size 24)
			    (score-paper #{ \paper {} #}) (part-paper #{ \paper {} #})
			    (score-layout #{ \layout {} #}) (part-layout #{ \layout {} #})
			    (part-overrides '())
			    (frontmatter #{ \markuplist {} #}))
   (set-paper-staff-size score-paper score-size)
   (set-paper-staff-size part-paper part-size)
   (if include-score?
       (with-fluids ((ignore-cues? #t))      
	 (let ((score-book #{ \book { \paper { $score-paper } \markuplist { $frontmatter } } #}))
	   (for-each 
	    (lambda (el) 
	      (ly:book-add-score! 
	       score-book 
	       (ly-score:make-score (car el) (cadr el) instruments #t transpose? score-layout include-midi?)))
	    movements)
	   (let ((header-module (ly-score:alist->module scorehead)))
	     (module-define! header-module 'transposition 
			     (if transpose?
				 "Transposed Score"
				 "Score in C"))
	     (ly:book-set-header! score-book header-module))
	   (ly:book-process score-book score-paper score-layout prefix))))
   (if include-parts? 
       (ly-score:process-part prefix parthead movements instruments part-layout part-paper part-overrides)))

#(define custom-instrument-definitions '())

addCustomInstrumentDefinition = #(define-void-function (parser location name context-properties other-properties) 
				   (string? list? list?)
   #{ \addInstrumentDefinition $name $context-properties #} 
   (set! custom-instrument-definitions 
	 (cons (cons name (append context-properties other-properties)) custom-instrument-definitions)))

% QUICK CUES
%
% Lilypond's built-in cues are not quite what I wanted in this
% application; they force you to make the cues have stems only in one
% direction to avoid colliding with rests. I use cues as the only
% voice in the bar they're in, so I make my own music events for cues
% that don't specify a direction.
%
% Also, these cues work nicely with the instrument specifications used
% to define as score.

#(define (symbol-or-pair? n)
   (or (symbol? n) (pair? n)))

quickCue = #(define-music-function 
	      (parser location key duration) 
	      (symbol-or-pair? ly:duration?) 
	      (if (pair? key)
		  (ly-score:quote-from (car key) duration #:number (cdr key))
		  (ly-score:quote-from key duration)))

quickClefCue = #(define-music-function 
		  (parser location key clef duration) 
		  (symbol-or-pair? string? ly:duration?) 
		  (if (pair? key)
		      (ly-score:quote-from (car key) duration #:number (cdr key) #:clef clef)
		      (ly-score:quote-from key duration #:clef clef)))

#(define (space duration)
  (make-music
   'SkipEvent
   'duration
   duration))

#(define* (ly-score:quote-from key duration #:key number clef)
   (if (fluid-ref ignore-cues?)
       (make-music 'MultiMeasureRestEvent 'duration duration)
       (let* ((instrument-def (assoc-ref custom-instrument-definitions (symbol->string key)))
	      (folder (fluid-ref current-folder))
	      (name (assq-ref instrument-def 'instrumentName))
	      (quote-name (format "~a~a" (assq-ref instrument-def 'key) (if number number "")))
	      (quotes (eval 'musicQuotes (current-module))))
	 (if (not (hash-ref quotes quote-name))
	     (let* ((no-part-music 
		     (with-fluids ((ignore-cues? #t)) 
		       #{ \include $(format #f "~a/~a~a.ly" folder key (if number number "")) #}))
		    (music #{ \keepWithTag #'part $no-part-music #}))
	       #{ \addQuote #quote-name $music #}))
	 #{ \new CueVoice { \set instrumentCueName = $(if number (markup (format #f "~a ~a" name number)) name) }
	    \new Voice {
		#(if clef
		     #{ \transposedCueDuringWithClef #quote-name c' $clef { $(space duration) } #}
		     #{ \transposedCueDuring #quote-name c' { $(space duration) }#})
		}#})))

hideCueName = \once \override Score.InstrumentSwitch #'transparent = ##t

showCueDynamicSpan = \set Score.quotedCueEventTypes = 
  #'(note-event 
     glissando-event rest-event tie-event beam-event tuplet-span-event dynamic-event span-dynamic-event)
hideCueDynamicSpan = \set Score.quotedCueEventTypes = 
  #'(note-event 
     glissando-event rest-event tie-event beam-event tuplet-span-event dynamic-event)

transposedCueDuring =
#(define-music-function
   (parser location what pitch main-music)
   (string? ly:pitch? ly:music?)

   (make-music 'QuoteMusic
	       'element main-music
	       'quoted-context-type 'Voice
	       'quoted-context-id "cue"
	       'quoted-music-name what
	       'quoted-transposition pitch))

transposedCueDuringWithClef =
#(define-music-function
   (parser location what pitch clef main-music)
   (string? ly:pitch? string? ly:music?)

   (make-music 'QuoteMusic 'element main-music
	       'quoted-context-type 'Voice
	       'quoted-context-id "cue"
	       'quoted-music-name what
	       'quoted-transposition pitch
	       'quoted-music-clef clef))
