#!/bin/sh
set -eu
cd "$(dirname "$0")/.."
sh -n create.sh
# Reject invalid input before creating any output or invoking block tools.
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT HUP INT TERM
printf kernel > "$tmp/kernel"
printf invalid > "$tmp/root"
mkdir "$tmp/out" "$tmp/bin"
# Exercise validation even in unprivileged CI; invalid input must stop before
# any privileged operation. Only the id check is replaced.
printf '#!/bin/sh\nprintf "0\\n"\n' > "$tmp/bin/id"
chmod +x "$tmp/bin/id"
PATH="$tmp/bin:$PATH"
export PATH
if sh ./create.sh "$tmp/kernel" "$tmp/root" "$tmp/out" 2>/dev/null; then
    echo 'invalid squashfs was accepted' >&2
    exit 1
fi
[ -z "$(ls -A "$tmp/out")" ]
echo 'syntax and invalid-input rejection OK'
