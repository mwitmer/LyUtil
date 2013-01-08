\version "2.16.0"

\addCustomInstrumentDefinition #"sopranino-saxophone"
#(treble-clef-instrument
  `((instrumentName . "Sopranino Saxophone")
    (shortInstrumentName . "Sno. Sax.")
    (midiInstrument . "soprano sax")
    (instrumentCueName . "sopranino sax")
    (instrumentTransposition . ,(ly:make-pitch -1 5 0))))
#`((staff-generator . ,staff-creator)
   (clef . "treble")
   (key . sopranino-saxophone))

\addCustomInstrumentDefinition #"soprano-saxophone"
#(treble-clef-instrument
  `((instrumentName . "Soprano Saxophone")
    (shortInstrumentName . "S. Sax.")
    (midiInstrument . "soprano sax")
    (instrumentCueName . "soprano sax")
    (instrumentTransposition . ,(ly:make-pitch 0 1 0))))
#`((staff-generator . ,staff-creator)
   (clef . "treble")
   (key . soprano-saxophone))

\addCustomInstrumentDefinition #"alto-saxophone"
#(treble-clef-instrument
  `((instrumentName . "Alto Saxophone")
    (shortInstrumentName . "A. Sax.")
    (midiInstrument . "alto sax")
    (instrumentCueName . "alto sax")
    (instrumentTransposition . ,(ly:make-pitch 0 5 0))))
#`((staff-generator . ,staff-creator)
   (clef . "treble")
   (key . alto-saxophone))

\addCustomInstrumentDefinition #"tenor-saxophone"
#(treble-clef-instrument
  `((instrumentName . "Tenor Saxophone")
    (shortInstrumentName . "T. Sax.")
    (midiInstrument . "tenor sax")
    (instrumentCueName . "tenor sax")
    (instrumentTransposition . ,(ly:make-pitch 1 1 0))))
#`((staff-generator . ,staff-creator)
   (clef . "treble")
   (transposed-clef . "treble")
   (key . tenor-saxophone))

\addCustomInstrumentDefinition #"baritone-saxophone"
#(bass-clef-instrument
  `((instrumentName . "Baritone Saxophone")
    (shortInstrumentName . "Bar. Sax.")
    (midiInstrument . "baritone sax")
    (instrumentCueName . "baritone sax")
    (instrumentTransposition . ,(ly:make-pitch 1 5 0))))
#`((staff-generator . ,staff-creator)
   (clef . "bass")
   (transposed-clef . "treble")
   (key . baritone-saxophone))

\addCustomInstrumentDefinition #"bass-saxophone"
#(bass-clef-instrument
  `((instrumentName . "Bass Saxophone")
    (shortInstrumentName . "B. Sax.")
    (midiInstrument . "baritone sax")
    (instrumentCueName . "bass sax")
    (instrumentTransposition . ,(ly:make-pitch 2 1 0))))
#`((staff-generator . ,staff-creator)
   (clef . "bass")
   (transposed-clef . "treble")
   (key . bass-saxophone))
