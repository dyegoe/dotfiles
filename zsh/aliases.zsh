#!/usr/bin/env zsh

# ##### General #####

alias ll='eza --icons=always --git -lah'
alias ls='eza --icons'

# ##### Bat #####
alias cat='bat -p'

# ##### Git #####

# Copied from https://github.com/ohmyzsh/ohmyzsh/blob/master/lib/git.zsh
function git_current_branch() {
  local ref
  ref=$(command git symbolic-ref --quiet HEAD 2>/dev/null)
  local ret=$?
  if [[ $ret != 0 ]]; then
    [[ $ret == 128 ]] && return # no git repo.
    ref=$(command git rev-parse --short HEAD 2>/dev/null) || return
  fi
  echo ${ref#refs/heads/}
}

alias g='git'
alias ga='git add'
alias gb='git branch'
alias gbd='git branch --delete'
alias gbD='git branch --delete --force'
alias gbr='git branch --remote'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gcmsg='git commit --message'
alias gf='git fetch'
alias gfa='git fetch --all --prune --jobs=10'
alias gl='git pull'
alias gpr='git pull --rebase'
alias gp='git push'
alias gpsup='git push --set-upstream origin $(git_current_branch)'
alias gst='git status'
alias gss='git status --short'
alias gsb='git status --short --branch'
alias gr='git restore'
alias grs='git restore --staged'
