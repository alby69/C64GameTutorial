# Capitolo 5 — Sprite Hardware del VIC-II

## Obiettivi

Al termine di questo capitolo saprai:

- Cosa sono gli sprite del C64
- I registri per controllare gli sprite
- Come creare dati per uno sprite
- Come visualizzare il primo sprite
- Come assegnare colore e posizione

---

## 5.1 Cos'e uno sprite

Uno sprite e un'immagine indipendente che il VIC-II disegna senza bisogno di riscrivere la memoria video. Ogni sprite:

```
Larghezza:    24 pixel
Altezza:      21 pixel
Dimensione:   63 byte (21 righe × 3 byte)
Numero:       8 sprite hardware (0-7)
```

```
+----------------------------+
|                            |
|         24 pixel           |
|                            |
+----------------------------+
        21 linee
```

Ogni riga = 24 bit = 3 byte. Un bit = 1 acceso, 0 spento.

```
Byte 0        Byte 1        Byte 2
┌──────────┐ ┌──────────┐ ┌──────────┐
│xxxxxxxx  │ │xxxxxxxx  │ │xxxxxxxx  │  ← riga 0
│xxxxxxxx  │ │xxxxxxxx  │ │xxxxxxxx  │  ← riga 1
│...       │ │...       │ │...       │  ← ...
│xxxxxxxx  │ │xxxxxxxx  │ │xxxxxxxx  │  ← riga 20
└──────────┘ └──────────┘ └──────────┘
PPHHHHHH    PPHHHHHH    PPHHHHHH
P = pixel 0-1, H = pixel 2-7
```

---

## 5.2 Registri principali degli sprite

### Coordinate

```
Sprite 0: X = $D000  Y = $D001
Sprite 1: X = $D002  Y = $D003
Sprite 2: X = $D004  Y = $D005
Sprite 3: X = $D006  Y = $D007
Sprite 4: X = $D008  Y = $D009
Sprite 5: X = $D00A  Y = $D00B
Sprite 6: X = $D00C  Y = $D00D
Sprite 7: X = $D00E  Y = $D00F
```

### Abilitazione (`$D015`)

Ogni bit controlla uno sprite:

```
Bit 0 = Sprite 0   Bit 4 = Sprite 4
Bit 1 = Sprite 1   Bit 5 = Sprite 5
Bit 2 = Sprite 2   Bit 6 = Sprite 6
Bit 3 = Sprite 3   Bit 7 = Sprite 7
```

```asm
LDA #%00000001   ; abilita solo Sprite 0
STA $D015
```

### Colore sprite

```
Sprite 0: $D027   Sprite 4: $D02B
Sprite 1: $D028   Sprite 5: $D02C
Sprite 2: $D029   Sprite 6: $D02D
Sprite 3: $D02A   Sprite 7: $D02E
```

```asm
LDA #1           ; bianco
STA $D027        ; colore sprite 0
```

---

## 5.3 Dove mettere i dati dello sprite

Lo sprite non si definisce nei registri VIC-II. I dati vanno in RAM e il VIC-II li legge tramite un **puntatore**.

```
Dati sprite → RAM (es. $3000)
                  ↓
Sprite pointer → $07F8 (per sprite 0)
                  ↓
VIC-II legge i dati e disegna lo sprite
```

### I 64 byte dello sprite

L'indirizzo dei dati deve essere multiplo di 64 (allineato).

```
Pointer = indirizzo ÷ 64

Esempio: $3000 = 12288
12288 ÷ 64 = 192

LDA #192
STA $07F8   ; sprite 0 punta a $3000
```

---

## 5.4 Tabella degli Sprite Pointer

Con screen RAM a `$0400`, i pointer sono in `$07F8`-`$07FF`:

```
$07F8 → Sprite 0
$07F9 → Sprite 1
$07FA → Sprite 2
$07FB → Sprite 3
$07FC → Sprite 4
$07FD → Sprite 5
$07FE → Sprite 6
$07FF → Sprite 7
```

---

## 5.5 Primo sprite visualizzato

Ecco il programma completo per vedere uno sprite a schermo:

