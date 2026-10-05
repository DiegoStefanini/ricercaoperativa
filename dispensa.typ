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

// grafo orientato: archi = ((a, b), ...), etichette = ("a-b": contenuto), evid = ("a-b", ...) archi in blu,
// note = (nome: ((dx, dy), contenuto)) scritte accanto ai nodi
#let rete(nodi, archi, etichette: (:), evid: (), note: (:), colori: (:), scala: 0.8) = canvas(length: scala * 1cm, {
  import draw: *
  let r = 0.32
  for (a, b) in archi {
    let (p, q) = (nodi.at(a), nodi.at(b))
    let (dx, dy) = (q.at(0) - p.at(0), q.at(1) - p.at(1))
    let l = calc.sqrt(dx * dx + dy * dy)
    let (ux, uy) = (dx / l, dy / l)
    let c = if evid.contains(a + "-" + b) { blu } else { grigio }
    line((p.at(0) + r * ux, p.at(1) + r * uy), (q.at(0) - r * ux, q.at(1) - r * uy),
      stroke: (if c == blu { 1.6pt } else { 0.8pt }) + c, mark: (end: "stealth", fill: c))
    let e = etichette.at(a + "-" + b, default: none)
    if e != none { content((p.at(0) + dx / 2, p.at(1) + dy / 2), box(fill: white, inset: 1.5pt, text(7pt, e))) }
  }
  for (n, p) in nodi {
    circle(p, radius: r, fill: colori.at(n, default: white), stroke: 0.7pt)
    content(p, text(8pt, n))
  }
  for (n, (d, c)) in note {
    let p = nodi.at(n)
    content((p.at(0) + d.at(0), p.at(1) + d.at(1)), text(7pt, c))
  }
})

// barche dell'esempio: (arrivo, partenza). Due barche sono incompatibili se gli intervalli si toccano.
#let barche = ((0, 2), (1, 2), (2.5, 5.5))
#let sovrapposte(a, b) = calc.max(a.at(0), b.at(0)) <= calc.min(a.at(1), b.at(1))
// tutti i turni possibili di un molo: sottoinsiemi di barche senza sovrapposizioni (calcolati, non scritti a mano)
#let turni = (range(1, calc.pow(2, barche.len()))
  .map(k => range(barche.len()).filter(i => calc.rem(calc.quo(k, calc.pow(2, i)), 2) == 1))
  .filter(s => s.all(i => s.all(j => i == j or not sovrapposte(barche.at(i), barche.at(j)))))
  .sorted(key: s => s.len() * 100 + s.fold(0, (a, i) => a * 10 + i)))
// linea del tempo: una riga per ogni gruppo di barche
#let tempi(righe, etichette: none) = canvas(length: 0.85cm, {
  import draw: *
  let n = righe.len()
  for (k, s) in righe.enumerate() {
    let y = (n - k) * 0.62
    line((0, y), (6, y), stroke: 0.4pt + grigio)
    if etichette != none { content((-0.25, y), anchor: "east", text(8pt, etichette.at(k))) }
    for i in s {
      let (a, b) = barche.at(i)
      rect((a, y - 0.22), (b, y + 0.22), fill: rgb("#d6e4ff"), stroke: 0.6pt + blu)
      content(((a + b) / 2, y), text(8pt)[#(i + 1)])
    }
  }
  line((0, 0), (6.3, 0), mark: (end: "stealth", fill: black))
  for t in range(7) { line((t, 0), (t, -0.1)); content((t, -0.35), text(7pt)[#t]) }
  content((6.9, 0), text(7pt)[ore])
})
// cammino di un camion: "d" deposito, "i…" importatore, "e…" esportatore
#let catena(..n) = box(baseline: 30%, stack(dir: ltr, spacing: 3pt, ..n.pos().map(x => box(width: 1.55em, height: 1.55em, radius: 50%, stroke: 0.6pt,
  fill: if x == "d" { luma(225) } else if x.starts-with("i") { rgb("#d6e4ff") } else { rgb("#fff3c4") },
  align(center + horizon, text(8pt, if x.len() == 1 { math.italic(x) } else { math.attach(math.italic(x.at(0)), b: x.slice(1)) }))))
  .intersperse(box(height: 1.55em, align(horizon, text(9pt, sym.arrow.r))))))

// home restaurant: ingredienti, casse e piatti (nome, quali ingredienti usa, valore)
#let ingr = ($M_f$, $M_a$, $O_i$, $O_r$, $S$)
#let ingrnomi = ("filetto", "avanzo / ossa", "foglie", "radici", "salsa")
#let ingrcassa = ($M$, $M$, $O$, $O$, $S$)
#let piatti = (
  ("Tagliata con insalata", (1, 1, 1, 0, 0), 6),
  ("Stufato rustico", (1, 1, 0, 0, 1), 3),
  ("Filetto al sale", (1, 0, 0, 0, 0), 2),
  ("Insalata di carne", (1, 0, 1, 0, 1), 5),
  ("Filetto con contorno", (1, 1, 1, 1, 0), 9),
  ("Stufato classico", (1, 1, 0, 0, 0), 10),
  ("Salsa del giorno", (0, 0, 0, 0, 1), 7),
  ("Piatto gourmet", (1, 1, 1, 1, 1), 8),
)
// valori di z permessi da un vincolo quando nel menù ci sono k piatti
#let zperm(k, f) = {
  let v = (0, 1).filter(z => f(k, z))
  if v.len() == 2 { [0 o 1] } else if v.len() == 1 { strong[#v.at(0)] } else { no }
}

// retta dei numeri: punti = valori ammessi isolati, interv = ((a, b), ...) intervalli ammessi
// tacca: un numero, oppure (posizione, etichetta)
#let tk(t) = if type(t) == array { t } else { (t, [#str(t).replace(".", ",")]) }
#let asse(max, punti: (), interv: (), tacche: (), sopra: (), scala: 1) = canvas(length: scala * 1cm, {
  import draw: *
  line((0, 0), (max + 0.3, 0), stroke: 0.5pt + grigio, mark: (end: "stealth", fill: grigio))
  for (t, l) in tacche.map(tk) { line((t, -0.08), (t, 0.08), stroke: 0.5pt); content((t, -0.35), text(7pt, l)) }
  for (a, b) in interv { line((a, 0), (b, 0), stroke: 3pt + blu) }
  for p in punti { circle((p, 0), radius: 0.09, fill: blu, stroke: none) }
  for (x, c) in sopra { content((x, 0.4), text(7pt, c)) }
})
// funzione a tratti: pezzi = ((a, b, f), ...), pieni / vuoti = punti (x, y) inclusi / esclusi
#let atratti(pezzi, xmax, ymin, ymax, sx: 1, sy: 1, pieni: (), vuoti: (), xt: (), yt: (), xl: $x$, yl: $f(x)$) = canvas(length: 1cm, {
  import draw: *
  let P((x, y)) = (x * sx, y * sy)
  line(P((0, ymin)), P((0, ymax)), stroke: 0.5pt, mark: (end: "stealth"))
  line(P((0, 0)), P((xmax, 0)), stroke: 0.5pt, mark: (end: "stealth"))
  content((xmax * sx + 0.3, 0), text(8pt, xl))
  content((0, ymax * sy + 0.3), text(8pt, yl))
  for (t, l) in xt.map(tk) { line(P((t, 0)), (t * sx, -0.08)); content((t * sx, -0.3), text(7pt, l)) }
  for (t, l) in yt.map(tk) { line(P((0, t)), (-0.08, t * sy)); content((-0.15, t * sy), anchor: "east", text(7pt, l)) }
  for (a, b, f) in pezzi { line(P((a, f(a))), P((b, f(b))), stroke: 1.4pt + blu) }
  for p in pieni { circle(P(p), radius: 0.08, fill: blu, stroke: none) }
  for p in vuoti { circle(P(p), radius: 0.08, fill: white, stroke: 0.8pt + blu) }
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

"s.t." sotto la funzione obiettivo sta per _subject to_, "soggetto a": da lì in poi ci sono i vincoli. Ricordarsi sempre di scrivere anche il *dominio* delle variabili, cioè i valori che possono assumere ($x >= 0$, $x in {0, 1}$…).

