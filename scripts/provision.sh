#!/bin/bash

set -uex

sudo apt update
sudo apt install -y wget git

mkdir -p ~/.local/bin
test -f ~/.local/bin/ubpkg || wget https://github.com/alexpdp7/ubpkg/releases/latest/download/ubpkg-linux-x86_64 -O ~/.local/bin/ubpkg
chmod +x ~/.local/bin/ubpkg
~/.local/bin/ubpkg bitwarden-cli

mkdir -p ~/.ssh

test -f ~/.ssh/id_ed25519 || {
    test -f "/home/alex/.config/Bitwarden CLI/data.json" || {
        ~/.local/bin/bw config server https://vault.bitwarden.eu
        ~/.local/bin/bw login alex.corcoles@veecle.io
    }
    python3 <(cat <<EOF)
import json, subprocess, pathlib
s = json.loads(subprocess.run(["/home/alex/.local/bin/bw", "list", "items", "--search", "ssh key"], check=True, stdout=subprocess.PIPE).stdout)
(pathlib.Path.home() / ".ssh/id_ed25519").write_text(s[0]["sshKey"]["privateKey"])
(pathlib.Path.home() / ".ssh/id_ed25519.pub").write_text(s[0]["sshKey"]["publicKey"])
EOF
}

chmod 400 ~/.ssh/id_ed25519

cat >~/.ssh/known_hosts <<EOF
|1|FFgTSfNtL5iS4jWP7ksbPkBbJ/k=|nkZEXGoxz4FRcNg03y1dLN56/4o= ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl
|1|ea7sUBp2+00F38+EQp0S6UMIQS0=|YniveecnuZ2SE+mKct9cYDUtirQ= ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCj7ndNxQowgcQnjshcLrqPEiiphnt+VTTvDP6mHBL9j1aNUkY4Ue1gvwnGLVlOhGeYrnZaMgRK6+PKCUXaDbC7qtbW8gIkhL7aGCsOr/C56SJMy/BCZfxd1nWzAOxSDPgVsmerOBYfNqltV9/hWCqBywINIR+5dIg6JTJ72pcEpEjcYgXkE2YEFXV1JHnsKgbLWNlhScqb2UmyRkQyytRLtL+38TGxkxCflmO+5Z8CSSNY7GidjMIZ7Q4zMjA2n1nGrlTDkzwDCsw+wqFPGQA179cnfGWOWRVruj16z6XyvxvjJwbz0wQZ75XK5tKSb7FNyeIEs4TT4jk+S4dhPeAUC5y+bDYirYgM4GC7uEnztnZyaVWQ7B381AK4Qdrwt51ZqExKbQpTUNn+EjqoTwvqNj4kqx5QUCI0ThS/YkOxJCXmPUWZbhjpCg56i+2aB6CmK2JGhn57K5mj0MNdBXA4/WnwH6XoPWJzK5Nyu2zB3nAZp+S5hpQs+p1vN1/wsjk=
|1|xdgO84qUOfrpTgXC+BlcNsyBc+0=|hNVNvQ8TfF37Bag0kByllZf2bbk= ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBEmKSENjQEezOmxkZMy7opKgwFB9nkt5YRrYMjNuG5N87uRgg6CLrbo5wAdT/y6v0mKV0U2w0WZ2YB/++Tpockg=
EOF

mkdir -p ~/git
cd ~/git
git clone git@github.com:veecle/alexveecle.git
cd alexveecle/provision
./provision
