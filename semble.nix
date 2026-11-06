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
      # semble[mcp]: a bare `semble` invocation runs the MCP server.
      mcp
      model2vec
      semble-grammars
      vicinity
    ]);

  # Searching a remote repository shells out to `git clone`.
  makeWrapperArgs = [
    "--prefix"
    "PATH"
    ":"
    (pkgs.lib.makeBinPath [ pkgs.git ])
  ];

  pythonImportsCheck = [
    "semble"
    "semble.mcp"
  ];

  doCheck = false;

  meta = with pkgs.lib; {
    description = "Instant code search for any local or remote git repository";
    homepage = "https://github.com/MinishLab/semble";
    license = licenses.mit;
  };
}
