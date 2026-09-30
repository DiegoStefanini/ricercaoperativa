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
| 25 set 2026 | `TecnicheModellazioneV_v4.pdf` p. 33-49 (p. 49 solo in parte) | registrazione `slide/registrazioni/2026-09-25.txt` (solo audio: niente schermo condiviso, tutto alla lavagna) | fine frequenze (y_f ≥ x_if, ogni antenna una frequenza), moli e barche con grafo di incompatibilità (= stesso modello delle frequenze = graph coloring), riformulazione per schedulazioni: set-partitioning / covering / packing, home restaurant (testo, variabili, budget, obiettivo, vincolo del bonus z ≤ Σx_c / 4) |
| 29 set 2026 | `TecnicheModellazioneV_v4.pdf` p. 44-65 | registrazione `slide/registrazioni/2026-09-29.txt` | ripasso home restaurant, secondo vincolo del bonus, disponibilità ingredienti (3 forme), budget; instradamento per cammini (modello finito alla lavagna); problemi su reti: fognature, variabili, obiettivo, conservazione del flusso, deficit b_i |

Da riprendere: `TecnicheModellazioneV_v4.pdf` **p. 66** (stampata 67), ultima slide delle fognature, poi p. 67 flusso di costo minimo. Il 29 set si è fermato su p. 65 (stampata 66): conservazione del flusso e deficit (sorgente / pozzo / transito), senza dire da dove riparte. La dispensa arriva fin qui (25 e 29 set scritti da registrazione e slide, senza grezzo: Diego era assente). In dispensa mancano, della p. 66: il dominio x_ij ≥ 0 e la nota su restrizioni / costi fissi degli archi (variabile binaria legata al flusso). `slide/EserciziarioTecincheModellazione.pdf` = esercizi di modellazione, utili per la prova 1.

Pagine = pagine del PDF. Dalla p. 5 il numero stampato sulla slide è PDF + 1 (la v4 ha tolto una slide doppia della fonderia ma non ha rinumerato): quando Diego dice "slide N" può intendere il numero stampato.

v4 (24 set 2026) rispetto alla v3: tolta la slide doppia della fonderia, riformulati i vincoli 5, 6 e 10 delle relazioni logiche, corretto "j ∈ A" nell'assegnamento, aggiunto "(2ⁿ − 2)" al numero di vincoli dell'MST. Modelli invariati.

Il grezzo del 22 set contiene una "formulazione equivalente" dell'MST (vincoli ≤ |S| − 1) che il prof **non** ha fatto (verificato sulla registrazione): non va in dispensa. In aula si è discusso invece Σ x = n − 1 (non basta da solo, ridondante con i tagli).

Detto solo a voce (22 set), in dispensa: niente <, >, ≠, |x|, min/max, prodotti di variabili; "s.t." = subject to; modelli diversi per lo stesso problema vanno bene, l'efficienza non conta nel corso; forma aggregata 2x_C ≤ x_A + x_B; trappola x_C ≥ x_A + x_B per lo xor.

Detto solo a voce (25 set): ogni volta che un modello ha due famiglie di variabili serve un vincolo che le leghi, sennò il solutore mette tutte le y a 0; il tempo non diventa variabile se arrivo e durata sono dati (l'incompatibilità si calcola prima, sui dati); i nomi partizione / copertura / riempimento sono "nomenclatura" che non chiederà ("e poi mi smentirò"); la generazione dinamica delle variabili non si fa nel corso; all'esame e al compitino l'esercizio di modellazione parte da un testo. (29 set) nell'instradamento un esportatore può avere 2 container: il parametro a vale 0, 1 o 2 (correzione di uno studente).

Nelle registrazioni del 29 set il prof ha aperte anche `LezioneLivorno1_v2.pdf` e `LezioneLivorno2_v3.pdf`: non usate a lezione, non sono in `slide/`.

In dispensa (scelte fatte): "zaino" e "relazioni logiche" sono una sezione sola; l'esempio delle tre barche (turni, matrice a_ip) e i vincoli degli ingredienti sono **calcolati da Typst** dai dati (`barche`, `piatti`); la soluzione disegnata delle fognature (x21 = 1, x15 = 2, x43 = 0,5, x35 = 1,5, costo 20,5) **non è del prof**: è in un riquadro `base`, aggiunta per controllare i vincoli (è anche l'ottimo).
