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
  5. "Se finanzio *sia A che B* devo finanziare C": \ $x_C >= x_A + x_B - 1$ \
     #text(9pt)[(a destra c'è 1 solo se $x_A = x_B = 1$, altrimenti $<= 0$)]
  6. "Posso finanziare C *solo se* finanzio A e B": \ $x_C <= x_A$ e $x_C <= x_B$

  Insieme danno $C = A and B$: la colonna 5 + 6 è ✓ solo dove $x_C = x_A dot x_B$.

  Con tre progetti: "se finanzio A, B e C devo finanziare D" è $x_D >= x_A + x_B + x_C - 2$.
]))

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

#nota[Schema che si ripete: il "*devo*" (se … allora C) è un vincolo $x_C >= dots$ che spinge C a 1; il "*posso solo se*" è un vincolo $x_C <= dots$ che tiene C a 0.]

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
