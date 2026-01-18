{
  inputs,
  pkgs,
  ...
}:
{
  imports = [ ./languages.nix ];

  programs.helix = {
    enable = true;
    #dont build from latest
    #package = inputs.helix.packages.${pkgs.system}.default;
    extraPackages = with pkgs; [
      markdown-oxide
      nodePackages.vscode-langservers-extracted
      shellcheck
      ltex-ls
      tinymist
    ];

    settings = {
      theme = "onedark";
      editor = {
        auto-format = true;
        color-modes = true;
        completion-trigger-len = 1;
        completion-replace = true;
        cursorline = true;
        cursor-shape = {
          insert = "bar";
          normal = "block";
          select = "underline";
        };
        indent-guides.render = true;
        inline-diagnostics = {
          cursor-line = "hint";
          other-lines = "error";
        };
        lsp.display-inlay-hints = true;
        statusline.center = [ "position-percentage" ];
        true-color = true;
        whitespace.characters = {
          newline = "↴";
          tab = "⇥";
        };
      };

      keys = {
        normal.space.u = {
          f = ":format";
          w = ":set whitespace.render all";
          W = ":set whitespace.render none";
        };

        # Save with Ctrl+S
        normal."C-s" = ":w";
        insert."C-s" = [
          "normal_mode"
          ":w"
          "insert_mode"
        ];

        # Clipboard actions in SELECT mode (like visual mode)
        select = {
          "C-c" = ":clipboard-yank"; # Copy
          "C-x" = [
            ":clipboard-yank"
            "delete_selection"
          ]; # Cut = Copy + Delete
        };

        # Clipboard paste in NORMAL and INSERT modes
        normal."C-v" = ":clipboard-paste-after"; # Paste after cursor
        insert."C-v" = [
          "normal_mode"
          ":clipboard-paste-after"
          "insert_mode"
        ]; # Paste at cursor

        normal."C-/" = "toggle_comments";
      };
    };
  };
}
