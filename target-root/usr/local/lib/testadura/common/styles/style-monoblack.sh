#!/usr/bin/env bash
# Monoblack style

# --- say() global defaults ----------------------------------------------------
    SAY_DATE_DEFAULT=0     # 0 = no date, 1 = add date
    SAY_SHOW_DEFAULT="symbol"   # label|icon|symbol|all|label,icon|...
    SAY_COLORIZE_DEFAULT="both"  # none|label|msg|both|all
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
      SYM_CNCL="(-)"
      SYM_EMPTY=""
      SYM_END="<<<"
      SYM_FAIL="(X)"
      SYM_INFO="(+)"
      SYM_OK="(✓)"
      SYM_STRT=">>>"
      SYM_WARN="(!)"

# -- Colors --------------------------------------------------------------------
  # By message type
    CLR_INFO=$SILVER
    CLR_STRT=$BOLD_SILVER
    CLR_OK=$BOLD_SILVER
    CLR_WARN=$SILVER
    CLR_FAIL=$BOLD_BLACK
    CLR_CNCL=$FAINT_BLACK
    CLR_END=$FAINT_SILVER
    CLR_EMPTY=$FAINT_SILVER
  # Text elements
    CLR_LABEL=$BOLD_SILVER
    CLR_MSG=$SILVER
    CLR_INPUT=$SILVER
    CLR_TEXT=$FAINT_SILVER
    CLR_INVALID=$BOLD_BLACK
    CLR_VALID=$SILVER
    CLR_DEFAULT=$FAINT_SILVER
