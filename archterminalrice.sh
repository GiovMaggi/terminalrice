#!/usr/bin/env bash
# Terminal rice: Alacritty + Starship + neofetch + fastfetch (Dracula theme, Arch logo)
#
# Recreates the setup from scratch:
#   - Hurmit Nerd Font Mono
#   - Alacritty: font, Dracula colors, default window size 110x24
#   - Starship prompt (Gruvbox Rainbow preset recolored to Dracula, single line)
#   - neofetch and fastfetch with a custom Arch logo in Arch blue
#   - fastfetch layout: user@host, Os, Cpu, Gpu 1, Gpu 2, Ram
#
# Existing config files are backed up to ~/.config/rice-backup-<date>/ first.
#
# Usage: ./archterminalrice.sh               install packages + write configs
#        ./archterminalrice.sh --no-install  only write configs

set -euo pipefail

INSTALL=1
[[ "${1:-}" == "--no-install" ]] && INSTALL=0

CFG="$HOME/.config"
export PATH="$HOME/.local/bin:$PATH"
BACKUP="$CFG/rice-backup-$(date +%Y%m%d-%H%M%S)"

say() { printf '\n\033[38;5;39m==>\033[0m %s\n' "$*"; }

backup() {
    if [[ -e "$1" ]]; then
        mkdir -p "$BACKUP/$(dirname "${1#"$HOME"/}")"
        cp -a "$1" "$BACKUP/${1#"$HOME"/}"
    fi
}

install_neofetch_upstream() {
    # neofetch is no longer packaged everywhere; it's a single bash script, so grab the last release
    mkdir -p "$HOME/.local/bin"
    curl -fsSL -o "$HOME/.local/bin/neofetch" https://raw.githubusercontent.com/dylanaraps/neofetch/7.1.0/neofetch
    chmod +x "$HOME/.local/bin/neofetch"
    grep -qs '.local/bin' "$HOME/.bashrc" || echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
}

# ---------------------------------------------------------------- packages
if (( INSTALL )); then
    say "Installing packages (alacritty, starship, fastfetch, lua, libdrm, unzip)"
    sudo pacman -S --needed --noconfirm alacritty starship fastfetch lua libdrm unzip

    if ! command -v neofetch >/dev/null; then
        say "Installing neofetch"
        if pacman -Si neofetch >/dev/null 2>&1; then
            sudo pacman -S --needed --noconfirm neofetch
        elif command -v yay >/dev/null; then
            yay -S --needed --noconfirm neofetch
        elif command -v paru >/dev/null; then
            paru -S --needed --noconfirm neofetch
        else
            install_neofetch_upstream
        fi
    fi

    if [[ -z "$(fc-list "Hurmit Nerd Font Mono")" ]]; then
        say "Installing Hurmit Nerd Font"
        tmp=$(mktemp -d)
        curl -fL -o "$tmp/Hermit.zip" https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Hermit.zip
        mkdir -p "$HOME/.local/share/fonts"
        unzip -o -q "$tmp/Hermit.zip" -d "$HOME/.local/share/fonts"
        rm -rf "$tmp"
        fc-cache -f >/dev/null
    fi
fi

for f in "$CFG/alacritty/alacritty.toml" "$CFG/starship.toml" "$CFG/neofetch/config.conf" \
         "$CFG/neofetch/arch.txt" "$CFG/fastfetch/config.jsonc" "$CFG/fastfetch/arch.txt" "$HOME/.bashrc"; do
    backup "$f"
done
[[ -d "$BACKUP" ]] && say "Backed up existing configs to $BACKUP"

# ---------------------------------------------------------------- alacritty
say "Writing Alacritty config"
mkdir -p "$CFG/alacritty"
cat > "$CFG/alacritty/alacritty.toml" <<'__ALACRITTY_EOF__'

[[keyboard.bindings]]
key = "Return"
mods = "Shift"
chars = "\u001B\r"

[font]
normal = { family = "Hurmit Nerd Font Mono", style = "Regular" }
bold = { family = "Hurmit Nerd Font Mono", style = "Bold" }
italic = { family = "Hurmit Nerd Font Mono", style = "Italic" }
bold_italic = { family = "Hurmit Nerd Font Mono", style = "Bold Italic" }

# Default window size (matches the size from the screenshot)
[window]
dimensions = { columns = 110, lines = 24 }

# Dracula color scheme
[colors.primary]
background = "#282a36"
foreground = "#f8f8f2"
bright_foreground = "#ffffff"

[colors.cursor]
text = "CellBackground"
cursor = "CellForeground"

[colors.vi_mode_cursor]
text = "CellBackground"
cursor = "CellForeground"

[colors.search.matches]
foreground = "#44475a"
background = "#50fa7b"

[colors.search.focused_match]
foreground = "#44475a"
background = "#ffb86c"

[colors.footer_bar]
background = "#282a36"
foreground = "#f8f8f2"

[colors.hints.start]
foreground = "#282a36"
background = "#f1fa8c"

[colors.hints.end]
foreground = "#f1fa8c"
background = "#282a36"

[colors.selection]
text = "CellForeground"
background = "#44475a"

[colors.normal]
black = "#21222c"
red = "#ff5555"
green = "#50fa7b"
yellow = "#f1fa8c"
blue = "#bd93f9"
magenta = "#ff79c6"
cyan = "#8be9fd"
white = "#f8f8f2"

[colors.bright]
black = "#6272a4"
red = "#ff6e6e"
green = "#69ff94"
yellow = "#ffffa5"
blue = "#d6acff"
magenta = "#ff92df"
cyan = "#a4ffff"
white = "#ffffff"
__ALACRITTY_EOF__

# ---------------------------------------------------------------- starship
say "Writing Starship config"
cat > "$CFG/starship.toml" <<'__STARSHIP_EOF__'
"$schema" = 'https://starship.rs/config-schema.json'

format = """
[](cyan)\
$os\
$username\
[](bg:foreground fg:cyan)\
$directory\
[](fg:foreground bg:green)\
$git_branch\
$git_status\
[](fg:green bg:red)\
$c\
$cpp\
$rust\
$golang\
$nodejs\
$bun\
$php\
$java\
$kotlin\
$haskell\
$python\
[](fg:red bg:comment)\
$docker_context\
$conda\
$pixi\
[](fg:comment bg:current_line)\
$time\
[ ](fg:current_line)\
$line_break$character"""

# Use the color palette
palette = "dracula"

# Define Dracula color palette
[palettes.dracula]
background = "#282a36"
current_line = "#44475a"
foreground = "#f8f8f2"
comment = "#6272a4"
cyan = "#8be9fd"
green = "#50fa7b"
orange = "#ffb86c"
pink = "#ff79c6"
purple = "#bd93f9"
red = "#ff5555"
yellow = "#f1fa8c"

[os]
disabled = false
style = "bg:cyan fg:background"

[os.symbols]
Windows = "󰍲"
Ubuntu = "󰕈"
SUSE = ""
Raspbian = "󰐿"
Mint = "󰣭"
Macos = "󰀵"
Manjaro = ""
Linux = "󰌽"
Gentoo = "󰣨"
Fedora = "󰣛"
Alpine = ""
Amazon = ""
Android = ""
AOSC = ""
Arch = "󰣇"
Artix = "󰣇"
EndeavourOS = ""
CentOS = ""
Debian = "󰣚"
Redhat = "󱄛"
RedHatEnterprise = "󱄛"
Pop = ""

[username]
show_always = true
style_user = "bg:cyan fg:background"
style_root = "bg:cyan fg:background"
format = '[ $user ]($style)'

[directory]
style = "fg:background bg:foreground"
format = "[ $path ]($style)"
truncation_length = 3
truncation_symbol = "…/"

[directory.substitutions]
"Documents" = "󰈙 "
"Downloads" = " "
"Music" = "󰝚 "
"Pictures" = " "
"Developer" = "󰲋 "

[git_branch]
symbol = ""
style = "bg:green"
format = '[[ $symbol $branch ](fg:background bg:green)]($style)'

[git_status]
style = "bg:green"
format = '[[($all_status$ahead_behind )](fg:background bg:green)]($style)'

[nodejs]
symbol = ""
style = "bg:red"
format = '[[ $symbol( $version) ](fg:background bg:red)]($style)'

[bun]
symbol = ""
style = "bg:red"
format = '[[ $symbol( $version) ](fg:background bg:red)]($style)'

[c]
symbol = " "
style = "bg:red"
format = '[[ $symbol( $version) ](fg:background bg:red)]($style)'

[cpp]
symbol = " "
style = "bg:red"
format = '[[ $symbol( $version) ](fg:background bg:red)]($style)'

[rust]
symbol = ""
style = "bg:red"
format = '[[ $symbol( $version) ](fg:background bg:red)]($style)'

[golang]
symbol = ""
style = "bg:red"
format = '[[ $symbol( $version) ](fg:background bg:red)]($style)'

[php]
symbol = ""
style = "bg:red"
format = '[[ $symbol( $version) ](fg:background bg:red)]($style)'

[java]
symbol = ""
style = "bg:red"
format = '[[ $symbol( $version) ](fg:background bg:red)]($style)'

[kotlin]
symbol = ""
style = "bg:red"
format = '[[ $symbol( $version) ](fg:background bg:red)]($style)'

[haskell]
symbol = ""
style = "bg:red"
format = '[[ $symbol( $version) ](fg:background bg:red)]($style)'

[python]
symbol = ""
style = "bg:red"
format = '[[ $symbol( $version) ](fg:background bg:red)]($style)'

[docker_context]
symbol = ""
style = "bg:comment"
format = '[[ $symbol( $context) ](fg:foreground bg:comment)]($style)'

[conda]
style = "bg:comment"
format = '[[ $symbol( $environment) ](fg:foreground bg:comment)]($style)'

[pixi]
style = "bg:comment"
format = '[[ $symbol( $version)( $environment) ](fg:background bg:comment)]($style)'

[time]
disabled = false
time_format = "%R"
style = "bg:current_line"
format = '[[  $time ](fg:foreground bg:current_line)]($style)'

[line_break]
disabled = true

[character]
disabled = true
success_symbol = '[](bold fg:green)'
error_symbol = '[](bold fg:red)'
vimcmd_symbol = '[](bold fg:green)'
vimcmd_replace_one_symbol = '[](bold fg:purple)'
vimcmd_replace_symbol = '[](bold fg:purple)'
vimcmd_visual_symbol = '[](bold fg:foreground)'
__STARSHIP_EOF__

touch "$HOME/.bashrc"
if ! grep -q 'starship init bash' "$HOME/.bashrc"; then
    echo 'eval "$(starship init bash)"' >> "$HOME/.bashrc"
fi

# ---------------------------------------------------------------- neofetch
if command -v neofetch >/dev/null; then
    say "Writing neofetch logo and config"
    mkdir -p "$CFG/neofetch"
cat > "$CFG/neofetch/arch.txt" <<'__NEOFETCH_LOGO_EOF__'
${c1}            ▗▖            
           ▗██▖           
          ▗████▖          
         ▗██████▖         
        ▗████████▖        
       ▗██████████▖       
${c2}      ▗████████████▖      
     ▗████▛▘  ▝▜████▖     
    ▗████▛      ▜████▖    
   ▟█████▌      ▐█████▙   
  ▟██▀▀▘          ▝▀▀██▙  
 ▀▘                    ▝▀ 
__NEOFETCH_LOGO_EOF__

    [[ -f "$CFG/neofetch/config.conf" ]] || neofetch --print_config > "$CFG/neofetch/config.conf"
    sed -i "s|^image_source=.*|image_source=\"$CFG/neofetch/arch.txt\"|; s|^ascii_colors=.*|ascii_colors=(39 32)|" \
        "$CFG/neofetch/config.conf"
fi

# ---------------------------------------------------------------- fastfetch
say "Writing fastfetch logo and config"
mkdir -p "$CFG/fastfetch"
cat > "$CFG/fastfetch/arch.txt" <<'__FASTFETCH_LOGO_EOF__'
$1            ▗▖            
           ▗██▖           
          ▗████▖          
         ▗██████▖         
        ▗████████▖        
       ▗██████████▖       
$2      ▗████████████▖      
     ▗████▛▘  ▝▜████▖     
    ▗████▛      ▜████▖    
   ▟█████▌      ▐█████▙   
  ▟██▀▀▘          ▝▀▀██▙  
 ▀▘                    ▝▀ 
__FASTFETCH_LOGO_EOF__
cat > "$CFG/fastfetch/config.jsonc" <<'__FASTFETCH_EOF__'
{
  "$schema": "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json",
  "logo": {
    "type": "file",
    "source": "~/.config/fastfetch/arch.txt",
    "color": {
      "1": "38;5;39",
      "2": "38;5;32"
    },
    "padding": { "top": 0, "left": 2, "right": 4 }
  },
  "display": {
    "separator": "  ",
    "color": {
      "keys": "38;5;39",
      "title": "38;5;39",
      "separator": "38;5;240"
    },
    "key": { "width": 11 }
  },
  "modules": [
    // two empty lines so the 8-line info block sits centered next to the 12-line logo
    "break",
    "break",
    {
      "type": "title",
      "format": "{#38;5;39}  {user-name}{#38;5;240}@{#38;5;32}{host-name}"
    },
    {
      "type": "custom",
      "format": "{#38;5;240}─────────────────────────────────────────────"
    },
    { "type": "os", "key": "󰣇  Os", "format": "{pretty-name}" },
    { "type": "cpu", "key": "  Cpu", "format": "{name}" },
    { "type": "gpu", "key": "󰢮  Gpu{?1} {1}{?}",
      // key: "Gpu" with one GPU, "Gpu 1", "Gpu 2"... with several
      // value: vendor + name, without the [Discrete]/[Integrated] tag (adds the vendor only when the name lacks it)
      "format": "lua:local a = ...; local n, v = a.name or '', a.vendor or ''; if v ~= '' and n:sub(1, #v) ~= v then n = v .. ' ' .. n end; return n" },
    { "type": "memory", "key": "  Ram" },
    {
      "type": "custom",
      "format": "{#38;5;240}─────────────────────────────────────────────"
    }
  ]
}
__FASTFETCH_EOF__

say "Done! Open a new Alacritty window, then try: fastfetch  or  neofetch"
