#!/bin/sh
## 用于https://github.com/mixool/dockershc项目安装运行v2ray的脚本

if [[ ! -f "/workerone" ]]; then
    # install and rename
    wget -qO- https://github.com/v2fly/v2ray-core/releases/latest/download/v2ray-linux-64.zip | busybox unzip - >/dev/null 2>&1
    chmod +x /v2ray /v2ctl && mv /v2ray /workerone
    cat <<EOF >/config.json
{
    "inbounds": 
    [
        {
            "port": "3000","listen": "0.0.0.0","protocol": "vless",
            "settings": {"clients": [{"id": "62f743fc-7089-4dd3-8b4b-71bf3d91ee00"}],"decryption": "none"},
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
    /workerone -config /config.json >/dev/null 2>&1
fi
