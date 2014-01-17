\version "2.16.0"

\addCustomInstrumentDefinition #"piccolo"
#(treble-clef-instrument
  `((instrumentName . "Piccolo")
    (shortInstrumentName . "Picc.")
    (midiInstrument . "flute")
    (instrumentCueName . "piccolo")))
#`((staff-generator . ,staff-creator)
   (clef . "treble")
   (key . piccolo))

\addCustomInstrumentDefinition #"flute"
#(treble-clef-instrument
  `((instrumentName . "Flute")
    (shortInstrumentName . "Fl.")
    (midiInstrument . "flute")
    (instrumentCueName . "flute")))
#`((staff-generator . ,staff-creator)
   (clef . "treble")
   (key . flute))

\addCustomInstrumentDefinition #"alto-flute"
#(treble-clef-instrument
  `((instrumentName . "Alto Flute")
    (instrumentTransposition . ,(ly:make-pitch 0 5 0))
    (shortInstrumentName . "Alt. Fl.")
    (midiInstrument . "flute")
    (instrumentCueName . "alto flute")))
#`((staff-generator . ,staff-creator)
   (clef . "treble")
   (key . alto-flute))

\addCustomInstrumentDefinition #"oboe"
#(treble-clef-instrument
  `((instrumentName . "Oboe")
    (shortInstrumentName . "Ob.")
    (midiInstrument . "oboe")
    (instrumentCueName . "oboe")))
#`((staff-generator . ,staff-creator)
   (clef . "treble")
   (key . oboe))

\addCustomInstrumentDefinition #"english-horn"
#(treble-clef-instrument
  `((instrumentName . "English Horn")
    (instrumentTransposition . ,(ly:make-pitch 0 4 0))
    (shortInstrumentName . "E.H.")
    (midiInstrument . "oboe")
    (instrumentCueName . "english horn")))
#`((staff-generator . ,staff-creator)
   (clef . "treble")
   (key . english-horn))

\addCustomInstrumentDefinition #"clarinet-in-e-flat"
#(treble-clef-instrument
  `((instrumentName . ,#{ \markup{ "E♭" " " "Clarinet" } #})
    (instrumentTransposition . ,(ly:make-pitch -1 5 0))
    (shortInstrumentName . ,#{ \markup \markup {"Cl.(E♭)" } #})
    (midiInstrument . "clarinet")
    (instrumentCueName . "E♭ clarinet)))
#`((staff-generator . ,staff-creator)
   (clef . "treble")
   (key . clarinet-in-e-flat))

\addCustomInstrumentDefinition #"clarinet-in-c"
#(treble-clef-instrument
  `((instrumentName . ,#{ \markup{ C " " Clarinet } #})
    (shortInstrumentName . "Cl. (C)")
    (midiInstrument . "clarinet")
    (instrumentCueName . "clarinet")))
#`((staff-generator . ,staff-creator)
   (clef . "treble")
   (key . clarinet-in-c))

\addCustomInstrumentDefinition #"clarinet-in-a"
#(treble-clef-instrument
  `((instrumentName . ,#{ \markup{ "Clarinet in A" } #})
    (instrumentTransposition . ,(ly:make-pitch 0 2 -1/2))
    (shortInstrumentName . "Cl. (A)")
    (midiInstrument . "clarinet")
    (instrumentCueName . "clarinet")))
#`((staff-generator . ,staff-creator)
   (clef . "treble")
   (key . clarinet-in-a))

\addCustomInstrumentDefinition #"clarinet-in-b-flat"
#(treble-clef-instrument
  `((instrumentName . ,#{ \markup{ B♭ Clarinet } #})
    (instrumentTransposition . ,(ly:make-pitch 0 1 0))
    (shortInstrumentName . "Cl. (B♭)" )
    (midiInstrument . "clarinet")
    (instrumentCueName . "clarinet")))
#`((staff-generator . ,staff-creator)
   (clef . "treble")
   (key . clarinet-in-b-flat))

