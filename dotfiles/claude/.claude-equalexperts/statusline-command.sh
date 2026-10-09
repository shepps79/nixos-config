#!/bin/bash
# Claude Code status line
# Colors, icons and git formatting are matched to the user's Powerlevel10k
# (classic dark, nerdfont-v3) theme in ~/.p10k.zsh

input=$(cat)

# ---- Colors (256-color ANSI, mirrored from ~/.p10k.zsh) ----
C_LINUX=$'\033[38;5;255m'        # penguin icon
C_DIR=$'\033[38;5;31m'          # POWERLEVEL9K_DIR_FOREGROUND
C_GIT_CLEAN=$'\033[38;5;76m'    # my_git_formatter(): clean/branch/ahead/behind/stash
C_GIT_MODIFIED=$'\033[38;5;178m' # my_git_formatter(): staged/unstaged
C_GIT_UNTRACKED=$'\033[38;5;39m' # my_git_formatter(): untracked
C_GIT_CONFLICT=$'\033[38;5;196m' # my_git_formatter(): conflicted
C_MODEL=$'\033[38;5;37m'        # tool/version style segments (virtualenv/pyenv, etc.)
C_META=$'\033[38;5;246m'        # git formatter: meta / separators
C_TOKENS=$'\033[38;5;244m'      # loading/meta grey
C_COST=$'\033[38;5;244m'        # loading/meta grey
C_PCT_LOW=$'\033[38;5;76m'
C_PCT_MED=$'\033[38;5;178m'
C_PCT_HIGH=$'\033[38;5;196m'
RESET=$'\033[0m'

# ---- Nerd Font icons ----
ICON_LINUX=$''  # nf-fa-linux (penguin)
ICON_FOLDER=$'' # nf-fa-folder
ICON_GIT=$''    # nf-pl-branch

SEP="${C_META} |${RESET} "

# legacy unused: _UNUSED_LEGACY_ICON_A=$''   # unused-marker
# legacy unused: ICON_GIT_TEST2=$''  # unused-marker

