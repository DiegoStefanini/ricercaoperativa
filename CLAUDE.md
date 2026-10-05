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
| 18 set 2026 | `TecnicheModellazioneV_v5.pdf` p. 1-21 | `grezzi/2026-09-18.md` | fonderia, zaino, relazioni logiche (negazione, implicazione, and, or, xor) |
| 22 set 2026 | `TecnicheModellazioneV_v5.pdf` p. 20-33 (p. 33 solo in parte) | `grezzi/2026-09-22.md`, registrazione `slide/registrazioni/2026-09-22.txt` | ripasso or/xor, albero di copertura, commesso viaggiatore, assegnamento, frequenze (fino a x_if + x_jf ≤ 1) |
| 25 set 2026 | `TecnicheModellazioneV_v5.pdf` p. 33-49 (p. 49 solo in parte) | registrazione `slide/registrazioni/2026-09-25.txt` (solo audio: niente schermo condiviso, tutto alla lavagna) | fine frequenze (y_f ≥ x_if, ogni antenna una frequenza), moli e barche con grafo di incompatibilità (= stesso modello delle frequenze = graph coloring), riformulazione per schedulazioni: set-partitioning / covering / packing, home restaurant (testo, variabili, budget, obiettivo, vincolo del bonus z ≤ Σx_c / 4) |
| 29 set 2026 | `TecnicheModellazioneV_v5.pdf` p. 44-65 | registrazione `slide/registrazioni/2026-09-29.txt` | ripasso home restaurant, secondo vincolo del bonus, disponibilità ingredienti (3 forme), budget; instradamento per cammini (modello finito alla lavagna); problemi su reti: fognature, variabili, obiettivo, conservazione del flusso, deficit b_i |
| 2 ott 2026 | `TecnicheModellazioneV_v5.pdf` p. 66-100 (saltate p. 77-80 multicommodity e p. 87-88 unione di intervalli) | registrazione `slide/registrazioni/2026-10-02.txt` | flusso di costo minimo con capacità, cammino minimo come flusso (soluzione 0,5 → binarie), variabili a valori discreti, semicontinue, costi di setup e big-M, funzioni lineari a tratti, fonderia II solo materiale B |

Da riprendere: `TecnicheModellazioneV_v5.pdf` **p. 101** (stampata 102), fonderia II materiale A: il prof ha annunciato i prezzi "a scaglioni" (prima parte a un prezzo, il resto a un altro), con le binarie legate in modo diverso. La dispensa arriva fin qui. `slide/EserciziarioTecincheModellazione.pdf` = esercizi di modellazione, utili per la prova 1.

Pagine = pagine del PDF (la v5 ha le stesse pagine della v4, solo refusi corretti). Dalla p. 5 il numero stampato sulla slide è PDF + 1 (la v4 ha tolto una slide doppia della fonderia ma non ha rinumerato): quando Diego dice "slide N" può intendere il numero stampato.

In dispensa ma **solo a voce** (verificato sulle registrazioni, non tagliare): cosa non si può scrivere in un modello, forma aggregata 2x_C ≤ x_A + x_B, trappola dello xor, Σx = n − 1 nell'MST, legame fra due famiglie di variabili, tempo non variabile, "nomenclatura", parametro a ∈ {0, 1, 2}, nodo con b ≠ 0 non di transito, continue bastano per il solo valore del cammino minimo, x_ij ≤ y_ij nelle condotte discrete, M "se il massimo è 10 metti 11 o 20", ε·z per il < stretto (non all'esame), due scritture del materiale B. **Non del prof** (non aggiungere): la formulazione MST con ≤ |S| − 1 del grezzo del 22 set.
