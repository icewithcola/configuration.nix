{
  config,
  lib,
  pkgs,
  ...
}:
let
  sampleEntity = "sensor.openwrt_wan_sample";
  attribute = name: "state_attr('${sampleEntity}', '${name}')";
  available = name: ''
    {{ is_state('${sampleEntity}', 'online')
       and (as_timestamp(now()) - (${attribute "sample_time"} | float(0))) < 60
       and ${attribute name} is number }}
  '';
  rateSensor = direction: {
    name = "OpenWrt ${direction}";
    unique_id = "openwrt_192_168_114_1_${lib.toLower direction}_mbps";
    unit_of_measurement = "Mbit/s";
    device_class = "data_rate";
    state_class = "measurement";
    availability = available "${lib.toLower direction}_mbps";
    state = "{{ ${attribute "${lib.toLower direction}_mbps"} }}";
  };
  counterSensor = direction: {
    name = "OpenWrt ${direction} Bytes";
    unique_id = "openwrt_192_168_114_1_${lib.toLower direction}_bytes";
    unit_of_measurement = "B";
    device_class = "data_size";
    state_class = "total_increasing";
    availability = available "${lib.toLower direction}_bytes";
    state = "{{ ${attribute "${lib.toLower direction}_bytes"} }}";
  };
  trafficCommand = pkgs.writeShellApplication {
    name = "openwrt-traffic";
    runtimeInputs = [ pkgs.python3 ];
    text = ''
      exec python3 ${./openwrt-traffic.py} \
        --credentials ${lib.escapeShellArg config.age.secrets.openwrt-monitor.path} \
        --certificate ${./openwrt-router.pem}
    '';
  };
in
{
  # Only rin's existing agenix key can decrypt this RPC-only password.
  age.secrets.openwrt-monitor = {
    file = ../../../../secrets/openwrt-monitor.age;
    owner = "hass";
    group = "hass";
    mode = "0400";
  };

  services.home-assistant = {
    extraComponents = [
      "command_line"
      "template"
    ];
    config.homeassistant.packages.openwrt_traffic = {
      command_line = [
        {
          sensor = {
            name = "OpenWrt WAN Sample";
            unique_id = "openwrt_192_168_114_1_wan_sample";
            command = lib.getExe trafficCommand;
            scan_interval = 15;
            command_timeout = 20;
            value_template = "{{ value_json.status }}";
            json_attributes = [
              "device"
              "sample_time"
              "download_bytes"
              "upload_bytes"
              "download_mbps"
              "upload_mbps"
            ];
          };
        }
      ];
      template = [
        {
          sensor =
            (map rateSensor [
              "Download"
              "Upload"
            ])
            ++ (map counterSensor [
              "Download"
              "Upload"
            ]);
        }
      ];
      utility_meter = lib.listToAttrs (
        lib.concatMap
          (
            cycle:
            map
              (direction: {
                name = "openwrt_${cycle}_${direction}";
                value = {
                  source = "sensor.openwrt_${direction}_bytes";
                  inherit cycle;
                  unique_id = "openwrt_${cycle}_${direction}";
                };
              })
              [
                "download"
                "upload"
              ]
          )
          [
            "daily"
            "monthly"
          ]
      );
    };
  };
}
