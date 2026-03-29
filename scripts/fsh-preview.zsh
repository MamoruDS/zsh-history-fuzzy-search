#!/usr/bin/env zsh

emulate -LR zsh
setopt extendedglob

{ [ -z "$FAST_BASE_DIR" ] || [ ! -d "$FAST_BASE_DIR" ]; } && { cat < /dev/null; return; }

{
    source "$FAST_BASE_DIR/fast-highlight"
    source "$FAST_BASE_DIR/fast-string-highlight"
    [ -f "$FAST_WORK_DIR/current_theme.zsh" ] && source "$FAST_WORK_DIR/current_theme.zsh"
    FAST_WORK_DIR="${FAST_WORK_DIR:-$FAST_BASE_DIR}"

    typeset -gA FAST_HIGHLIGHT __fast_highlight_main__command_type_cache FAST_BLIST_PATTERNS

    local BUFFER
    IFS= read -r BUFFER

    local -a reply
    local REPLY
    local right_brace_is_recognised_everywhere
    integer path_dirs_was_set multi_func_def ointeractive_comments
    -fast-highlight-fill-option-variables
    -fast-highlight-init
    -fast-highlight-process "" "$BUFFER" 0

    local result="" reset=$'\e[0m' ansi style p r
    local -a sorted=(${(on)reply})
    integer pos=0 s e
    for entry in "${sorted[@]}"; do
        s=${entry%% *}
        r=${entry#* }
        e=${r%% *}
        style=${r#* }
        (( s > pos )) && result+="${BUFFER:$pos:$((s-pos))}"
        ansi=""
        for p in ${(s:,:)style}; do
            case $p in
                fg=*) ansi+="$(print -Pn "%F{${p#fg=}}")" ;;
                bg=*) ansi+="$(print -Pn "%K{${p#bg=}}")" ;;
                bold) ansi+=$'\e[1m' ;;
                underline) ansi+=$'\e[4m' ;;
                standout) ansi+=$'\e[7m' ;;
                none) ansi+="$reset" ;;
            esac
        done
        result+="${ansi}${BUFFER:$s:$((e-s))}${reset}"
        (( pos = e > pos ? e : pos ))
    done
    (( pos < ${#BUFFER} )) && result+="${BUFFER:$pos}"
} > /dev/null

print -r -- "${result}${reset}"
