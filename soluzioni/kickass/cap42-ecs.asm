// Converted to Kick Assembler syntax
.segmentdef Ex1 [start=$c000]
.segmentdef Ex2 [start=$c000]
.segmentdef Ex3 [start=$c000]
.segmentdef Ex4 [start=$c000]
.segmentdef Ex5 [start=$c000]

// --- Shared Constants ---
.const MAX_ENTITIES = 32
.const SYS_MOVE = %00000001
.const SYS_RENDER = %00000010
.const SYS_COLLISION = %00000100

// =============================================
// SOLUZIONI Capitolo 42 — Entity Component System
// --- METADATA ---
// chapter: 42
// title: Entity Component System (ECS)
// difficulty: master
// --- END METADATA ---
// =============================================

// --- ESERCIZIO 1: Definizione SoA per 32 Entità ---
.segment Ex1
.namespace Ex1 {
    pos_x: .fill MAX_ENTITIES, 0
    pos_y: .fill MAX_ENTITIES, 0
    vel_x: .fill MAX_ENTITIES, 0
    vel_y: .fill MAX_ENTITIES, 0
    flags: .fill MAX_ENTITIES, 0
}

// --- ESERCIZIO 2: Movement System via Bitmask ---
.segment Ex2
.namespace Ex2 {
    movement_system:
        ldx #0
    loop:
        lda Ex1.flags,x
        and #SYS_MOVE
        beq next
        lda Ex1.pos_x,x
        clc
        adc Ex1.vel_x,x
        sta Ex1.pos_x,x
    next:
        inx
        cpx #MAX_ENTITIES
        bne loop
        rts
}

// --- ESERCIZIO 3: Render System ---
.segment Ex3
.namespace Ex3 {
    render_system:
        ldx #0
    loop:
        lda Ex1.flags,x
        and #SYS_RENDER
        beq next
        lda Ex1.pos_x,x
        sta $D000,x
        lda Ex1.pos_y,x
        sta $D001,x
    next:
        inx
        cpx #8              // max 8 HW sprites
        bne loop
        rts
}

// --- ESERCIZIO 4: Collision System ---
.segment Ex4
.namespace Ex4 {
    collision_system:
        ldx #0
    loop:
        lda Ex1.flags,x
        and #SYS_COLLISION
        beq next
        // Test Bounding Box
    next:
        inx
        cpx #MAX_ENTITIES
        bne loop
        rts
}

// --- ESERCIZIO 5: Entity Allocator / Deallocator ---
.segment Ex5
.namespace Ex5 {
    spawn_entity:
        ldx #0
    loop:
        lda Ex1.flags,x
        beq found
        inx
        cpx #MAX_ENTITIES
        bne loop
        rts                 // Nessuno slot libero
    found:
        lda #(SYS_MOVE | SYS_RENDER)
        sta Ex1.flags,x
        rts
}
