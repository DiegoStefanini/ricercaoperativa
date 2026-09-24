#import "@preview/cetz:0.4.2": canvas, draw

#set document(title: "Ricerca Operativa — Dispensa")
#set page(paper: "a4", margin: 2.2cm, numbering: "1")
#set text(lang: "it", size: 11pt)
#set par(justify: true)
#set heading(numbering: "1.1")
#show heading.where(level: 1): it => { pagebreak(weak: true); it }
#show raw.where(block: true): block.with(fill: luma(245), inset: 8pt, radius: 4pt, width: 100%)
#show raw.where(block: false): box.with(fill: luma(240), inset: (x: 3pt), outset: (y: 3pt), radius: 2pt)
#set table(stroke: 0.5pt + luma(180), inset: 6pt)
#show table.cell.where(y: 0): strong
#show grid: it => block(breakable: false, it)

#let blu = rgb("#3b6fd8")
#let verde = rgb("#2e9e5b")
#let grigio = luma(170)

// osservazione del prof, trappola
#let nota(body) = block(
  fill: rgb("#eef4ff"), stroke: (left: 3pt + blu),
  inset: 10pt, width: 100%, body,
)
// prerequisito non spiegato in aula, aggiunto su richiesta
#let base(titolo, body) = block(
  fill: rgb("#eefaf2"), stroke: (left: 3pt + verde),
  inset: 10pt, width: 100%,
)[*Da sapere — #titolo* #h(0.3em) #text(8pt, fill: verde)[(aggiunto, non spiegato in aula)] \ #body]

#let mono(s) = text(font: "DejaVu Sans Mono", s)
// conto in colonna: righe allineate a destra, riga sopra il risultato
#let conto(op: "+", sopra: (), ..righe) = {
  let r = righe.pos()
  let celle = ()
  for s in sopra { celle += ([], text(fill: grigio, mono(s))) }
  for (i, x) in r.slice(0, -1).enumerate() {
    if i == 2 { celle.push(grid.hline(start: 1, stroke: 0.5pt)) }
    celle += (if i == 1 { op } else { [] }, mono(x))
  }
  celle += (grid.hline(start: 1, stroke: 0.8pt), [], strong(mono(r.last())))
  box(grid(columns: 2, align: right, inset: (x: 2pt, y: 3pt), ..celle))
}
// passaggi etichettati: ((etichetta, bit), ...), riga sopra l'ultimo
#let passi(..righe) = {
  let r = righe.pos()
  let celle = ()
  for (i, (e, x)) in r.enumerate() {
    if i == r.len() - 1 { celle.push(grid.hline(stroke: 0.8pt)) }
    celle += (text(8pt, fill: gray, e), if i == r.len() - 1 { strong(mono(x)) } else { mono(x) })
  }
  box(grid(columns: 2, align: (left, right), inset: (x: 3pt, y: 3pt), ..celle))
}
// pila di livelli: ogni elemento è (testo, colore di sfondo)
#let pila(larghezza: 3.4cm, ..livelli) = stack(..livelli.pos().map(((t, c)) =>
  box(width: larghezza, inset: 5pt, stroke: 0.6pt, fill: c, align(center, text(9pt, t)))))
#let figura(corpo, didascalia) = figure(corpo, caption: didascalia, kind: image, supplement: none)

// tabella di verità calcolata: nomi = ("A", "B"), ogni colonna = (titolo, funzione bit -> bool)
#let tv(nomi, ..col) = {
  let n = nomi.len()
  let c = col.pos()
  let righe = range(calc.pow(2, n)).map(k => range(n).map(i => calc.rem(calc.quo(k, calc.pow(2, n - 1 - i)), 2)))
  block(breakable: false, table(columns: n + c.len(), align: center, inset: 5pt,
    ..nomi.map(v => $x_#v$), ..c.map(((t, f)) => t),
    ..righe.map(b => b.map(v => [#v]) + c.map(((t, f)) =>
      if f(b) { text(fill: verde, weight: "bold")[✓] } else { text(fill: red, weight: "bold")[✗] })).flatten()))
}
// grafo: nodi = (nome: (x, y)), lati = ((a, b), ...), scelti = lati evidenziati (x = 1),
// costi = ("a-b": c), colori = (nome: colore), extra = disegni CeTZ sotto il grafo
#let grafo(nodi, lati, scelti: (), costi: (:), colori: (:), extra: (), scala: 0.8) = canvas(length: scala * 1cm, {
  import draw: *
  for e in extra { e }
  for (a, b) in lati {
    let sel = scelti.any(((c, d)) => (c == a and d == b) or (c == b and d == a))
    line(nodi.at(a), nodi.at(b), stroke: if sel { 1.6pt + blu } else { (paint: grigio, thickness: 0.6pt, dash: "dashed") })
    let c = costi.at(a + "-" + b, default: none)
    if c != none {
      let (p, q) = (nodi.at(a), nodi.at(b))
      content(((p.at(0) + q.at(0)) / 2, (p.at(1) + q.at(1)) / 2), box(fill: white, inset: 1.5pt, text(7pt, str(c))))
    }
  }
  for (n, p) in nodi {
    circle(p, radius: 0.3, fill: colori.at(n, default: white), stroke: 0.7pt)
    content(p, text(8pt, n))
  }
})

#let si = text(fill: verde, weight: "bold")[✓]
#let no = text(fill: red, weight: "bold")[✗]

