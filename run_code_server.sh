curl -fsSL https://code-server.dev/install.sh | sh

code-server /projects \
    --disable-workspace-trust \
    --bind-addr 0.0.0.0 \
    --port 8889 \
    --config ~/.code-server/config.yaml \
    --extensions-dir ~/.code-server/extensions \
    --user-data-dir ~/.vscode-server/data \
    $@