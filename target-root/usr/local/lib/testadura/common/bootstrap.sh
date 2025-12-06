#!/usr/bin/env bash
# ===============================================================================
# Testadura Consultancy — bootstrap.sh
# -------------------------------------------------------------------------------
# Purpose : Bootstrapper for Testadura scripts
# Author  : Mark Fieten
# 
# © 2025 Mark Fieten — Testadura Consultancy
# Licensed under the Testadura Non-Commercial License (TD-NC) v1.0.
# -------------------------------------------------------------------------------
# Description :
# Minimal bootstrap: config -> args -> main
#   To be sourced at the end of a Testadura script.
#   Sets up argument parsing based on ARGS_SPEC if defined.
#   Calls main() with remaining positional arguments.
# ===============================================================================

set -euo pipefail
# --- Script metadata ----------------------------------------------------------
    SCRIPT_FILE="${BASH_SOURCE[0]}"
    SCRIPT_NAME=""
    SCRIPT_DESC="Short description of what this script does."
    SCRIPT_VERSION="1.0"
    SCRIPT_VERSION_STATUS="alpha"
    SCRIPT_BUILD="20250110"
    
# --- Argument parsing functions -----------------------------------------------

    # Split "name|short|type|var|help|choices" into fields
    __td_arg_split() {
        local spec="$1"
        IFS='|' read -r __td_name __td_short __td_type __td_var __td_help __td_choices <<< "$spec"
    }

    # Find spec line for an option (long or short)
    #   wanted = "undeploy"  (long, without leading --)
    #          = "u"         (short, without leading -)
    # Returns the spec line or empty if not found
    __td_arg_find_spec() {
        local wanted="$1" spec
        for spec in "${ARGS_SPEC[@]:-}"; do
            __td_arg_split "$spec"
            if [[ "$__td_name" == "$wanted" || "$__td_short" == "$wanted" ]]; then
                printf '%s\n' "$spec"
                return 0
            fi
        done
        return 1
    }

    # --- Optional framework autoload ----------------------------------------------
    __td_load_framework_libs() {
        # Determine library directory:
        # 1) Use LIB_COMMON if the script defined it
        # 2) Otherwise default to the directory containing this bootstrap file
        local libdir="${COMMON_LIB:-}"
        if [[ -z "$libdir" ]]; then
            libdir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
        fi

        [[ -d "$libdir" ]] || return 0

        local f base self
        self="$(basename "${BASH_SOURCE[0]}")"

        for f in "$libdir"/*.sh; do
            [[ -f "$f" ]] || continue
            base="$(basename "$f")"

            case "$base" in
                _*|.*)          continue ;; # skip “private” / hidden libs
                "$self")        continue ;; # skip bootstrap itself
            esac
        
            # shellcheck disable=SC1090
            . "$f"
        done
    }


    __td_show_help() {
        local script_name="${SCRIPT_NAME:-$(basename "$SCRIPT_FILE")}"

        echo "Usage: $script_name [options]"
        echo
        echo "${SCRIPT_DESC:-No description available}"
        echo
        echo "Options:"
        echo "  -h, --help         Show this help and exit"

        # No ARGS_SPEC defined? Then we're done with options.
        if declare -p ARGS_SPEC >/dev/null 2>&1; then   
            local spec
            for spec in "${ARGS_SPEC[@]:-}"; do
                __td_arg_split "$spec"

                # Build "-u, --undeploy" or "    --something" if no short
                local opt
                if [[ -n "${__td_short:-}" ]]; then
                    opt="-$__td_short, --$__td_name"
                else
                    opt="    --$__td_name"
                fi

                local meta=""
                case "$__td_type" in
                    value) meta=" VALUE" ;;
                    enum)  meta=" {${__td_choices//,/|}}" ;;
                    flag)  meta="" ;;
                esac
                printf "  %-18s %s\n" "$opt$meta" "$__td_help"
            done
        fi

        # Optional examples block
        if declare -p SCRIPT_EXAMPLES >/dev/null 2>&1; then
            echo
            echo "Usage examples:"
            local ex
            for ex in "${SCRIPT_EXAMPLES[@]:-}"; do
                printf "  %s\n" "$ex"
            done
        fi

    }

# Parse arguments based on ARGS_SPEC -------------------------------------------
    # Expects ARGS_SPEC to be defined as an array of strings. Each string:
    #   "name|short|type|var|help|choices"
    #   name    = long option name WITHOUT leading --
    #   short   = single-character short option WITHOUT leading -
    #             (leave empty if no short form)
    #   type    = flag | value | enum
    #   var     = shell variable that will be set
    #   help    = help string for auto-generated help output
    #   choices = for enum: comma-separated values (e.g. fast,slow,auto)
    #             for flag/value: leave empty
    # ------------------------------------------------------------------------
__td_parse_args() {
    # Initialize option variables to defaults if ARGS_SPEC exists
    if declare -p ARGS_SPEC >/dev/null 2>&1; then
        local spec
        for spec in "${ARGS_SPEC[@]:-}"; do
            __td_arg_split "$spec"
            case "$__td_type" in
                flag)  printf -v "$__td_var" '0' ;;
                value) printf -v "$__td_var" ''  ;;
                enum)  printf -v "$__td_var" ''  ;;
            esac
        done
    fi

    HELP_REQUESTED=0
    # echo "Parsing CLI" >&2   # (leave commented – useful when debugging)

    # Parse CLI
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                HELP_REQUESTED=1
                shift
                ;;

            --*)
                # If there is no ARGS_SPEC, we don't know any long options
                if ! declare -p ARGS_SPEC >/dev/null 2>&1; then
                    echo "Unknown option: $1 (no ARGS_SPEC defined)" >&2
                    return 1
                fi

                local opt spec
                opt="${1#--}"
                spec="$(__td_arg_find_spec "$opt" || true)"
                if [[ -z "${spec:-}" ]]; then
                    echo "Unknown option: $1" >&2
                    return 1
                fi
                __td_arg_split "$spec"

                case "$__td_type" in
                    flag)
                        printf -v "$__td_var" '1'
                        shift
                        ;;
                    value)
                        if [[ $# -lt 2 ]]; then
                            echo "Missing value for --$opt" >&2
                            return 1
                        fi
                        printf -v "$__td_var" '%s' "$2"
                        shift 2
                        ;;
                    enum)
                        if [[ $# -lt 2 ]]; then
                            echo "Missing value for --$opt" >&2
                            return 1
                        fi
                        local value="$2" ok=0 choice
                        IFS=',' read -r -a __td_choices_arr <<< "$__td_choices"
                        for choice in "${__td_choices_arr[@]}"; do
                            if [[ "$choice" == "$value" ]]; then
                                ok=1
                                break
                            fi
                        done
                        if [[ "$ok" -eq 0 ]]; then
                            echo "Invalid value '$value' for --$opt (allowed: $__td_choices)" >&2
                            return 1
                        fi
                        printf -v "$__td_var" '%s' "$value"
                        shift 2
                        ;;
                esac
                ;;

            # --- Short options: -u, -x, etc. (no clustering) ----------------
            -?*)
                # Example: -u, -v, -X
                if ! declare -p ARGS_SPEC >/dev/null 2>&1; then
                    echo "Unknown option: $1 (no ARGS_SPEC defined)" >&2
                    return 1
                fi

                local sopt spec
                sopt="${1#-}"        # strip leading '-'

                spec="$(__td_arg_find_spec "$sopt" || true)"
                if [[ -z "${spec:-}" ]]; then
                    echo "Unknown option: $1" >&2
                    return 1
                fi
                __td_arg_split "$spec"

                case "$__td_type" in
                    flag)
                        printf -v "$__td_var" '1'
                        shift
                        ;;
                    value)
                        if [[ $# -lt 2 ]]; then
                            echo "Missing value for -$sopt" >&2
                            return 1
                        fi
                        printf -v "$__td_var" '%s' "$2"
                        shift 2
                        ;;
                    enum)
                        if [[ $# -lt 2 ]]; then
                            echo "Missing value for -$sopt" >&2
                            return 1
                        fi
                        local value="$2" ok=0 choice
                        IFS=',' read -r -a __td_choices_arr <<< "$__td_choices"
                        for choice in "${__td_choices_arr[@]}"; do
                            if [[ "$choice" == "$value" ]]; then
                                ok=1
                                break
                            fi
                        done
                        if [[ "$ok" -eq 0 ]]; then
                            echo "Invalid value '$value' for -$sopt (allowed: $__td_choices)" >&2
                            return 1
                        fi
                        printf -v "$__td_var" '%s' "$value"
                        shift 2
                        ;;
                esac
                ;;

            *)
                # Stop at first positional arg; we currently leave "$@" as-is for main()
                break
                ;;
        esac
    done
}

# --- Bootstrap main function --------------------------------------------------
__td_bootstrap_main() {
    # --1 Figure out script path and directory
        local last_index=$(( ${#BASH_SOURCE[@]} - 1 ))
        local src="${BASH_SOURCE[$last_index]}"

        SCRIPT_FILE="${SCRIPT_FILE:-$src}"
        SCRIPT_DIR="${SCRIPT_DIR:-$(cd "$(dirname "$SCRIPT_FILE")" && pwd)}"

    # --2 Optional framework autoload
        if [[ "${AUTOLOAD_FRAMEWORK:-true}" == true ]]; then
            __td_load_framework_libs
        fi

    # --3 Config loading
        # If the script defines load_config(), call that.
        # Otherwise auto-source SCRIPT_DIR/<SCRIPT_NAME>.conf if it exists.
        if declare -f load_config >/dev/null; then
            load_config
        else
            local script_name="${SCRIPT_NAME:-$(basename "$SCRIPT_FILE")}"
            local default_cfg="$SCRIPT_DIR/${script_name}.conf"
            if [[ -f "$default_cfg" ]]; then
                # shellcheck source=/dev/null
                . "$default_cfg"
            fi
        fi

    # --4 Parse arguments
    __td_parse_args "$@" || exit 1

    # --5 Help handling
    if [[ "${HELP_REQUESTED:-0}" -eq 1 ]]; then
        __td_show_help
        exit 0
    fi

    # --6 Call main()
    if ! declare -f main >/dev/null; then
        echo "Error: main() not defined in script" >&2
        exit 1
    fi

    main "$@"
}

# --- Run bootstrap when this file is sourced from a script --------------------
__td_bootstrap_main "$@"
