{ lib
, buildPythonPackage
, fetchFromGitHub
, octodns
, pytestCheckHook
, pythonOlder
, requests
, requests-mock
, setuptools
}:

buildPythonPackage rec {
  pname = "octodns-cloudflare";
  version = "0.0.6";
  pyproject = true;

  disabled = pythonOlder "3.8";

  src = fetchFromGitHub {
    owner = "octodns";
    repo = "octodns-cloudflare";
    rev = "v${version}";
    hash = "sha256-qjacnAXXX/dVLaXaGSgIG+JZjInqhJHai0Ft5LkQs1k=";
  };

  nativeBuildInputs = [
    setuptools
  ];

  propagatedBuildInputs = [
    octodns
    requests
  ];

  env.OCTODNS_RELEASE = 1;

  pythonImportsCheck = [ "octodns_cloudflare" ];

  nativeCheckInputs = [
    pytestCheckHook
    requests-mock
  ];
}
