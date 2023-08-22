
# If ZSH is not defined, use the current script's directory.
[[ -z "$ZSH" ]] && export ZSH="${${(%):-%x}:a:h}"

$DEBUG || DEBUG=false

$DEBUG && echo "   \$ZSH set to \"$ZSH\""

# $DEBUG && echo "-- checking for updates"
#
# # Check for updates on initial load...
# source "$ZSH/tools/check_for_upgrade.sh"

# Initializes Oh My Zsh

# add a function path
fpath=("$ZSH/functions" "$ZSH/completions" $fpath)

$DEBUG && echo "-- loading stock functions (compaudit compinit zrecompile)"

# Load all stock functions (from $fpath files) called below.
autoload -U compaudit compinit zrecompile

# Set ZSH_CUSTOM to the path where your custom config files
# and plugins exists, or else we will use the default custom/
if [[ -z "$ZSH_CUSTOM" ]]; then
    ZSH_CUSTOM="$ZSH/custom"
fi

$DEBUG && echo "   \$ZSH_CUSTOM set to \"$ZSH_CUSTOM\""

is_plugin() {
  local base_dir=$1
  local name=$2
  builtin test -f $base_dir/plugins/$name/$name.plugin.zsh \
    || builtin test -f $base_dir/plugins/$name/_$name
}

$DEBUG && echo "-- adding all defined plugins to function path"

# Add all defined plugins to fpath. This must be done
# before running compinit.
for plugin ($plugins); do
  if is_plugin "$ZSH_CUSTOM" "$plugin"; then
    fpath=("$ZSH_CUSTOM/plugins/$plugin" $fpath)
  elif is_plugin "$ZSH" "$plugin"; then
    fpath=("$ZSH/plugins/$plugin" $fpath)
  else
    echo "[oh-my-zsh] plugin '$plugin' not found"
  fi
done

# Figure out the SHORT hostname
if [[ "$OSTYPE" = darwin* ]]; then
  # macOS's $HOST changes with dhcp, etc. Use ComputerName if possible.
  SHORT_HOST=$(scutil --get ComputerName 2>/dev/null) || SHORT_HOST="${HOST/.*/}"
else
  SHORT_HOST="${HOST/.*/}"
fi

_lime_source() {

  local context filepath="$1"

  # Construct zstyle context based on path
  case "$filepath" in
  lib/*) context="lib:${filepath:t:r}" ;;         # :t = lib_name.zsh, :r = lib_name
  plugins/*) context="plugins:${filepath:h:t}" ;; # :h = plugins/plugin_name, :t = plugin_name
  esac

  # Source file from $ZSH_CUSTOM if it exists, otherwise from $ZSH
  if [[ -f "$ZSH_CUSTOM/$filepath" ]]; then
    source "$ZSH_CUSTOM/$filepath"
  elif [[ -f "$ZSH/$filepath" ]]; then
    source "$ZSH/$filepath"
  fi
}

# Load all of the config files in ~/oh-my-zsh that end in .zsh
# TIP: Add files you don't want in git to .gitignore
for config_file ("$ZSH"/lib/*.zsh); do
  $DEBUG && echo "-- loading lib file ($config_file)"
  _lime_source "lib/${config_file:t}"
done
unset custom_config_file

# Load all of the plugins that were defined in ~/.zshrc
for plugin ($plugins); do
  $DEBUG && echo "-- loading plugin file ($plugin)"
  _lime_source "plugins/$plugin/$plugin.plugin.zsh"
done
unset plugin

# Load all of your custom configurations from custom/
for config_file ("$ZSH_CUSTOM"/*.zsh(N)); do
  $DEBUG && echo "-- loading custom config file ($config_file)"
  source "$config_file"
done
unset config_file

for config_file ("$ZSH_CUSTOM"/aliases/*.zsh); do
  $DEBUG && echo "-- loading aliases ($config_file)"
  _lime_source "aliases/$config_file"
done
unset config_file

# Load the theme
is_theme() {
  local base_dir=$1
  local name=$2
  builtin test -f $base_dir/$name.zsh-theme
}

$DEBUG && echo "-- loading theme file"

if [[ -n "$ZSH_THEME" ]]; then
  if is_theme "$ZSH_CUSTOM" "$ZSH_THEME"; then
    source "$ZSH_CUSTOM/$ZSH_THEME.zsh-theme"
  elif is_theme "$ZSH_CUSTOM/themes" "$ZSH_THEME"; then
    source "$ZSH_CUSTOM/themes/$ZSH_THEME.zsh-theme"
  elif is_theme "$ZSH/themes" "$ZSH_THEME"; then
    source "$ZSH/themes/$ZSH_THEME.zsh-theme"
  else
    echo "[oh-my-zsh] theme '$ZSH_THEME' not found"
  fi
fi

# vim: ft=zsh
