\version "2.16.0"

\addCustomInstrumentDefinition #"violin" 
#(treble-clef-instrument
  `((instrumentName . "Violin")
    (shortInstrumentName . "Vl.")
    (instrumentCueName . "violin")
    (midiInstrument . "violin")))
#`((staff-generator . ,staff-creator)
   (clef . "treble")
   (key . violin))

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
