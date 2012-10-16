\version "2.16.0"

\addCustomInstrumentDefinition #"piccolo"
#(treble-clef-instrument
  `((instrumentName . "Piccolo")
    (shortInstrumentName . "Picc.")
    (instrumentCueName . "piccolo")))
#`((staff-generator . ,staff-creator)
   (clef . "treble")
   (key . piccolo))

\addCustomInstrumentDefinition #"flute"
#(treble-clef-instrument
  `((instrumentName . "Flute")
    (shortInstrumentName . "Fl.")
    (instrumentCueName . "flute")))
#`((staff-generator . ,staff-creator)
   (clef . "treble")
   (key . flute))

\addCustomInstrumentDefinition #"oboe"
#(treble-clef-instrument
  `((instrumentName . "Oboe")
    (shortInstrumentName . "Ob.")
    (instrumentCueName . "oboe")))
#`((staff-generator . ,staff-creator)
   (clef . "treble")
   (key . oboe))

\addCustomInstrumentDefinition #"english-horn"
#(treble-clef-instrument
  `((instrumentName . "English Horn")
    (instrumentTransposition . ,(ly:make-pitch 0 4 0))
    (shortInstrumentName . "E.H.")
    (instrumentCueName . "english horn")))
#`((staff-generator . ,staff-creator)
   (clef . "treble")
   (key . english-horn))

\addCustomInstrumentDefinition #"clarinet-in-b-flat"
#(treble-clef-instrument
  `((instrumentName . ,#{ \markup{ B \flat " " Clarinet } #})
    (instrumentTransposition . ,(ly:make-pitch 0 1 0))
    (shortInstrumentName . "Cl.")
    (instrumentCueName . "clarinet")))
#`((staff-generator . ,staff-creator)
   (clef . "treble")
   (key . clarinet-in-b-flat))

\addCustomInstrumentDefinition #"bass-clarinet"
#(bass-clef-instrument
  `((instrumentName . "Bass Clarinet")
    (instrumentTransposition . ,(ly:make-pitch 1 1 0))
    (shortInstrumentName . "B. Cl.")
    (instrumentCueName . "bass clarinet")))
#`((staff-generator . ,staff-creator)
   (clef . "bass")
   (transposed-clef . "treble")
   (key . bass-clarinet))

\addCustomInstrumentDefinition #"bassoon"
#(bass-clef-instrument
  `((instrumentName . "Bassoon")
    (shortInstrumentName . "Bs.")
    (instrumentCueName . "bassoon")))
#`((staff-generator . ,staff-creator)
   (clef . "bass")
   (key . bassoon))

\addCustomInstrumentDefinition #"contrabassoon"
#(bass-clef-instrument
  `((instrumentName . "Contrabassoon")
    (shortInstrumentName . "Cbn.")
    (instrumentCueName . "contrabassoon")))
#`((staff-generator . ,staff-creator)
   (clef . "bass")
   (key . contrabassoon))

\addCustomInstrumentDefinition #"horn"
#(treble-clef-instrument
  `((instrumentName . "Horn")
    (instrumentTransposition . ,(ly:make-pitch 0 4 0))
    (shortInstrumentName . "Hn.")
    (instrumentCueName . "horn")))
#`((staff-generator . ,staff-creator)
   (clef . "treble")
   (key . horn))

\addCustomInstrumentDefinition #"trumpet-in-c"
#(treble-clef-instrument
  `((instrumentName . "C Trumpet")
    (shortInstrumentName . "Tr.")
    (instrumentCueName . "trumpet")))
#`((staff-generator . ,staff-creator)
   (clef . "treble")
   (key . trumpet-in-c))

\addCustomInstrumentDefinition #"trombone"
#(bass-clef-instrument
  `((instrumentName . "Trombone")
    (shortInstrumentName . "Tbn.")
    (instrumentCueName . "trombone")))
#`((staff-generator . ,staff-creator)
   (clef . "bass")
   (key . trombone))

\addCustomInstrumentDefinition #"bass-trombone"
#(bass-clef-instrument
  `((instrumentName . "Bass Trombone")
    (shortInstrumentName . "B. Tbn.")
    (instrumentCueName . "bass trombone")))
#`((staff-generator . ,staff-creator)
   (clef . "bass")
   (key . bass-trombone))

\addCustomInstrumentDefinition #"tuba"
#(bass-clef-instrument
  `((instrumentName . "Tuba")
    (shortInstrumentName . "Tb.")
    (instrumentCueName . "tuba")))
#`((staff-generator . ,staff-creator)
   (clef . "bass")
   (key . tuba))

\addCustomInstrumentDefinition #"violin" 
#(treble-clef-instrument
  `((instrumentName . "Violin")
    (shortInstrumentName . "Vl.")
    (instrumentCueName . "violin")
    (midiInstrument . "violin")))
#`((staff-generator . ,staff-creator)
   (clef . "treble")
   (key . violin))

\addCustomInstrumentDefinition #"viola"
#(treble-clef-instrument
  `((instrumentName . "Viola")
    (shortInstrumentName . "Vla.")
    (instrumentCueName . "viola")
    (midiInstrument . "violin")))
#`((staff-generator . ,staff-creator)
   (clef . "alto")
   (key . viola))

\addCustomInstrumentDefinition #"cello"
#(bass-clef-instrument
  `((instrumentName . "Cello")
    (shortInstrumentName . "Vc.")
    (instrumentCueName . "cello")
    (midiInstrument . "cello")))
#`((staff-generator . ,staff-creator)
   (clef . "bass")
   (key . cello))

\addCustomInstrumentDefinition #"contrabass"
#(bass-clef-instrument
  `((instrumentName . "Contrabass")
    (shortInstrumentName . "Cb.")
    (instrumentCueName . "contrabass")
    (midiInstrument . "contrabass")))
#`((staff-generator . ,staff-creator)
   (clef . "bass")
   (key . contrabass))

\addCustomInstrumentDefinition #"timpani"
#(treble-clef-instrument
  `((instrumentName . "Timpani")
    (shortInstrumentName . "Timp.")
    (instrumentCueName . "timpani")
    (midiInstrument . "timpania")))
#`((staff-generator . ,staff-creator)
   (clef . "bass")
   (key . timpani))

\addCustomInstrumentDefinition #"percussion"
#'((instrumentName . "Percussion")
   (shortInstrumentName . "Perc.")
   (instrumentCueName . "percussion")
   (midiInstrument . "percussion"))
#`((staff-generator . ,drum-staff-creator)
   (clef . "percussion")
   (key . percussion))

\addCustomInstrumentDefinition #"piano"
#'((instrumentName . "Piano")
   (shortInstrumentName . "Pn.")
   (instrumentCueName . "piano")
   (midiInstrument . "acoustic grand"))
#`((staff-generator . ,piano-staff-creator)
   (key . piano)
   (left-definition . ((clef . "bass") (key . piano-left)))
   (right-definition . ((clef . "treble") (key . piano-right))))

\addCustomInstrumentDefinition #"harp"
#'((instrumentName . "Harp")
   (shortInstrumentName . "Hp.")
   (instrumentCueName . "harp")
   (midiInstrument . "harp"))
#`((staff-generator . ,piano-staff-creator)
   (key . harp)
   (left-definition . ((clef . "bass") (key . harp-left)))
   (right-definition . ((clef . "treble") (key . harp-right))))