#align(center)[
  #v(4cm)
  #text(24pt, weight: "bold")[Ricerca Operativa]
  #v(0.3cm)
  #text(14pt)[Diego Stefanini — prof. Stefano Novellani, a.a. 2026-27]
]
#v(1cm)
#outline(depth: 2)

= Tecniche di modellazione

Un modello ha sempre tre pezzi: *variabili* (le decisioni), *funzione obiettivo* (cosa minimizzo o massimizzo), *vincoli* (cosa devo rispettare).

#base[equazione lineare in più variabili][
Un'espressione è *lineare* se ogni variabile compare *da sola, alla prima potenza, moltiplicata solo per un numero*, e i termini si sommano:
$ a_1 x_1 + a_2 x_2 + dots + a_n x_n = b $
con $a_1, dots, a_n, b$ numeri fissi. Vale lo stesso per $<=$ e $>=$ (disequazioni lineari).

#grid(columns: (1fr, auto, 1fr), inset: 4pt,
  [$4x_1 + x_2 + 0.6x_3 >= 3250$], si, [lineare],
  [$x_1 + 3 >= 2 x_2 - 7$], si, [lineare (sposto tutto a sinistra)],
  [$x_1 dot x_2 <= 5$], no, [prodotto di due variabili],
  [$x_1^2 + x_2 <= 5$], no, [potenza],
  [$x_1 / (x_1 + x_2) >= 0.2$], no, [divisione per variabili (ma si può rendere lineare, vedi sotto)],
)
Perché conta: se funzione obiettivo e vincoli sono lineari, il problema è di *Programmazione Lineare* (PL) e ci sono algoritmi efficienti per risolverlo.
]

#nota[*Cosa non si può scrivere in un modello* (errori che all'esame escono sempre):
- solo $<=$, $>=$ e $=$: niente disuguaglianze strette ($<$, $>$) e niente $!=$ ("$x != y$" non si può scrivere);
- niente prodotti o divisioni fra variabili, niente valore assoluto $|x|$, niente $min$ o $max$ di variabili dentro i vincoli: solo espressioni lineari.

"s.t." sotto la funzione obiettivo sta per _subject to_, "soggetto a": da lì in poi ci sono i vincoli. Ricordarsi sempre di scrivere anche il *dominio* delle variabili ($x >= 0$, $x in {0, 1}$…).

Lo stesso problema si può scrivere con *modelli diversi*, alcuni più efficienti di altri. In questo corso l'efficienza non conta: un modello che funziona è accettabile, anche con qualche vincolo in più non necessario.]

== Il problema della fonderia (mix di produzione)

#align(center, stack(dir: ltr, spacing: 0.8em,
  grid(columns: 1, gutter: 3pt,
    ..(("materiale 1", "4% Si · 0,45% Mn · 0,025 €/kg"), ("materiale 2", "1% Si · 0,50% Mn · 0,030 €/kg"),
       ("materiale 3", "0,6% Si · 0,40% Mn · 0,018 €/kg"), ("manganese puro", "100% Mn · 10 €/kg")).enumerate().map(((i, (m, d))) =>
      box(stroke: 0.6pt, inset: 5pt, width: 9cm, fill: if i == 3 { rgb("#fff3c4") } else { rgb("#eef4ff") })[
        $x_#(i + 1)$ kg di *#m* #h(1fr) #text(8pt, d)])),
  align(horizon, text(20pt)[→]),
  align(horizon, box(stroke: 1pt, inset: 8pt, radius: 4pt)[
    *1000 pezzi da 1 kg* \
    #text(9pt)[silicio fra 3,25% e 5,5% \ manganese almeno 0,45%]]),
))

*Variabili*: $x_1, x_2, x_3$ = kg di materiale ferroso 1, 2, 3 nel mix; $x_4$ = kg di manganese puro.

*Da percentuali a vincoli*: il silicio nel mix, in kg, è $0.04x_1 + 0.01x_2 + 0.006x_3$. Deve essere almeno il 3,25% di 1000 kg, cioè 32,5 kg. Moltiplico tutto per 1000 per togliere le virgole:

#align(center, grid(columns: 3, align: (right, center, left), inset: 4pt,
  [$0.04x_1 + 0.01x_2 + 0.006x_3$], [$>=$], [$32.5$],
  [$40x_1 + 10x_2 + 6x_3$], [$>=$], [$32500$ #h(1em) #text(9pt, fill: gray)[(× 1000)]],
))

Stesso ragionamento per il manganese: $0.0045x_1 + 0.005x_2 + 0.004x_3 + x_4 >= 4.5$, moltiplicato per 10 000.

#grid(columns: (1.2fr, 1fr), gutter: 1em, align: horizon,
$
min z = & 0.025x_1 + 0.030x_2 + 0.018x_3 + 10x_4 \
& x_1 + x_2 + x_3 + x_4 = 1000 \
& 40x_1 + 10x_2 + 6x_3 >= 32500 \
& 40x_1 + 10x_2 + 6x_3 <= 55000 \
& 45x_1 + 50x_2 + 40x_3 + 10000x_4 >= 45000 \
& x_1, x_2, x_3, x_4 >= 0
$,
text(9pt)[
  ← minimizzo il costo \
  ← totale da produrre \
  ← silicio minimo \
  ← silicio massimo \
  ← manganese minimo \
  ← non negatività
])

Il modello si può scrivere in *forma generale*: al posto dei numeri metto dei *parametri*: $n = 4$ materiali, $K = 1000$ kg, $c_i$ costo al kg, $s_i$ e $m_i$ percentuali di silicio e manganese del materiale $i$, $underline(s)$ e $overline(s)$ silicio minimo e massimo, $underline(m)$ manganese minimo.

$
min z = sum_(i=1)^n c_i x_i quad "s.t." quad sum_(i=1)^n x_i = K, quad underline(s) K <= sum_(i=1)^(n-1) s_i x_i <= overline(s) K, quad sum_(i=1)^n m_i x_i >= underline(m) K, quad x_i >= 0
$

#nota[La somma del silicio arriva a $n - 1$: il manganese puro (materiale 4) non contiene silicio.

Un'*istanza* è una configurazione concreta del problema: il modello generale con dei valori al posto dei parametri. Quello con i numeri sopra è un'istanza.]