\addCustomInstrumentDefinition #"basset-horn"
#(treble-clef-instrument
  `((instrumentName . "Basset Horn in F")
    (instrumentTransposition . ,(ly:make-pitch 0 4 0))
    (shortInstrumentName . "B.H.")
    (midiInstrument . "clarinet")
    (instrumentCueName . "basset horn")))
#`((staff-generator . ,staff-creator)
   (clef . "treble")
   (key . basset-horn))

\addCustomInstrumentDefinition #"alto-clarinet"
#(treble-clef-instrument
  `((instrumentName . ,#{ \markup{ Alto Clarinet in E♭ } #})
    (instrumentTransposition . ,(ly:make-pitch 0 5 0))
    (shortInstrumentName . "A. Cl. (E♭)")
    (midiInstrument . "clarinet")
    (instrumentCueName . "alto clarinet")))
#`((staff-generator . ,staff-creator)
   (clef . "treble")
   (key . alto-clarinet))


\addCustomInstrumentDefinition #"bass-clarinet"
#(bass-clef-instrument
  `((instrumentName . "Bass Clarinet in B♭")
    (instrumentTransposition . ,(ly:make-pitch 1 1 0))
    (shortInstrumentName . B. Cl. (B♭)")
    (midiInstrument . "clarinet")
    (instrumentCueName . "bass clarinet")))
#`((staff-generator . ,staff-creator)
   (clef . "bass")
   (transposed-clef . "treble")
   (key . bass-clarinet))

\addCustomInstrumentDefinition #"bassoon"
#(bass-clef-instrument
  `((instrumentName . "Bassoon")
    (shortInstrumentName . "Bs.")
    (midiInstrument . "bassoon")
    (instrumentCueName . "bassoon")))
#`((staff-generator . ,staff-creator)
   (clef . "bass")
   (key . bassoon))

\addCustomInstrumentDefinition #"contrabassoon"
#(bass-clef-instrument
  `((instrumentName . "Contrabassoon")
    (shortInstrumentName . "Cbn.")
    (midiInstrument . "bassoon")
    (instrumentCueName . "contrabassoon")))
#`((staff-generator . ,staff-creator)
   (clef . "bass")
   (key . contrabassoon))

\addCustomInstrumentDefinition #"horn"
#(treble-clef-instrument
  `((instrumentName . "Horn")
    (instrumentTransposition . ,(ly:make-pitch 0 4 0))
    (shortInstrumentName . "Hn.")
    (midiInstrument . "french horn")
    (instrumentCueName . "horn")))
#`((staff-generator . ,staff-creator)
   (clef . "treble")
   (key . horn))

\addCustomInstrumentDefinition #"trumpet-in-b-flat"
#(treble-clef-instrument
  `((instrumentName . ,#{ \markup{ B♭ " " Trumpet } #})
    (instrumentTransposition . ,(ly:make-pitch 0 1 0))
    (shortInstrumentName . "Tr. (B♭)")
    (instrumentCueName . "trumpet")))
#`((staff-generator . ,staff-creator)
   (clef . "treble")
   (key . trumpet-in-b-flat))

\addCustomInstrumentDefinition #"trumpet-in-c"
#(treble-clef-instrument
  `((instrumentName . "C Trumpet")
    (shortInstrumentName . "Tr.")
    (instrumentCueName . "trumpet")))
#`((staff-generator . ,staff-creator)
   (clef . "treble")
   (key . trumpet-in-c))

\addCustomInstrumentDefinition #"trumpet-in-d"
#(treble-clef-instrument
  `((instrumentName . "D Trumpet")
    (instrumentTransposition . ,(ly:make-pitch -1 6 -1/2))
    (shortInstrumentName . "Tr. (D)")
    (instrumentCueName . "trumpet")))
#`((staff-generator . ,staff-creator)
   (clef . "treble")
   (key . trumpet-in-d))

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

\addCustomInstrumentDefinition #"euphonium"
#(bass-clef-instrument
  `((instrumentName . "Euphonium")
    (shortInstrumentName . "Eup.")
    (instrumentCueName . "euphonium")))
#`((staff-generator . ,staff-creator)
   (clef . "bass")
   (key . euphonium))

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
    (midiInstrument . "timpani")))
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
