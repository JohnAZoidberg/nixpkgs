{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.nodebb;

  mongoconf = {
    url = "http://localhost:4567";
    secret = "kljxdff98y23lknsefk8";
    database = "mongo";
    port = 4567;
    mongo = {
      host = "127.0.0.1";
      port = 27017;
      database= "nodebb";
    };
    type = "literal";
  };

  basePath = "/home/nodebb/files";

in {
  ###### interface

  options = {
    services.nodebb = {
      enable = mkEnableOption "nodebb";
    };
  };

  config = mkIf cfg.enable {
    services.mongodb.enable = true;

    users.extraUsers = [{
      name = "nodebb";
      group = "nodebb";
      home = "/home/nodebb";
      #shell = "${pkgs.bash}/bin/bash";
      #uid = config.ids.uids.gitlab;
    }];

    users.extraGroups = [{
      name = "nodebb";
      #gid = config.ids.gids.gitlab;
    }];

    systemd.services.nodebb = {
      #enable = true;
      description = "Service which runs NodeBB";
      after = [ "system.slice" "multi-user.target" "mongod.service" ];
      wantedBy = [ "multi-user.target" ];
      path = with pkgs; [ nodejs ];
      preStart = ''
        mkdir -p ${basePath}

        cp -r ${pkgs.nodebb} ${basePath}

        pushd ${basePath}

        npm install

        ./nodebb setup --config ${pkgs.writeText "fuck_this_shit" (builtins.toJSON mongoconf)}
      '';

      serviceConfig = {
        PermissionsStartOnly = true; # preStart must be run as root
        Description = "NodeBB";

        #Type = "simple";
        User = "nodebb";
        Group = "nodebb";

        WorkingDirectory = basePath;
        ExecStart = "${pkgs.nodejs}/bin/node loader.js --no-silent --no-daemon";
        #Restart = "always";
      };
    };

    #networking.firewall.allowedTCPPorts = if cfg.openFirewall then singleton cfg.listenPort else [];
  };
}
