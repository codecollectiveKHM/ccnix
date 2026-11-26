# PATH exports
export PATH="$HOME/.local/bin/:$PATH"
export ANDROID_USER_HOME="$HOME/.local/share/android"
export STARSHIP_CONFIG=~/.config/starship/starship.toml

# Keys: never commit them. Scripts read them from pass (e.g. `pass show api/gemini`).

# EDITOR/VISUAL: home.sessionVariables in zsh.nix
# XDG paths (HISTFILE: programs.zsh.history.path in zsh.nix)
export SVN_CONFIG_DIR="$HOME/.config/subversion"
export XDG_CONFIG_HOME="$HOME/.config"
export PYTHONHISTORY="$HOME/.local/state/python/"

# Oh My Zsh cache location fix
export ZSH_COMPDUMP="$HOME/.cache/zsh/zcompdump-$ZSH_VERSION"
