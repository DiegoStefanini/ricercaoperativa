# Ricerca Operativa

Workflow generale: `../CLAUDE.md`.

- Docente: Stefano Novellani (stefano.novellani@unipi.it), a.a. 2026-27.
- Testo: Bigi, Frangioni, Gallo, Pallottino, Scutellà, "Appunti di Ricerca Operativa" = `slide/AppuntiRO.pdf`. Le slide citano le pagine delle dispense ("PAG 9-47 DISPENSE").
- Esame: scritto + orale (orale = ±5 punti sul voto dello scritto). Solo calcolatrice non programmabile. Programma e regole complete in `programma.md`.
- Prove in itinere (esonerano dallo scritto se "quasi sufficiente"): **prova 1 a metà novembre** = 1 esercizio di modellazione vero/falso su un modello parziale + domanda aperta, e 3 esercizi sui grafi. **Prova 2 a fine corso** = 4 esercizi su PL e Branch&Bound. Le slide dicono "tre prove", `programma.md` dice "due": da chiarire.

## Mappa materiale ↔ lezione

| Giorno | Materiale (`slide/`) | Grezzo | Argomento |
|---|---|---|---|
| prima lezione | `IntroRO2026.pdf` | — | introduzione ed esame. **Nessun capitolo, per scelta di Diego**: l'unica parte utile è l'esempio Pintel di risoluzione grafica (p. 28-29), già nel riquadro sul gradiente. |
| 18 set 2026 | `TecnicheModellazioneV_v4.pdf` p. 1-21 | `grezzi/2026-09-18.md` | fonderia, zaino, relazioni logiche (negazione, implicazione, and, or, xor) |
| 22 set 2026 | `TecnicheModellazioneV_v4.pdf` p. 20-33 (p. 33 solo in parte) | `grezzi/2026-09-22.md`, registrazione `slide/registrazioni/2026-09-22.txt` | ripasso or/xor, albero di copertura, commesso viaggiatore, assegnamento, frequenze (fino a x_if + x_jf ≤ 1) |

Da riprendere: `TecnicheModellazioneV_v4.pdf` p. 33, **il vincolo y_f ≥ x_if** che lega y e x nell'assegnamento di frequenze (il prof: "ripartiamo da qua", "ci torniamo venerdì"), poi grafo coloring e p. 34 (ordinamento di lavori su macchine; 139 pagine in tutto). Nella dispensa c'è una `nota` "il modello non è ancora finito" da sostituire. `slide/EserciziarioTecincheModellazione.pdf` = esercizi di modellazione, utili per la prova 1.

Pagine = pagine del PDF. Dalla p. 5 il numero stampato sulla slide è PDF + 1 (la v4 ha tolto una slide doppia della fonderia ma non ha rinumerato): quando Diego dice "slide N" può intendere il numero stampato.

v4 (24 set 2026) rispetto alla v3: tolta la slide doppia della fonderia, riformulati i vincoli 5, 6 e 10 delle relazioni logiche, corretto "j ∈ A" nell'assegnamento, aggiunto "(2ⁿ − 2)" al numero di vincoli dell'MST. Modelli invariati.

Refuso nelle slide (ancora nella v4): p. 17 "x_D ≥ x_A + x_B + x_D − 2" deve essere x_C al posto dell'ultimo x_D.

Il grezzo del 22 set contiene una "formulazione equivalente" dell'MST (vincoli ≤ |S| − 1) che il prof **non** ha fatto (verificato sulla registrazione): non va in dispensa. In aula si è discusso invece Σ x = n − 1 (non basta da solo, ridondante con i tagli).

Detto solo a voce (22 set), in dispensa: niente <, >, ≠, |x|, min/max, prodotti di variabili; "s.t." = subject to; modelli diversi per lo stesso problema vanno bene, l'efficienza non conta nel corso; forma aggregata 2x_C ≤ x_A + x_B; trappola x_C ≥ x_A + x_B per lo xor.
