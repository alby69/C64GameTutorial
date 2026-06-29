# Appendice D — Schemi Rapidi: Video e Sprite

## Layout Schermo Testo

```
 Schermo: 40 colonne × 25 righe = 1000 caratteri

 $0400 ┌──────┬──────┬──────┬──────┬──────┐
       │  R0  │  R0  │  R0  │ .... │  R0  │  Riga 0: $0400-$0427
       │ C0   │ C1   │ C2   │      │ C39  │
       ├──────┼──────┴──────┴──────┴──────┤
       │  R1  │                          │  Riga 1: $0428-$044F
       ├──────┤                          │
       │ ...  │     Area di gioco        │  ...
       ├──────┤     (25 righe)           │
       │ R23  │                          │  Riga 23: $0788-$07AF
       ├──────┼──────┬──────┬──────┬──────┤
       │ R24  │  R24 │  R24 │ .... │ R24  │  Riga 24: $07C0-$07E7
 $07E7 └──────┴──────┴──────┴──────┴──────┘
```

### Calcolo Indirizzi

```
offset = riga * 40 + colonna

indirizzo_carattere = $0400 + offset
indirizzo_colore    = $D800 + offset

Esempi:
  Riga 0, Colonna 0   → $0400 / $D800
  Riga 12, Colonna 20 → $0400 + 500 = $05F4 / $D9F4
  Riga 24, Colonna 39 → $0400 + 999 = $07E7 / $DBE7
```

---

## Schema Sprite 24x21

```
 Ogni sprite: 24 pixel × 21 righe = 63 byte

 Riga 0:  ┌──────────────────────────────────┐
          │ Byte 0          Byte 1    Byte 2 │
          │ bit: 543210     543210    543210 │
 Riga 1:  ├──────────────────────────────────┤
          │                                  │
    ...   │     Dati pixel (1=acceso)        │
          │                                  │
 Riga 20: ├──────────────────────────────────┤
          │                                  │
          └──────────────────────────────────┘

 Struttura byte:
 76543210  76543210  76543210
 ││││││││  ││││││││  ││││││││
 PPHHHHHH  PPHHHHHH  PPHHHHHH
 ││       ││       ││
 │└─ pixel 2-7     │└─ pixel 10-15
 │                  └─ pixel 18-23
 └── pixel 0-1 (multicolore)
```

### Legenda bit multicolore

| P1 | P0 | Colore |
|----|----|--------|
| 0 | 0 | Sfondo (trasparente) |
| 0 | 1 | Colore $D025 |
| 1 | 0 | Colore sprite (es. $D027) |
| 1 | 1 | Colore $D026 |

---

## Mappa Registri VIC-II per Sprite

```
             Sprite:  0     1     2     3     4     5     6     7
             ──────────────────────────────────────────────────────
 Coordinate X:       D000  D002  D004  D006  D008  D00A  D00C  D00E
 Coordinate Y:       D001  D003  D005  D007  D009  D00B  D00D  D00F
 Colori:             D027  D028  D029  D02A  D02B  D02C  D02D  D02E
 Sprite pointer:     $07F8 $07F9 $07FA $07FB $07FC $07FD $07FE $07FF

 Registri globali (1 bit per sprite, da 0 a 7):
   $D015  → Abilitazione sprite
   $D010  → MSB X (9° bit per X > 255)
   $D017  → Espansione verticale (2x)
   $D01D  → Espansione orizzontale (2x)
   $D01C  → Modo multicolore
   $D01B  → Priorita sfondo/sprite
   $D01E  → Collisioni sprite-sprite
   $D01F  → Collisioni sprite-sfondo
```

### Formula Sprite Pointer

```
pointer = indirizzo_dati_sprite / 64

Esempio: dati a $2000 → pointer = $2000 / $40 = $80 = 128
         dati a $3100 → pointer = $3100 / $40 = $C4 = 196
```

---

## Raster Beam e Interrupt

### Schema fascio raster

```
  Riga 0 → ┌──────────────────────────────────┐
  Riga 50 →│  HUD / bordo superiore           │
           │                                   │
  Riga 100→│  Area di gioco                   │
           │   Il beam scende:                │
  Riga 150→│   ← e qui ora                    │
           │                                   │
  Riga 250→│                                   │
           ├──────────────────────────────────┤
  Riga 311→│  Fuori schermo (ritorno)         │
           └──────────────────────────────────┘
```

### Flusso Interrupt Raster

```
  INIZIO FRAME
       │
       ▼
  Il VIC-II inizia a disegnare dall'alto
       │
       │ Quando il raster raggiunge la riga X
       ▼
  ┌─────────────────┐
  │  VIC genera IRQ  │────→ CPU ferma il main, esegue ISR
  └─────────────────┘
       │
       ▼
  ISR (es. cambia colore, prepara sprite)
       │
       ▼
  ├── ACK interrupt ($D019) ──→ Torna al main loop
  │
  └── Prepara prossimo IRQ (nuova riga, nuovo vettore)
```

