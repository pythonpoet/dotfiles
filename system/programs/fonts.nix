{pkgs, ...}: {
  fonts = {

      packages = with pkgs; [
      # icon fonts
      material-design-icons

      # normal fonts
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji

      # nerdfonts
      (nerdfonts.override {fonts = ["FiraCode" "JetBrainsMono"];})
    ];

    # causes more issues than it solves
    enableDefaultPackages = false;

    # user defined fonts
    # the reason there's Noto Color Emoji everywhere is to override DejaVu's
    # B&W emojis that would sometimes show instead of some Color emojis
    fontconfig.defaultFonts = let
      addAll = builtins.mapAttrs (_: v: v ++ ["Noto Color Emoji"]);
    in
      addAll {
        serif = ["Libertinus Serif"];
        sansSerif = ["Inter"];
        monospace = ["JetBrains Mono Nerd Font"];
        emoji = [];
      };
  };
}
