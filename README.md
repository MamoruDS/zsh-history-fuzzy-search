# zsh history fuzzy search

[![Github License](https://img.shields.io/github/license/MamoruDS/zsh-history-fuzzy-search?style=flat-square)](https://github.com/MamoruDS/zsh-history-fuzzy-search/blob/main/LICENSE)

A zsh plugin that provides fuzzy search for zsh history, inspired by [zsh-fzf-history-search](https://github.com/joshskidmore/zsh-fzf-history-search). Differences from zsh-fzf-history-search, history is loaded into the buffer untouched, eliminating parsing issues. Preview window is also supported for better multi-line command preview.

## Install

Either [fzf](https://github.com/junegunn/fzf) or [skim](https://github.com/lotabout/skim) is required.

### Manual

```zsh
git clone https://github.com/MamoruDS/dotfiles.git ~/somewhere
```

Then add the following line to your `.zshrc`:

```zsh
source ~/somewhere/zsh-history-fuzzy-search.zsh
```

### zinit

```zsh
zinit light MamoruDS/zsh-history-fuzzy-search
```

## Config

-   `ZSH_HISTORY_FUZZY_SEARCH_BIND`

    Default: `^r`
    Keybinding to start plugin.

-   `ZSH_HISTORY_FUZZY_SEARCH_SHOW_DATES`

    Default: `0`

    Show time-date stamps in ISO 8601 format in the searching list.

-   `ZSH_HISTORY_FUZZY_SEARCH_SHOW_EVENT_NUMBERS`

    Default: `0`

    Show event numbers in the searching list.

-   `ZSH_HISTORY_FUZZY_SEARCH_FUZZER`

    Default: `fzf`
    Valid fuzzy finders are `fzf` and `sk`.

-   `ZSH_HISTORY_FUZZY_SEARCH_FUZZER_ARGS`

    Default (for fzf): ` +s +m -e`
    Default (for skim): ` --no-sort --no-multi --ansi -e`

-   `ZSH_HISTORY_FUZZY_SEARCH_REMOVE_DUPLICATES`

    Default: `0`

    Remove duplicate commands from the searching list.

-   `ZSH_HISTORY_FUZZY_SEARCH_PREVIEW_PIPE_CMD`

    Default: `cat`

-   `ZSH_HISTORY_FUZZY_SEARCH_PREVIEW_WINDOW_ARGS`

    Default: `down:30%`