```asm
*=$8000

START
    ; Abilita sprite 0
    LDA #%00000001
    STA $D015

    ; Colore bianco
    LDA #1
    STA $D027

    ; Posizione iniziale
    LDA #100
    STA $D000       ; X = 100
    STA $D001       ; Y = 100

    ; Pointer a $3000 (192 = 12288/64)
    LDA #192
    STA $07F8

LOOP
    JMP LOOP

; ----------------------------------
; Dati sprite a $3000
; ----------------------------------
*=$3000

SPRITE_DATA
    .byte 0,0,0
    .byte 0,60,0
    .byte 0,126,0
    .byte 255,255,255
    .byte 255,255,255
    .byte 0,126,0
    .byte 0,60,0
    .byte 0,24,0
    .byte 0,0,0
    .byte 0,0,0
    .byte 0,0,0
    .byte 0,0,0
    .byte 0,0,0
    .byte 0,0,0
    .byte 0,0,0
    .byte 0,0,0
    .byte 0,0,0
    .byte 0,0,0
    .byte 0,0,0
    .byte 0,0,0
    .byte 0,0,0
```

> **Attenzione:** il file va assemblato tutto insieme. TMP gestisce le due sezioni `*=$8000` e `*=$3000` nello stesso sorgente.

---

## 5.6 Disegnare il proprio sprite

Ogni byte rappresenta 8 pixel orizzontali. Bit 1 = pixel acceso, Bit 0 = spento.

### Strumento per disegnare

Usa un foglio a quadretti 24×21 e converti ogni riga in 3 byte:

```
Riga 0:  00000000 00000000 00000000  → .byte 0,0,0
Riga 1:  00011000 00100100 00011000  → .byte $18,$24,$18
Riga 2:  00111100 01000010 00111100  → .byte $3C,$42,$3C
...
```

### Calcolatrice visuale

```
Bit: 7 6 5 4 3 2 1 0
     x x x x x x x x
     | | | | | | | |
    128 64 32 16 8 4 2 1

00011000 = 16+8 = 24 = $18
00100100 = 32+4 = 36 = $24
```

---

## 5.7 Organizzare piu sprite

Per gestire piu sprite in modo ordinato:

```asm
; Abilita sprite 0 e 1
LDA #%00000011
STA $D015

; Colori
LDA #1
STA $D027       ; sprite 0 bianco
LDA #7
STA $D028       ; sprite 1 giallo

; Posizioni
LDA #50
STA $D000       ; sprite 0 X
LDA #100
STA $D002       ; sprite 1 X

LDA #80
STA $D001       ; sprite 0 Y
LDA #80
STA $D003       ; sprite 1 Y

; Pointer
LDA #192
STA $07F8       ; sprite 0 → $3000
INC             ; 193
STA $07F9       ; sprite 1 → $3040 (192+1)*64 = $3040
```

---

## 5.8 Tabella riassuntiva registri sprite

| Registro | Funzione |
|---|---|
| `$D000`-`$D00F` | Coordinate X/Y sprite 0-7 |
| `$D010` | MSB X (bit 0-7 per sprite 0-7) |
| `$D015` | Abilitazione sprite |
| `$D017` | Espansione verticale (bit 0-7) |
| `$D01B` | Sprite background priority |
| `$D01C` | Sprite multicolore |
| `$D01D` | Espansione orizzontale (bit 0-7) |
| `$D027`-`$D02E` | Colori sprite 0-7 |
| `$07F8`-`$07FF` | Sprite pointer |

---

## Esercizi

### Esercizio 1
Visualizza uno sprite a forma di astronave (16×16 pixel centrata nel 24×21) al centro dello schermo.

### Esercizio 2
Crea due sprite: uno bianco a sinistra, uno rosso a destra.

### Esercizio 3
Disegna a mano su carta griglia un alieno 24×21, converti in byte e visualizzalo.

### Esercizio 4
Assegna a Sprite 0 i dati a $3100 (calcola il pointer corretto).

### Esercizio 5
Visualizza uno sprite il cui colore cambia ogni iterazione del loop, ciclando tra tutti i 16 colori disponibili.

---

## Riepilogo

Hai imparato:

- Cosa sono gli sprite del VIC-II
- I registri di controllo (posizione, colore, abilitazione)
- I puntatori sprite ($07F8-$07FF) e il calcolo indirizzo÷64
- Come organizzare i dati sprite a 63 byte
- Visualizzare il primo sprite a schermo

## Riferimenti

- [Capitolo 6 — Movimento sprite](06-movimento-e-controllo-sprite.md) — animazione, MSB, multicolore
- [Capitolo 16 — Sprite multiplexing](16-sprite-multiplexing.md) — gestire 8+ sprite
- [Soluzioni](../soluzioni/cap05-sprite.asm) — soluzioni degli esercizi
