{pkgs, ...}: {
  home.packages = [
    (pkgs.python3.withPackages (p:
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
        pmdarima
      ]))
    pkgs.poetry
  ];
}
