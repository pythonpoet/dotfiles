{ pkgs, ... }:
let
  ImageDir = pkgs.copyPathToStore ./oroborus;
in
pkgs.stdenv.mkDerivation rec {
  pname = "oroborus";
  version = "1.7";
  src = pkgs.writeTextFile {
    name = "${pname}.script";
    text = ''
      // Init screen
      screen.w = Window.GetWidth();
      screen.h = Window.GetHeight();
      screen.half.w = screen.w / 2;
      screen.half.h = screen.h / 2;

      // Init animation
      images_count = 50;

      for (i = 0; i < images_count; ++i) {
          // The file extension here must match the file names in your theme directory.
          // Since you're using PNG files named with a .gif extension, this is correct.
          images[i] = Image("oroborus-" + (i + 1) + ".png");
      }

      cur_sprite = Sprite();
      cur_sprite.SetX(screen.half.w - images[0].GetWidth() / 2);
      cur_sprite.SetY(screen.half.h - images[0].GetHeight() / 2);

      ts = 0;

      fun update() {
          cur_sprite.SetImage(images[Math.Int(ts / 2.4) % images_count]);
          ts++;
      }

      Plymouth.SetRefreshFunction(update);
    '';
  };
  unpackPhase = "true";

  buildPhase = ''
    themeDir="$out/share/plymouth/themes/${pname}"
    mkdir -p "$themeDir"

    cp "${ImageDir}"/* "$themeDir/"
    cp $src $themeDir/${pname}.script
  '';

  installPhase = ''
    # Verify that all expected images exist
    for i in $(seq 0 49); do
      if [ ! -f "$themeDir/oroborus-$i.png" ]; then
        echo "Missing image: oroborus-$i.png" >&2
        exit 1
      fi
    done


    # Write the .plymouth file using tee instead of shell redirection
    tee "$themeDir/${pname}.plymouth" > /dev/null <<EOF
    [Plymouth Theme]
    Name=Oroburos
    Description=Custom Oroburos theme
    ModuleName=script

    [script]
    ImageDir=$themeDir
    ScriptFile=$themeDir/${pname}.script
    EOF
  '';
}