Un vincolo che capita spesso è quello *in percentuale*:

"Il materiale 1 deve essere almeno il 20% dei materiali ferrosi usati."

#align(center, stack(dir: ltr, spacing: 1em,
  box(stroke: 0.6pt + red, inset: 8pt)[$display(x_1 / (x_1 + x_2 + x_3)) >= 0.2$ \ #text(8pt, fill: red)[non lineare: divido per variabili]],
  align(horizon)[moltiplico per \ il denominatore →],
  box(stroke: 0.6pt + verde, inset: 8pt)[$x_1 >= 0.2 (x_1 + x_2 + x_3)$ \ #text(8pt, fill: verde)[lineare]],
))

#nota[Si può moltiplicare senza girare il $>=$ perché il denominatore è una somma di quantità $>= 0$. Lo stesso trucco serve quando chiedono una *media pesata*.]

#base[gradiente][
Per una funzione lineare $z = c_1 x_1 + c_2 x_2$ il *gradiente* è il vettore dei coefficienti, $nabla z = (c_1, c_2)$. Indica la direzione in cui $z$ *cresce più in fretta*.

#grid(columns: (auto, 1fr), gutter: 1.2em, align: horizon,
canvas(length: 0.6cm, {
  import draw: *
  line((0, 0), (0, 9), mark: (end: "stealth")); content((0, 9.5), text(8pt)[$x_C$])
  line((0, 0), (6, 0), mark: (end: "stealth")); content((6.6, 0), text(8pt)[$x_P$])
  line((0, 0), (4, 0), (4, 1), (1, 7), (0, 7), close: true, fill: rgb("#eef4ff"), stroke: 0.8pt + blu)
  content((1.5, 1.5), text(8pt)[ammissibile])
  for (k, a, b) in ((10, 0, 2), (22, 2.4, 4.4)) {
    line((a, (k - 5 * a) / 2), (b, (k - 5 * b) / 2), stroke: (paint: gray, dash: "dashed"))
  }
  content((2.4, 0.3), text(7pt, fill: gray)[$z = 10$])
  content((4.2, 4.6), text(7pt, fill: gray)[$z = 22$])
  line((0.3, 3.8), (2.8, 4.8), stroke: 1.5pt + red, mark: (end: "stealth"))
  content((1.6, 5.9), text(8pt, fill: red)[$nabla z = (5, 2)$])
  circle((4, 1), radius: 0.18, fill: red)
  content((6.4, 1.3), text(8pt)[ottimo $(4, 1)$])
}),
[
  Esempio: $max z = 5x_P + 2x_C$ con $x_P <= 4$, $x_C <= 7$, $2x_P + x_C <= 9$.

  - Le rette tratteggiate sono *linee di livello*: punti con lo stesso $z$. Sono perpendicolari al gradiente.
  - Per un *max* sposto la retta nella direzione del gradiente finché tocca ancora la regione: l'ultimo punto toccato è l'ottimo, $(4, 1)$ con $z = 22$.
  - Per un *min* vado nella direzione opposta, $-nabla z$.
])
]

== Variabili binarie: il problema dello zaino

Un investitore ha un capitale $B$ e $n$ progetti. Il progetto $i$ costa $c_i$ e rende $w_i$. Quali progetti finanzio per rendere il più possibile senza sforare il budget?

#align(center, box(width: 12cm)[
  #text(9pt)[budget $B$] \
  #box(width: 100%, stroke: 1pt, inset: 3pt, stack(dir: ltr, spacing: 3pt,
    box(width: 3.2cm, height: 0.9cm, fill: rgb("#eef4ff"), stroke: 0.6pt, align(center + horizon)[$x_1 = 1$]),
    box(width: 2.4cm, height: 0.9cm, fill: rgb("#eef4ff"), stroke: 0.6pt, align(center + horizon)[$x_3 = 1$]),
    box(width: 3.6cm, height: 0.9cm, fill: rgb("#eef4ff"), stroke: 0.6pt, align(center + horizon)[$x_4 = 1$]),
    align(horizon, text(8pt, fill: gray)[avanzo])))
  #v(4pt)
  #stack(dir: ltr, spacing: 4pt, text(9pt)[restano fuori:],
    box(width: 2.8cm, height: 0.7cm, fill: luma(230), stroke: 0.6pt, align(center + horizon)[$x_2 = 0$]),
    box(width: 3.4cm, height: 0.7cm, fill: luma(230), stroke: 0.6pt, align(center + horizon)[$x_5 = 0$]))
])

