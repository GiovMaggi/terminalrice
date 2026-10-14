# terminalrice

One-command terminal rice for **Arch Linux** and **Fedora**: Alacritty + Starship + neofetch + fastfetch,
with the Dracula color scheme and a custom distro logo.

## What you get

- **Font:** Hurmit Nerd Font Mono
- **Alacritty:** Dracula colors, opens at 110×24
- **Starship prompt:** Gruvbox Rainbow preset recolored to Dracula, on a single line
- **neofetch / fastfetch:** a custom block-style Arch or Fedora logo in light blue
- **fastfetch layout:** `user@host`, Os, Cpu, Gpu, Ram, nothing else

## Install

Arch Linux:

```bash
git clone https://github.com/GiovMaggi/terminalrice.git
cd terminalrice
./archterminalrice.sh
```

Fedora:

```bash
git clone https://github.com/GiovMaggi/terminalrice.git
cd terminalrice
./fedoraterminalrice.sh
```

The script asks for your password to install packages. Then open a new Alacritty window and run `fastfetch` or `neofetch`.

To only write the config files without installing anything, add `--no-install`:

```bash
./archterminalrice.sh --no-install
```

## Good to know

- Your existing configs are backed up to `~/.config/rice-backup-<date>/` before anything is overwritten.
- Files written: `~/.config/alacritty/alacritty.toml`, `~/.config/starship.toml`, `~/.config/neofetch/`,
  `~/.config/fastfetch/`, plus a Starship line in `~/.bashrc`.
- neofetch isn't packaged on every distro anymore. If it isn't available, the script downloads the official
  neofetch script into `~/.local/bin`.
