# __PROJEKT__
<One sentence: what it is.> License: __SPDX__.

## Befehle
make build | lint | test | acceptance | e2e | audit | image
Vor jedem Commit: make lint test. Generierten Code mit stagen.

## Aufbau
<5-10 Zeilen: Verzeichnisse und ihre Verantwortung, Kernmodule>

## Regeln
- Einfachste Form, die die Anforderung erfuellt. Keine unbestellten Funktionen.
- Sicherheitsentscheidungen nur ueber die Kernmodule: <Liste>.
- Jede neue Quelldatei mit SPDX-Header. Commit nennt die Anforderungs-ID.
- Tests entfernen GIT_* vor jedem git-Aufruf und schreiben nie in die git-Config.
- Code, Kommentare, Commits, PRs, Nutzerdoku: Englisch.
- Tests nie abschwaechen oder loeschen, um gruen zu werden.

## Stolperfallen
<wird in der Retro ergaenzt: je wiederkehrendem Fehler eine Zeile>
