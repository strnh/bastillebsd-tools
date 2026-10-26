#!/bin/sh
# usage: pkgpush.sh pkgname [jailname]
#   jailname 省略時は稼働中の全 jail が対象
set -u

usage() { echo "Usage: $0 pkgname [jailname]" >&2; exit 1; }
[ $# -ge 1 ] && [ $# -le 2 ] || usage
[ "$(id -u)" -eq 0 ] || { echo "must be root" >&2; exit 1; }

PKG=$1
TARGET=${2:-}

# 対象 jail リストの決定
if [ -n "$TARGET" ]; then
    JLIST=$(jls -j "$TARGET" name path 2>/dev/null)
    if [ -z "$JLIST" ]; then
        echo "jail '$TARGET' not found or not running" >&2
        exit 1
    fi
else
    JLIST=$(jls name path)
    [ -n "$JLIST" ] || { echo "no running jails" >&2; exit 1; }
fi

if ! pkg info -e "$PKG"; then
    echo "$PKG is not installed on host" >&2
    exit 1
fi

WORK=$(mktemp -d /tmp/pkgpush.XXXXXX) || exit 1
trap 'rm -rf "$WORK"' EXIT INT TERM

HOSTABI=$(pkg config abi)
PKGNAME=$(pkg query '%n' "$PKG")
PKGVER=$(pkg query '%v' "$PKG")

pkg check -s "$PKGNAME" || echo "WARN: checksum mismatch on host: $PKGNAME" >&2
pkg create -o "$WORK" "$PKGNAME" || { echo "create failed: $PKGNAME" >&2; exit 1; }
PKGFILE="$WORK/$PKGNAME-$PKGVER.pkg"
[ -f "$PKGFILE" ] || { echo "not found: $PKGFILE" >&2; exit 1; }
BASE=${PKGFILE##*/}

printf '%s\n' "$JLIST" | while read -r J JPATH; do
    if ! pkg -j "$J" info -e "$PKGNAME" </dev/null; then
        echo "skip: $J ($PKGNAME not installed)"
        continue
    fi

    JABI=$(pkg -j "$J" config abi </dev/null)
    if [ "$JABI" != "$HOSTABI" ]; then
        echo "skip: $J ABI mismatch ($JABI != $HOSTABI)"
        continue
    fi

    JVER=$(pkg -j "$J" query '%v' "$PKGNAME" </dev/null)
    case $(pkg version -t "$JVER" "$PKGVER") in
        '<') ;;
        '=') echo "skip: $J already $PKGNAME-$PKGVER"; continue ;;
        '>') echo "skip: $J has newer $PKGNAME-$JVER"; continue ;;
    esac

    echo "==> $J: $PKGNAME $JVER -> $PKGVER"
    cp "$PKGFILE" "$JPATH/tmp/$BASE" || { echo "FAILED copy: $J" >&2; continue; }
    if pkg -j "$J" add "/tmp/$BASE" </dev/null; then
        echo "OK: $J"
    else
        echo "FAILED: $J" >&2
    fi
    rm -f "$JPATH/tmp/$BASE"
done
