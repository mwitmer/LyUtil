\version "2.16.0"

% vibrato.ly
% Author: Mark Witmer

% Sets the next trill spanner to draw a waveform with the provided wevelength
% and amplitudes. The waveform will go from one amplitude to the next in a
% linear fashion.
vibrato = #(define-music-function (parser location amplitudes wavelength) (list? number?) #{ 
  \once \override TrillSpanner #'after-line-breaking = $(lambda (grob) 
     (ly:grob-set-property! grob 'stencil (makevib grob amplitudes wavelength)))
#})

% Example:
% \relative c' {\time 4/4 \key d \major \vibrato #'(4 0 4) #1.5 c\startTrillSpan d e d c d e d c\stopTrillSpan 
% \vibrato #'(1 6 2 1 3 7 4) #1 c\startTrillSpan d e d c d e d c d e d c d e d c d e d c d e d c d e d c d e d 
% c d e d c d e d c d e d c d e d c d e d c d e d c d e d c d e\stopTrillSpan}

#(define adjustvib #t)

% Creates the postscript for one system of the vibrato marking
#(define (make_ps lbound xspan span-so-far amplitude-vector wavelength) 
    (letrec (
        (frontmatter
          (string-append "gsave " (if (and (> span-so-far 0) adjustvib) "-15.0 0.0 rmoveto " "") " currentpoint translate " 
              "0.15 setlinewidth newpath\n "))
           (backmatter "stroke grestore")
         (make-curve (lambda (current last)
           (if (= current (vector-length amplitude-vector)) ""
             (if (< (vector-ref amplitude-vector current) 0) ""
           (let (
            (current-ps (string-append " x " (number->string (exact->inexact (/ wavelength 3))) " add " (number->string (vector-ref amplitude-vector current)) 
                " x " (number->string (exact->inexact (* 2 (/ wavelength 3)))) " add " (number->string (- (vector-ref amplitude-vector current)))
                " x " (number->string wavelength) " add 0.0 curveto
                /x x " (number->string wavelength) " add def\n")))
            (if (= (+ current 1) last) current-ps (string-append current-ps (make-curve (+ 1 current) last)))))))))
     (if (or (= xspan -inf.0) (= xspan +inf.0))
       (string-append frontmatter backmatter) 
       (string-append frontmatter " /x " (number->string lbound) " def
           x 0.0 moveto\n"
           (make-curve (inexact->exact (floor span-so-far)) (+ (inexact->exact (floor span-so-far)) (inexact->exact (floor xspan))))
            backmatter))))

% Returns the width of a grob
#(define (grob-width grob)
  (if (or (= (car (ly:grob-property grob 'X-extent)) -inf.0) (= (car (ly:grob-property grob 'X-extent)) +inf.0)) 0
  (- (cdr (ly:grob-property grob  'X-extent)) (car (ly:grob-property grob 'X-extent)))))

% Returns the number of ems already traversed by the grob's siblings in previous systems
#(define (width-up-to grob siblings count)
  (if (eq? (car siblings) grob) count (+ (+ count (width-up-to grob (cdr siblings) count)) (grob-width (car siblings)))))

% Returns the total width of the individual grobs for each system that make up the original grob
#(define (calcfull siblings count)
  (if (eqv? (length siblings) 0)
    count
    (calcfull (cdr siblings) (+ count (grob-width (car siblings))))))

% Fills a vector of length len with linear interpolations between the values found in amplitudes
#(define (fill-amplitude-vector! amplitude-vector len current-index amplitudes)
  (if (> (length amplitudes) 1)
    (let ((start-amplitude (car amplitudes))
          (end-amplitude (cadr amplitudes))
          (start-index current-index)
          (end-index (+ current-index (inexact->exact (floor (/ (vector-length amplitude-vector) (- len 1)))))))
      (do ((n current-index (+ 1 n))) ((or (> n (+ start-index end-index)) (>= n (vector-length amplitude-vector))))
        (vector-set! amplitude-vector n (exact->inexact (+ start-amplitude (* (/ (- n start-index) (- end-index start-index)) (- end-amplitude start-amplitude))))))
        (fill-amplitude-vector! amplitude-vector len end-index (cdr amplitudes)))))

% Makes the vector of amplitudes for the vibrato marking
#(define (make-amplitude-vector amplitudes total-span wavelength)
  (let* (
      (current-start 0)
      (len (inexact->exact (floor (/ total-span wavelength))))
      (amplitude-vector (make-vector len)))
      (if (> (length amplitudes) 1) 
        (fill-amplitude-vector! amplitude-vector (length amplitudes) 0 amplitudes)
        (vector-fill! amplitude-vector (car amplitudes)))
    amplitude-vector))

% Creates a stencil that draws a sine wave for vibrato based on the provided amplitudes and wavelength
#(define (makevib grob amplitudes wavelength)
  (let* ((orig (ly:grob-original grob))
      (siblings (if (ly:grob? orig) (ly:spanner-broken-into orig) '()))
      (span (ly:grob-property grob 'X-extent))
      (xbeg (car span))
      (xend (cdr span))
      (xspan (- xend xbeg))
      (total-span (if (eqv? (length siblings) 0) (- xspan 3) (- (calcfull siblings 0) 3)))
      (lbound (if (or (null? siblings) (eq? (car siblings) grob)) 0 (cdr (assq 'X (ly:grob-property grob 'left-bound-info)))))
      (span-so-far (if (null? siblings) 0 (width-up-to grob siblings 0))))
  (ly:make-stencil (list 'embedded-ps (make_ps lbound xspan span-so-far (make-amplitude-vector amplitudes total-span wavelength) wavelength)) '(0 . 0) '(-1 . 3))))

vib = #(define-music-function (parser location sizes) (list?) #{ \vibrato $sizes #1  #})
sVib = \startTrillSpan
eVib = \stopTrillSpan
