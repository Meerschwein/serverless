let
  pkgs = import <nixpkgs> {system = "x86_64-linux";};
in
  pkgs.mkShell {
    buildInputs = with pkgs; [
      (google-cloud-sdk.withExtraComponents [google-cloud-sdk.components.gke-gcloud-auth-plugin])
      (pkgs.callPackage ./protoc-gen-grpc-java.nix {})
      (python3.withPackages (ps: with ps; [pyyaml]))
      jdk8
      kubectl
      protobuf
    ];
  }