Lo stesso problema si può scrivere con *modelli diversi*: nel corso l'efficienza non conta, basta che il modello funzioni (anche con qualche vincolo in più).]

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

== Variabili binarie: zaino e relazioni logiche

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
x_i in {0, 1} quad forall i = 1, dots, n
$,
[
  Le variabili *binarie* (o booleane) servono per le decisioni sì/no.

  Il trucco: moltiplicando per $x_i$, nella somma entrano *solo i progetti scelti* ($x_i = 1$); gli altri valgono 0.

  $sum c_i x_i <= B$ è il *vincolo di budget*.
])

Con le variabili binarie si scrivono anche le *relazioni logiche* fra le decisioni: "se finanzio questo devo finanziare quello", "al massimo uno fra questi". Ogni relazione diventa un vincolo lineare. Tutte le variabili qui sono binarie: $x_A = 1$ se finanzio il progetto A. Nelle tabelle, ✓ = combinazione permessa dal vincolo.

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

#block(sticky: true)[*Implicazione*.]

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

#nota[I due vincoli del 6 si possono sommare in uno solo: $2 x_C <= x_A + x_B$, cioè $x_C <= (x_A + x_B) / 2$. Se almeno uno fra A e B vale 0, a destra c'è al massimo $1/2$, e una variabile binaria $<= 1/2$ può solo valere 0. Stessa cosa per il 7 più avanti: $2 x_C >= x_A + x_B$. Per l'esame le due scritture valgono uguale.]

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

#nota[Trappola sul 9: $x_C >= x_A + x_B$ è sbagliato. Con A e B entrambi finanziati chiede $x_C >= 2$, impossibile per una binaria: il problema diventa *inammissibile* (nessuna soluzione rispetta tutti i vincoli). In quel caso invece C deve restare libero.]

#nota[Schema che si ripete: il "*devo*" (se … allora C) è un vincolo $x_C >= dots$ che spinge C a 1; il "*posso solo se*" è un vincolo $x_C <= dots$ che tiene C a 0.]

== Scegliere lati di un grafo: albero di copertura e commesso viaggiatore

Nello zaino le variabili binarie sceglievano un *sottoinsieme* dei progetti. Qui scelgono un sottoinsieme dei *lati di un grafo*, e i vincoli gli impongono una forma: prima un albero, poi un ciclo.

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
    Si potrebbe usare una variabile per ogni albero possibile, ma gli alberi sono un numero esponenziale: meglio costruire la soluzione *a pezzettini*, un lato alla volta. Nel disegno i lati in blu hanno $x_(i j) = 1$: costo $1 + 4 + 3 + 2 = 10$, il minimo per questo grafo.
  ])

*Funzione obiettivo*: come nello zaino, nella somma entrano solo i lati scelti,
$ min z = sum_({i, j} in E) c_(i j) x_(i j) $

*Vincoli*: come si scrive "la rete è connessa"? Qualunque gruppo di città $S$ prenda, almeno un lato scelto deve *uscire* da $S$, sennò le città di $S$ restano isolate. Vale per ogni $S$ non vuoto e diverso da tutto $V$ (con $S = V$ non c'è un "fuori"): si scrive $S subset V$ (sottoinsieme *proprio*) e $S != emptyset$:

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

Il modello chiede solo che la rete sia *connessa*, non che sia un albero. Ma all'ottimo lo è per forza: se i lati scelti formassero un ciclo, togliendone uno la rete resterebbe connessa e costerebbe meno, perché ogni $c_(i j) > 0$.

Un'altra idea: un albero su $n$ vertici ha sempre $n - 1$ lati, quindi si potrebbe scrivere $sum_({i, j} in E) x_(i j) = n - 1$. *Da solo non basta*: $n - 1$ lati possono chiudere un ciclo e lasciare fuori un vertice (è il triangolo di prima: 3 lati, $n - 1 = 3$, ma il 4 è isolato). *Insieme ai vincoli di taglio è ridondante*: con costi positivi l'ottimo è già un albero. Servirebbe solo con costi negativi, perché allora al modello converrebbe prendere lati in più.

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

Nel giro invece in ogni città *entro una volta ed esco una volta*: ogni vertice tocca esattamente *due* lati scelti (ha *grado* 2). Fissato il vertice $i$, sommo le $x$ dei lati che lo toccano:
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

Il vincolo $sum x_(i j) = n$ ora è *ridondante*: se ogni vertice tocca 2 lati, sommando su tutti i vertici conto $2n$, e ogni lato l'ho contato due volte (una per estremo), quindi i lati sono $n$.

#nota[È il modello dell'albero di copertura più i vincoli di grado 2. Non è l'unico modello del TSP: si può usare una variabile per ogni ciclo hamiltoniano (ma sono un numero esponenziale e bisogna generarli tutti), oppure sostituire i vincoli di taglio con vincoli che vietano direttamente i sottocicli.]

== Assegnamento, semi-assegnamento e colorazione di grafi

Un'azienda deve assegnare delle attività a dei lavoratori. Lavoratori $L$ e attività $A$ sono due insiemi con lo stesso numero $n$ di elementi. Assegnare il lavoratore $i in L$ all'attività $j in A$ costa $c_(i j)$. Tutte le attività vanno assegnate e ogni lavoratore riceve *una e una sola* attività; si vuole il costo minimo.

#grid(columns: (auto, 1fr), gutter: 1.5em, align: horizon,
  grafo((("1"): (0, 2.4), ("2"): (0, 1.2), ("3"): (0, 0), ("a"): (2.6, 2.4), ("b"): (2.6, 1.2), ("c"): (2.6, 0)),
    (("1", "a"), ("1", "b"), ("2", "a"), ("2", "b"), ("2", "c"), ("3", "b"), ("3", "c")),
    scelti: (("1", "b"), ("2", "a"), ("3", "c")),
    extra: (draw.content((0, 3.2), text(8pt)[$L$]), draw.content((2.6, 3.2), text(8pt)[$A$]))),
  [
    Si può vedere come una scelta di lati sul grafo *bipartito* $G = (L union A, E)$: a sinistra i lavoratori, a destra le attività, un lato per ogni coppia (nel disegno solo alcuni).

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
Un problema è *polinomiale* se esiste un algoritmo che lo risolve in un tempo che cresce come una potenza della dimensione ($n^2$, $n^3$, …) e non come $2^n$. In pratica: si risolve in fretta anche quando $n$ è grande.
]

Gli stessi vincoli tornano nel commesso viaggiatore su un grafo *orientato*, dove il lato $(i, j)$ va da $i$ a $j$ e non è lo stesso di $(j, i)$. Il "grado 2" si spezza in due vincoli simili a quelli dell'assegnamento: da ogni città *esco* una volta, $sum_j x_(i j) = 1$, e in ogni città *entro* una volta, $sum_i x_(i j) = 1$.

Nell'assegnamento "esattamente uno" vale *dai due lati*. Se vale da *un lato solo* si parla di *vincoli di semi-assegnamento*: ogni elemento del primo insieme riceve esattamente un elemento del secondo, ma un elemento del secondo può essere dato a molti (o a nessuno).

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
& y_f >= x_(i f) quad && i in S, f in F quad && #text(9pt)[← una frequenza assegnata è una frequenza usata] \
& x_(i f) in {0, 1} quad && i in S, f in F \
& y_f in {0, 1} quad && f in F
$

Ogni vincolo è una relazione logica già vista:
- $sum_f x_(i f) = 1$ è "*esattamente uno*": il semi-assegnamento (per ogni antenna, non per ogni frequenza);
- $x_(i f) + x_(j f) <= 1$ è "*al massimo uno*": fra due antenne vicine $i$ e $j$ al massimo una usa $f$. Si scrive per ogni lato del grafo di incompatibilità e per ogni frequenza.
- $y_f >= x_(i f)$ è il *legame* fra le due famiglie di variabili: l'implicazione "se assegno $f$ all'antenna $i$, allora $f$ è usata" ($x_(i f) <= y_f$). Se nessuna antenna usa $f$, $y_f$ sarebbe libera, ma il $min$ la porta a 0.

Senza quest'ultimo vincolo il modello sarebbe sbagliato: niente lega le $y$ alle $x$, quindi il $min$ metterebbe tutte le $y_f$ a 0 (costo 0) mentre le antenne usano comunque le frequenze.

#nota[Ogni volta che un modello ha *due o più famiglie di variabili* serve un vincolo che le leghi. Il significato che do a una variabile quando la definisco a parole ("$y_f$ vale 1 se uso la frequenza") è come un commento nel codice: il solutore (il programma che risolve il modello) non lo legge. Quel significato deve essere imposto dai vincoli.]

Questo modello è la *colorazione di un grafo* (graph coloring): dare un colore a ogni vertice, con il minor numero di colori, in modo che due vertici uniti da un lato abbiano colori diversi. Lo stesso modello risolve anche il prossimo problema.

*Moli e barche (ordinamento di lavori su macchine)*. Un porto ha un insieme di moli $M = {1, dots, k}$, tutti uguali. Ogni giorno arrivano $n$ barche, $B = {1, dots, n}$. La barca $i$ arriva all'istante $t_i >= 0$ e occupa il molo per una durata $d_i$ per scaricare, quindi riparte a $t_i + d_i$. Le barche non possono aspettare: vanno servite appena arrivano. Ogni barca va assegnata a *esattamente un molo*, e due barche non possono stare sullo stesso molo in intervalli di tempo che si sovrappongono. Si vuole usare il *minor numero di moli*.

#grid(columns: (auto, 1fr), gutter: 1.5em, align: horizon,
  tempi(((0,), (1,), (2,)), etichette: ([barca 1], [barca 2], [barca 3])),
  [
    Esempio con tre barche: la 1 sta in porto nell'intervallo $[0, 2]$, la 2 in $[1, 2]$, la 3 in $[2.5, 5.5]$.

    La 1 e la 2 si sovrappongono (quando arriva la 2, la 1 è ancora al molo): non possono condividere un molo. La 3 arriva quando le altre due sono già ripartite: può usare il molo di una delle due. Bastano 2 moli.
  ])

