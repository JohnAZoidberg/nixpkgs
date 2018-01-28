{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.nodebb;

in {
  ###### interface

  options = {
    services.nodebb = {
      enable = mkEnableOption "nodebb";

      host = mkOption {
        type = types.str;
        example = "nodebb.example.com";
        description = ''
          Hostname under which this nodebb instance can be reached.
        '';
      };

      openFirewall = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to automatically open the specified ports in the firewall.
        '';
      };

      listenAddress = mkOption {
        type = types.str;
        default = "localhost";
        description = ''
          Address or hostname nodebb should listen on.
        '';
      };

      listenPort = mkOption {
        type = types.int;
        default = 3000;
        description = ''
          Port nodebb should listen on.
        '';
      };

      user = mkOption {
        type = types.str;
        default = "nodebb";
        description = ''
          User to run nodebb.
        '';
      };

      group = mkOption {
        type = types.str;
        default = "nodebb";
        description = ''
          Group to run nodebb.
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    #environment.systemPackages = [ nodebb ];

    users.extraUsers = [{
      name = cfg.user;
      group = cfg.group;
    }];

    users.extraGroups = [{
      name = cfg.group;
    }];

    systemd.services.nodebb = {
      description = "Service which runs NodeBB";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        #PermissionsStartOnly = true;
        #PrivateTmp = true;
        #PrivateDevices = true;
        #Type = "simple";
        User = cfg.user;
        Group = cfg.group;
        #TimeoutSec = "300s";
        #Restart = "on-failure";
        #RestartSec = "10s";
        #WorkingDirectory = "${package}/share/frab";
        ExecStart = "${pkgs.nodebb}/start";
      };
    };

    networking.firewall.allowedTCPPorts = if cfg.openFirewall then singleton cfg.virtualHost.listenPort else [];

    services.nginx = {
      enable = cfg.virtualHost.enable;
      disableSymlinks = "off";

      virtualHosts.nodebb = {
        listen = [ {
          serverName = cfg.listenHost;
          port = cfg.listenPort;
        } ];
        default = true;
        locations = {
          "/" = {
            autoIndex = true;
          };
        };
        #serverName = cfg.virtualHost.serverName;
        root = "/srv/aptly"; #"${cfg.dataDir}/public";
      };
    };
  };
}
