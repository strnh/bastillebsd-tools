#!/bin/sh
# usage: pkgpush.sh pkgname [pkgname ...]
set -u

[ $# -ge 1 ] || { echo "Usage: $0 pkgname [pkgname ...]" >&2; exit 1; }
[ "$(id -u)" -eq 0 ] || { echo "must be root" >&2; exit 1; }

WORK=$(mktemp -d /tmp/pkgpush.XXXXXX) || exit 1
trap 'rm -rf "$WORK"' EXIT INT TERM

HOSTABI=$(pkg config abi)

for PKG in "$@"; do
    if ! pkg info -e "$PKG"; then
        echo "skip: $PKG is not installed on host" >&2
        continue
    fi
    PKGNAME=$(pkg query '%n' "$PKG")
    PKGVER=$(pkg query '%v' "$PKG")

    pkg check -s "$PKGNAME" || { echo "WARN: checksum mismatch on host: $PKGNAME" >&2; }
    pkg create -o "$WORK" "$PKGNAME" || { echo "create failed: $PKGNAME" >&2; continue; }
    PKGFILE="$WORK/$PKGNAME-$PKGVER.pkg"
    [ -f "$PKGFILE" ] || { echo "not found: $PKGFILE" >&2; continue; }
    BASE=${PKGFILE##*/}

    jls name path | while read -r J JPATH; do
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
done
