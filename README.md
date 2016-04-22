###Howto

1. [Ruby installieren](https://www.ruby-lang.org/de/documentation/installation/)
2. Dateien [downloaden](https://github.com/flo-l/sep-tests/archive/master.zip) und in den Ordner, in dem die `basic` liegt kopieren.
2. Terminal: `ruby test.rb`

###Beschreibung
Das sind ein paar Tests die ich für SEP geschrieben habe.

Das Ruby Skript füttert jede *.in Datei in testcases/ via stdin an ein programm `basic`.
stdout wird in eine testcases/*.out Datei geschrieben. Diese .out Datei wird mit der passenden .ref Datei
verglichen.

Bei manchen Tests werden auch .save.out mit .save.ref Dateien verglichen, um das autosave Feature zu
testen.

Das Skript führt alle Tests 2 mal durch, 1 mal normal und einmal mit valgrind, sollte somit also auch
memory leaks entdecken.