### Setup IRQ Standard

```asm
; 1. Disabilita interrupt
SEI

; 2. Salva vettore IRQ esistente
LDA #<MIA_IRQ
STA $0314
LDA #>MIA_IRQ
STA $0315

; 3. Imposta riga raster per l'IRQ
LDA #50           ; riga 50
STA $D012

; 4. MSB del raster a 0
LDA $D011
AND #$7F
STA $D011

; 5. Abilita interrupt raster
LDA #1
STA $D01A

; 6. Riabilita interrupt
CLI
```

---

## Schema Raster Split Multi-Zona

```
 IRQ 1 (riga 40)
   │
   ▼
 ┌────────────────────────────────────────┐
 │  ZONA HUD: sfondo blu                 │
 │  Colori, bordo, eventuale sprite      │
 └────────────────────────────────────────┘
   │
   │ IRQ 2 (riga 200)
   ▼
 ┌────────────────────────────────────────┐
 │  ZONA GIOCO: sfondo nero              │
 │  Area principale, scroll eventuale    │
 └────────────────────────────────────────┘
   │
   │ IRQ 3 (riga 250)
   ▼
 ┌────────────────────────────────────────┐
 │  ZONA INFERIORE: sfondo grigio        │
 │  Barra info, punteggio                │
 └────────────────────────────────────────┘
   │
   ▼ Torna a IRQ 1
```

### Catena IRQ a 3 zone

```
IRQ_1: cambia colore per HUD
       imposta prossimo IRQ a riga 200 → IRQ_2
       ACK, fine

IRQ_2: cambia colore per area gioco
       imposta prossimo IRQ a riga 250 → IRQ_3
       ACK, fine

IRQ_3: cambia colore per barra inferiore
       imposta prossimo IRQ a riga 40 → IRQ_1
       ACK, fine
       ───→ loop
```

---

## Sprite Multiplexing — Divisione a Zone

```
  ┌──────────────────────────────────┐
  │ ZONA 0 (righe 0-79)              │
  │                                  │
  │  Sprite HW 0-7 → entita 0-7     │  ← IRQ a riga 80
  │                                  │
  ├──────────────────────────────────┤
  │ ZONA 1 (righe 80-159)            │
  │                                  │
  │  Sprite HW 0-7 → entita 8-15    │  ← IRQ a riga 160
  │                                  │
  ├──────────────────────────────────┤
  │ ZONA 2 (righe 160-239)           │
  │                                  │
  │  Sprite HW 0-7 → entita 16-23   │  ← IRQ a riga 240
  │                                  │
  └──────────────────────────────────┘

  Ogni IRQ: riscrive le coordinate X/Y degli 8 sprite HW
  con le coordinate delle entita della zona corrispondente.
```

### Pool Entita (16/24/32 entita virtuali)

```
ENTITIES:
  ┌────┬────┬────┬────┬────┬────┬────┬────┬────┬────┬───
  │ E0 │ E1 │ E2 │ E3 │ E4 │ E5 │ E6 │ E7 │ E8 │ E9 │...
  └────┴────┴────┴────┴────┴────┴────┴────┴────┴────┴───
   ↑                                ↑
   Zona 0                           Zona 1
   (sprite HW 0-7)                  (stessi sprite HW 0-7)
```

---

## Collision Detection — Bounding Box

```
  Due sprite collidono se i loro rettangoli si sovrappongono:

  Sprite A              Sprite B
  ┌─────────┐           ┌─────────┐
  │ 24x21   │           │ 24x21   │
  │         │           │         │
  └─────────┘           └─────────┘
       ↑                     ↑
   (Ax, Ay)              (Bx, By)

  CONDIZIONE:
      |Ax - Bx| < 24    (differenza X minore della larghezza)
  AND |Ay - By| < 21    (differenza Y minore dell'altezza)
```

### Codice Collisione (differenza assoluta)

```asm
    LDA AX
    SEC
    SBC BX
    BCS POS_X         ; se positivo, ok
    EOR #$FF          ; altrimenti valore assoluto
    CLC
    ADC #1
POS_X
    CMP #24
    BCS NO_COLLISION

    LDA AY
    SEC
    SBC BY
    BCS POS_Y
    EOR #$FF
    CLC
    ADC #1
POS_Y
    CMP #21
    BCS NO_COLLISION
    ; qui collisione rilevata!
```

---

## Tabella Color RAM e Colori Sprite

```
  Color RAM: $D800-$DBE7
  Ogni byte = colore del carattere corrispondente in Screen RAM

  $D800 → colore carattere in $0400
  $D801 → colore carattere in $0401
  ...       ...
  $DBE7 → colore carattere in $07E7

  Registri colore sprite:
  $D025 → Colore multicolore 0 (comune a tutti gli sprite)
  $D026 → Colore multicolore 1 (comune a tutti gli sprite)
  $D027-$D02E → Colori individuali sprite 0-7
```
