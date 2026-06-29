; =============================================
; CONFIG — Costanti e zero page
; =============================================

; ---- Zero page ----
FRAME_CNT   = $02
JOY_STATE   = $03
JOY_EDGE    = $04
JOY_OLD     = $05
GAME_STATE  = $06
SCORE_LO    = $07
SCORE_HI    = $08
PLAYER_LIVES = $09
WAVE_NUM    = $0A
TEMP        = $0B
TEMP2       = $0C
RAND_SEED   = $0D
PTR_LO      = $0E
PTR_HI      = $0F

; ---- Entity arrays ($1800) ----
MAX_ENTITIES = 8

ENTITY_X       = $1800
ENTITY_Y       = $1810
ENTITY_TYPE    = $1820
ENTITY_ACTIVE  = $1830
ENTITY_HP      = $1840
ENTITY_TIMER   = $1850
ENTITY_FLAGS   = $1860

T_PLAYER  = 0
T_BULLET  = 1
T_ENEMY   = 2
T_BOSS    = 3
T_EXPLOSION = 4

; ---- Bullet pool ($1870) ----
PB_ACTIVE = $1870
PB_X      = $1871
PB_Y      = $1872
EB_ACTIVE = $1873
EB_X      = $1877
EB_Y      = $187B
EB_COUNT  = $1880
MAX_EB    = 4

; ---- Wave config ----
ENEMIES_PER_WAVE = $1881
ENEMIES_LEFT     = $1882
WAVE_DELAY       = $1883
BOSS_ACTIVE      = $1884

; ---- Zero-page moduli ----
SCHED_PHASE      = $10
SHOT_COOLDOWN    = $11
TITLE_BLINK      = $12
ENEMY_TIMER_LO   = $13
ENEMY_TIMER_HI   = $14
ENEMY_DIR        = $15
BOSS_DIR         = $16
BOSS_CURRENT_HP  = $17
ENEMY_SHOOT_INTERVAL = $18
WAVE_ENEMY_TYPE  = $19
PLAYER_RESPAWN_X = $1A
SFX_PTR          = $1B
SFX_TIMER        = $1C

; ---- Hardware ----
VIC_SPRITE_X   = $D000
VIC_SPRITE_Y   = $D001
VIC_SPRITE_MSB = $D010
VIC_SPRITE_EN  = $D015
VIC_SPRITE_EXP = $D017
VIC_SPRITE_DBL = $D01D
VIC_SPRITE_COL = $D027
VIC_SPRITE_PTR = $07F8
VIC_COL_BK     = $D021
VIC_COL_BORDER = $D020
VIC_CTRL1      = $D011
VIC_CTRL2      = $D016
VIC_IRQ_EN     = $D01A
VIC_IRQ_STAT   = $D019
VIC_RAST       = $D012
CIA1_PRA       = $DC01
CIA2_PRA       = $DD00
SID_VOL        = $D418
SID_V1_FREQ_LO = $D400
SID_V1_FREQ_HI = $D401
SID_V1_PW_LO   = $D402
SID_V1_CTRL    = $D404
SID_V1_AD      = $D405
SID_V1_SR      = $D406
SID_V2_FREQ_LO = $D407
SID_V2_FREQ_HI = $D408
SID_V2_CTRL    = $D40B
SID_V2_AD      = $D40C
SID_V2_SR      = $D40D
SID_V3_FREQ_LO = $D40E
SID_V3_FREQ_HI = $D40F
SID_V3_CTRL    = $D412

; ---- Screen addresses ----
SCREEN_RAM  = $0400
COLOR_RAM   = $D800

; ---- Game constants ----
PLAYER_MIN_X  = 24
PLAYER_MAX_X  = 296
PLAYER_Y_POS  = 220
BULLET_SPEED  = 3
ENEMY_SPEED   = 1
MAX_LIVES     = 3
INVINCIBLE_TICKS = 120
BOSS_HP       = 20
BOSS_SHOOT_INTERVAL = 30
