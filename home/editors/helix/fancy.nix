{
  config,
  lib,
  pkgs,
  inputs,
  ...
} @ args:
with lib; let
  cfg = config.ncfg.cli.helix;

  base = home: {
    # imports = [ ];
    programs.git.extraConfig.core.editor = lib.mkOverride 100 "hx";
    programs.helix = {
      enable = true;
      # package = inputs.helix.packages.${pkgs.system}.default;
      package = inputs.helix.packages.${pkgs.system}.default.overrideAttrs (self: {
        makeWrapperArgs = with pkgs;
          self.makeWrapperArgs
          or []
          ++ [
            "--suffix"
            "PATH"
            ":"
            (lib.makeBinPath [
              # Debugging stuff
              lldb

              # clang-tools # C-Style
              cmake-language-server
              jsonnet-language-server
              # dart
              xsel
              # haskell-language-server # Haskell
              julia-bin # Julia
              luaformatter
              elixir_ls # Elixir
              marksman # Markdown
              ltex-ls
              # solargraph # Ruby
              # go # Go
              # gopls # Go
              texlab # LaTeX
              taplo # Toml
              # (rustPlatform.buildRustPackage {
              #   pname = "taplo";
              #   version = "0.8.2-git";
              #   src = inputs.taplo;
              #   # cargoSha256 = ""; # when updating the flake input, necessary for new hash...
              #   cargoSha256 = "sha256-UFj8oqLJdX0AWnW2a4qJCZ7EyvkZ5yUhheooiDO3V6w=";
              #   buildFeatures = [ "lsp" ];
              # }) # Toml
              pgformatter
              # kotlin-language-server # Kotlin
              # nickel.packages.${pkgs.system}.default
              (python3.withPackages (ps: with ps; [python-lsp-server] ++ python-lsp-server.optional-dependencies.all))
              nil # Nix
              nodePackages.bash-language-server # Bash
              nodePackages.dockerfile-language-server-nodejs
              nodePackages.pyright # Python
              nodePackages.stylelint
              # nodePackages.svelte-language-server # Svelte
              nodePackages.vls
              nodePackages.vim-language-server
              nodePackages.vscode-langservers-extracted
              nodePackages.yaml-language-server # YAML / JSON
              # ocamlPackages.ocaml-lsp # Ocaml
              # ocamlPackages.dune_3 # Ocaml
              # opam # Ocaml
              # ocamlPackages.reason # Ocaml
              pkgs.dotnet-sdk
              pkgs.omnisharp-roslyn # .NET
              pkgs.msbuild
              ripgrep
              rnix-lsp
              # java-language-server
              sumneko-lua-language-server # Lua
              yapf
              zathura
              # zls # Zig
            ])
            "--set-default"
            "RUST_SRC_PATH"
            "${rustPlatform.rustcSrc}/library"
          ];
      });

      languages = with pkgs; {
        language-server = {
          efm-lsp-prettier = {
            command = "${efm-langserver}/bin/efm-langserver";
            config = {
              documentFormatting = true;
              languages = lib.genAttrs ["typescript" "javascript" "typescriptreact" "javascriptreact" "vue" "json" "markdown"] (_: [
                {
                  formatCommand = "${nodePackages.prettier}/bin/prettier --stdin-filepath \${INPUT}";
                  formatStdin = true;
                }
              ]);
            };
          };
          eslint = {
            command = "vscode-eslint-language-server";
            args = ["--stdio"];
            config = {
              validate = "on";
              packageManager = "yarn";
              useESLintClass = false;
              codeActionOnSave.mode = "all";
              # codeActionsOnSave = { mode = "all"; };
              format = true;
              quiet = false;
              onIgnoredFiles = "off";
              rulesCustomizations = [];
              run = "onType";
              # nodePath configures the directory in which the eslint server should start its node_modules resolution.
              # This path is relative to the workspace folder (root dir) of the server instance.
              nodePath = "";
              # use the workspace folder location or the file location (if no workspace folder is open) as the working directory

              workingDirectory.mode = "auto";
              experimental = {};
              problems.shortenToSingleLine = false;
              codeAction = {
                disableRuleComment = {
                  enable = true;
                  location = "separateLine";
                };
                showDocumentation.enable = true;
              };
            };
          };

          typescript-language-server = {
            command = "${nodePackages.typescript-language-server}/bin/typescript-language-server";
            args = ["--stdio" "--tsserver-path=${nodePackages.typescript}/lib/node_modules/typescript/lib"];
            config.documentFormatting = false;
          };

          nil = {
            command = "${inputs.nil.packages.${pkgs.system}.default}/bin/nil";
            # command = "nil";
            config.nil = {
              formatting.command = ["${nixpkgs-fmt}/bin/nixpkgs-fmt"];
              # formatting.command = [ "alejandra" "-q" ];
              nix.flake.autoEvalInputs = true;
            };
          };
          # lexical = {
          #   command = "${inputs.lexical.packages.${pkgs.system}.default}/bin/lexical";
          #   config.lexical = {
          #     # formatting.command = [ "${nixpkgs-fmt}/bin/nixpkgs-fmt" ];
          #   };
          # };
          ltex-ls.command = "ltex-ls";
          rust-analyzer = {
            config.rust-analyzer = {
              cargo.loadOutDirsFromCheck = true;
              checkOnSave.command = "clippy";
              procMacro.enable = true;
              lens = {
                references = true;
                methodReferences = true;
              };
              completion.autoimport.enable = true;
              experimental.procAttrMacros = true;
            };
          };
          omnisharp = {
            command = "omnisharp";
            args = ["-l" "Error" "--languageserver" "-z"];
          };
        };
        language = let
          jsTsWebLanguageServers = [
            {
              name = "typescript-language-server";
              except-features = ["format"];
            }
            "eslint"
            {
              name = "efm-lsp-prettier";
              only-features = ["format"];
            }
          ];
        in [
          {
            name = "bash";
            auto-format = true;
            file-types = ["sh" "bash"];
            formatter = {
              command = "${pkgs.shfmt}/bin/shfmt";
              # Indent with 2 spaces, simplify the code, indent switch cases, add space after redirection
              args = ["-i" "4" "-s" "-ci" "-sr"];
            };
          }
          # { name = "ruby"; file-types = [ "rb" "rake" "rakefile" "irb" "gemfile" "gemspec" "Rakefile" "Gemfile" "Fastfile" "Matchfile" "Pluginfile" "Appfile" ]; }
          {
            name = "rust";
            auto-format = false;
            file-types = ["lalrpop" "rs"];
            language-servers = ["rust-analyzer"];
          }

          # {
          #   name = "rust";
          #   language-server = { command = "${pkgs.rust-analyzer}/bin/rust-analyzer"; };
          #   config.checkOnSave = {
          #     command = "clippy";
          #   };
          # }

          {
            name = "c-sharp";
            language-servers = ["omnisharp"];
          }
          {
            name = "typescript";
            language-servers = jsTsWebLanguageServers;
          }
          {
            name = "javascript";
            language-servers = jsTsWebLanguageServers;
          }
          {
            name = "jsx";
            language-servers = jsTsWebLanguageServers;
          }
          {
            name = "tsx";
            language-servers = jsTsWebLanguageServers;
          }
          {
            name = "vue";
            language-servers = [
              {
                name = "vuels";
                except-features = ["format"];
              }
              {name = "efm-lsp-prettier";}
              "eslint"
            ];
          }
          {
            name = "sql";
            formatter.command = "pg_format";
          }
          {
            name = "nix";
            language-servers = ["nil"];
          }
          {
            name = "elixir";
            formatter.command = "${pkgs.elixir}/bin/mix format";
          }
          # { name = "elixir"; language-servers = [ "lexical" ]; }
          # { name = "heex"; language-servers = [ "lexical" ]; }
          {
            name = "json";
            language-servers = [
              {
                name = "vscode-json-language-server";
                except-features = ["format"];
              }
              "efm-lsp-prettier"
            ];
          }
          {
            name = "markdown";
            language-servers = [
              {
                name = "marksman";
                except-features = ["format"];
              }
              "ltex-ls"
              "efm-lsp-prettier"
            ];
          }

          {
            name = "xml";
            # auto-format = true;
            file-types = ["xml"];
            formatter = {
              command = "${pkgs.yq-go}/bin/yq";
              args = ["--input-format" "xml" "--output-format" "xml" "--indent" "2"];
            };
          }
          # {
          #   name = "markdown";
          #   language-server = {
          #     command = "${pkgs.ltex-ls}/bin/ltex-ls";
          #   };
          #   file-types = [ "md" "txt" ];
          #   scope = "source.markdown";
          #   roots = [ ];
          # }
        ];
      };

      settings = {
        theme = "doom_acario_dark";
        editor = {
          scrolloff = 8;
          mouse = false;
          middle-click-paste = false;
          # shell = ["bash"];
          shell = ["zsh" "-c"];
          line-number = "relative";
          cursorline = true;
          gutters = ["diagnostics" "line-numbers" "spacer" "diff"];
          auto-format = true;
          # auto-save = true;
          completion-replace = true;
          completion-trigger-len = 1;
          idle-timeout = 200;
          true-color = true;
          # rulers = [ 80];
          # bufferline = "multiple";
          bufferline = "always";
          color-modes = true;
          statusline = {
            # mode-separator = "";
            # mode-separator = "";
            # mode-separator = "";
            separator = "";
            # separator = "";
            left = ["mode" "selections" "spinner" "file-name" "total-line-numbers"];
            center = [];
            right = ["diagnostics" "file-encoding" "file-line-ending" "file-type" "position-percentage" "position"];
            mode = {
              normal = "N     ";
              insert = "   INS";
              select = "SELECT";
            };
          };
          lsp.display-messages = true;
          cursor-shape = {
            normal = "block";
            insert = "bar";
            select = "underline";
          };
          # file-picker.hidden = false;
          whitespace.render = "all";
          whitespace.characters = {
            # space = "·";
            nbsp = "⍽";
            tab = "→";
            newline = "⤶";
          };
          # indent-guides = {
          #   render = true;
          #   rainbow = "normal";
          #   # rainbow = "dim";
          # };

          # auto-pairs = {
          #   "(" = ")";
          #   "{" = "}";
          #   "[" = "]";
          #   "\"" = "\"";
          #   "'" = "'";
          #   "<" = ">";
          # };
          rainbow-brackets = true;
          # sticky-context = {
          #   enable = true;
          #   indicator = true;
          # };
          # popup-border = "all";
          # explorer = {
          #   position = "embed";
          # };
        };

        keys = let
          spaceMode = {
            w = {
              "C-k" = "jump_view_down";
              "k" = "jump_view_down";
              "C-h" = "jump_view_up";
              "h" = "jump_view_up";
              "C-j" = "jump_view_left";
              "j" = "jump_view_left";
              "K" = "swap_view_down";
              "H" = "swap_view_up";
              "J" = "swap_view_left";
            };
            # space = "file_picker";
            # n = "global_search";
            # f = ":format"; # format using LSP formatter
            space = ":format"; # format using LSP formatter
            c = "toggle_comments"; # Or 'C-c'
            t = {
              t = "goto_definition";
              i = "goto_implementation";
              r = "goto_reference";
              d = "goto_type_definition";
            };
            x = ":buffer-close";
            # w = ":w";
            # q = ":q";
            # u = {
            #   w = ":set whitespace.render all";
            #   W = ":set whitespace.render none";
            # };
          };
          commonMovementMappings = {
            "'" = "repeat_last_motion";
            g.j = "goto_line_start";
            z.k = "scroll_down";
            z.h = "scroll_up";
            Z.k = "scroll_down";
            Z.h = "scroll_up";
            "C-w" = {
              "C-k" = "jump_view_down";
              "k" = "jump_view_down";
              "C-h" = "jump_view_up";
              "h" = "jump_view_up";
              "C-j" = "jump_view_left";
              "j" = "jump_view_left";
              "K" = "swap_view_down";
              "H" = "swap_view_up";
              "J" = "swap_view_left";
            };
            # move line-up
            "C-k" = ["extend_to_line_bounds" "delete_selection" "paste_after"];
            # move line-down
            "C-h" = ["extend_to_line_bounds" "delete_selection" "move_line_up" "paste_before"];
          };
        in {
          normal =
            {
              D = ["delete_selection_noyank"];
              n = ["search_next" "align_view_center"];
              N = ["search_prev" "align_view_center"];
              j = "move_char_left";
              h = ["move_line_up" "align_view_center"];
              k = ["move_line_down" "align_view_center"];
              "X" = "extend_line_above";
              "{" = "goto_prev_paragraph";
              "}" = "goto_next_paragraph";
              "C-q" = ":bc";
              "C-u" = ["half_page_up" "goto_window_center"];
              "C-d" = ["half_page_down" "goto_window_center"];
              "C-p" = ["move_line_up" "scroll_up"];
              "C-n" = ["move_line_down" "scroll_down"];
              backspace = ["collapse_selection" "keep_primary_selection"];
              esc = ["collapse_selection" "keep_primary_selection"];
              space = spaceMode;
            }
            // commonMovementMappings;
          insert."C-space" = "completion";
          select =
            {
              D = ["delete_selection_noyank"];
              j = "extend_char_left";
              h = "extend_line_up";
              k = "extend_line_down";
              space = spaceMode;
            }
            // commonMovementMappings;
          # changes = {
          #   "p" = "replace";
          #   "P" = "replace_with_yanked";
          #   "~" = "switch_case";
          #   "`" = "switch_to_lowercase";
          #   "Alt-`" = "switch_to_uppercase";
          #   "u" = "insert_mode";
          #   "U" = "prepend_to_line";
          #   "d" = "delete_selection";
          #   "Alt-d" = "delection_selection_noyank";
          # };
        };
      };
    };

    home.sessionVariables.EDITOR = lib.mkOverride 100 "hx";
  };
in {
  options.ncfg.cli.helix = {
    enable = lib.mkOption {
      default = config.ncfg.cli.advanced;
    };
  };

  config = lib.mkIf cfg.enable {
    environment.sessionVariables.EDITOR = lib.mkOverride 100 "hx";
    environment.sessionVariables.VISUAL = lib.mkOverride 100 "hx";

    home-manager.users.${config.ncfg.primaryUserName} = {...}: (base "/home/${config.ncfg.primaryUserName}");
    # home-manager.users."root" = { ... }: (base "/root");
  };
}
