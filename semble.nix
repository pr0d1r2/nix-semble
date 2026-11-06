{
  pkgs,
  src,
  deps,
}:
pkgs.python313Packages.buildPythonPackage {
  pname = "semble";
  version = "0.7.2";
  pyproject = true;

  inherit src;

  env.SETUPTOOLS_SCM_PRETEND_VERSION = "0.7.2";

  build-system = with pkgs.python313Packages; [
    setuptools
    setuptools-scm
  ];

  dependencies =
    with pkgs.python313Packages;
    [
      numpy
      orjson
      pathspec
      questionary
      tqdm
    ]
    ++ (with deps; [
      model2vec
      semble-grammars
      vicinity
    ]);

  pythonImportsCheck = [ "semble" ];

  doCheck = false;

  meta = with pkgs.lib; {
    description = "Instant code search for any local or remote git repository";
    homepage = "https://github.com/MinishLab/semble";
    license = licenses.mit;
  };
}
