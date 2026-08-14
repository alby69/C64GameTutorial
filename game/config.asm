#importonce
// =============================================
// CONFIG — Costanti e zero page
// =============================================

// ---- Zero page ----
.const FRAME_CNT = $02
.const JOY_STATE = $03
.const JOY_EDGE = $04
.const JOY_OLD = $05
.const GAME_STATE = $06
.const SCORE_LO = $07
.const SCORE_HI = $08
.const PLAYER_LIVES = $09
.const WAVE_NUM = $0A
.const TEMP = $0B
.const TEMP2 = $0C
.const RAND_SEED = $0D
.const PTR_LO = $0E
.const PTR_HI = $0F

// ---- Entity arrays ($1800) ----
.const MAX_ENTITIES = 8

.const ENTITY_X = $1800
.const ENTITY_Y = $1810
.const ENTITY_TYPE = $1820
.const ENTITY_ACTIVE = $1830
.const ENTITY_HP = $1840
.const ENTITY_TIMER = $1850
.const ENTITY_FLAGS = $1860

.const T_PLAYER = 0
.const T_BULLET = 1
.const T_ENEMY = 2
.const T_BOSS = 3
.const T_EXPLOSION = 4

// ---- Bullet pool ($1870) ----
.const PB_ACTIVE = $1870
.const PB_X = $1871
.const PB_Y = $1872
.const EB_ACTIVE = $1873
.const EB_X = $1877
.const EB_Y = $187B
.const EB_COUNT = $1880
.const MAX_EB = 4

// ---- Wave config ----
.const ENEMIES_PER_WAVE = $1881
.const ENEMIES_LEFT = $1882
.const WAVE_DELAY = $1883
.const BOSS_ACTIVE = $1884

// ---- Zero-page moduli ----
.const SCHED_PHASE = $10
.const SHOT_COOLDOWN = $11
.const TITLE_BLINK = $12
.const TITLE_VISIBLE = $21
.const ENEMY_TIMER_LO = $13
.const ENEMY_TIMER_HI = $14
.const ENEMY_DIR = $15
.const BOSS_DIR = $16
.const BOSS_CURRENT_HP = $17
.const ENEMY_SHOOT_INTERVAL = $18
.const WAVE_ENEMY_TYPE = $19
.const PLAYER_RESPAWN_X = $1A
.const SFX_PTR = $1B
.const SFX_TIMER = $1C
.const SCROLL_FINE_X = $1D
.const SCROLL_COARSE_X = $1E
.const SCROLL_TICK = $1F
.const HS_TEMP = $20

// ---- Hardware ----
.const VIC_SPRITE_X = $D000
.const VIC_SPRITE_Y = $D001
.const VIC_SPRITE_MSB = $D010
.const VIC_SPRITE_EN = $D015
.const VIC_SPRITE_EXP = $D017
.const VIC_SPRITE_DBL = $D01D
.const VIC_SPRITE_COL = $D027
.const VIC_SPRITE_PTR = $07F8
.const VIC_COL_BK = $D021
.const VIC_COL_BORDER = $D020
.const VIC_CTRL1 = $D011
.const VIC_CTRL2 = $D016
.const VIC_IRQ_EN = $D01A
.const VIC_IRQ_STAT = $D019
.const VIC_RAST = $D012
.const CIA1_PRA = $DC01
.const CIA2_PRA = $DD00
.const SID_VOL = $D418
.const SID_V1_FREQ_LO = $D400
.const SID_V1_FREQ_HI = $D401
.const SID_V1_PW_LO = $D402
.const SID_V1_CTRL = $D404
.const SID_V1_AD = $D405
.const SID_V1_SR = $D406
.const SID_V2_FREQ_LO = $D407
.const SID_V2_FREQ_HI = $D408
.const SID_V2_CTRL = $D40B
.const SID_V2_AD = $D40C
.const SID_V2_SR = $D40D
.const SID_V3_FREQ_LO = $D40E
.const SID_V3_FREQ_HI = $D40F
.const SID_V3_CTRL = $D412

// ---- Screen addresses ----
.const SCREEN_RAM = $0400
.const COLOR_RAM = $D800

// ---- Game constants ----
.const PLAYER_MIN_X = 24
.const PLAYER_MAX_X = 296
.const PLAYER_Y_POS = 220
.const BULLET_SPEED = 3
.const ENEMY_SPEED = 1
.const MAX_LIVES = 3
.const INVINCIBLE_TICKS = 120
.const BOSS_HP = 20
.const BOSS_SHOOT_INTERVAL = 30
