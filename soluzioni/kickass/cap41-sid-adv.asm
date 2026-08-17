// Converted to Kick Assembler syntax
.segmentdef Ex1 [start=$c000]
.segmentdef Ex2 [start=$c000]
.segmentdef Ex3 [start=$c000]
.segmentdef Ex4 [start=$c000]
.segmentdef Ex5 [start=$c000]

// --- Shared Constants ---
.const SID_CUTOFF_LO = $D415
.const SID_CUTOFF_HI = $D416
.const SID_RES_FILT  = $D417
.const SID_MODE_VOL  = $D418
.const SID_V3_CTRL   = $D412

// =============================================
// SOLUZIONI Capitolo 41 — SID Avanzato
// --- METADATA ---
// chapter: 41
// title: SID Avanzato
// difficulty: master
// --- END METADATA ---
// =============================================

// --- ESERCIZIO 1: Low-Pass Filter Sweep ---
.segment Ex1
.namespace Ex1 {
    setup_filter:
        lda #$F1            // Resonanza max, filtra Voce 1
        sta SID_RES_FILT
        lda #$1F            // Low-pass mode, Volume 15
        sta SID_MODE_VOL
        rts

    filter_sweep:
        inc cutoff
        lda cutoff
        sta SID_CUTOFF_HI
        rts

    cutoff: .byte 0
}

// --- ESERCIZIO 2: Ring Modulation (Voice 3) ---
.segment Ex2
.namespace Ex2 {
    ring_mod_laser:
        lda #$04            // Triangle + Ring Mod bit
        sta SID_V3_CTRL
        lda #$11            // Gate ON
        ora SID_V3_CTRL
        sta SID_V3_CTRL
        rts
}

// --- ESERCIZIO 3: Hard Sync ---
.segment Ex3
.namespace Ex3 {
    hard_sync_guitar:
        lda #$02            // Sync bit
        sta $D404           // Voice 1 control
        rts
}

// --- ESERCIZIO 4: Priority Audio Mixer ---
.segment Ex4
.namespace Ex4 {
    play_sfx:
        // Priorita: SFX ha la precedenza su Voce 3
        lda #1
        sta sfx_active
        rts

    sfx_active: .byte 0
}

// --- ESERCIZIO 5: Noise + Filter Explosion ---
.segment Ex5
.namespace Ex5 {
    explosion_sfx:
        lda #$81            // Noise + Gate ON
        sta $D40E+4
        lda #$F4            // Filter Voice 3
        sta SID_RES_FILT
        rts
}