#grid(columns: (1fr, 1fr), gutter: 1.5em, align: horizon,
$
x_i = cases(1 "se finanzio il progetto" i, 0 "altrimenti") \
max z = sum_(i=1)^n w_i x_i \
"s.t." sum_(i=1)^n c_i x_i <= B \
x_i in {0, 1} quad forall i in I
$,
[
  Le variabili *binarie* (o booleane) servono per le decisioni sì/no.

  Il trucco: moltiplicando per $x_i$, nella somma entrano *solo i progetti scelti* ($x_i = 1$); gli altri valgono 0.

  $sum c_i x_i <= B$ è il *vincolo di budget*.
])

== Relazioni logiche

Tutte le variabili qui sono binarie: $x_A = 1$ se finanzio il progetto A. Nelle tabelle, ✓ = combinazione permessa dal vincolo.

#nota[Sono esempi separati: non devono valere tutti insieme.]

#block(sticky: true)[Il caso più semplice: *esattamente, almeno o al massimo uno* fra A e B.]

#block(breakable: false, grid(columns: (auto, 1fr), gutter: 1.5em, align: horizon,
tv(("A", "B"),
  ($x_A + x_B = 1$, b => b.at(0) + b.at(1) == 1),
  ($x_A + x_B >= 1$, b => b.at(0) + b.at(1) >= 1),
  ($x_A + x_B <= 1$, b => b.at(0) + b.at(1) <= 1),
),
[
  1. *esattamente uno* fra A e B: $x_A + x_B = 1$
  2. *almeno uno*: $x_A + x_B >= 1$
  3. *al massimo uno*: $x_A + x_B <= 1$

  Funziona con più variabili e un termine noto diverso: "non più di due fra A, B, C" è $x_A + x_B + x_C <= 2$.

  *Negazione*: B = non A si scrive $x_B = 1 - x_A$ (è il caso 1).
]))

#block(sticky: true)[*Implicazione*: se finanzio A, allora devo finanziare anche C.]

#block(breakable: false, grid(columns: (auto, 1fr), gutter: 1.5em, align: horizon,
tv(("A", "C"), ($x_A <= x_C$, b => b.at(0) <= b.at(1))),
[
  4. "Se investo in A devo investire in C; se non investo in A, C è libero": $x_A <= x_C$.

  Se $x_A = 1$ il vincolo forza $x_C = 1$; se $x_A = 0$ diventa $0 <= x_C$, sempre vero.

  Il "se e solo se" (relazione biunivoca) è l'uguaglianza: $x_A = x_C$.
]))

#block(sticky: true)[*And*: si vuole $C = A and B$.]

#block(breakable: false, grid(columns: (auto, 1fr), gutter: 1.5em, align: horizon,
tv(("A", "B", "C"),
  ([5], b => b.at(2) >= b.at(0) + b.at(1) - 1),
  ([6], b => b.at(2) <= b.at(0) and b.at(2) <= b.at(1)),
  ([5 + 6], b => b.at(2) == b.at(0) * b.at(1)),
),
[
  5. "Se finanzio *sia A che B* devo finanziare C; altrimenti C è libero": \ $x_C >= x_A + x_B - 1$ \
     #text(9pt)[(a destra c'è 1 solo se $x_A = x_B = 1$, altrimenti $<= 0$)]
  6. "Posso finanziare C *solo se* finanzio A e B contemporaneamente": \ $x_C <= x_A$ e $x_C <= x_B$

  Insieme danno $C = A and B$: la colonna 5 + 6 è ✓ solo dove $x_C = x_A dot x_B$.

  Con tre progetti: "se finanzio A, B e C devo finanziare D" è $x_D >= x_A + x_B + x_C - 2$. In generale con $k$ progetti il $-1$ diventa $-(k - 1)$.
]))

#nota[I due vincoli del 6 si possono sommare in uno solo: $2 x_C <= x_A + x_B$, cioè $x_C <= (x_A + x_B) / 2$. Se almeno uno fra A e B vale 0, a destra c'è al massimo $1/2$, e una variabile binaria $<= 1/2$ può solo valere 0. Stessa cosa per il 7 più avanti: $2 x_C >= x_A + x_B$. Per l'esame le due scritture valgono uguale; in pratica i vincoli separati sono in genere più forti.]

#block(sticky: true)[*Or*: si vuole $C = A or B$.]

#block(breakable: false, grid(columns: (auto, 1fr), gutter: 1.5em, align: horizon,
tv(("A", "B", "C"),
  ([7], b => b.at(2) >= b.at(0) and b.at(2) >= b.at(1)),
  ([8], b => b.at(2) <= b.at(0) + b.at(1)),
  ([7 + 8], b => b.at(2) == calc.max(b.at(0), b.at(1))),
),
[
  7. "*Devo* finanziare C se finanzio almeno uno fra A e B": \ $x_C >= x_A$ e $x_C >= x_B$
  8. "*Posso* finanziare C solo se finanzio almeno uno fra A e B": \ $x_C <= x_A + x_B$

  Insieme danno $C = A or B$.
]))

#block(sticky: true)[*Or esclusivo*: si vuole C finanziato quando c'è esattamente uno fra A e B.]

#block(breakable: false, grid(columns: (auto, 1fr), gutter: 1.5em, align: horizon,
tv(("A", "B", "C"),
  ([9], b => b.at(2) >= b.at(0) - b.at(1) and b.at(2) >= b.at(1) - b.at(0)),
  ([10], b => b.at(2) <= 2 - b.at(0) - b.at(1) and b.at(2) <= b.at(0) + b.at(1)),
  ([9 + 10], b => b.at(2) == calc.rem(b.at(0) + b.at(1), 2)),
),
[
  9. "*Devo* finanziare C se finanzio esattamente uno fra A e B": \ $x_C >= x_A - x_B$ e $x_C >= x_B - x_A$
  10. "*Posso* finanziare C solo se finanzio esattamente uno fra A e B": \ $x_C <= 2 - x_A - x_B$ e $x_C <= x_A + x_B$

  Insieme danno $C = A xor B$.
]))

