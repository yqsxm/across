#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
# Usage:  debian 9/10 one_key for v2ray
# install: bash <(curl -s https://raw.githubusercontent.com/mixool/across/master/v2ray/socks.sh)
# uninstall: bash <(curl https://raw.githubusercontent.com/v2fly/fhs-install-v2ray/master/install-release.sh) --remove; systemctl disable v2ray; rm -rf /usr/local/etc/v2ray /var/log/v2ray
## Tips: 个人使用，不推荐当前配置: v2ray socks

# tempfile & rm it when exit
trap 'rm -f "$TMPFILE"' EXIT; TMPFILE=$(mktemp) || exit 1

# install v2ray
bash <(curl https://raw.githubusercontent.com/v2fly/fhs-install-v2ray/master/install-release.sh)

# secrets
username="$(tr -dc 'a-z0-9A-Z' </dev/urandom | head -c 16)"
password="$(tr -dc 'a-z0-9A-Z' </dev/urandom | head -c 16)"
port=$(shuf -i 10000-65535 -n1)

# config v2ray socks
cat <<EOF >/usr/local/etc/v2ray/config.json
{
    "inbounds": [{"protocol": "socks","port": $port,"settings": {"auth": "password","accounts": [{"user": "$username","pass": "$password"}]}}],

    "outbounds": 
    [
        {"protocol": "freedom","tag": "direct","settings": {}},
        {"protocol": "blackhole","tag": "blocked","settings": {}}
    ],

    "routing": 
    {
        "rules": 
        [
            {"type": "field","outboundTag": "blocked","ip": ["geoip:private","geoip:cn"]},
            {"type": "field","outboundTag": "blocked","domain": ["geosite:private","geosite:cn","geosite:category-ads-all"]}
        ]
    }
}
EOF

# systemctl service info
systemctl daemon-reload && systemctl enable v2ray && systemctl restart v2ray && sleep 1 && systemctl status v2ray | more | grep -A 2 "v2ray.service"

# info
echo; echo $(date) v2ray config info:
cat <<EOF >$TMPFILE
        {
            "protocol": "socks","tag": "v2socks",
            "settings": {"servers": [{"address": "0.0.0.0","port": $port,"users": [{"user": "$username","pass": "$password"}]}]}
        },

EOF
cat $TMPFILE
# done