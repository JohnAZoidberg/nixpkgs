{
  # From https://hydra.nixos.org/eval/1648761?filter=riscv&compare=1648406&full=#tabs-still-succeed
  busybox = import <nix/fetchurl.nix> {
    url = "http://danielschaefer.me/static/ijq5gc6rd8r3wsvjj6pzmpwhcvb4a2mg-busybox";
    sha256 = "0imxx0m1z3qfwaja22q4vir1011lmchmpi6kfg5kab07dyndvcq3";
    executable = true;
  };
  bootstrapTools = import <nix/fetchurl.nix> {
    url = "http://danielschaefer.me/static/gjc1fkcx8pl633cq070gdg938rdfnh1c-bootstrap-tools.tar.xz";
    sha256 = "0y0f6cbx300pyapj4lfyf1fj7bwyypvcdirys9myspklw79x6vcz";
  };
}
