#!/usr/bin/env bash
# Carnaval style

# --- say() global defaults ----------------------------------------------------
    SAY_DATE_DEFAULT=1    # 0 = no date, 1 = add date
    SAY_SHOW_DEFAULT="all"   # label|icon|symbol|all|label,icon|...
    SAY_COLORIZE_DEFAULT="all"  # none|label|msg|both|all
    SAY_DATE_FORMAT="%Y-%j %H:%M:%S" 
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
        SYM_CNCL="⏹"
        SYM_EMPTY=" "
        SYM_END="🏁"
        SYM_FAIL="✖"
        SYM_INFO="🛈"
        SYM_OK="✓"
        SYM_STRT="⮞"
        SYM_WARN="⚠"




# -- Colors --------------------------------------------------------------------
    # By message type
        CLR_INFO=$BOLD_CYAN
        CLR_STRT=$BOLD_BLUE
        CLR_OK=$BOLD_GREEN
        CLR_WARN=$BOLD_YELLOW
        CLR_FAIL=$BOLD_RED
        CLR_CNCL=$BOLD_MAGENTA
        CLR_END=$BOLD_ORANGE
        CLR_EMPTY=$FAINT_SILVER
    # Text elements
        CLR_LABEL=$BOLD_MAGENTA
        CLR_MSG=$BOLD_BLUE
        CLR_INPUT=$BOLD_ORANGE
        CLR_TEXT=$BOLD_CYAN
        CLR_INVALID=$BOLD_RED
        CLR_VALID=$BOLD_GREEN
        CLR_DEFAULT=$FAINT_SILVER