#nota[Trappola sul 9: viene da scrivere $x_C >= x_A + x_B$. Ma con A e B entrambi finanziati diventa $x_C >= 2$, che una binaria non può rispettare: il problema diventa *inammissibile* (nessuna soluzione rispetta tutti i vincoli). Il testo del 9 dice solo quando C è obbligatorio; con A e B entrambi a 1 non dice niente, quindi C deve restare libero.]

#nota[Schema che si ripete: il "*devo*" (se … allora C) è un vincolo $x_C >= dots$ che spinge C a 1; il "*posso solo se*" è un vincolo $x_C <= dots$ che tiene C a 0.]

== Scegliere lati di un grafo: albero di copertura e commesso viaggiatore

Nello zaino le variabili binarie sceglievano un *sottoinsieme* dei progetti. È il loro uso generale: le variabili binarie selezionano sottoinsiemi di un insieme dato e, con i vincoli giusti, il sottoinsieme scelto può avere una struttura complessa quanto si vuole. Qui l'insieme è quello dei *lati di un grafo*, e la struttura richiesta è prima un albero, poi un ciclo.

#base[grafi][
Un *grafo non orientato* $G = (V, E)$ è un insieme di *vertici* $V$ (i pallini) e di *lati* $E$ (le linee). Un lato unisce due vertici e si scrive ${i, j}$: le graffe dicono che l'ordine non conta, ${i, j}$ e ${j, i}$ sono lo stesso lato. Con $n = |V|$ si indica il numero di vertici ($|dot|$ = numero di elementi di un insieme). Nei grafi *orientati* le linee hanno un verso e si chiamano *archi*, $(i, j)$; qui sono non orientati e si chiamano *lati* (se il prof dice "arco", qui leggi "lato").

#align(center, grid(columns: 4, column-gutter: 1.6em, row-gutter: 6pt, align: center + bottom,
  grafo((("1"): (0, 1.6), ("2"): (1.6, 1.6), ("3"): (0, 0), ("4"): (1.6, 0)),
    (("1", "2"), ("1", "3"), ("2", "4"), ("3", "4"), ("1", "4"))),
  grafo((("1"): (0, 1.6), ("2"): (1.6, 1.6), ("3"): (0, 0), ("4"): (1.6, 0)),
    (("1", "2"), ("1", "3"), ("2", "4"), ("3", "4"), ("1", "4"), ("2", "3")),
    scelti: (("1", "2"), ("1", "3"), ("1", "4"))),
  grafo((("1"): (0, 1.6), ("2"): (1.6, 1.6), ("3"): (0, 0), ("4"): (1.6, 0)),
    (("1", "2"), ("1", "3"), ("2", "4"), ("3", "4"), ("1", "4"), ("2", "3")),
    scelti: (("1", "2"), ("2", "4"), ("4", "3"), ("3", "1"))),
  grafo((("1"): (0, 1.6), ("2"): (0, 0.8), ("3"): (0, 0), ("a"): (1.6, 1.6), ("b"): (1.6, 0.8), ("c"): (1.6, 0)),
    (("1", "a"), ("1", "b"), ("2", "a"), ("2", "c"), ("3", "b"), ("3", "c"))),
  text(8pt)[un grafo connesso], text(8pt)[grafo completo, \ in blu un albero], text(8pt)[in blu un ciclo \ hamiltoniano], text(8pt)[grafo bipartito],
))

- *connesso*: da ogni vertice si arriva a ogni altro camminando sui lati.
- *ciclo*: un giro di lati che torna al vertice di partenza. Un ciclo *hamiltoniano* passa per *tutti* i vertici, *una sola volta* ciascuno.
- *albero*: grafo connesso e *senza cicli*. Un albero su $n$ vertici ha sempre $n - 1$ lati. Un *albero di copertura* di $G$ è un albero fatto con lati di $G$ che tocca tutti i vertici.
- *completo*: c'è un lato fra ogni coppia di vertici.
- *bipartito*: i vertici si dividono in due gruppi e ogni lato va da un gruppo all'altro, mai dentro lo stesso gruppo.
- *taglio*: preso un sottoinsieme $S$ di vertici, $V without S$ sono i vertici *fuori* da $S$; i lati del taglio sono quelli con un estremo in $S$ e l'altro in $V without S$, cioè quelli che "escono" da $S$.
]

*Albero di copertura di costo minimo* (Minimum Spanning Tree, MST). Il grafo $G = (V, E)$ è connesso e non orientato: i vertici $V = {1, dots, n}$ sono città, i lati sono i collegamenti che si possono costruire, e il lato ${i, j}$ costa $c_(i j) > 0$. Si vuole che ogni città raggiunga ogni altra attraverso la rete, spendendo il meno possibile.

