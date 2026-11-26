# # FZF Integration
# source /usr/share/fzf/shell/completion.zsh 2> /dev/null
# source /usr/share/fzf/shell/key-bindings.zsh 2> /dev/null

# Disable Ctrl S and Ctrl Q
stty -ixon
stty eof '^Q'
# This was indirectly making Alt-l
bindkey -r '^[l'

# Ctrl+D for fzf directory and restore Ctrl+T to its default Zsh behavior
bindkey '^D' fzf-file-widget
bindkey '^T' transpose-chars

# Bind Ctrl S for fzf our command history this is set declaratively after loading the fzf fzf-history-widget
# bindkey '^S' fzf-history-widget

# Bind Ctrl Q to what previously Ctrl D did
bindkey '^Q' delete-char-or-list

# Prompt & Navigation
eval "$(starship init zsh)"

# OSC 133 marks inside zellij (starship emits none; kitty's integration covers plain kitty).
# The output mark (C) sits at the prompt, so zellij's CopyLastCommandOutput (mod Y)
# copies prompt + command + output.
if [[ -n $ZELLIJ ]]; then
  _osc133_precmd() {
    local s=$?
    (( ${+_osc133_ran} )) && print -n "\e]133;D;$s\a"
    print -n '\e]133;A\a\e]133;C\a'
  }
  _osc133_preexec() { _osc133_ran=1 }
  precmd_functions=(_osc133_precmd $precmd_functions) # first, so $? is the command's
  preexec_functions+=(_osc133_preexec)
fi
eval "$(zoxide init zsh)"

# Check if file exists before sourcing it
[ -f "$HOME/.deno/env" ] && . "$HOME/.deno/env"
