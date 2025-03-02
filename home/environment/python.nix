{pkgs, ...}: let
  python_version = "311";
in {
  home.packages = [
    (pkgs.${"python" + python_version}.withPackages (p:
      with p; [
        numpy
        pandas
        matplotlib
        statsmodels
        scipy
        jupyter-core
        notebook
        scikit-learn
        deep-translator
        tqdm
        nltk
        seaborn
        # pmdarima
      ]))
    (pkgs.poetry.override {python3 = pkgs.${"python" + python_version};}) # <--- Fixed here
  ];
}
