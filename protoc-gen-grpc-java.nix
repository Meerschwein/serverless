{
  stdenv,
  fetchurl,
  autoPatchelfHook,
  system,
}: let
  system-data =
    if system == "x86_64-linux"
    then {
      suffix = "linux-x86_64.exe";
      sha256 = "sha256-XS044olE1UujIVr1HJZwq8fqHTR3xYhOojfG8q35AhA=";
    }
    else if system == "aarch64-linux"
    then {
      suffix = "linux-aarch_64.exe";
      sha256 = "sha256-eBiJht34kMuhOgvL6qfMhhcZvLW3wGgpZgVV7vmQLZY=";
    }
    else throw ("Invalid system system: " + system);
in
  stdenv.mkDerivation
  rec {
    pname = "protoc-gen-grpc-java";
    version = "1.47.0";

    filename = "${pname}-${version}-${system-data.suffix}";

    src = fetchurl {
      url = "https://repo1.maven.org/maven2/io/grpc/${pname}/${version}/${filename}";
      inherit (system-data) sha256;
    };

    nativeBuildInputs = [
      autoPatchelfHook
    ];

    dontUnpack = true;

    installPhase = ''
      mkdir -p $out/bin
      install -m755 -D ${src} $out/bin/protoc-gen-grpc
    '';
  }
