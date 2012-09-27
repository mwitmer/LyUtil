\version "2.16.0"

#(use-modules (ice-9 format))

#(define-markup-command (mainfont layout props text) (markup?) 
   (interpret-markup layout props (markup text)))

#(define-markup-command (secondaryfont layout props text) (markup?) 
   (interpret-markup layout props (markup text)))

#(define ly-score:hide-instrument-names #f)

lyScoreMidi = \midi {}

lyPartLyouat = \layout {
 \context{
    \Voice
    \remove "Forbid_line_break_engraver"
    \override Beam #'breakable = ##t
    \override Glissando #'breakable = ##t
  }
  \context {
    \Score
    \override Hairpin #'minimum-length = #8
  }
  \context {
    \DrumStaff
    \accepts Voice
    \consists "Accidental_engraver"
    \consists "Piano_pedal_engraver"
  }
}

lyScoreLayout = \layout { 
  \context{
    \Voice
    \remove "Forbid_line_break_engraver"
    \override Beam #'breakable = ##t
    \override Glissando #'breakable = ##t
  }
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
  \context {
    \Score
    \accepts TimeSig
     \override Hairpin #'minimum-length = #8
  }
  \context {
    \StaffGroup
    \accepts TimeSig
  }
  \context {
    \Staff
    \remove "Time_signature_engraver"
  }
  \context {
    \DrumStaff
    \accepts Voice
    \remove "Time_signature_engraver"
    \consists "Accidental_engraver"
    \consists "Piano_pedal_engraver"
  }
}

% A music function that can take a list of parts and combine them into one staff. Still doesn't really work for more than 2 parts
multipartcombine =
#(define-music-function (parser location parts) (ly:music-list?)
   (make-part-combine-music parser parts -1))

#(define (get-paper-size-from-user score-or-parts)
   (format #t "Paper size for ~s? (l = letter, a = arch a, (default) = tabloid) \n" score-or-parts)
   (let ((papsizechar (read-char)))
     (case papsizechar
       ((#\a) "arch a") 
       ((#\l) "letter")
       (else "11x17"))))

scorepap = \paper { 
  #(set-paper-size (if (defined? 'score-paper-size) 
		       score-paper-size 
		       (get-paper-size-from-user "score")))
  short-indent = 15\mm
  two-sided = ##t
  top-markup-spacing  =
    #'((basic-distance . 10)
       (minimum-distance . 5)
       (padding . 5))
  markup-system-spacing  =
    #'((basic-distance . 30)
       (minimum-distance . 20)
       (padding . 5))
  system-system-spacing = 
    #'((basic-distance . 25)
       (minimum-distance . 20)
       (padding . 5))
}
partpap = \paper {
  #(set-paper-size (if (defined? 'part-paper-size) 
		       part-paper-size 
		       (get-paper-size-from-user "parts")))
  left-margin = 20
  bookTitleMarkup = \markup {
    \dir-column {
      \fill-line {
	\fontsize #3 \fromproperty #'header:instrument \null \null
      }
      \fill-line {
	\null \fromproperty #'header:title \null
      }
      \fill-line {
	\fromproperty #'header:notes \null \fromproperty #'header:composer
      }
    }
  }
  system-system-spacing = 
    #'((basic-distance . 8)
       (minimum-distance . 6)
       (padding . 5))
}