#grid(columns: (auto, 1fr), gutter: 1.5em, align: horizon,
  grafo((("1"): (0, 1.6), ("2"): (2, 2.8), ("3"): (4, 1.6), ("4"): (3, 0), ("5"): (1, 0)),
    (("1", "2"), ("2", "3"), ("3", "4"), ("4", "5"), ("5", "1"), ("1", "4"), ("2", "4")),
    scelti: (("5", "1"), ("1", "2"), ("2", "3"), ("3", "4")),
    costi: ("1-2": 4, "2-3": 3, "3-4": 2, "4-5": 5, "5-1": 1, "1-4": 6, "2-4": 7)),
  [
    *Variabili*: una per lato,
    $ x_(i j) = cases(1 "se costruisco il collegamento" {i, j} in E, 0 "altrimenti") $
    Scegliere i valori delle $x$ vuol dire scegliere un insieme di lati. Si potrebbe anche usare una variabile per ogni albero possibile, ma gli alberi sono un numero esponenziale: meglio costruire la soluzione *a pezzettini*, un lato alla volta. Nel disegno i lati in blu hanno $x_(i j) = 1$: collegano tutte le città con costo $1 + 4 + 3 + 2 = 10$, il minimo possibile per questo grafo.
  ])

*Funzione obiettivo*: come nello zaino, nella somma entrano solo i lati scelti,
$ min z = sum_({i, j} in E) c_(i j) x_(i j) $

*Vincoli*: come si scrive "la rete è connessa"? Si guarda il problema da fuori. Se la rete è connessa, qualunque gruppo di città $S$ prenda, almeno un lato scelto deve *uscire* da $S$, sennò le città di $S$ restano isolate dal resto. Questo vale per ogni $S$ che non sia vuoto e non sia tutto $V$ (se $S = V$ non c'è nessun "resto" da raggiungere). Si scrive $S subset V$, sottoinsieme *proprio* cioè diverso da $V$, e $S != emptyset$:

$ sum_(i in S, j in V without S) x_(i j) >= 1 quad forall S subset V, S != emptyset quad quad x_(i j) in {0, 1} quad forall {i, j} in E $

La somma conta i lati scelti che attraversano il taglio: deve essere almeno 1.

#grid(columns: (auto, 1fr), gutter: 1.5em, align: horizon,
  grafo((("1"): (0, 1.6), ("2"): (1.8, 1.6), ("3"): (0.9, 0), ("4"): (3.4, 0.6)),
    (("1", "2"), ("2", "3"), ("3", "1"), ("2", "4"), ("3", "4")),
    scelti: (("1", "2"), ("2", "3"), ("3", "1")),
    extra: (draw.circle((3.4, 0.6), radius: 0.65, stroke: (paint: red, dash: "dotted")),
            draw.content((3.4, -0.4), text(7pt, fill: red)[$S = {4}$]))),
  [
    Esempio: scelgo i lati del triangolo 1-2-3. Il vertice 4 resta fuori dalla rete. Con $S = {4}$ i lati che escono da $S$ sono ${2, 4}$ e ${3, 4}$, entrambi con $x = 0$: la somma fa $0 < 1$, il vincolo è violato e la soluzione è esclusa.
  ])

#nota[Il *numero di vincoli è esponenziale*: uno per ogni sottoinsieme $S$. I sottoinsiemi di $n$ vertici sono $2^n$; tolti $emptyset$ e $V$ restano $2^n - 2$ vincoli. Con 30 città sono già più di un miliardo.]

Il modello chiede solo che la rete sia *connessa*, non che sia un albero. Ma all'ottimo è per forza un albero: se i lati scelti formassero un ciclo, togliendo un lato del ciclo la rete resterebbe connessa (le città si raggiungono dall'altra parte del ciclo) e costerebbe meno, perché ogni $c_(i j) > 0$. Quindi una soluzione con un ciclo non può essere ottima.

Un'altra idea: un albero su $n$ vertici ha sempre $n - 1$ lati, quindi si potrebbe scrivere $sum_({i, j} in E) x_(i j) = n - 1$. *Da solo non basta*: $n - 1$ lati possono chiudere un ciclo e lasciare fuori un vertice (è proprio il triangolo di prima: 3 lati, $n - 1 = 3$, ma il 4 è isolato). *Insieme ai vincoli di taglio è ridondante*: non serve, perché con costi positivi l'ottimo è già un albero. Diventerebbe necessario se i costi potessero essere negativi: allora al modello converrebbe prendere lati in più, e bisognerebbe fermarlo a $n - 1$.

*Problema del commesso viaggiatore* (Travelling Salesman Problem, TSP). Il grafo $G = (V, E)$ è *completo* e non orientato: $V = {1, dots, n}$ sono città, $E = {{i, j} : i, j in V, i != j}$ contiene tutti i collegamenti possibili, ognuno con costo $c_(i j) >= 0$. Si cerca un *ciclo hamiltoniano di costo minimo*: parto da una città, visito ciascuna delle altre *una e una sola volta*, torno alla città di partenza, e il giro costa il meno possibile.

*Variabili* e *funzione obiettivo* sono le stesse dell'albero: $x_(i j) = 1$ se uso il collegamento ${i, j}$, e $min z = sum_({i, j} in E) c_(i j) x_(i j)$. Cambiano i vincoli.

Senza vincoli il $min$ non sceglierebbe nessun lato (costo 0). Prima idea: in un ciclo che passa per tutte le città ci sono tanti lati quanti vertici, quindi $sum_({i, j} in E) x_(i j) = n$. Non basta:

