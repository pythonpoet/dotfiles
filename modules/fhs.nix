{ pkgs, ... }:
let
  fhsEnv = pkgs.buildFHSEnv {
    name = "fhs";
    targetPkgs = pkgs:
      # TODO despite all the gobject/Gtk stuff, the matplotlib Gtk3Agg backend still doesn't work.
      # I narrowed it down to GI_TYPELIB_PATH not being set - which is apparently a design choice in NixOS (https://nixos.wiki/wiki/FAQ#I_installed_a_library_but_my_compiler_is_not_finding_it._Why.3F)
      # because only applications not libraries are linked into the environment. A nix-shell explicitly does that (because development purposes:)
      # > nix-shell -p gtk3 -p gobject-introspection -p 'python3.withPackages (ps: with ps; [pygobject3])'
      # But that is ridiculous. So another shortcoming of FHSEnv, I guess. Well, TkAgg and QtAgg work now at least...
      with pkgs; [
        (python3.withPackages
          (ps: with ps; [ matplotlib tkinter pygobject3 ipython pyqt6 ]))
        gtk3 # for Gtk3Agg matplotlib backend
        gobject-introspection # for Gtk3Agg matplotlib backend
        librsvg # for Gtk3Agg matplotlib backend
        file # for libmagic
        zlib # for numpy
        openssl # needed that once for opentimestamps
      ]; # TODO: ideally this is all environment.systemPackages
    runScript =
      "fish"; # TODO: hard-coded fish here. Should be the default system shell.
    profile = ''
      if ! python -c 'import tkinter' 2>/dev/null >/dev/null;then
        # Fix tkinter import (was necessary at some point?)
        for d in ${
          toString pkgs.python3Packages.tkinter
        }/lib/python*/site-packages;do
          export PYTHONPATH="$d:$PYTHONPATH"
        done
        if ! python -c 'import tkinter' 2>/dev/null >/dev/null;then
          echo "Still not possible to 'import tkinter', despite setting PYTHONPATH=$PYTHONPATH"
        fi
      fi
      # export MPLBACKEND=TkAgg # the other matplotlib backends don't work for some reason 🤷
    '';
  };
in {
  environment.systemPackages = [ fhsEnv ];
  # Provide virtual /bin and /usr/bin directories with executables magically available
  # disable for now, gives warnings on boot and @Sandro@c3d2.social reported issues with agetty
  services.envfs.enable = false;
  # Help programs expecting FHS environment
  programs = {
    nix-ld = {
      enable = true;
      libraries = with pkgs; [
        stdenv.cc.cc.lib
        zlib
        file
        zlib
        zstd
        stdenv.cc.cc
        curl
        openssl
        attr
        libssh
        bzip2
        libxml2
        acl
        libsodium
        util-linux
        xz
        systemd
        # Add mesa here:
        mesa # provides libGL.so.1
        libGL
        glib
        glib-networking
      ];
    };
  };
}
