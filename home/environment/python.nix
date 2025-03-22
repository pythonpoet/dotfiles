{pkgs, ...}: let
  python_version = "312";
in {
  home.packages = [
    (pkgs.${"python${python_version}"}.withPackages (ps: [
      ps.numpy
      ps.pandas
      ps.matplotlib
      ps.statsmodels
      ps.scipy
      ps.jupyter-core
      ps.notebook
      ps.scikit-learn
      ps.deep-translator
      ps.tqdm
      ps.nltk
      ps.seaborn
      ps.jupyter
    ]))
    (pkgs.poetry.override {python3 = pkgs.${"python${python_version}"};})
    # (pkgs.uv.override {python3 = pkgs.${"python${python_version}"};})
  ];
}