#grid(columns: (auto, 1fr), gutter: 1.5em, align: horizon,
  grafo((("1"): (0, 1.6), ("2"): (1.6, 1.6), ("3"): (0.8, 0), ("4"): (2.6, 0)),
    (("1", "2"), ("2", "3"), ("3", "1"), ("3", "4"), ("2", "4"), ("1", "4")),
    scelti: (("1", "2"), ("2", "3"), ("3", "1"), ("3", "4"))),
  [
    4 lati su 4 vertici, e il grafo è anche connesso, ma non è un giro: il vertice 3 tocca *tre* lati scelti, il 4 uno solo.
  ])

Nel giro invece in ogni città *entro una volta ed esco una volta*: ogni vertice tocca esattamente *due* lati scelti. Fissato il vertice $i$, sommo le $x$ dei lati che lo toccano:
$ sum_(j : {i, j} in E) x_(i j) = 2 quad forall i in V $

Questo però non basta. I lati in blu qui sotto danno a ogni vertice esattamente due lati, eppure non sono *un* giro ma *due* cicli separati (sottocicli):

#grid(columns: (auto, 1fr), gutter: 1.5em, align: horizon,
  grafo((("1"): (0, 1.6), ("2"): (1.6, 1.6), ("3"): (0.8, 0), ("4"): (3, 1.6), ("5"): (4.6, 1.6), ("6"): (4.6, 0), ("7"): (3, 0)),
    (("1", "2"), ("2", "3"), ("3", "1"), ("4", "5"), ("5", "6"), ("6", "7"), ("7", "4"), ("2", "4"), ("3", "7")),
    scelti: (("1", "2"), ("2", "3"), ("3", "1"), ("4", "5"), ("5", "6"), ("6", "7"), ("7", "4")),
    extra: (draw.circle((0.8, 1.05), radius: (1.45, 1.3), stroke: (paint: red, dash: "dotted")),
            draw.content((0.8, -0.6), text(7pt, fill: red)[$S = {1, 2, 3}$]))),
  [
    Ogni vertice ha grado 2, ma il commesso viaggiatore non passa mai dal triangolo al quadrato.

    Il rimedio sono i *vincoli di taglio dell'albero*: con $S = {1, 2, 3}$ nessun lato scelto esce da $S$ (${2, 4}$ e ${3, 7}$ hanno $x = 0$), quindi il vincolo è violato. Se il grafo è connesso e ogni vertice ha grado 2, l'unica possibilità è un solo ciclo che passa per tutti: un ciclo hamiltoniano.
  ])

$
min z = & sum_({i, j} in E) c_(i j) x_(i j) &&&& #text(9pt)[← costo del giro] \
& sum_(j : {i, j} in E) x_(i j) = 2 quad && forall i in V quad && #text(9pt)[← entro ed esco da ogni città] \
& sum_(i in S, j in V without S) x_(i j) >= 1 quad && forall S subset V, S != emptyset quad && #text(9pt)[← niente sottocicli (connessione)] \
& x_(i j) in {0, 1} quad && forall {i, j} in E
$

Il vincolo $sum x_(i j) = n$ ora è *ridondante*: se ogni vertice tocca 2 lati, sommando su tutti i vertici conto $2n$, e ogni lato l'ho contato due volte (una per estremo), quindi i lati sono $n$. Nella somma sui lati invece ${i, j}$ compare una volta sola: il lato non ha verso, ${i, j}$ e ${j, i}$ sono lo stesso.

#nota[È il modello dell'albero di copertura più i vincoli di grado 2. Non è l'unico modello del TSP: si può usare una variabile per ogni ciclo hamiltoniano (ma sono un numero esponenziale e bisogna generarli tutti), oppure sostituire i vincoli di taglio con vincoli che vietano direttamente i sottocicli.]

== Assegnamento e semi-assegnamento

Un'azienda deve assegnare delle attività a dei lavoratori. Lavoratori $L$ e attività $A$ sono due insiemi con lo stesso numero $n$ di elementi. Assegnare il lavoratore $i in L$ all'attività $j in A$ costa $c_(i j)$. Tutte le attività vanno assegnate e ogni lavoratore riceve *una e una sola* attività; si vuole il costo minimo.

#grid(columns: (auto, 1fr), gutter: 1.5em, align: horizon,
  grafo((("1"): (0, 2.4), ("2"): (0, 1.2), ("3"): (0, 0), ("a"): (2.6, 2.4), ("b"): (2.6, 1.2), ("c"): (2.6, 0)),
    (("1", "a"), ("1", "b"), ("2", "a"), ("2", "b"), ("2", "c"), ("3", "b"), ("3", "c")),
    scelti: (("1", "b"), ("2", "a"), ("3", "c")),
    extra: (draw.content((0, 3.2), text(8pt)[$L$]), draw.content((2.6, 3.2), text(8pt)[$A$]))),
  [
    Si può vedere come una scelta di lati sul grafo *bipartito* $G = (L union A, E)$: a sinistra i lavoratori, a destra le attività, un lato per ogni coppia possibile. Non tutti sanno fare tutto (il lavoratore 1 non sa fare c): l'importante è che un assegnamento completo esista.

    Un assegnamento è un insieme di lati in cui ogni vertice, di qualunque lato, tocca *esattamente un* lato scelto (in blu: 1 fa b, 2 fa a, 3 fa c).
  ])

$ x_(i j) = cases(1 "se assegno il lavoratore" i in L "all'attività" j in A, 0 "altrimenti") $

