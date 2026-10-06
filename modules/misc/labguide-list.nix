# Shared list
{
  myModules.apps.labguide = {
    enable = true;
    packages = [
      # TUIs — run and stay
      "btop"
      "yazi"
      "lazygit"
      "dysk"
      "fish"
      "wev"

      # Search and navigation
      {
        name = "ripgrep";
        action = "man rg";
      }
      {
        name = "fd";
        action = "fd --help | less -R";
      }
      {
        name = "ast-grep";
        action = "ast-grep --help | less -R";
      }
      {
        name = "zoxide";
        action = "zoxide --help | less -R";
      }
      {
        name = "fasd";
        action = "man fasd";
      }
      {
        name = "as-tree";
        action = "as-tree --help | less -R";
      }

      # Files and text
      {
        name = "bat";
        action = "bat --help | less -R";
      }
      {
        name = "jq";
        action = "man jq";
      }
      {
        name = "pandoc";
        action = "man pandoc";
      }
      {
        name = "trash-cli";
        action = "trash --help | less -R";
      }
      {
        name = "unzip";
        action = "man unzip";
      }

      # PDF and media
      {
        name = "poppler-utils";
        action = "man pdfinfo";
      }
      {
        name = "qpdf";
        action = "man qpdf";
      }
      {
        name = "imagemagick";
        action = "magick --help | less -R";
      }
      {
        name = "chafa";
        action = "chafa --help | less -R";
      }
      {
        name = "yt-dlp";
        action = "yt-dlp --help | less -R";
      }

      # Network and remote
      {
        name = "tailscale";
        action = "tailscale status; read";
      }
      {
        name = "sshfs";
        action = "man sshfs";
      }
      {
        name = "wget";
        action = "man wget";
      }
      {
        name = "dnsutils";
        action = "man dig";
      }
      {
        name = "gh";
        action = "gh --help | less -R";
      }

      # Nix and Wayland
      {
        name = "colmena";
        action = "colmena --help | less -R";
      }
      {
        name = "statix";
        action = "statix --help | less -R";
      }
      {
        name = "hyprshot";
        action = "hyprshot --help | less -R";
      }
      {
        name = "wl-clipboard";
        action = "man wl-copy";
      }
    ];
  };
}
