SoilMod - Soil Management & Growth Control (v1.2.0)

Benötigte zusätzliche Mods:
- PDAMod v2.0.2 (or neuer) - http://fs-uk.com/mods/view/34554

Modbeschreibung

'SoilMod' ist eine Modifikation, die auf Maps, welche entsprechend vorbereitet wurden, folgendes hinzufügt:
- individuelle Kontrolle des Wachstums, so dass es sich nach der Ingame-Zeit richtet,
- eine realistische Verwendung für Kalk, die den pH-Wert des Bodens beeinflusst,
- Mist muss eingepflügt oder eingegrubbert werden, um volle Wirkung zu erzielen,
- automatisches Unkrautwachstum und Nutzung von Herbiziden,
- sowie einige andere Funktionen.

Bitte beachten! Dieser Mod ist möglicherweise nicht genau das, was du erwartest oder macht nicht alles so, wie du denkst. Also sei so nett und gib bitte offene und konstruktive Kritik und / oder Vorschläge, wie man Verbesserungen für zukünftige Versionen realisieren kann.


So wird die Map 'vorbereitet' - MUSS GELESEN WERDEN! -

(HINWEIS: Du kannst diesen Schritt überspringen, wenn du dies bereits für eine frühere Version 1.x.x von SoilMod erledigt hast.)

"SoilManagement.ZIP" funktioniert nur auf Maps, die dafür vorbereitet worden sind. Es sind Ergänzungen in .I3D- und .lua-Dateien der Map erforderlich. Diese findest du im entpackten Download.

Es wird vorausgesetzt, dass du weißt, wie man einen Texteditor wie Notepad++ ("Notepad Plus Plus") oder einen ähnlichen Editor verwendet, und dazu in der Lage bist, in Text-Dateien wie der .I3D und .lua zu navigieren.


Vorbereitung der Map.I3D für SoilMod

Der schwierigste Teil ist, die erforderlichen und richtigen Zeilen zu deiner eigenen map.I3D Datei hinzufügen. Wie das geht, ist in der Datei 'map - InstructionsDE.txt' beschrieben, die du im Ordner mit Anleitungen findest.

Denk vor dem Bearbeiten deiner Map daran, eine Sicherheitskopie zu erstellen. So kannst du, wenn etwas schief geht, zur letzten funktionierenden Version zurück kehren, und versuchen von vorne zu beginnen.

Beachte, dass die normale Mapgröße "x1" ist (d.h. density-Dateien haben eine Größe von 4096 x 4096 Pixeln). Im Download enthalten sind auch density-Dateien für X.25 (klein) und x4 (groß) Mapgrößen. Es ist darauf zu achten, die richtige density-Datei zu kopieren, wenn die Map nicht Standardgröße hat.


Vorbereitung der SampleModMap.LUA für SoilMod

Die zweite Änderung, um deine Map vorzubereiten, ist das Hinzufügen von Code zur SampleModMap.LUA (oder wie auch immer diese benannt wurde).

Im Anleitungs-Verzeichnis findest du die Datei 'SampleModMap - Additions.LUA', die 5 deutlich markierte Codeblöcke enthält. Diese musst du kopieren und an der entsprechenden Position in der SampleModMap.LUA deiner Map einfügen.


Nutzung im Spiel

ACHTUNG! Da es auch andere Mods gibt, welche die internen Funktionen 'Düngen / Grubbern / Ernten' von Landwirtschafts-Simulator 2013 verändern, KANN es zu Mod-Konflikten mit 'SoilMod' kommen.

Es ist sehr ratsam, alle Mods, die möglicherweise den ordnungsgemäßen Betrieb von 'SoilMod' beeinträchtigen könnten, zu löschen oder zu deaktivieren.

Sobald die Map für 'SoilMod' vorbereitet wurde, können die zwei benötigten Mods in den MODS-Ordner kopiert werden:
SoilManagement.ZIP und PDAModPlugin_SoilCondition.ZIP
Denk auch daran PDAMod.ZIP (oder neuer) herunter zu laden, falls du ihn nicht bereits hast. - Http://fs-uk.com/mods/view/34554

Starte den Landwirtschafts Simulator 13 und lade die Map, die für 'SoilMod' vorbereitet wurde. Beachte, dass es möglich ist, ein bestehendes Savegame weiter zu spielen. Aber bitte teste zuerst, um zu sehen, ob alles normal arbeitet.

Wenn die Map geladen wird, schreiben die Soil Management & Growth Control Skripte weitere Informationen in die Konsole und LOG.TXT, die im Falle eines Problems benötigt werden.


Bodenzustand - ein PDA MOD-Plugin

Zuerst solltest du sicherstellen, dass der 'Bodenzustand'-Bildschirm im PDA angezeigt wird. Wenn dieser Bildschirm nicht verfügbar ist (PDA MOD vergessen?), oder nicht wie auf den Screenshots aussieht, ist die Map unter Umständen nicht korrekt für 'SoilMod' vorbereitet. In diesem Fall musst du in die LOG.TXT schauen, um das Problem zu finden.

