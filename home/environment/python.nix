{pkgs, ...}: let
  python_version = "312";
in {
  nixpkgs.overlays = [
    (final: prev: {
      python3 = prev.python3.override {
        packageOverrides = py-final: py-prev: {
          pmdarima = py-prev.pmdarima.overridePythonAttrs (old: {
            propagatedBuildInputs = (old.propagatedBuildInputs or []) ++ [py-prev.scikit-learn_1_5];

            preCheck =
              (old.preCheck or "")
              + ''
                export HOME=$TMPDIR
                export PYTHONWARNINGS="ignore::DeprecationWarning"
                export PYTHONWARNINGS="$PYTHONWARNINGS,ignore::UserWarning"
              '';

            checkPhase = ''
              pytest -k "not test_oob_with_zero_out_of_sample_size and not test_issue_351" -p no:warnings
            '';
          });
        };
      };
    })
  ];

  home.packages = [
    (pkgs.${"python${python_version}"}.withPackages (ps: [
      ps.numpy
      ps.pandas
      ps.matplotlib
      ps.statsmodels
      ps.scipy
      ps.jupyter-core
      ps.notebook
      #ps.scikit-learn
      ps.deep-translator
      ps.tqdm
      ps.nltk
      ps.seaborn
      ps.uv
    ]))
    # (pkgs.poetry.override {python3 = pkgs.${"python${python_version}"};})
    # (pkgs.uv.override {python3 = pkgs.${"python${python_version}"};})
  ];
}
