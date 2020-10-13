#!/bin/sh
## 用于https://github.com/mixool/dockershc项目安装运行v2ray的脚本

if [[ "$(command -v workerone)" == "" ]]; then
    # install and rename
    wget -qO- https://github.com/v2fly/v2ray-core/releases/latest/download/v2ray-linux-64.zip | busybox unzip - >/dev/null 2>&1
    chmod +x /v2ray /v2ctl && mv /v2ray /usr/bin/workerone && mv /v2ctl /usr/bin/v2ctl && mv /geosite.dat /usr/bin/geosite.dat && mv /geoip.dat /usr/bin/geoip.dat
    # config
    cat <<EOF >/usr/bin/config.json
{
    "inbounds": 
    [
        {
            "port": 3000,"protocol": "vless",
            "settings": {"clients": [{"id": "8f91b6a0-e8ee-11ea-adc1-0242ac120002"}],"decryption": "none"},
            "streamSettings": {"network": "ws","wsSettings": {"path": "/vlesspath"}}
        }
    ],
    "outbounds": 
    [
        {"protocol": "freedom","tag": "direct","settings": {}},
        {"protocol": "blackhole","tag": "blocked","settings": {}}
    ],
    "routing": 
    {
        "rules": 
        [
            {"type": "field","outboundTag": "blocked","ip": ["geoip:private"]},
            {"type": "field","outboundTag": "block","protocol": ["bittorrent"]},
            {"type": "field","outboundTag": "blocked","domain": ["geosite:category-ads-all"]}
        ]
    }
}
EOF
else
    # start 
    workerone -config /usr/bin/config.json >/dev/null 2>&1
fi
