{
  pkgs,
  src,
  deps,
}:
pkgs.python313Packages.buildPythonPackage {
  pname = "semble";
  version = "0.3.1";
  pyproject = true;

  inherit src;

  env.SETUPTOOLS_SCM_PRETEND_VERSION = "0.3.1";

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
      tree-sitter
    ]
    ++ (with deps; [
      bm25s
      model2vec
      tree-sitter-language-pack
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
