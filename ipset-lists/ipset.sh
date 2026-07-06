#!/usr/bin/env bash
set -o errexit -o pipefail -o nounset
shopt -s inherit_errexit

mkdir -p /var/lib/ipsets

download() {
    family="$1"
    name="$2"
    url="$3"

    filename="/var/lib/ipsets/${name}.netset"
    if systemctl is-active --quiet network-online.target; then
        wget --timestamping --quiet "--output-document=${filename}" "${url}"
    else
        if [ -f "$filename" ]; then
            echo "No internet, use existing ipset" >&2
        else
            echo "No internet, create empty ipset" >&2
            touch --date="@0" "$filename"
        fi
    fi

    ipset restore < <(
        echo "destroy -! tmp"
        length=$(wc -l < "${filename}")
        echo "create tmp hash:net family ${family} hashsize ${length} maxelem ${length}"
        sed -n -e "s/^\([^;#]\+\).*/add tmp \1/p" "${filename}"
    )
    if ipset list -name "${name}" >/dev/null 2>&1; then
        ipset swap tmp "${name}"
        ipset destroy tmp
    else
        ipset rename tmp "${name}"
    fi
}

download "inet" "firehol_level1" "https://iplists.firehol.org/files/firehol_level1.netset"
download "inet" "firehol_level2" "https://iplists.firehol.org/files/firehol_level2.netset"
download "inet" "firehol_level3" "https://iplists.firehol.org/files/firehol_level3.netset"
download "inet" "firehol_level4" "https://iplists.firehol.org/files/firehol_level4.netset"
download "inet6" "dropv6" "https://www.spamhaus.org/drop/dropv6.txt"
