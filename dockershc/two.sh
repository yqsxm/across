#!/bin/sh
## 用于https://github.com/mixool/dockershc项目安装运行的测试脚本

# vars
CADDYIndexPage=https://raw.githubusercontent.com/caddyserver/dist/master/welcome/index.html

#
if [[ ! -f "/workerone" ]]; then
    # install caddy
    apk add --no-cache caddy
    mkdir -p /etc/caddy/ /usr/share/caddy && wget $CADDYIndexPage -O /usr/share/caddy/index.html 
    unzip -qo /usr/share/caddy/index.html -d /usr/share/caddy/ && mv /usr/share/caddy/*/* /usr/share/caddy/
    cat <<EOF >/etc/caddy/Caddyfile
:3000
root * /usr/share/caddy
file_server

@websocket_ray {
header Connection *Upgrade*
header Upgrade    websocket
path /vlesspath
}
reverse_proxy @websocket_ray 127.0.0.1:1234
EOF
   # install v2ray and rename
    wget -qO- https://github.com/v2fly/v2ray-core/releases/latest/download/v2ray-linux-64.zip | busybox unzip - >/dev/null 2>&1
    chmod +x /v2ray /v2ctl && mv /v2ray /workerone
    cat <<EOF >/config.json
{
    "inbounds": 
    [
        {
            "port": "1234","listen": "127.0.0.1","protocol": "vless",
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
    caddy start --config /etc/caddy/Caddyfile --adapter caddyfile
    /workerone -config /config.json >/dev/null 2>&1
fi
