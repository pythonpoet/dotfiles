{pkgs, ...}: {
  programs.vscode = {
    enable = true;
    package = pkgs.vscodium;

    extensions = with pkgs.vscode-extensions; [
      dracula-theme.theme-dracula
      yzhang.markdown-all-in-one
    ];

    userSettings = {
      "security.workspace.trust.untrustedFiles" = "open";
      "editor.largeFileOptimizations" = true;
      "explorer.confirmDelete" = false;
      "typst-lsp.experimentalFormatterMode" = "on";
      "typst-lsp.exportPdf" = "onType";
      "tinymist.lsp.serverPath" = "${pkgs.tinymist}/bin/tinymist"; # if installed with nix
      "tinymist.exportPdf" = "onType";
      "tinymist.outputPath" = "\${workspaceFolder}/\${fileBasenameNoExtension}";
    };
  };
}
