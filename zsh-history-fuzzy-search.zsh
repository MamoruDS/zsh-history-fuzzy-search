zsh_history_fuzzy_search() {
    local search_bind=${ZSH_HISTORY_FUZZY_SEARCH_BIND:-"^r"}
    local search_fuzzer=${ZSH_HISTORY_FUZZY_SEARCH_FUZZER:-"fzf"}
    local search_fuzzer_args
    if [ "$search_fuzzer" = "fzf" ]; then
        search_fuzzer_args=${ZSH_HISTORY_FUZZY_SEARCH_FUZZER_ARGS:-" +s +m -e"}
    elif [ "$search_fuzzer" = "sk" ]; then
        search_fuzzer_args=${ZSH_HISTORY_FUZZY_SEARCH_FUZZER_ARGS:-" --no-sort --no-multi --ansi -e"}
    fi
    local search_remove_duplicates=${ZSH_HISTORY_FUZZY_SEARCH_REMOVE_DUPLICATES:-0}

    local show_dates=${ZSH_HISTORY_FUZZY_SEARCH_SHOW_DATES:-0}
    local show_event_numbers=${ZSH_HISTORY_FUZZY_SEARCH_SHOW_EVENT_NUMBERS:-0}

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

    fc_args+=("-1")
    fc_args+=("0")
    fc_args=$(printf " %s" "${fc_args[@]}")

    local history_cmd="fc${fc_args}"
    if [ $search_remove_duplicates -eq 1 ]; then
        history_cmd="fc${fc_args} | awk -v n=$space_n '{ s = substr(\$0, index(\$0, \$n)); if (!a[s]++) print }' "
    fi

    candidates=("$(eval $history_cmd | ${search_fuzzer}${=search_fuzzer_args} --with-nth $space_nth.. -q "$BUFFER" )")
    if [ -n "$candidates" ]; then
        BUFFER="${candidates[@]}"
        zle vi-fetch-history -n $BUFFER
    fi
}

autoload zsh_history_fuzzy_search
zle -N zsh_history_fuzzy_search
bindkey "$search_bind" zsh_history_fuzzy_search
