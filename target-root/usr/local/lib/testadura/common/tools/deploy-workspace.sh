#!/usr/bin/env bash
# ===============================================================================
# Testadura Consultancy — deploy-workspace.sh
# -------------------------------------------------------------------------------
# Purpose : Generic script template
# Author  : Mark Fieten
# 
# © 2025 Mark Fieten — Testadura Consultancy
# Licensed under the Testadura Non-Commercial License (TD-NC) v1.0.
# -------------------------------------------------------------------------------
# Description :
#   Includes boilerplate  for a generic Testadura script.
#   Sources bootstrap.sh at the end of this file.
#   Copy this template to create a new script.
#   Replace <NAME> with the actual script name.
#   Sets global variables:
#     SCRIPT_FILE   - absolute path to this script file
#     SCRIPT_NAME   - script name without path and .sh extension
#     SCRIPT_DESC   - short description of the script
#     SCRIPT_DIR    - directory where this script lives
#     TD_ROOT       - Testadura root ("" for production, or path to target-root)
#     COMMON_LIB    - path to common library    
#     RUN_MODE      - "development" or "production"
# ==============================================================================
set -euo pipefail

# --- Script metadata ----------------------------------------------------------
    SCRIPT_FILE="${BASH_SOURCE[0]}"
    SCRIPT_NAME=""
    SCRIPT_DESC="Short description of what this script does."
    SCRIPT_VERSION="1.0"
    SCRIPT_VERSION_STATUS="alpha"
    SCRIPT_BUILD="20250110"

    # Determine the directory where this script lives
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    # Derive default SCRIPT_NAME from SCRIPT_FILE if not explicitly set
    if [[ -z "${SCRIPT_NAME:-}" ]]; then
        base="$(basename "$SCRIPT_FILE")"
        SCRIPT_NAME="${base%.sh}"
    fi

    # Determine the testadura root:
        # If "target-root" is part of the script path, use that as TD_ROOT
        # Otherwise fall back to the real root "/"
        TD_ROOT="$SCRIPT_DIR"
        RUN_MODE="production"
        while [[ "$TD_ROOT" != "/" ]]; do
        if [[ "$(basename "$TD_ROOT")" == "target-root" ]]; then
            RUN_MODE="development"
            break
        fi
            TD_ROOT="$(dirname "$TD_ROOT")"
        done

        # If we reached "/" without finding target-root, assume production
        if [[ "$TD_ROOT" == "/" ]]; then
            TD_ROOT=""
        fi

    # Find framework libraries
    DEV_COMMON_LIB="${TD_ROOT}/usr/local/lib/testadura/common"
    SYS_COMMON_LIB="/usr/local/lib/testadura/common"

    if [[ -d "$DEV_COMMON_LIB" ]]; then
        COMMON_LIB="$DEV_COMMON_LIB"
    elif [[ -d "$SYS_COMMON_LIB" ]]; then
        COMMON_LIB="$SYS_COMMON_LIB"
    else
        say FAIL "SoluxGround framework not found in either %s or %s" "$DEV_COMMON_LIB" "$SYS_COMMON_LIB"
    fi

# --- Argument specification ---------------------------------------------------
    # --------------------------------------------------------------------------
    # Each entry:
    #   "name|type|var|help|choices"
    #
    #   name    = long option name WITHOUT leading --
    #   short   - short option name WITHOUT leading -
    #   type    = flag | value | enum
    #   var     = shell variable that will be set
    #   help    = help string for auto-generated --help output
    #   choices = for enum: comma-separated values (e.g. fast,slow,auto)
    #             for flag/value: leave empty
    #
    # Notes:
    #   - -h / --help is built in, you don't need to define it here.
    #   - After parsing you can use: FLAG_VERBOSE, VAL_CONFIG, ENUM_MODE, ...
    # ------------------------------------------------------------------------
    ARGS_SPEC=(
        "undeploy|u|flag|FLAG_UNDEPLOY|Remove files from main root|"
        "source|s|value|SRC_ROOT|Set Source directory|"
        "target|t|value|DEST_ROOT|Set Target directory|"
        "dryrun|d|flag|FLAG_DRYRUN|Just list the files don't do any work|"
        "version|v|action|show_version|Show version information"
    )

    SCRIPT_EXAMPLES=(
    "Deploy using defaults:"
    "  $SCRIPT_NAME"
    ""
    "Undeploy everything:"
    "  $SCRIPT_NAME --undeploy"
    "  $SCRIPT_NAME -u"
    )

# --- Optional: custom config loading ----------------------------------------
    # ------------------------------------------------------------------------
    # If you define this function, bootstrap will call it before parsing args.
    # If you DON'T define it, bootstrap will automatically try:
    #   $SCRIPT_DIR/${SCRIPT_NAME}.conf
    #
    # Example:
    #
    # load_config() {
    #   local cfg="$SCRIPT_DIR/${SCRIPT_NAME}.conf"
    #   [[ -f "$cfg" ]] && . "$cfg"
    # }
    # -----------------------------------------------------------------------


