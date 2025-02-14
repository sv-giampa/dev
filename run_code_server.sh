curl -fsSL https://code-server.dev/install.sh | sh
code-server /projects \
    --disable-workspace-trust \
    --bind-addr 0.0.0.0 \
    --port 8889 \
    --config ~/.vscode-server/code-server/config.yaml \
    --extensions-dir ~/.vscode-server/code-server/extensions \
    --user-data-dir ~/.vscode-server/data \
    $@