Viene da pensare a una variabile per ogni molo e ogni istante ("il molo $m$ è occupato all'istante $t$"). Non serve: *il tempo qui non è una decisione*. Arrivo e durata sono dati, e una variabile serve solo per ciò che devo decidere (servirebbe se potessi scegliere *quando* servire una barca). In più gli istanti sono infiniti: bisognerebbe spezzare il tempo in intervallini (*discretizzare*).

Il tempo si usa *prima* di scrivere il modello, sui dati, per costruire il *grafo di incompatibilità* $G = (B, E)$: i vertici sono le barche, e c'è un lato fra due barche quando i loro intervalli hanno almeno un istante in comune,
$ {i, j} in E quad "se" quad [t_i, t_i + d_i] ∩ [t_j, t_j + d_j] != emptyset $
($∩$ è l'intersezione, $emptyset$ l'insieme vuoto: "l'intersezione non è vuota"). Nell'esempio $E$ ha un solo lato, ${1, 2}$.

Le decisioni sono due, come per le antenne: *su quale molo va ogni barca* e *quali moli uso*.
$ x_(i m) = cases(1 "se assegno la barca" i in B "al molo" m in M, 0 "altrimenti") quad quad y_m = cases(1 "se uso il molo" m in M, 0 "altrimenti") $

$
min z = & sum_(m in M) y_m &&&& #text(9pt)[← numero di moli usati] \
& sum_(m in M) x_(i m) = 1 quad && i in B quad && #text(9pt)[← ogni barca ha un solo molo] \
& x_(i m) + x_(j m) <= 1 quad && {i, j} in E, m in M quad && #text(9pt)[← barche incompatibili: moli diversi] \
& y_m >= x_(i m) quad && i in B, m in M quad && #text(9pt)[← un molo con una barca è un molo usato] \
& x_(i m) in {0, 1} quad && i in B, m in M \
& y_m in {0, 1} quad && m in M
$

È *lo stesso modello* dell'assegnamento di frequenze, con altri nomi:

#align(center, table(columns: 4, align: center,
  [], [frequenze], [moli e barche], [lavori su macchine],
  [vertici del grafo], [antenne], [barche], [lavori],
  [colori], [frequenze], [moli], [macchine],
  [lato = incompatibili], [troppo vicine], [intervalli sovrapposti], [lavori nello stesso momento],
))

Prima lo stesso problema aveva modelli diversi; qui succede il contrario: *lo stesso modello risolve problemi diversi*.

== Selezione di sottoinsiemi: partizione, copertura, riempimento

Nel modello dei moli la soluzione è costruita a pezzettini: una variabile per ogni coppia barca-molo. Niente vieta di usare *pezzi più grandi*. Invece di decidere barca per barca, elenco tutti i *turni* possibili di un molo (cioè tutti i gruppi di barche che un molo può servire in una giornata senza sovrapposizioni) e uso una variabile per ogni turno: lo scelgo oppure no.

Sia $cal(F)$ la famiglia (un "insieme di insiemi") di tutti i sottoinsiemi non vuoti $S subset.eq B$ di barche che *non si sovrappongono fra loro*: ogni $S in cal(F)$ è un possibile turno (o schedulazione) di un molo. Con le tre barche dell'esempio i turni possibili sono #turni.len():