Wenn der Bildschirm 'Bodenzustand' funktioniert, zeigt er einige Informationen zum Bodenzustand in einem Umkreis von 10 x 10 m rund um die aktuelle Position des Spielers. Dies wird alle zwei Sekunden aktualisiert.

Eine Unterseite 'Fruchtauswirkungen' beinhaltet einige statische Informationen darüber, welche Pflanzen mit einem bestimmten Kunstdünger einen höheren Ertrag abwerfen, und welche Art Herbizid eine negative Wirkung auf die Pflanzen hat (d.h. wächst langsamer oder verwelkt).


Wachstum (auch verwelken) geschieht jeden Tag um Mitternacht

Der Hauptgrund diesen Mod zu erstellen, war für mich zu wissen, wann der nächste Wachstumszyklus eintritt, und diesen in bestimmter Weise zu beeinflussen.

Aktuell startet das Wachstum für alle Kulturen jeden Tag um Mitternacht.

Eine Fortschrittsanzeige zeigt, wie viel bereits bearbeitet wurde, da das Wachstum stufenweise über die Map ausgeführt wird, um mögliche "Ruckler" und Netzwerk-Latenzen (Verzögerung) zu reduzieren.

Verwelken ist aktiviert! ... Und es gibt noch keinen "einfachen Weg", um es zu deaktivieren, außer man findet und ändert eine Stelle im SoilMod-Skript.

Während des Wachstumszyklus passieren folgende Dinge:
- Getreide wächst um eine Stufe, es sei denn, es wird von einem bestimmten Herbizid-Typ entweder das Wachstum pausiert oder zum verwelken gebracht.
- Schwaden und nicht eingearbeiteter Mist wird um eine Stufe reduziert (d.h. verschwindet langsam)
- Nicht eingearbeiteter Kalk und Gülle zieht in den Boden ein, allerdings mit reduziertem Wirkungsgrad im Vergleich zum Einarbeiten.
- Herbizid lässt Unkrautpflanzen verwelken und dann verschwinden.
- Feuchtigkeit vom Spritzen / Düngen verdampft.


pH-Wert / Kalk beeinflusst den Ernteertrag

Der pH-Wert ist ein neuer Aspekt dieses Mods, der den Ertneertrag stark beeinflusst, wenn der Boden zu sauer wird.

Der Bildschirm "Bodenzustand' zeigt den durchschnittlichen pH-Wert für den 10 x 10 m Bereich im Umkreis - NICHT das gesamte Feld - also habe ein Auge darauf.

Für eine optimale Ernte muss der pH-Wert im "neutralen" Bereich liegen. Etwas unterhalb oder oberhalb beeinflusst die Ertne gemäß der folgenden Tabelle, wobei 100% dem normalen Ertrag entspricht:

  - 5.1 - 5.6 - 6.1 - 6.6 -  7.3 - 7.9 - 8.5 - 9.0 -
  5%   50%   75%   95%   100%   95%   90%   80%   70%

Streuen von Kalk erhöht den pH-Wert, und wenn danach gepflügt / gegrubbert wird, ist die Wirkung des Kalks höher, als wenn er unbearbeitet bis zum nächsten Wachstumszyklus liegen gelassen wird.

Aufgrund technischer Einschränkungen des Spiels und der Art, wie das Skript funktioniert, werden pH-Werte in größeren Stufen, als dies in der Realität der Fall ist, wechseln.

Bei Verwendung der Standard-Geräte für das Ausbringen von Festdünger (außer Mist), ist es möglich, die Düngerart zu Kalk zu wechseln. Das F1-Hilfefenster zeigt, mit welcher Taste umgeschaltet wird.


Mist & Gülle - organische Dünger

Einige Spieler hatten den Wunsch, erst Mist / Gülle auszubringen und dies dann mit dem Pflug oder Grubber in den Boden einzuarbeiten.

Das ist ebenfalls etwas, das mit 'SoilMod' nun möglich ist, da das Ausbringen von Mist und Gülle nicht sofort wirkt, sondern durch Einarbeitung "in den Boden" den Nährstoffgehalt und damit die Ernteerträge erhöht.

Die Möglichkeiten für die Verwendung von Mist und Gülle in 'SoilMod' sind:

1. Ausbringen von Mist oder Gülle auf dem Feld.
2a. Für die besten Ergebnisse muss Mist in den Boden gepflügt werden, da hierdurch die Düngung um drei Stufen erhöht wird (bis zu einem Maximum von 3).
2c. Untergrubbern von Mist ist weniger effektiv, da es nur um eine Stufe erhöht.
2b. Gülle, egal ob mit Pflügen oder Grubbern, erhöht die Düngung um 1 (bis zu einem Maximum von 3).
2d. Gülle kann auch "unbearbeitet" auf den nächsten Wachstumszyklus warten, wird aber dann auch weniger wirksam sein, weil nur ein maximum von 1 erreicht wird.