$
min z = & sum_(i in L) sum_(j in A) c_(i j) x_(i j) &&&& #text(9pt)[← costo totale] \
& sum_(j in A) x_(i j) = 1 quad && forall i in L quad && #text(9pt)[← ogni lavoratore ha una sola attività] \
& sum_(i in L) x_(i j) = 1 quad && forall j in A quad && #text(9pt)[← ogni attività ha un solo lavoratore] \
& x_(i j) in {0, 1} quad && forall i in L, j in A
$

Ogni riga è il vincolo "esattamente uno fra…" delle relazioni logiche ($x_A + x_B = 1$). Servono *tutte e due*: con solo "ogni attività ha un lavoratore" potrei dare due attività allo stesso lavoratore e lasciarne un altro senza niente; con solo l'altra, due lavoratori potrebbero fare la stessa attività. Insieme si chiamano *vincoli di assegnamento*. L'assegnamento è un *problema polinomiale*.

#base[problema polinomiale][
Un problema è *polinomiale* se esiste un algoritmo che lo risolve in un tempo che cresce come una potenza della dimensione ($n^2$, $n^3$, …) e non come $2^n$. In pratica: si risolve in fretta anche quando $n$ è grande. Non è ovvio guardando il modello: il modello elenca i vincoli, l'algoritmo è un'altra cosa.
]

Gli stessi vincoli tornano nel commesso viaggiatore su un grafo *orientato*, dove il lato $(i, j)$ va da $i$ a $j$ e non è lo stesso di $(j, i)$. Il "grado 2" si spezza in due vincoli simili a quelli dell'assegnamento: da ogni città *esco* una volta, $sum_j x_(i j) = 1$, e in ogni città *entro* una volta, $sum_i x_(i j) = 1$.

Nell'assegnamento il vincolo "esattamente uno" vale *dai due lati*: ogni lavoratore ha un'attività e ogni attività ha un lavoratore. Se vale da *un lato solo* si parla di *vincoli di semi-assegnamento*: ogni elemento del primo insieme riceve esattamente un elemento del secondo, ma un elemento del secondo può essere dato a molti (o a nessuno).

*Assegnamento di frequenze*. Una compagnia telefonica copre la città con un insieme di antenne $S = {1, dots, n}$, tutte attive. A ogni antenna va assegnata una frequenza fra quelle disponibili $F = {f_1, dots, f_m}$. Due antenne troppo vicine non possono avere la stessa frequenza, altrimenti interferiscono. Ogni frequenza ha un costo (lo stesso per tutte), quindi si vuole coprire la città usando il *minor numero di frequenze*.

L'interferenza si disegna con il *grafo di incompatibilità* $G = (S, E)$: i vertici sono le antenne e c'è il lato ${i, j} in E$ se le antenne $i != j$ sono troppo vicine.

#grid(columns: (auto, 1fr), gutter: 1.5em, align: horizon,
  grafo((("1"): (1.5, 2.9), ("2"): (3, 1.8), ("3"): (2.4, 0), ("4"): (0.6, 0), ("5"): (0, 1.8)),
    (("1", "2"), ("2", "3"), ("3", "4"), ("4", "5"), ("5", "1")),
    scelti: (("1", "2"), ("2", "3"), ("3", "4"), ("4", "5"), ("5", "1")),
    colori: ("1": rgb("#ffd6d6"), "3": rgb("#ffd6d6"), "2": rgb("#d6e4ff"), "4": rgb("#d6e4ff"), "5": rgb("#fff3c4"))),
  [
    Ogni frequenza è un *colore*: *rosso* $f_1$, *blu* $f_2$, *giallo* $f_3$. Due antenne unite da un lato devono avere colori diversi. Le antenne 1 e 3 non sono vicine e possono condividere $f_1$: è il semi-assegnamento, una frequenza serve più antenne.

    Qui servono 3 frequenze: con due sole, alternandole lungo il giro 1-2-3-4-5, la 5 e la 1 (vicine) avrebbero la stessa.
  ])

*Variabili*: due famiglie, una per decidere *chi usa cosa*, una per sapere *quali frequenze sono usate*:
$ x_(i f) = cases(1 "se assegno la frequenza" f in F "all'antenna" i in S, 0 "altrimenti") quad quad y_f = cases(1 "se uso la frequenza" f in F, 0 "altrimenti") $

$
min z = & sum_(f in F) y_f &&&& #text(9pt)[← numero di frequenze usate] \
& sum_(f in F) x_(i f) = 1 quad && i in S quad && #text(9pt)[← ogni antenna ha una sola frequenza] \
& x_(i f) + x_(j f) <= 1 quad && {i, j} in E, f in F quad && #text(9pt)[← antenne vicine: frequenze diverse] \
& x_(i f) in {0, 1} quad && i in S, f in F \
& y_f in {0, 1} quad && f in F
$

Ogni vincolo è una relazione logica già vista:
- $sum_f x_(i f) = 1$ è "*esattamente uno*": il semi-assegnamento (per ogni antenna, non per ogni frequenza);
- $x_(i f) + x_(j f) <= 1$ è "*al massimo uno*": fra due antenne vicine $i$ e $j$ al massimo una usa $f$. Si scrive per ogni lato del grafo di incompatibilità e per ogni frequenza.

La funzione obiettivo conta le frequenze usate: $y$ è un "vettorino" di 0 e 1 lungo $|F|$, e la sua somma è il numero di 1.

#nota[Il modello *non è ancora finito*: nessun vincolo lega le $y$ alle $x$. Così com'è, il $min$ metterebbe tutte le $y_f$ a 0 (costo 0) mentre le antenne usano comunque le frequenze. Il pezzo mancante è il prossimo argomento.]