# ---- Directory ----
cwd=$(printf '%s' "$input" | jq -r '.workspace.current_dir // .cwd')
dir_display=${cwd/#$HOME/\~}

# ---- Git branch and status (only shown when inside a git repo) ----
git_segment=""
if git --no-optional-locks rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  branch=$(git --no-optional-locks symbolic-ref --short HEAD 2>/dev/null)
  if [ -z "$branch" ]; then
    branch=$(git --no-optional-locks describe --tags --exact-match 2>/dev/null)
  fi
  if [ -z "$branch" ]; then
    branch=$(git --no-optional-locks rev-parse --short HEAD 2>/dev/null)
  fi

  if [ -n "$branch" ]; then
    porcelain=$(git --no-optional-locks status --porcelain 2>/dev/null)
    staged=$(printf '%s\n' "$porcelain" | grep -c '^[MADRC]')
    unstaged=$(printf '%s\n' "$porcelain" | grep -c '^.[MD]')
    untracked=$(printf '%s\n' "$porcelain" | grep -c '^??')
    conflicted=$(printf '%s\n' "$porcelain" | grep -cE '^(UU|AA|DD|AU|UA|UD|DU)')

    ahead_behind=$(git --no-optional-locks rev-list --left-right --count '@{upstream}...HEAD' 2>/dev/null)
    behind=0
    ahead=0
    if [ -n "$ahead_behind" ]; then
      behind=$(printf '%s' "$ahead_behind" | awk '{print $1}')
      ahead=$(printf '%s' "$ahead_behind" | awk '{print $2}')
    fi
    stashes=$(git --no-optional-locks stash list 2>/dev/null | wc -l)

    # my_git_formatter() in ~/.p10k.zsh always renders the branch name (and the
    # icon, ahead/behind counters and stash count) in "clean" green. Only the
    # staged/unstaged/untracked/conflicted counters get their own colors.
    git_body="${C_GIT_CLEAN}${ICON_GIT} ${branch}"
    [ "$behind" -gt 0 ] 2>/dev/null && git_body="${git_body} ${C_GIT_CLEAN}⇣${behind}"
    [ "$ahead" -gt 0 ] 2>/dev/null && git_body="${git_body} ${C_GIT_CLEAN}⇡${ahead}"
    [ "$stashes" -gt 0 ] 2>/dev/null && git_body="${git_body} ${C_GIT_CLEAN}*${stashes}"
    [ "$conflicted" -gt 0 ] && git_body="${git_body} ${C_GIT_CONFLICT}~${conflicted}"
    [ "$staged" -gt 0 ] && git_body="${git_body} ${C_GIT_MODIFIED}+${staged}"
    [ "$unstaged" -gt 0 ] && git_body="${git_body} ${C_GIT_MODIFIED}!${unstaged}"
    [ "$untracked" -gt 0 ] && git_body="${git_body} ${C_GIT_UNTRACKED}?${untracked}"

    git_segment="${SEP}${git_body}${RESET}"
  fi
fi

# ---- Model ----
model=$(printf '%s' "$input" | jq -r '.model.display_name')

# ---- Context usage (percentage + bar + tokens) ----
total_tokens=$(printf '%s' "$input" | jq -r '.context_window.total_input_tokens // 0')
context_size=$(printf '%s' "$input" | jq -r '.context_window.context_window_size // empty')
used_pct=$(printf '%s' "$input" | jq -r '.context_window.used_percentage // empty')

# used_percentage is null until the first API response of a session (or when
# no messages have been sent yet). Fall back to computing it from the raw
# token counts so the percentage/bar/token segment is always shown, in git
# and non-git directories alike, instead of silently disappearing.
if [ -z "$used_pct" ]; then
  if [ -n "$context_size" ] && [ "$context_size" -gt 0 ] 2>/dev/null; then
    used_pct=$(awk -v t="$total_tokens" -v c="$context_size" 'BEGIN{printf "%.2f", (t/c)*100}')
  else
    used_pct=0
  fi
fi

pct_int=${used_pct%.*}
[ -z "$pct_int" ] && pct_int=0
if [ "$pct_int" -lt 50 ]; then
  pct_color="$C_PCT_LOW"
elif [ "$pct_int" -lt 80 ]; then
  pct_color="$C_PCT_MED"
else
  pct_color="$C_PCT_HIGH"
fi
pct_formatted=$(awk -v p="$used_pct" 'BEGIN{printf "%.0f", p}')

# Context usage bar: ▓ = used, ░ = remaining.
BAR_SIZE=6
filled=$(awk -v p="$used_pct" -v n="$BAR_SIZE" 'BEGIN{f=int((p/100*n)+0.999999); if(f<0)f=0; if(f>n)f=n; print f}')
empty=$((BAR_SIZE - filled))
bar=""
for ((i = 0; i < filled; i++)); do bar="${bar}▓"; done
for ((i = 0; i < empty; i++)); do bar="${bar}░"; done

# Thousand-separated numbers, e.g. 1234567 -> 1,234,567
add_commas() {
  printf '%s' "$1" | rev | sed 's/\([0-9]\{3\}\)/\1,/g' | rev | sed 's/^,//'
}

used_tokens_fmt=$(add_commas "$total_tokens")
if [ -n "$context_size" ] && [ "$context_size" -gt 0 ] 2>/dev/null; then
  context_size_fmt=$(add_commas "$context_size")
  tokens_display="${used_tokens_fmt}/${context_size_fmt} tok"
else
  tokens_display="${used_tokens_fmt} tok"
fi

# ---- Cost ----
cost=$(printf '%s' "$input" | jq -r '.cost.total_cost_usd // empty')
cost_segment=""
if [ -n "$cost" ]; then
  cost_formatted=$(awk -v c="$cost" 'BEGIN{printf "%.2f", c}')
  cost_segment="${SEP}${C_COST}\$${cost_formatted} cost${RESET}"
fi

# ---- Assemble (built as a single string to avoid printf arg/format drift) ----
line="${C_LINUX}${ICON_LINUX}${RESET}${SEP}EE${SEP}${C_DIR}${ICON_FOLDER} ${dir_display}${RESET}${git_segment}"
line="${line}${SEP}${C_MODEL}${model}${RESET}"
line="${line}${SEP}ctx ${pct_color}${pct_formatted}%${RESET} ${pct_color}${bar}${RESET}"
line="${line}${SEP}${C_TOKENS}${tokens_display}${RESET}"
line="${line}${cost_segment}"

printf '%s\n' "$line"
