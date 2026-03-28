typeset -g _ZSH_HISTORY_FUZZY_SEARCH_DIR="${${(%):-%N}:A:h}"

zsh-history-fuzzy-search() {
    local search_fuzzer
    if [ -n "$ZSH_HISTORY_FUZZY_SEARCH_FUZZER" ]; then
        search_fuzzer=$ZSH_HISTORY_FUZZY_SEARCH_FUZZER
    elif [ -x "$(command -v sk)" ]; then
        search_fuzzer="sk"
    elif [ -x "$(command -v fzf)" ]; then
        search_fuzzer="fzf"
    fi

    local search_fuzzer_args
    if [ "$search_fuzzer" = "fzf" ]; then
        search_fuzzer_args=${ZSH_HISTORY_FUZZY_SEARCH_FUZZER_ARGS:-" +s +m -e"}
    elif [ "$search_fuzzer" = "sk" ]; then
        search_fuzzer_args=${ZSH_HISTORY_FUZZY_SEARCH_FUZZER_ARGS:-" --no-sort --no-multi --ansi -e"}
    fi

    local search_remove_duplicates=${ZSH_HISTORY_FUZZY_SEARCH_REMOVE_DUPLICATES:-0}

    local show_dates=${ZSH_HISTORY_FUZZY_SEARCH_SHOW_DATES:-0}
    local show_event_numbers=${ZSH_HISTORY_FUZZY_SEARCH_SHOW_EVENT_NUMBERS:-0}

    local preview_window_args=${ZSH_HISTORY_FUZZY_SEARCH_PREVIEW_WINDOW_ARGS:-"down:30%"}
    local preview_pipe_cmd
    if [ "${ZSH_HISTORY_FUZZY_SEARCH_FSH_PREVIEW:-0}" -eq 1 ] && [ -d "$FAST_BASE_DIR" ]; then
        preview_pipe_cmd="FAST_BASE_DIR='$FAST_BASE_DIR' FAST_WORK_DIR='$FAST_WORK_DIR' zsh '${_ZSH_HISTORY_FUZZY_SEARCH_DIR}/fsh-preview.zsh'"
    else
        preview_pipe_cmd=${ZSH_HISTORY_FUZZY_SEARCH_PREVIEW_PIPE_CMD:-"cat"}
    fi

    command -v "$search_fuzzer" >/dev/null || return

    local space_n=2
    local space_nth=2
    local fc_args=("-l")

    if [ "$search_fuzzer" = "sk" ]; then
        ((space_nth++))
    fi

    if [ $show_dates -eq 1 ]; then
        ((space_n+=2))
        fc_args+=("-i")
    fi

    if [ $show_event_numbers -eq 1 ]; then
        ((space_nth--))
    fi

    fc_args+=("-r")
    fc_args+=("0")
    fc_args=$(printf " %s" "${fc_args[@]}")

    local history_cmd="fc${fc_args}"
    if [ $search_remove_duplicates -eq 1 ]; then
        history_cmd="fc${fc_args} | awk -v n=$space_n '{ s = substr(\$0, index(\$0, \$n)); if (!a[s]++) print }' "
    fi

    local preview_extra_cmd='_fetch() { setopt extendedglob && event_ln=$(echo $1) && event_num=$((${(M)event_ln## #<->})) && HISTFILE='"$HISTFILE"' && HISTSIZE=1000000000 && fc -R && print -rNC1 -- ${(v)history[$event_num]} }'
    local preview_semble="$preview_extra_cmd && "'( echo "$(_fetch {})" |'"$preview_pipe_cmd"' )'

    candidates=("$(eval $history_cmd | ${search_fuzzer}${=search_fuzzer_args} --with-nth $space_nth.. --preview-window=$preview_window_args --preview $preview_semble -q "$BUFFER" )")
    if [ -n "$candidates" ]; then
        setopt localoptions extendedglob
        local prefix="${(M)BUFFER##[[:space:]]#}"
        local event_num=${${candidates[@]##[[:space:]]#}%%[^0-9]*}
        BUFFER="${prefix}${history[$event_num]}"
    fi
    zle redisplay
    zle reset-prompt
}

autoload zsh-history-fuzzy-search
zle -N zsh-history-fuzzy-search

local zsh_history_fuzzy_search_bind="${ZSH_HISTORY_FUZZY_SEARCH_BIND:-"^r"}"
local zsh_history_fuzzy_search_no_bind=${ZSH_HISTORY_FUZZY_SEARCH_NO_BIND:-0}
if [ $zsh_history_fuzzy_search_no_bind -eq 0 ]; then
    bindkey "$zsh_history_fuzzy_search_bind" zsh-history-fuzzy-search
fi