#(define (set-paper-staff-size pap sz)
   (let ((new-scope (ly:output-def-scope pap)))
     (layout-set-absolute-staff-size-in-module 
      new-scope
      (* sz (eval 'pt new-scope)))))

#(set-paper-staff-size scorepap 10)
#(set-paper-staff-size partpap 24)

#(define (ly-score:transpose music note)
   (ly:music-transpose music note))

% Helper functions
#(define (ly-score:alist->module alist) 
   (let ((mod (make-module))) 
     (map (lambda (list-el) (module-define! mod (car list-el) (cadr list-el))) alist) 
     mod))

#(define (ly-score:combined-part-numbers n)
   (string-append (number->string (car n)) ", " (number->string (cdr n))))

addQuotedPart = #(define-music-function (parser location folder name mus) (string? string? ly:music?)
		  (add-quotable parser name #{
<<
		   \keepWithTag #'part $(ly-score:include folder name)
		   $(ly-score:time-signature folder #f)
		   
>>
#}) mus)

#(define ly-score:head (make-module))
#(define (ly-score:part-creator file key name)
   (lambda* (prefix head reversed-movements number)
     (let ((filename (string-append prefix "-" (if number (string-append file (number->string number)) file))))
       (module-define! head 'instrument (markup #:secondaryfont (if number (markup #:secondaryfont (markup name " " (number->string number))) name)))
      (set! ly-score:head head)
	(let ((music (map (lambda (el) 
		       (ly-score:make-score 
			(car el) 
			(cadr el) 
			`(Parallel 
			  ,(if number (string-append file (number->string number)) file)
			  ,(if number (cons key number) key)) #f #t))
			  reversed-movements)))
	  (ly:book-process 
	   (apply ly:make-book partpap ly-score:head music) 
	   partpap 
	   lyPartLayout 
	   filename)
       (module-define! ly-score:head 'notes "")))))

#(define (ly-score:create-file key)
   (format #f "Creating missing file: ~s.\n" key)
   (let ((newfile (open-file key "w")))
     (display "" newfile)
     (close-port newfile)))

% Caches included files so multiple includes only parse once

#(define ly-score:include 
   (let ((parsed (make-hash-table)))
     (lambda (folder file)
       (if (ly:moment? folder)
	   #{ \mark \markup Tacet  #}
	   (let* ((key (string-append folder "/" file ".ly")))
	     (ly:music-deep-copy 
	      (or (hash-ref parsed key)
		  (begin (if (not (file-exists? key))
			     (ly-score:create-file key))
			 (let ((new-music #{ \include $key #}))
			   (hash-set! parsed key new-music)
			   new-music)))))))))

#(define (ly-score:tacet-staff) 
  #{
  \new Staff \with  { \remove "Staff_symbol_engraver" } {
    \override Staff.TimeSignature #'transparent = ##t
    \override Staff.InstrumentName #'transparent = ##t
    \override Staff.Clef #'transparent = ##t
    {s8^\markup \secondaryfont Tacet}
  }
  #})

% Define staff creators. These functions return a new function that takes a symbol as an argument and returns another function corresponding to that symbol
% 'combine returns a function that creates a staff with a number of parts on the instrument combined
% 'staff returns a single staff for a single part
% 'make-part creates the pdf file for a single part
#(define (ly-score:piano-staff-creator key file name shortName midi)
   (lambda (method)
     (let* ((staff 
	     (lambda (folder number transpose? is-full-score?)
	       (let ((music-right 
		      (ly-score:include folder (string-append (if number (string-append file (number->string number)) file) "-right")))
		     (music-left  
		      (ly-score:include folder (string-append (if number (string-append file (number->string number)) file) "-left"))))
		 (if (and (= (ly:moment-main-numerator (ly:music-length music-left)) 0) (= (ly:moment-main-numerator (ly:music-length music-right)) 0))
		     '()
		     #{
		  \new PianoStaff {
		  $(if (not ly-score:hide-instrument-names) #{
		    \set PianoStaff.shortInstrumentName = $(markup #:secondaryfont shortName)
		    \set PianoStaff.instrumentName = $(markup #:secondaryfont name)
		    #})
		  \set PianoStaff.midiInstrument = $midi
		  <<
		  \new Staff = $(string-append file "-right") \with {
		  \consists "Span_arpeggio_engraver"
		}{
		  \override Staff.VerticalAxisGroup #'minimum-Y-extent = #'(-5 . 5)
		  #(set-accidental-style 'neo-modern)
		  \clef treble $music-right 
		}
		  \new Staff = $(string-append file "-left") \with {
		    \consists "Span_arpeggio_engraver"
		  }{
		    \override Staff.VerticalAxisGroup #'minimum-Y-extent = #'(-5 . 5)
		    #(set-accidental-style 'neo-modern)
		    \clef bass $music-left
		  }
		>>
		}
		  #}))))
	    (make-part (ly-score:part-creator file key name)))
       (case method
	 ((combine) (ly:error "Cannot combine piano staves into one staff"))
	 ((staff) staff)
	 ((make-part) make-part)
	 (else (ly:error (string-append "Unknown method " (symbol->string method) " called on staff creator")))))))

#(define ly-score:time-signature-creator 
   (lambda ()
     (lambda (method)
       (if (eq? method 'make-part) (lambda (folder numbers transpose? is-full-score?) #f)
	   (lambda (folder numbers transpose? is-full-score?)
	     #{\new TimeSig \keepWithTag #'score $(ly-score:include folder "time_signature") #})))))

#(define ly-score:drum-staff-creator (lambda (key file name shortName midi)
  (lambda (method)
    (let* ((combine (lambda* (folder numbers transpose? is-full-score?)
            (let ((combined-music #{ \multipartcombine $(map (lambda (n) 
              (let ((music (ly-score:include folder (string-append file (number->string n)))))
                (if transpose? (ly-score:transpose music transpose) music)))
                (list (car numbers) (cdr numbers))) #}))
            (if (= (ly:moment-main-numerator (ly:music-length combined-music)) 0)
              '()
            #{
              \new DrumStaff = $file {
                \clef $clef
                \set Staff.soloText = $(number->string (car numbers))
                \set Staff.soloIIText = $(number->string (cdr numbers))
                \set Staff.aDueText = $(string-append (number->string (car numbers)) "," (number->string (cdr numbers)))
                \set Staff.midiInstrument = $midi
                #(if (not ly-score:hide-instrument-names) #{
                  \set Staff.instrumentName = $(markup #:secondaryfont (string-append name " " (ly-score:combined-part-numbers numbers)))
                  \set Staff.instrumentName = $(markup #:secondaryfont shortName)
                #})
                \override Staff.VerticalAxisGroup #'minimum-Y-extent = #'(-5 . 5)
                #(set-accidental-style 'modern-cautionary)
                #(if is-full-score?  #{ \keepWithTag #'score  $combined-music #} #{ \keepWithTag #'part $combined-music #})
              }
            #}))))
          (staff (lambda* (folder number transpose? is-full-score?)
            (let* (
              (no-part-music (ly-score:include folder (if number (string-append file (number->string number)) file)))
              (music (if is-full-score?  #{ \keepWithTag #'score $no-part-music #} #{ \keepWithTag #'part $no-part-music #})))
              (if (= (ly:moment-main-numerator (ly:music-length music)) 0) '()
            #{
              \new DrumStaff  = $(if number (string-append file (number->string number)) file) \with  {
		\override VerticalAxisGroup #'staff-staff-spacing =
                  #'((basic-distance . 5)
                     (minimum-distance . 4)
                     (padding . 3)
                     (stretchability . 4))
              } {
                 $(if (not ly-score:hide-instrument-names) #{
                   \set Staff.instrumentName =  $(if number (markup #:secondaryfont name " " #:secondaryfont (number->string number)) (markup #:secondaryfont name))
                   \set Staff.shortInstrumentName = $(if number (markup #:secondaryfont shortName " " #:secondaryfont (number->string number)) (markup #:secondaryfont shortName))
                 #})
                 \set Staff.midiInstrument = $midi
		 \override Staff.VerticalAxisGroup #'minimum-Y-extent = #'(-5 . 5)
                 #(set-accidental-style 'modern-cautionary)
                 \compressFullBarRests
		 $music
              }
            #}))))
          (make-part (ly-score:part-creator file key name)))
    (case method
      ((combine) combine)
      ((staff) staff)
      ((make-part) make-part)
      (else (ly:error (string-append "Unknown method " (symbol->string method) " called on staff creator"))))))))

#(define ly-score:single-staff-creator (lambda (key file name shortName midi clef transpose)
  (lambda (method)
    (let* ((combine (lambda* (folder numbers transpose? is-full-score?)
            (let ((combined-music #{ \multipartcombine $(map (lambda (n) 
              (let ((music (ly-score:include folder (string-append file (number->string n)))))
                (if transpose? (ly-score:transpose music transpose) music)))
                (list (car numbers) (cdr numbers))) #}))
            (if (= (ly:moment-main-numerator (ly:music-length combined-music)) 0)
              '()
            #{
              \new Staff = $file {
                \clef $clef
                \set Staff.soloText = $(number->string (car numbers))
                \set Staff.soloIIText = $(number->string (cdr numbers))
                \set Staff.aDueText = $(string-append (number->string (car numbers)) "," (number->string (cdr numbers)))
                \set Staff.midiInstrument = $midi
                #(if (not ly-score:hide-instrument-names) #{
                  \set Staff.instrumentName = $(markup #:secondaryfont (string-append name " " (ly-score:combined-part-numbers numbers)))
                  \set Staff.instrumentName = $(markup #:secondaryfont shortName)
                #})
                \override Staff.VerticalAxisGroup #'minimum-Y-extent = #'(-5 . 5)
                #(set-accidental-style 'modern-cautionary)
                #(if is-full-score?  #{ \keepWithTag #'score $combined-music #} #{ \keepWithTag #'part $combined-music #})
              }
            #}))))
          (staff (lambda* (folder number transpose? is-full-score?)
            (let* (
              (no-part-music (ly-score:include folder (if number (string-append file (number->string number)) file)))
              (music (if is-full-score?  #{ \keepWithTag #'score $no-part-music #} #{ \keepWithTag #'part $no-part-music #})))
              (if (= (ly:moment-main-numerator (ly:music-length music)) 0) '()
            #{
              \new Staff  = $(if number (string-append file (number->string number)) file) \with  {
		\override VerticalAxisGroup #'staff-staff-spacing =
                  #'((basic-distance . 5)
                     (minimum-distance . 4)
                     (padding . 3)
                     (stretchability . 4))
              } {
                 $(if (not ly-score:hide-instrument-names) #{
                   \set Staff.instrumentName =  $(if number (markup #:secondaryfont name " " #:secondaryfont (number->string number)) (markup #:secondaryfont name))
                   \set Staff.shortInstrumentName = $(if number (markup #:secondaryfont shortName " " #:secondaryfont (number->string number)) (markup #:secondaryfont shortName))
                 #})
                 \set Staff.midiInstrument = $midi
                 \clef $clef
                 \override Staff.VerticalAxisGroup #'minimum-Y-extent = #'(-5 . 5)
                 #(set-accidental-style 'modern-cautionary)
                 \compressFullBarRests
                 $(if transpose? 
		      (ly-score:transpose music transpose) music)
              }
            #}))))
          (make-part (ly-score:part-creator file key name)))
    (case method
      ((combine) combine)
      ((staff) staff)
      ((make-part) make-part)
      (else (ly:error (string-append "Unknown method " (symbol->string method) " called on staff creator"))))))))

% Define a table to store staff creators 
#(define ly-score-private:instrument-defs (make-hash-table))

#(define ly-score:register-instrument (lambda (key creator)
  (hash-set! ly-score-private:instrument-defs key creator)))

#(define ly-score:instrument-defs-lookup (lambda (key)
  (let ((inst (hash-ref ly-score-private:instrument-defs key)))
    (if (not inst)
      (ly:error (string-append "Missing instrument: " (symbol->string key))))
      inst)))

% Define some built-in staff creators
#(map (lambda (l) (ly-score:register-instrument (car l) (cadr l)))
   `(
    (time-sig    ,(ly-score:time-signature-creator))
    (violin            ,(ly-score:single-staff-creator 'violin             "violin"        "Violin"      "Vl."        "violin"       "treble"      (ly:make-pitch 0 0 0)))
    (viola              ,(ly-score:single-staff-creator 'viola              "viola"         "Viola"       "Vla."        "violin"       "alto"        (ly:make-pitch 0 0 0)))
    (cello              ,(ly-score:single-staff-creator 'cello              "cello"         "Cello"       "Vc."        "cello"        "bass"        (ly:make-pitch 0 0 0)))
    (contrabass         ,(ly-score:single-staff-creator 'contrabass         "contrabass"    "Contrabass"  "Cb."        "cello"        "bass"        (ly:make-pitch 0 0 0)))
    (piccolo            ,(ly-score:single-staff-creator 'piccolo            "piccolo"       "Piccolo"     "Picc."       "flute"        "treble"     (ly:make-pitch 0 0 0)))
    (flute              ,(ly-score:single-staff-creator 'flute              "flute"         "Flute"       "Fl."        "flute"        "treble"    (ly:make-pitch 0 0 0)))
    (alto-flute         ,(ly-score:single-staff-creator 'alto-flute         "alto-flute"    "Alto Flute"  "A. Fl."     "flute"        "treble"      (ly:make-pitch 0 4 0)))
    (clarinet-in-e-flat ,(ly-score:single-staff-creator 'clarinet-in-e-flat "clarinet-in-e-flat"      (markup "E" #:flat " Clarinet")    (markup "Cl(E" #:flat ")")        "clarinet"       "treble"      (ly:make-pitch 0 2 -1/2)))
    (clarinet-in-b-flat ,(ly-score:single-staff-creator 'clarinet-in-b-flat "clarinet-in-b-flat"      (markup "B" #:flat " Clarinet")    "Cl."        "clarinet"       "treble"      (ly:make-pitch -1 6 -1/2)))
    (clarinet-in-a      ,(ly-score:single-staff-creator 'clarinet-in-a      "clarinet-in-a" "A Clarinet"  "Cl."     "clarinet"     "treble"      (ly:make-pitch -1 5 0)))
    (bass-clarinet      ,(ly-score:single-staff-creator 'bass-clarinet      "bass-clarinet" "Bass Clarinet""B. Cl."   "clarinet"     "bass"      (ly:make-pitch -2 6 -1/2)))
    (oboe               ,(ly-score:single-staff-creator 'oboe               "oboe"          "Oboe"        "Ob."        "oboe"         "treble"      (ly:make-pitch 0 0 0)))
    (english-horn       ,(ly-score:single-staff-creator 'english-horn       "english-horn"  "English Horn""E.H."     "oboe"         "treble"      (ly:make-pitch 0 3 0)))
    (bassoon            ,(ly-score:single-staff-creator 'bassoon            "bassoon"       "Bassoon"     "Bs."        "bassoon"      "bass"        (ly:make-pitch 0 0 0)))
    (contrabassoon      ,(ly-score:single-staff-creator 'contrabassoon      "contrabassoon" "Contrabassoon""Cbn."      "bassoon"      "bass"        (ly:make-pitch 0 0 0)))
    (trumpet-in-d       ,(ly-score:single-staff-creator 'trumpet-in-d       "trumpet-in-d"  "Trumpet in D""Tr(D)"     "trumpet"      "treble"      (ly:make-pitch 0 0 0)))
    (trumpet-in-c       ,(ly-score:single-staff-creator 'trumpet-in-c       "trumpet-in-c"  "Trumpet"     "Tr."        "trumpet"      "treble"      (ly:make-pitch 0 0 0)))
    (horn               ,(ly-score:single-staff-creator 'horn               "horn"          "Horn"        "Hn."        "french horn"  "treble"      (ly:make-pitch 0 3 0)))
    (trombone           ,(ly-score:single-staff-creator 'trombone           "trombone"      "Trombone"    "Tbn."       "trombone"     "bass"        (ly:make-pitch 0 0 0)))
    (bass-trombone      ,(ly-score:single-staff-creator 'bass-trombone      "bass-trombone" "Bass Trombone" "B Tbn."   "trombone"     "bass"        (ly:make-pitch 0 0 0)))
    (tuba               ,(ly-score:single-staff-creator 'tuba               "tuba"          "Tuba"        "Tb."        "tuba"         "bass"        (ly:make-pitch 0 0 0)))
    (percussion         ,(ly-score:drum-staff-creator   'percussion         "percussion"    "Percussion"  "Perc."      "vibraphone"))
    (timpani            ,(ly-score:single-staff-creator 'timpani            "timpani"       "Timpani"     "Timp."      "timpani"      "bass"  (ly:make-pitch 0 0 0)))
    (harp               ,(ly-score:piano-staff-creator  'harp               "harp"          "Harp"        "Hp."        "harp"))
    (piano              ,(ly-score:piano-staff-creator  'piano              "piano"         "Piano"       "Pno."        "acoustic grand"))))


% Returns a staff that contains information global to a score. There must be a file called "time_signature.ly" with this information in every movement's folder
#(define* (ly-score:time-signature folder #:optional (is-full-score? #t)) 
  #{
  \new Staff \with { 
    \override VerticalAxisGroup #'remove-empty = ##t 
    \override VerticalAxisGroup #'remove-first = ##t 
  } 
{
  $(if is-full-score? #{ \keepWithTag #'score $(ly-score:include folder "time_signature") #}
   #{ \keepWithTag #'part $(ly-score:include folder "time_signature") #})
}
#})

% Create parallel music or a specified context for a list of instrument specifications
#(define (ly-score:make-music instruments folder is-transposed? is-full-score?)
   (let ((music (ly-score:make-parallel-staves (cddr instruments) folder is-transposed? is-full-score?)))
     (if (eq? (car instruments) 'Parallel) music 
	 (context-spec-music music (car instruments) (cadr instruments)))))

% Create an individual staff from an instrument specification
#(define (ly-score:make-staff instrument folder is-transposed? is-full-score?)
   (if (pair? instrument)
       (if (pair? (cdr instrument))
	   (((ly-score:instrument-defs-lookup (car instrument)) 'combine) folder (cdr instrument) is-transposed? is-full-score?)
	   (((ly-score:instrument-defs-lookup (car instrument)) 'staff) folder (cdr instrument) is-transposed? is-full-score?))
       (((ly-score:instrument-defs-lookup instrument) 'staff) folder #f is-transposed? is-full-score?)))

% Create parallel music for a list of instrument specifications
#(define (ly-score:make-parallel-staves instruments folder is-transposed? is-full-score?)
   (make-simultaneous-music 
    (filter (lambda (el) (not (null? el))) 
	    (map (lambda (instrument)
		   (if (list? instrument)
		       (ly-score:make-music instrument folder is-transposed? is-full-score?)
		       (ly-score:make-staff instrument folder is-transposed? is-full-score?))) instruments))))

#(define (ly-score:make-metered-music folder instruments is-full-score? is-transposed?)
   (let* ((my-time-signature (ly-score:time-signature folder is-full-score?))
	  (my-music-timeless (ly-score:make-music instruments folder is-transposed? is-full-score?))
	  (my-length (ly:music-length my-time-signature))
	  (my-music-with-time 
           (if (and (= (ly:moment-main-numerator (ly:music-length my-music-timeless)) 0) (not is-full-score?))
	       (ly-score:tacet-staff) my-music-timeless))
	  (my-music (make-simultaneous-music (list my-time-signature my-music-with-time))))
     my-music))

% Create a score for a given instrument specification, folder, and movement title
#(define (ly-score:make-score folder title instruments is-full-score? is-transposed?) 
   (if (not (file-exists? folder))
       (begin
	 (display (string-append "Creating directory: " folder))
	 (newline)
	 (mkdir folder)))
   (let* ((my-music (ly-score:make-metered-music folder instruments is-full-score? is-transposed?))
	  (my-midi (ly:output-def-clone lyScoreMidi))
	  (my-score #{ \score { $my-music } #}))
     (ly:score-set-header! my-score (ly-score:alist->module title))
;;     (if is-full-score? (ly:score-add-output-def! my-score my-midi))
     (ly:score-add-output-def! my-score (ly:output-def-clone lyScoreLayout))
     my-score))

% Recursive function to go through the instrument specification and extract parts
#(define (ly-score:process-part prefix head reversed-movements instrument)
   (if (list? instrument)
       (for-each (lambda (instr) (ly-score:process-part prefix head reversed-movements instr)) (cddr instrument))
       (if (pair? instrument)
	   (if (pair? (cdr instrument))
	       (map (lambda (n) (((ly-score:instrument-defs-lookup (car instrument)) 'make-part) prefix head reversed-movements n)) (list (cadr instrument) (cddr instrument)))
	       (((ly-score:instrument-defs-lookup (car instrument)) 'make-part) prefix head reversed-movements (cdr instrument)))
	   (((ly-score:instrument-defs-lookup instrument) 'make-part) prefix head reversed-movements #f))))

#(define adjustvib #t)

% Create a score and parts from the given information
#(define ly-score:process 
   (lambda* (prefix scorehead parthead movements instruments 
	     #:key transpose? include-parts? include-score?)
     (if include-score?
	 (begin (ly:book-process 
		 (apply ly:make-book scorepap 
			(ly-score:alist->module scorehead) 
			(map (lambda (el) (ly-score:make-score (car el) (cadr el) instruments #t transpose?)) 
			     (reverse movements))) 
		 partpap 
		 lyScoreLayout 
		 prefix)))
     (set! adjustvib #f)
     (set! ly-score:hide-instrument-names #t)
     (if include-parts? 
	 (ly-score:process-part 
	  prefix 
	  (ly-score:alist->module parthead) (reverse movements) instruments))))