#grid(columns: (auto, 1fr), gutter: 1.5em, align: horizon,
  tempi(turni, etichette: turni.enumerate().map(((k, s)) => $S_#(k + 1)$)),
  [
    $cal(F) = { #turni.map(s => ${#s.map(i => str(i + 1)).join(",")}$).join($,$) }$

    Un molo può servire una barca sola, oppure la 1 e poi la 3, oppure la 2 e poi la 3. Il turno ${1, 2}$ *non c'è*: le barche 1 e 2 sono incompatibili. L'incompatibilità è già sistemata quando costruisco $cal(F)$, sui dati, e nel modello non compare più.

    I moli sono tutti uguali: non serve dire *quale* molo fa un turno, basta sapere quali turni vengono fatti.
  ])

*Variabili*: una per turno,
$ y_S = cases(1 "se uso un molo con il gruppo di barche" S in cal(F), 0 "altrimenti") $

*Funzione obiettivo*: ogni turno scelto occupa un molo, quindi i moli usati sono $sum_(S in cal(F)) y_S$, da minimizzare.

*Vincoli*: ogni barca deve essere servita, e una volta sola. La barca 1 compare nei turni $S_1$ e $S_4$: fra questi due ne devo scegliere esattamente uno. Stesso discorso per le altre:
#let ys = i => turni.enumerate().filter(((k, s)) => s.contains(i)).map(((k, s)) => $y_#(k + 1)$).join($+$)
$ #ys(0) = 1 quad "(barca 1)" quad quad #ys(1) = 1 quad "(barca 2)" quad quad #ys(2) = 1 quad "(barca 3)" $

In generale, per ogni barca $i$ sommo le variabili dei soli turni che la contengono:

$
min z = & sum_(S in cal(F)) y_S &&&& #text(9pt)[← numero di moli usati] \
& sum_(S in cal(F) : i in S) y_S = 1 quad && forall i in B quad && #text(9pt)[← ogni barca sta in un solo turno scelto] \
& y_S in {0, 1} quad && forall S in cal(F)
$

Una soluzione è $y_2 = y_4 = 1$ e le altre a 0: un molo serve la barca 2, un altro serve la 1 e poi la 3. Due moli.

Lo stesso vincolo si scrive in modo più comodo con un *parametro binario*. Numero i turni con un insieme di indici $P = {1, dots, #turni.len()}$ ($y_p$ al posto di $y_S$) e definisco
$ a_(i p) = cases(1 "se la barca" i in B "è nel turno" p in P, 0 "altrimenti") $

#grid(columns: (auto, 1fr), gutter: 1.5em, align: horizon,
  table(columns: turni.len() + 1, align: center, inset: 5pt,
    $a_(i p)$, ..range(turni.len()).map(k => $p = #(k + 1)$),
    ..range(barche.len()).map(i => ($i = #(i + 1)$,) + turni.map(s => if s.contains(i) { strong[1] } else { text(fill: grigio)[0] })).flatten()),
  [
    Ogni colonna è un turno, ogni riga una barca. Il vincolo della barca $i$ si legge sulla riga $i$: moltiplico ogni $y_p$ per il numero sopra e sommo. Dove c'è 0 la variabile sparisce dalla somma, dove c'è 1 resta.

    Riga 1: $1 y_1 + 0 y_2 + 0 y_3 + 1 y_4 + 0 y_5 = 1$, cioè $y_1 + y_4 = 1$ come prima.
  ])

$
min z = sum_(p in P) y_p quad "s.t." quad sum_(p in P) a_(i p) y_p = 1 quad forall i in B, quad quad y_p in {0, 1} quad forall p in P
$

#nota[*Parametro o variabile?* $a_(i p)$ è un *parametro*: un dato, come gli orari delle barche. Elencati i turni so già dove vale 1 e dove 0: non c'è niente da decidere, quindi non è fra le variabili e non ha un dominio. $x_(i m)$ nel modello di prima era una *variabile*: a quale molo va la barca lo decide il solutore.

Il parametro può anche valere 2, 3, … per dire "quante volte", non solo "sì o no": tornerà utile.]

I due modelli a confronto: con le $x_(i m)$ ho poche variabili (barche × moli) e molti vincoli; con i turni ho *pochissimi vincoli* (uno per barca) ma *tantissime variabili*, una per ogni gruppo compatibile, e i gruppi possono essere un numero esponenziale. Questi modelli funzionano molto bene quando le variabili si generano un po' alla volta invece che tutte insieme, ma è una tecnica che nel corso non si vede.

Scegliere turni in modo che ogni barca stia in *esattamente uno* vuol dire dividere $B$ in gruppi che non si sovrappongono e non lasciano fuori nessuno: una *partizione* di $B$. Cambiando il segno del vincolo si ottengono tre problemi con un nome:

#align(center, table(columns: (auto, auto, auto, auto), align: (left, center, left, left), inset: 7pt,
  [problema], [per ogni $i in B$], [ogni elemento sta in…], [per le barche],
  [*partizione* \ #text(9pt)[set partitioning]], $display(sum_(S in cal(F) : i in S) y_S = 1)$, [esattamente un insieme scelto], [ogni barca a un solo molo],
  [*copertura* \ #text(9pt)[set covering]], $display(sum_(S in cal(F) : i in S) y_S >= 1)$, [almeno un insieme scelto], [ogni barca ad almeno un molo],
  [*riempimento* \ #text(9pt)[set packing]], $display(sum_(S in cal(F) : i in S) y_S <= 1)$, [al più un insieme scelto], [ogni barca al più a un molo],
))

#nota[I nomi sono nomenclatura: il prof dice che non li chiederà ("e poi mi smentirò"). Servono come campanello: se un problema è una partizione, una copertura o un riempimento, il modello c'è già.]

*Selezione di una configurazione: l'home restaurant*. All'esame e al compitino l'esercizio di modellazione parte da un *testo*, come questo. Tommaso ha un home restaurant e sabato sera ha una prenotazione. La mattina va al mercato con *16,5 €*. Gli ingredienti si vendono solo in *casse* già fatte, che non si possono dividere:

#align(center, stack(dir: ltr, spacing: 0.8em,
  ..(($M$, "Cassa Proteica", [1 filetto $M_f$ \ 1 avanzo / ossa $M_a$], "6,5 €"),
     ($O$, "Cassa Orto", [1 foglie miste $O_i$ \ 1 radici $O_r$], "4,0 €"),
     ($S$, "Barattolo Salse", [1 salsa $S$], "1,5 €")).map(((s, n, c, p)) =>
    box(stroke: 0.6pt, inset: 7pt, width: 5cm, height: 1.9cm, fill: rgb("#eef4ff"), align(left)[*#n* (#s) #h(1fr) *#p* \ #text(9pt, c)]))))

Deve decidere *quante casse comprare* e *quali piatti mettere nel menù*. Ogni piatto usa alcuni ingredienti (una porzione ciascuno) e ha un *valore* $v_c$, cioè quanto piace ai clienti. Tommaso vuole il menù di valore totale massimo. In più, se il menù ha *almeno 4 piatti* guadagna un *bonus di 10 punti* (menù vario).

#align(center, table(columns: 8, align: (center, left) + (center,) * 6, inset: 5pt,
  [$c$], [piatto], ..ingr, [valore $v_c$],
  ..piatti.enumerate().map(((c, (n, u, v))) => ([#(c + 1)], n) + u.map(a => if a == 1 { strong[1] } else { text(fill: grigio)[0] }) + ([#v],)).flatten()))

La tabella piatto-ingrediente è una matrice di 0 e 1: è di nuovo un parametro binario.

*Variabili*. Le decisioni sono tre:
- quali piatti fare: $x_c in {0, 1}$ per ogni piatto $c in C = {1, dots, 8}$, vale 1 se il piatto $c$ è nel menù;
- quante casse comprare: $y_M, y_O, y_S$. Se ne può comprare più di una, quindi non sono binarie ma *intere*, $y in NN_0$ (0, 1, 2, …): dicono *se* compro e *quante*;
- se prendo il bonus: $z in {0, 1}$, vale 1 se il menù ha almeno 4 piatti.

*Funzione obiettivo*: il valore di ogni piatto scelto, più il bonus $b = 10$ se $z = 1$.
$ max w = sum_(c in C) v_c x_c + b z quad quad "cioè" quad max #piatti.enumerate().map(((c, p)) => $#p.at(2) x_#(c + 1)$).join($+$) + 10 z $

*Vincolo del bonus*. Così com'è, $z$ è slegata dal resto: il $max$ la metterebbe sempre a 1 e prenderebbe il bonus anche con un piatto solo. È la situazione delle $y_f$ con le antenne: serve un vincolo che leghi $z$ alle $x_c$. Deve impedire $z = 1$ quando i piatti sono meno di 4:
$ sum_(c in C) x_c >= 4 z quad quad "(o, che è lo stesso," quad z <= 1/4 sum_(c in C) x_c ")" $
Con $z = 0$ dice $sum x_c >= 0$, sempre vero. Con $z = 1$ dice $sum x_c >= 4$: posso avere $z = 1$ solo con almeno 4 piatti. Visto dall'altra parte: con 3 piatti $z <= 3/4$, e una binaria $<= 3/4$ può solo valere 0.

E quando i piatti sono 4 o più? Il vincolo permette sia $z = 0$ sia $z = 1$. Ma $z$ ha coefficiente positivo ($+10$) in una funzione obiettivo di *massimo*: appena può, il modello la mette a 1. *Basta questo vincolo* perché la funzione obiettivo spinge dalla parte giusta.

Se $z$ non fosse nella funzione obiettivo (o il suo coefficiente spingesse dalla parte sbagliata), niente la obbligherebbe a valere 1 con 4 piatti o più. Per avere "$z = 1$ *se e solo se* i piatti sono almeno 4" serve un secondo vincolo, che obbliga $z$ a 1:
$ sum_(c in C) x_c <= 3 + (|C| - 3) z $
($|C| = 8$ è il numero di piatti.) Con $z = 0$ dice $sum x_c <= 3$: per fare 4 piatti o più devo per forza avere $z = 1$. Con $z = 1$ dice $sum x_c <= |C|$, sempre vero. La tabella mostra, per ogni numero di piatti nel menù, quali valori di $z$ lascia passare ciascun vincolo:

#align(center, table(columns: 10, align: center, inset: 5pt,
  [piatti nel menù], ..range(9).map(k => [#k]),
  $sum x_c >= 4 z$, ..range(9).map(k => zperm(k, (k, z) => k >= 4 * z)),
  $sum x_c <= 3 + 5 z$, ..range(9).map(k => zperm(k, (k, z) => k <= 3 + 5 * z)),
  [tutti e due], ..range(9).map(k => zperm(k, (k, z) => k >= 4 * z and k <= 3 + 5 * z)),
))

Il primo vincolo è del tipo "*posso* solo se" (tiene $z$ a 0), il secondo del tipo "*devo* se" (spinge $z$ a 1): lo stesso schema delle relazioni logiche.

*Vincoli sugli ingredienti*. I piatti scelti non possono usare più ingredienti di quelli comprati. Ogni Cassa Proteica contiene un filetto, quindi i filetti disponibili sono $y_M$; quelli che servono sono tanti quanti i piatti scelti che usano il filetto. Un vincolo per ogni ingrediente, letto dalle colonne della tabella:

#let usa = h => piatti.enumerate().filter(((c, p)) => p.at(1).at(h) == 1).map(((c, p)) => $x_#(c + 1)$).join($+$)
#align(center, grid(columns: 4, align: (left, right, center, left), inset: 4pt,
  ..range(ingr.len()).map(h => ([#ingrnomi.at(h) #ingr.at(h):], $#usa(h)$, $<=$, $y_#ingrcassa.at(h)$)).flatten()))

Se faccio i piatti 5 e 6, tutti e due con il filetto, il primo vincolo dà $y_M >= 2$: due casse proteiche. Può capitare di comprare ingredienti che poi non uso (con le casse arrivano anche quelli).

Scrivere cinque vincoli a mano va bene qui, ma non con cento ingredienti. La stessa cosa si scrive in forma generale in due modi. Con gli *insiemi*: chiamo $H = {M_f, M_a, O_i, O_r, S}$ gli ingredienti e $C_h$ l'insieme dei piatti che usano l'ingrediente $h$; per il filetto, $sum_(c in C_(M_f)) x_c <= y_M$. Oppure con il *parametro binario* $a_(h c)$, che vale 1 se il piatto $c$ usa l'ingrediente $h$ (è la tabella dei piatti): $sum_(c in C) a_(M_f, c) x_c <= y_M$. La somma è su tutti i piatti, e quelli che non usano il filetto spariscono perché moltiplicati per 0.

Il parametro permette di arrivare a *una sola formula per tutti gli ingredienti*. Chiamo $J = {M, O, S}$ i tipi di cassa e aggiungo un secondo parametro, $d_(h j) = 1$ se l'ingrediente $h$ sta nella cassa $j$ (0 altrimenti):
$ underbrace(sum_(c in C) a_(h c) x_c, "quanto ne serve") <= underbrace(sum_(j in J) d_(h j) y_j, "quanto ne compro") quad forall h in H $

#nota[Questa forma regge anche casi che le altre non reggono, cambiando solo i numeri nei parametri: un piatto che usa *due* porzioni dello stesso ingrediente ($a_(h c) = 2$), una cassa che contiene *più unità* di un ingrediente ($d_(h j) = 2$), lo stesso ingrediente presente in *casse diverse* (più $d_(h j)$ a 1 sulla stessa riga). All'esame va bene anche la forma lunga.]

*Vincolo di budget*, come nello zaino: con $k_j$ costo della cassa $j$ e $B = 16.5$,
$ sum_(j in J) k_j y_j <= B quad quad "cioè" quad 6.5 y_M + 4 y_O + 1.5 y_S <= 16.5 $
Il $<=$ perché posso spendere anche meno. Non serve una variabile in più per "quanto spendo": è già la somma a sinistra.

Il modello completo, con i domini (che vanno sempre scritti: il solutore non sa da solo che $z$ è binaria):
$
max w = & sum_(c in C) v_c x_c + b z &&&& #text(9pt)[← valore del menù più bonus] \
& sum_(c in C) x_c >= 4 z &&&& #text(9pt)[← bonus solo con almeno 4 piatti] \
& sum_(c in C) a_(h c) x_c <= sum_(j in J) d_(h j) y_j quad && forall h in H quad && #text(9pt)[← ingredienti usati ≤ comprati] \
& sum_(j in J) k_j y_j <= B &&&& #text(9pt)[← budget] \
& x_c in {0, 1} quad forall c in C, quad y_j in NN_0 quad forall j in J, quad z in {0, 1}
$

*Instradamento: una variabile per ogni cammino*. Nei moli la famiglia $cal(F)$ si poteva elencare guardando gli orari. Spesso la famiglia non è data: va costruita dalle regole del testo. La Trans-Port, azienda di logistica, deve pianificare i viaggi dei suoi camion. Ogni camion parte dal *deposito* $d$, *consegna* container pieni agli *importatori* (insieme $I$) e/o *ritira* container vuoti dagli *esportatori* (insieme $E$), poi torna a $d$. Le regole:
- un camion porta *al massimo due container*;
- *prima consegna, poi ritira*: mai un esportatore prima di un importatore;
- si conosce la distanza $c_(h k)$ fra ogni coppia di punti (deposito, importatori, esportatori), uguale nei due versi;
- ogni importatore $i$ ha una domanda $q_i$ di container da ricevere, ogni esportatore $e$ una domanda $q_e$ di container da far ritirare;
- i camion sono quanti ne servono (un camion rientrato può ripartire).
Si vogliono soddisfare tutte le domande percorrendo la *minima distanza totale*.

Con due container al massimo e la regola "prima consegno, poi ritiro", i giri possibili sono pochi: al più 2 fermate dagli importatori seguite da al più 2 dagli esportatori. Si dividono per numero di fermate:

#align(center, table(columns: 3, align: (center, left, left), inset: 6pt,
  [insieme], [cammini], [perché non ce ne sono altri],
  [$P_1$ \ 1 fermata], [#catena("d", "i", "d") \ #v(2pt) #catena("d", "e", "d")], [],
  [$P_2$ \ 2 fermate], [#catena("d", "i1", "i2", "d") \ #v(2pt) #catena("d", "i", "e", "d") \ #v(2pt) #catena("d", "e1", "e2", "d")], [manca $d -> e -> i -> d$: \ prima si consegna, poi si ritira],
  [$P_3$ \ 3 fermate], [#catena("d", "i1", "i2", "e", "d") \ #v(2pt) #catena("d", "i", "e1", "e2", "d")], [mai tre importatori o tre esportatori: \ il camion porta due container],
  [$P_4$ \ 4 fermate], [#catena("d", "i1", "i2", "e1", "e2", "d")], [parte con 2 pieni, torna con 2 vuoti],
))

L'insieme di tutti i cammini è $P = P_1 union P_2 union P_3 union P_4$. Da qui in poi tutto il lavoro è sui dati, prima del modello:
- il *costo* $c_p$ del cammino $p$ è la somma delle distanze dei suoi tratti. Per il cammino $d -> i -> e -> d$ è $c_(d i) + c_(i e) + c_(e d)$. È un parametro: lo calcolo una volta generati i cammini;
- nulla vieta $i_1 = i_2$ (o $e_1 = e_2$): lo stesso camion porta *due container allo stesso cliente*, e il tratto fra le due "fermate" costa 0. Per questo il parametro che dice se un cammino passa da un cliente non è binario: $a_(p i)$ = numero di volte (0, 1 o 2) che il cammino $p$ visita l'importatore $i$, e $a_(p e)$ lo stesso per l'esportatore $e$. Ecco il caso in cui il parametro vale 2;
- se un cliente è sia importatore sia esportatore, lo si tratta come due punti diversi a distanza 0.

*Variabili*: $y_p$ = numero di volte che viene fatto il cammino $p in P$. È intera e non binaria perché lo stesso giro può servire più volte (un importatore che aspetta 6 container riceve più camion).

$
min & sum_(p in P) c_p y_p &&&& #text(9pt)[← distanza totale] \
& sum_(p in P) a_(p i) y_p = q_i quad && forall i in I quad && #text(9pt)[← ogni importatore riceve i suoi container] \
& sum_(p in P) a_(p e) y_p = q_e quad && forall e in E quad && #text(9pt)[← da ogni esportatore ritiro i suoi container] \
& y_p in NN_0 quad && forall p in P
$

I vincoli hanno la forma della partizione, con $q_i$ al posto di 1: sommo i cammini che passano da $i$, ciascuno contato quanti container gli lascia, e il totale deve essere la sua domanda. La capacità del camion e l'ordine consegna-ritiro *non compaiono nel modello*: sono già dentro la costruzione di $P$, come l'incompatibilità delle barche era dentro $cal(F)$.

#nota[Tutta la difficoltà sta nel generare i cammini; il modello poi è semplice. Qui si può fare perché i cammini hanno al più 4 fermate: con giri lunghi sarebbero troppi, e si generano solo quando servono (generazione di colonne, non si fa nel corso).]

== Problemi di flusso su rete

Le variabili *binarie* dicono se faccio una cosa, le *intere* quante volte. Anche una variabile *continua* (un numero reale) può dire sì o no: se vale 0 la scelta non è fatta, se è positiva è fatta e il valore dice *quanto*.

Si usa nei *problemi di flusso su rete*. Una rete è un grafo orientato: qualcosa (merce, energia, dati, acqua, gas) si muove lungo gli archi, e le variabili dicono *quanto* ne passa su ogni arco, quindi anche quali archi si usano.

*Il problema delle fognature*. Una città ha 4 quartieri, i nodi 1, 2, 3 e 4. Ogni quartiere produce una quantità nota di acque reflue, in m³/h: 1 i quartieri 1, 2 e 3, e 0,5 il quartiere 4. Tutta l'acqua va portata a un unico depuratore, il nodo 5. Le condotte che si possono costruire sono gli archi $A = {(1, 5), (2, 1), (2, 3), (2, 5), (3, 5), (4, 3)}$: ogni condotta ha un verso. Il costo della condotta $(i, j)$ è proporzionale all'acqua che ci passa: $c_(i j)$ per ogni m³/h. Si vuole decidere quali condotte costruire e quanto grandi, per portare tutto al depuratore al costo minimo. È un problema di *disegno di rete*.

#let fogn = (("1"): (0, 3.6), ("5"): (4.4, 3.6), ("2"): (0, 1.2), ("3"): (4.4, 1.2), ("4"): (2.6, -0.4))
#let fogna = (("1", "5"), ("2", "1"), ("2", "3"), ("2", "5"), ("3", "5"), ("4", "3"))
#let fognc = ("1-5": 6, "2-1": 3, "2-3": 7, "2-5": 12, "3-5": 3, "4-3": 2)
#let prod = (("1"): 1, ("2"): 1, ("3"): 1, ("4"): 0.5)
#let dec(x) = str(x)
#let fognnote = (("1"): ((-1.25, 0), [produce 1]), ("2"): ((-1.25, 0), [produce 1]), ("3"): ((1.25, 0), [produce 1]), ("4"): ((-1.45, 0), [produce 0,5]), ("5"): ((1.35, 0), [depuratore]))

#grid(columns: (auto, 1fr), gutter: 1.5em, align: horizon,
  rete(fogn, fogna, colori: ("5": rgb("#fff3c4")), note: fognnote,
    etichette: fognc.pairs().map(((k, c)) => (k, $c = #c$)).to-dict()),
  [
    *Variabili*: $x_(i j)$ = flusso (m³/h) sulla condotta $(i, j) in A$. È continua. Se $x_(i j) = 0$ la condotta non si costruisce; se è positiva si costruisce, e il valore è anche la sua *dimensione*.

    *Funzione obiettivo*: ogni condotta costa $c_(i j)$ per ogni unità di flusso,
    $ min sum_((i, j) in A) c_(i j) x_(i j) $
    cioè $min #(fogna.map(((a, b)) => $#fognc.at(a + "-" + b) x_(#a #b)$).join($+$))$.
  ])

*Vincoli*. Senza vincoli il minimo sarebbe tutto a 0: niente condotte, costo zero. Bisogna dire dove va l'acqua. La regola è la *conservazione del flusso*: in ogni nodo l'acqua non si crea e non sparisce, quindi *tutto quello che entra è uguale a tutto quello che esce*. Quello che il quartiere produce conta come acqua che entra nel nodo.

#block(breakable: false, align(center, table(columns: 4, align: (center, right, center, left), inset: 6pt,
  [nodo], [entra], [], [esce],
  ..("1", "2", "3", "4").map(n => {
    let e = fogna.filter(((a, b)) => b == n).map(((a, b)) => $x_(#a #b)$)
    let u = fogna.filter(((a, b)) => a == n).map(((a, b)) => $x_(#a #b)$)
    ([#n], $#((e + ($#dec(prod.at(n))$,)).join($+$))$, $=$, $#(u.join($+$))$)
  }).flatten(),
  [5], $#(fogna.filter(((a, b)) => b == "5").map(((a, b)) => $x_(#a #b)$).join($+$))$, $=$, $1 + 1 + 1 + 0.5 = 3.5$,
)))

Il nodo 4 non ha scelta: il suo 0,5 va tutto sulla condotta $(4, 3)$. Il nodo 2 invece ha tre strade e deve dividere la sua unità fra $x_(2 1)$, $x_(2 3)$ e $x_(2 5)$: è lì che il modello decide. Nel nodo 5 quello che "esce" è l'acqua che il depuratore assorbe: tutta quella prodotta, 3.5. Questo vincolo è *ridondante*: si ottiene sommando gli altri quattro.

Per scrivere questi vincoli in forma generale si dà un nome alla quantità che ogni nodo produce o richiede: il *deficit* $b_i$, cioè quanto *manca* al nodo $i$. Per ragioni storiche si ragiona "al contrario": un nodo che produce ha deficit *negativo*.

#align(center, table(columns: 3, align: (center, left, left),
  [deficit], [il nodo è…], [nelle fognature],
  $b_i < 0$, [una *sorgente*: offre $|b_i|$ unità di flusso], [i quartieri: $b_1 = b_2 = b_3 = -1$, $b_4 = -0.5$],
  $b_i > 0$, [un *pozzo*: richiede $b_i$ unità di flusso], [il depuratore: $b_5 = 3.5$],
  $b_i = 0$, [un *nodo di transito*: il flusso ci passa e basta], [nessuno (sarebbe un incrocio di tubi)],
))

Portando tutte le variabili a sinistra, "entra = esce" diventa *entra − esce = deficit*. Sono i *vincoli di conservazione del flusso* (o di bilancio), uno per nodo:
$ sum_(j : (j, i) in A) x_(j i) - sum_(j : (i, j) in A) x_(i j) = b_i quad "per ogni nodo" i $
La prima somma è sugli archi che *entrano* in $i$, la seconda su quelli che *escono*. Per il nodo 1: $x_(2 1) - x_(1 5) = -1$, che è $x_(2 1) + 1 = x_(1 5)$ di prima.

Tutto quello che le sorgenti offrono deve essere assorbito dai pozzi, quindi i deficit sommati fanno zero: $sum_i b_i = 0$. Il deficit del depuratore non è un dato in più: $b_5 = -(b_1 + b_2 + b_3 + b_4) = 3.5$.

Resta il dominio: il flusso non può essere negativo, $x_(i j) >= 0$ per ogni $(i, j) in A$.

#nota[Un nodo *di transito* è solo quello con $b_i = 0$. Se un nodo produce o richiede qualcosa ($b_i != 0$) non è di transito, anche se ci passa dentro il flusso di altri nodi: nelle fognature il 3 riceve l'acqua del 4 ma resta una sorgente.]

*Flusso di costo minimo* (Minimum Cost Flow, MCF). Le fognature sono un caso di un problema più generale: un grafo orientato $G = (V, A)$, un deficit $b_i$ per ogni nodo, un costo $c_(i j)$ per unità di flusso su ogni arco e, in più, una *capacità* $mu_(i j)$: il massimo flusso che l'arco può portare. Il modello è quello di prima con la capacità nel dominio:

$
min z = & sum_((i, j) in A) c_(i j) x_(i j) &&&& #text(9pt)[← costo del flusso] \
& sum_(j : (j, i) in A) x_(j i) - sum_(j : (i, j) in A) x_(i j) = b_i quad && forall i in V quad && #text(9pt)[← conservazione del flusso] \
& 0 <= x_(i j) <= mu_(i j) quad && forall (i, j) in A quad && #text(9pt)[← capacità e non negatività]
$

Quando un arco è pieno, il resto del flusso deve prendere altre strade. Le fognature sono un MCF senza capacità ($mu_(i j) = +infinity$): lì la condotta si costruiva della misura giusta per il flusso.

*Cammino di costo minimo* (Shortest Path Problem, SPP). Su un grafo orientato con un costo $c_(i j)$ per arco ci sono un nodo di partenza $s$ e uno di arrivo $t != s$. Si cerca il cammino da $s$ a $t$ che costa meno, come fa Google Maps. Ci sono algoritmi fatti apposta, ma si può scrivere anche come MCF, con due piccole modifiche.

Un cammino è un flusso di *una sola unità*: sono io che mi sposto da $s$ a $t$. Quindi $s$ è una sorgente che offre 1, $t$ un pozzo che chiede 1, e tutti gli altri nodi sono di transito: se il cammino ci passa entra 1 ed esce 1, altrimenti 0 e 0.
$ b_i = cases(-1 quad & i = s, 1 & i = t, 0 & "altrimenti") $
Visto che passa una persona sola, la capacità si può mettere a 1 su tutti gli archi ($mu_(i j) = 1$; va bene anche $+infinity$).

#let spn = (("1"): (0, 1.1), ("2"): (2, 2.2), ("3"): (2, 0), ("4"): (4, 1.1))
#let spa = (("1", "2"), ("1", "3"), ("2", "4"), ("3", "2"), ("3", "4"))
#let spc = ("1-2": 2, "1-3": 1, "2-4": 1, "3-2": 3, "3-4": 2)
#let spb = (("1"): -1, ("2"): 0, ("3"): 0, ("4"): 1)
#let spnote = (("1"): ((-0.75, 0), $s$), ("4"): ((0.75, 0), $t$))

#align(center, grid(columns: 2, column-gutter: 2.5em, row-gutter: 6pt, align: center,
  rete(spn, spa, evid: ("1-2", "2-4"), note: spnote, etichette: spc.pairs().map(((k, c)) => (k, $c = #c$)).to-dict()),
  rete(spn, spa, evid: ("1-2", "2-4", "1-3", "3-4"), note: spnote,
    etichette: ("1-2": $0.5$, "2-4": $0.5$, "1-3": $0.5$, "3-4": $0.5$, "3-2": $0$)),
  text(8pt)[un cammino ottimo, $1 -> 2 -> 4$], text(8pt)[mezzo cammino per parte: ammesso dal modello],
))

Nell'esempio i cammini da 1 a 4 sono tre: $1 -> 2 -> 4$ costa $2 + 1 = 3$, $1 -> 3 -> 4$ costa $1 + 2 = 3$, $1 -> 3 -> 2 -> 4$ costa $1 + 3 + 1 = 5$. I primi due sono ottimi, ed è indifferente quale scegliere. Il modello:

#block(breakable: false, grid(columns: (auto, 1fr), gutter: 1.5em, align: horizon,
  table(columns: 4, align: (center, right, center, left), inset: 5pt,
    [nodo], [entra − esce], [], [$b_i$],
    ..("1", "2", "3", "4").map(n => {
      let e = spa.filter(((a, b)) => b == n).map(((a, b)) => $+ x_(#a #b)$)
      let u = spa.filter(((a, b)) => a == n).map(((a, b)) => $- x_(#a #b)$)
      ([#n], $#((e + u).join())$, $=$, $#spb.at(n)$)
    }).flatten()),
  [
    $min z = #(spa.map(((a, b)) => { let c = spc.at(a + "-" + b); $#(if c != 1 { str(c) }) x_(#a #b)$ }).join($+$))$

    Nel nodo 1 esce soltanto, nel 4 entra soltanto. Nei nodi 2 e 3 quello che entra deve uscire.
  ]))

Il modello però ammette anche la soluzione a destra: $x_(1 2) = x_(2 4) = x_(1 3) = x_(3 4) = 0.5$, mezza persona su un cammino e mezza sull'altro. Rispetta tutti i bilanci (nel nodo 2 entra 0,5 ed esce 0,5) e costa $0.5 dot 3 + 0.5 dot 3 = 3$, come l'ottimo. Ma non è un cammino. Per avere un cammino vero serve il *vincolo di interezza*: $x_(i j) in {0, 1}$.

#nota[Se interessa solo il *valore* ottimo (quanto costa il cammino migliore), le variabili continue bastano: il valore esce giusto e il modello si risolve molto più in fretta. Per sapere *quale* cammino fare servono le binarie.]

== Variabili discrete, semicontinue e funzioni a tratti

A volte una variabile non può prendere tutti i valori di un intervallo, ma solo alcuni: pochi valori fissi, oppure zero o un intervallo, oppure deve seguire una funzione fatta a pezzi. Il trucco è sempre lo stesso: *una variabile binaria per ogni caso possibile*, che dice in quale caso sono.

*Variabili a valori discreti*. Nelle fognature $x_(i j)$ era insieme il flusso e la dimensione della condotta. In realtà le condotte esistono solo in tre misure, con portata 0,7, 1,4 e 3: la condotta può essere più grande del flusso che ci passa. Servono due variabili per arco: $x_(i j)$ resta il flusso, e $y_(i j)$ è la dimensione della condotta, con $y_(i j) in {0, 0.7, 1.4, 3}$ (0 = non la costruisco). Ora si paga la condotta, quindi il costo dipende dalla dimensione: $min sum_((i, j) in A) c_(i j) y_(i j)$.

#align(center, asse(3.2, scala: 2.2, punti: (0, 0.7, 1.4, 3), tacche: (0, 0.7, 1.4, 3),
  sopra: ((0, [tutte $z = 0$]), (0.7, $z^1_(i j) = 1$), (1.4, $z^2_(i j) = 1$), (3, $z^3_(i j) = 1$))))

Un dominio come ${0, 0.7, 1.4, 3}$ non si scrive direttamente: si usa una binaria per ogni valore, $z^h_(i j) = 1$ se la condotta $(i, j)$ ha la misura $h$.

$
& y_(i j) = 0.7 z^1_(i j) + 1.4 z^2_(i j) + 3 z^3_(i j) quad && forall (i, j) in A quad && #text(9pt)[← la dimensione è la misura scelta] \
& z^1_(i j) + z^2_(i j) + z^3_(i j) <= 1 quad && forall (i, j) in A quad && #text(9pt)[← al massimo una misura] \
& x_(i j) <= y_(i j) quad && forall (i, j) in A quad && #text(9pt)[← il flusso non supera la portata] \
& z^h_(i j) in {0, 1} quad && forall (i, j) in A, h = 1, 2, 3
$

Il $<= 1$ e non $= 1$ perché posso anche non scegliere nessuna misura: tutte le $z$ a 0 danno $y_(i j) = 0$, e allora $x_(i j) <= 0$, cioè niente condotta e niente flusso. Se lo 0 non fosse ammesso, cioè se dovessi per forza scegliere una delle misure, la somma sarebbe $= 1$. Il vincolo $x_(i j) <= y_(i j)$ è il legame fra le due famiglie di variabili: senza, il $min$ metterebbe tutte le $y$ a 0.

In forma generale, con valori ammessi $d_1, dots, d_n$: $y = sum_(i=1)^n d_i z_i$, $sum_(i=1)^n z_i = 1$ (o $<= 1$ se è ammesso anche lo 0), $z_i in {0, 1}$.

*Variabili semicontinue*. Ora la condotta, se la costruisco, può avere qualunque dimensione fra un minimo $l_(i j)$ e un massimo $u_(i j)$. Quindi $y_(i j)$ vale 0 oppure sta in $[l_(i j), u_(i j)]$: non è un intervallo solo, c'è un buco fra 0 e $l_(i j)$.

#align(center, asse(4, scala: 1.6, punti: (0,), interv: ((1.5, 3.5),), tacche: (0, (1.5, $l_(i j)$), (3.5, $u_(i j)$)),
  sopra: ((0, [$z = 0$]), (2.5, [$z = 1$: $l_(i j) <= y_(i j) <= u_(i j)$]))))

Con una binaria $z_(i j) = 1$ se costruisco la condotta, *moltiplico i due limiti per $z$*:
$ l_(i j) z_(i j) <= y_(i j) <= u_(i j) z_(i j) quad quad z_(i j) in {0, 1} $
Se $z = 1$ restano i limiti originali, $l <= y <= u$. Se $z = 0$ diventa $0 <= y <= 0$, cioè $y = 0$.

*Costi di setup*. Capita spesso nei problemi di produzione. Produrre costa $c$ per ogni unità (costo variabile), ma avviare la produzione, per esempio accendere la macchina, costa $k$ una volta sola, che faccia un pezzo o 500: è il *costo di setup*. In più, se produco, devo farlo fra una quantità minima $l$ e una massima $u$. Con $x$ = quantità prodotta e $y = 1$ se produco:

#grid(columns: (auto, 1fr), gutter: 1.5em, align: horizon,
  atratti(((0.01, 4, x => 1.5 + 0.5 * x),), 4.5, 0, 4, sx: 0.9, sy: 0.6, pieni: ((0, 0), (4, 3.5)), vuoti: ((0, 1.5),), xt: ((4, $u$),), yt: ((1.5, $k$),), xl: $x$, yl: [costo]),
  [
    $
    min & c x + k y \
    & l y <= x <= u y \
    & x >= 0, quad y in {0, 1}
    $
    Il costo vale 0 se non produco e $k + c x$ se produco: nel disegno il salto in 0 è il setup.
  ])

È lo stesso trucco delle semicontinue: se $y = 0$ allora $x = 0$, e $k$ non lo pago; se produco qualcosa il vincolo obbliga $y = 1$, e pago $k$. Una variabile dice *se* produco, l'altra *quanto*.

Se il testo non dà un massimo $u$, il legame fra $x$ e $y$ serve lo stesso. Allora il massimo me lo invento: un numero $M$ *grande a piacere*, più grande di qualunque quantità possibile nel problema (se non si può superare 10, va bene 11 o 20). Con $l = 0$ il vincolo diventa solo $x <= M y$.

*Funzioni lineari a tratti*. Un costo può cambiare forma a pezzi: un prezzo fino a una certa quantità, poi uno sconto, poi un altro prezzo… Esempio:

#let fpezzi = ((0, 2, x => 1 + 2 * x), (3, 4, x => 3), (5, 8, x => 22 - 3 * x))
#grid(columns: (auto, 1fr), gutter: 1.5em, align: horizon,
  atratti(fpezzi, 8.7, -2.5, 7.5, sx: 0.55, sy: 0.38, pieni: ((0, 0), (2, 5), (3, 3), (4, 3), (5, 7), (8, -2)), vuoti: ((0, 1),),
    xt: range(1, 9), yt: (-2, 3, 5, 7)),
  [
    $ f(x) = cases(0 & x = 0, 1 + 2x quad & x in (0, 2], 3 & x in [3, 4], 22 - 3x & x in [5, 8]) $
    Fra 2 e 3 e fra 4 e 5 la $x$ non può stare: la funzione ha dei *buchi* (è discontinua).
  ])

Per scriverla nel modello devo sapere *in quale tratto* sono e *dove*, dentro quel tratto:
- una binaria per tratto, $z^i = 1$ se $x$ sta nel tratto $i$. Non posso stare in due tratti insieme: $z^1 + z^2 + z^3 <= 1$ (tutte a 0 vuol dire $x = 0$);
- una continua per tratto, $w^i$ = il valore di $x$ se sono nel tratto $i$, 0 altrimenti. Si lega alla sua $z$ come una semicontinua: $3 z^2 <= w^2 <= 4 z^2$;
- $x = w^1 + w^2 + w^3$: al più una delle $w$ è diversa da 0, ed è proprio la $x$;
- in ogni tratto $f$ è una retta, termine noto + pendenza × $x$. Il termine noto è un *costo fisso*, pagato solo se sono in quel tratto (moltiplico per $z^i$); la pendenza è un *costo variabile* (moltiplico per $w^i$).

$
min f = & z^1 + 2 w^1 + 3 z^2 + 22 z^3 - 3 w^3 &&#text(9pt)[← $1 + 2x$, $3$, $22 - 3x$ tratto per tratto] \
& x = w^1 + w^2 + w^3 \
& 0 <= w^1 <= 2 z^1, quad 3 z^2 <= w^2 <= 4 z^2, quad 5 z^3 <= w^3 <= 8 z^3 \
& z^1 + z^2 + z^3 <= 1 \
& x, w^1, w^2, w^3 >= 0, quad z^1, z^2, z^3 in {0, 1}
$

$w^2$ non compare in $f$ perché il secondo tratto è piatto: pendenza 0. Se lo 0 non fosse fra i valori ammessi di $x$, la somma delle $z$ sarebbe $= 1$.

#nota[Il primo tratto è aperto in 0, $(0, 2]$, ma il $<$ stretto non si scrive: si mette $0 <= w^1$. Di solito non cambia niente, perché si minimizza e fra $f = 1$ (primo tratto con $x = 0$) e $f = 0$ il modello sceglie 0. Se servisse davvero, si mette $epsilon z^1 <= w^1$ con $epsilon$ piccolo. All'esame non si chiede.]

In generale, con $n$ tratti $[l_i, u_i]$ che non si sovrappongono e $f = b_i + c_i x$ nel tratto $i$ (la somma delle $z$ è $<= 1$ se è ammesso lo 0, altrimenti $= 1$):
$ min f = sum_(i=1)^n (b_i z^i + c_i w^i) quad "s.t." quad x = sum_(i=1)^n w^i, quad l_i z^i <= w^i <= u_i z^i, quad sum_(i=1)^n z^i <= 1, quad w^i >= 0, quad z^i in {0, 1} $

*La fonderia con gli sconti*. La fonderia del primo esempio deve sempre produrre 1000 kg, ma ora i tre materiali ferrosi (qui A, B e C, cioè $x_1$, $x_2$, $x_3$) si comprano da tre fornitori, ognuno con le sue condizioni:

#align(center, block(breakable: false, table(columns: 2, align: (center, left), inset: 6pt,
  [fornitore], [condizioni],
  [A], [fino a 350 kg 0,03 €/kg; da 350 a 750 kg 0,05 €/kg; oltre 750 kg 0,08 €/kg],
  [B], [fino a 600 kg 0,04 €/kg; oltre 600 kg 0,02 €/kg; ordini fra 450 e 600 kg non accettati],
  [C], [10 € fissi per qualunque quantità fra 100 e 400 kg; oltre 400 kg 0,06 €/kg; meno di 100 kg non si può],
)))

I vincoli sul silicio e sul manganese non cambiano. Cambia la funzione obiettivo: il costo di ogni materiale non è più prezzo × quantità, ma una funzione a tratti della quantità comprata.

Il caso più semplice è B. Tradotto: o ordino *da 0 a 450 kg a 0,04 €/kg*, o ordino *da 600 kg in su a 0,02 €/kg* (tutto al prezzo scontato). Oltre i 1000 kg non serve andare: in tutto ne servono 1000.

#grid(columns: (auto, 1fr), gutter: 1.5em, align: horizon,
  atratti(((0, 450, x => 0.04 * x), (600, 1000, x => 0.02 * x)), 1100, 0, 22, sx: 0.0055, sy: 0.13,
    pieni: ((0, 0), (450, 18), (600, 12), (1000, 20)), xt: (450, 600, 1000), yt: (12, 18), xl: [kg], yl: [€]),
  [
    Due tratti, quindi due binarie e due continue. Il pedice è il materiale (2 = B), l'apice il tratto:
    - $z^1_2 = 1$ se ordino fra 0 e 450 kg, $w^1_2$ = quanti kg a 0,04 €/kg;
    - $z^2_2 = 1$ se ordino fra 600 e 1000 kg, $w^2_2$ = quanti kg a 0,02 €/kg.
  ])

$
& x_2 = w^1_2 + w^2_2 &&#text(9pt)[← B comprato a uno dei due prezzi] \
& 0 <= w^1_2 <= 450 z^1_2, quad 600 z^2_2 <= w^2_2 <= 1000 z^2_2 &&#text(9pt)[← ogni quantità nel suo intervallo] \
& z^1_2 + z^2_2 <= 1, quad z^1_2, z^2_2 in {0, 1} &&#text(9pt)[← al massimo un prezzo (o niente)]
$

e nella funzione obiettivo il termine $0.030 x_2$ diventa $0.04 w^1_2 + 0.02 w^2_2$.

Va bene anche contare in $w^2_2$ solo i kg *oltre* 600: $x_2 = w^1_2 + 600 z^2_2 + w^2_2$, con $0 <= w^2_2 <= (1000 - 600) z^2_2$ e costo $0.04 w^1_2 + 0.02 dot 600 z^2_2 + 0.02 w^2_2$. È lo stesso modello scritto in un altro modo.