Beachte, dass Mist, der unverarbeitet auf dem Feld bleibt, im Laufe der Zeit (3 Tage) verschwindet und in diesem Fall keine Düngung stattfindet.


Kunstdünger, nur während des Wachstums

Verwendung von organischen Dünger ist ideal, aber Kunstdünger kann in Situationen helfen, in denen nur ein bisschen mehr Düngung gewünscht wird.

Allerdings ist Kunstdünger nur in den frühen Wachstumsstadien wirksam. Wenn Kunstdünger zu einem anderen Zeitpunkt ausgebracht wird, werden die Pflanzen ihn nicht annehmen.

Im erweiterten Modus von SoilMod (Standardeinstellung) gibt es drei Arten von Kunstdünger: Typ-A, Typ-B & Typ-C. Jeder Fruchttyp akzeptiert nur eine bestimmte Art von Kunstdünger (oder gar keine), die in der PDA-Ansicht 'Fruchtauswirkungen' zu sehen ist.

Bei Verwendung der Standard-Geräte für die Ausbringung von Kunstdünger, ist es möglich, die Dünger-Art zu jeder der drei Kunstdünger-Typen zu wechseln. Das F1-Hilfefenster zeigt, mit welcher Taste umgeschaltet wird.


Unkrautpflanzen & Herbizid - erscheint zufällig in Feldbereichen

Kleine Flächen mit Unkrautpflanzen entstehen kontinuierlich und zufällig in Feldern, da sich ihre Samen mit dem Wind verbreiten. Pflügen, Grubbern oder Säen entfernt das Unkraut. Aber manchmal sind diese Methoden nicht möglich, dann muss Herbizid gespritzt werden.

Im erweiterten Modus von SoilMod (Standardeinstellung) gibt es drei Arten von Herbiziden: Typ-A, Typ-B & Typ-C. Jedes dieser Herbizide wird Unkrautpflanzen vernichten. Doch einige Fruchtarten reagieren negativ auf bestimmte Arten von Herbizid. Dies ist im PDA-Bildschirm 'Fruchtauswirkungen' zu überprüfen. Im schlimmsten Fall werden Pflanzen, die mit dem falschen Herbizid behandelt wurden, verwelken.

Wenn Unkrautpflanzen mit Herbizid behandelt wurden, werden sie erst verwelken und nach einigen Tagen absterben. - Doch bis dahin können in der Umgebung neue Unkrautpflanzen gewachsen sein.

Bei Verwendung der Standard-Geräte für die Ausbringung von Flüssigdünger (nicht Gülle), ist es möglich, die Herbizid-Art zu jeder der drei Herbizid-Typen zu wechseln. Das F1-Hilfefenster zeigt, mit welcher Taste umgeschaltet wird.


Probleme oder Fehler?

Wenn dir Probleme oder Bugs im 'SoilMod' auffallen, nutze bitte den Support-Thread auf http://fs-uk.com - der Mod (und die richtige Version) ist dort im Mods-Bereich in der Kategorie 'Other - Game Scripts' zu finden.

Bekannten Mängel / Fehler:
- Ausbringen einer anderen Art von Dünger / Herbizid auf dem Feld, wird jede vorherige Art von Dünger / Herbizid ersetzen.
- Es ist möglich, Gülle einen Tag vor der Ernte zu auszubringen, und dadurch die Wirkung des organischen Düngers zu erhalten.
- Wechseln zum 'einfachen Modus' kann nur durch Bearbeiten von fmcSoilMod.LUA durchgeführt werden.
- Ändern von Wachstumsparametern kann nur durch Bearbeiten von fmcGrowthControl.LUA durchgeführt werden.


Einschränkungen

Die MOD-Dateien SoilManagement.ZIP, PDAMod.zip und PDAModPlugin_SoilCondition.ZIP dürfen in keinem anderen Mod eingebettet werden. - Allerdings ist es erlaubt, sie in ein Mod-pack einzufügen, wenn die Original-Hash-Werte des Mods erhalten bleiben, d.h. unverändert sind.

Bitte lade diesen Mod NICHT auf andere Hosting-Seiten - das kann ich selbst, wenn nötig!

Benutzen Sie den original Download-Link!


Credits:
Script: Decker_MMIV.
Graphics: KaosKnite, JakobT, GIANTS, Decker_MMIV and others.
Translation 'DE': JakobT, webalizer.
Translation 'RU': Gonimy_Vetrom, VAHA.
Translation 'CZ': KingFrame, Albi.
Translation 'FR': Marxtai, Dural.
Translation 'IT': DD ModPassion.
