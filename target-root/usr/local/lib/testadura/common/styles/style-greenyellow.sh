#!/usr/bin/env bash
# Green-Yellow (labels green, values yellow)

# --- say() global defaults ----------------------------------------------------
    SAY_DATE_DEFAULT=0       # 0 = no date, 1 = add date
    SAY_SHOW_DEFAULT="label, symbol"   # label|icon|symbol|all|label,icon|...
    SAY_COLORIZE_DEFAULT=label  # none|label|msg|both|all
    SAY_DATE_FORMAT="%Y-%m-%d %H:%M:%S" 
    
# -- Say prefixes --------------------------------------------------------------
    # Labels
      #LBL_CNCL="[CNCL]"
      #LBL_EMPTY="     "
      #LBL_END="[ END]"
      #LBL_FAIL="[FAIL]"
      #LBL_INFO="[INFO]"
      #LBL_OK="[ OK ]"
      #LBL_STRT="[STRT]"
      #LBL_WARN="[WARN]"

    # Icons
      #ICO_CNCL=$'⏹️'
      #ICO_EMPTY=$''
      #ICO_END=$'🏁'
      #ICO_FAIL=$'❌'
      #ICO_INFO=$'ℹ️'
      #ICO_OK=$'✅'
      #ICO_STRT=$'▶️'
      #ICO_WARN=$'⚠️'

    # Symbols
        SYM_INFO="i"
        SYM_STRT=">"
        SYM_OK="+"
        SYM_WARN="!"
        SYM_FAIL="x"
        SYM_CNCL="/"
        SYM_EMPTY=" "

# -- Colors --------------------------------------------------------------------
    # By message type
        CLR_INFO=$GREEN
        CLR_STRT=$BOLD_GREEN
        CLR_OK=$BOLD_GREEN
        CLR_WARN=$BOLD_YELLOW
        CLR_FAIL=$BOLD_RED
        CLR_CNCL=$FAINT_RED
        CLR_END=$FAINT_SILVER
        CLR_EMPTY=$FAINT_SILVER
    # Text elements
        CLR_LABEL=$GREEN
        CLR_MSG=$ITALIC_GREEN
        CLR_INPUT=$YELLOW
        CLR_TEXT=$YELLOW
        CLR_INVALID=$ORANGE
        CLR_VALID=$GREEN
        CLR_DEFAULT=$FAINT_SILVER
