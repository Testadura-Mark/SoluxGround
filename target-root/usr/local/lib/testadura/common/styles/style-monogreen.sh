#!/usr/bin/env bash
# Mono Green (Retro terminal) style

# --- say() global defaults ----------------------------------------------------
    SAY_DATE_DEFAULT="1"        # 0 = no date, 1 = add date
    SAY_SHOW_DEFAULT="symbol"   # label|icon|symbol|all|label,icon|...
    SAY_COLORIZE_DEFAULT="both"  # none|label|msg|both|all
    SAY_DATE_FORMAT="%a %H:%M:%S" 

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
        CLR_INFO=$FAINT_GREEN
        CLR_STRT=$GREEN
        CLR_OK=$BOLD_GREEN
        CLR_WARN=$GREEN
        CLR_FAIL=$BOLD_GREEN
        CLR_CNCL=$FAINT_GREEN
        CLR_END=$FAINT_GREEN
        CLR_EMPTY=$FAINT_SILVER
    # Text elements
        CLR_LABEL=$GREEN
        CLR_MSG=$GREEN
        CLR_INPUT=$BOLD_GREEN
        CLR_TEXT=$FAINT_GREEN
        CLR_INVALID=$BOLD_GREEN
        CLR_VALID=$GREEN
        CLR_DEFAULT=$FAINT_SILVER