# --- local script functions -------------------------------------------------

    __deploy()
    {
        say STRT "Starting deployment from $SRC_ROOT to $DEST_ROOT" --show=symbol

        find "$SRC_ROOT" -type f |
        while IFS= read -r file; do

        rel="${file#$SRC_ROOT/}"
        name="$(basename "$file")"
        perms=$(stat -c "%a" "$file")
        dst="$DEST_ROOT$rel"

        say "$rel  $name $perms $dst"
        # Skip top-level files, hidden dirs, private dirs
        if [[ "$rel" != */* || "$name" == _* || "$name" == *.old || \
                "$rel" == .*/* || "$rel" == _*/* || \
                "$rel" == */.*/* || "$rel" == */_*/* ]]; then
            continue
        fi

        if [[ ! -e "$dst" || "$file" -nt "$dst" ]]; then
            say "Deploying $SRC_ROOT/$rel to $dst with permissions $perms"
            if [[ $FLAG_DRYRUN == 0 ]]; then
                install -D -m "$perms" "$SRC_ROOT/$rel" "$dst"
            else
                sayinfo "Would have installed $SRC_ROOT/$rel --> $dst, with $perms permissions"
            fi
        else
            say "Skipping $rel; destination is up-to-date."
        fi

        done
        say END "End deployment complete." 
    }

    __undeploy()
    {

        say STRT "Starting UNINSTALL from $SRC_ROOT to $DEST_ROOT" --show=symbol

        find "$SRC_ROOT" -type f |
        while IFS= read -r file; do

        rel="${file#$SRC_ROOT/}"
        name="$(basename "$file")"
        dst="$DEST_ROOT$rel"

        if [[ "$rel" != */* || "$name" == _* || "$name" == *.old || \
                "$rel" == .*/* || "$rel" == _*/* || \
                "$rel" == */.*/* || "$rel" == */_*/* ]]; then
            continue
        fi

        if [[ -e "$dst" ]]; then
            say WARN "Removing $dst"
            if [[ $FLAG_DRYRUN == 0 ]]; then
                rm -f "$dst"
            else
                sayinfo "Would have removed $dst"
            fi
        else
            say "Skipping $rel; does not exist."
        fi

        done
    }

    __link_executables()
    {
        local root_dir="$DEST_ROOT/usr/local/lib/testadura"
        local bin_dir="$DEST_ROOT/usr/local/bin"

        [[ -d "$root_dir" ]] || return 0

        saystart "Creating symlinks in $bin_dir for executables under $root_dir" --show=symbol

        # Ensure bin directory exists
        if [[ $FLAG_DRYRUN == 0 ]]; then
            install -d "$bin_dir"
        else
            sayinfo "Would ensure directory exists: $bin_dir"
        fi

        # Recursively find executable files, but EXCLUDE templates/
        find "$root_dir" \
            -path "$root_dir/templates" -prune -o \
            -type f -perm -111 -print |
        while IFS= read -r f; do

            # f example:
            #   /usr/local/lib/testadura/common/tools/create-workspace.sh

            local rel_target base_src base_noext base link_path

            # Produce a relative path for the symlink target
            rel_target="$(realpath --relative-to="$bin_dir" "$f")"

            base_src="$(basename "$f")"        # e.g., create-workspace.sh
            base_noext="${base_src%.sh}"       # e.g., create-workspace
            base="td-$base_noext"              # e.g., td-create-workspace

            link_path="$bin_dir/$base"

            # Optional: skip private/internal files
            case "$base" in
                td-_*) continue ;;
                td.*)  continue ;;
            esac

            if [[ $FLAG_DRYRUN == 0 ]]; then
                sayinfo "Linking $link_path -> $rel_target"
                ln -sfn "$rel_target" "$link_path"
            else
                sayinfo "Would link $link_path -> $rel_target"
            fi

        done

        sayend "Symlink creation complete."
    }

   __unlink_executables()
    {
        local bin_dir="$DEST_ROOT/usr/local/bin"
        local root_dir="$DEST_ROOT/usr/local/lib/testadura"

        [[ -d "$bin_dir" ]] || return 0

        saystart "Removing symlinks in $bin_dir pointing into Testadura" --show=symbol

        local link target resolved

        for link in "$bin_dir"/td-*; do
            [[ -L "$link" ]] || continue

            target="$(readlink "$link")"

            # Resolve to absolute path
            if [[ "$target" == /* ]]; then
                resolved="$target"
            else
                resolved="$(realpath "$bin_dir/$target")"
            fi

            # Does this link belong to Testadura?
            case "$resolved" in
                "$root_dir"/*)
                    saywarning "Removing symlink $link -> $resolved"
                    if [[ $FLAG_DRYRUN == 0 ]]; then
                        rm -f "$link"
                    else
                        sayinfo "Would remove $link"
                    fi
                    ;;
                *)
                    continue
                    ;;
            esac
        done

        sayend "Symlink cleanup complete."
    }

# --- main() must be the last function in the script -------------------------
    showarguments() 
    {
        printf "Script          : %s\n" "$SCRIPT_NAME"
        printf "Script dir      : %s\n" "$SCRIPT_DIR"

        printf -- "Arguments / Flags:\n"

        local entry varname
        for entry in "${ARGS_SPEC[@]}"; do
            # Split the spec into fields
            IFS='|' read -r name short type varname help choices <<< "$entry"

            # Skip empty or malformed entries
            [[ -z "$varname" ]] && continue

            # Use indirect expansion to get the variable value
            local value="${!varname:-<unset>}"

            printf "  %-15s = %s\n" "$varname" "$value"
        done

        # Optional: print other environment metadata
        printf "Run mode        : %s\n" "$RUN_MODE"
        printf "COMMON_LIB      : %s\n" "$COMMON_LIB"
        printf "TD_ROOT         : %s\n" "$TD_ROOT"
    }

    main() {
        need_root
        SRC_ROOT="${SRC_ROOT:-$TD_ROOT}"
        DEST_ROOT="${DEST_ROOT:-"/"}"
        FLAG_DRYRUN="${FLAG_DRYRUN:-0}"

        showarguments

        if [[ "${FLAG_UNDEPLOY:-0}" -eq 0 ]]; then
            __deploy
            __link_executables
        else
            __undeploy
            __unlink_executables
        fi
    }

# --- Hand off to the bootstrapper (framework) ----------------------------
    AUTOLOAD_FRAMEWORK=true
    # shellcheck source=/dev/null
    . "${COMMON_LIB}/bootstrap.sh"
