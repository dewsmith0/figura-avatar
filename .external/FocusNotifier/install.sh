#!/bin/bash

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )";

cd $SCRIPT_DIR/helpers/bashscripts;
install -D -t "$HOME/.local/bin/" FocusNotifierListener.sh;
install -D -t "$HOME/.local/bin/" activewindow;

cd $SCRIPT_DIR/helpers/services
install -D -t "$HOME/.config/systemd/user/" scot.massie.FocusNotifier.listener.service;

# Enable and start the service, or restart it if it's already running

servicename="scot.massie.FocusNotifier.listener.service"

systemctl --user restart "$servicename";
systemctl --user enable --now "$servicename";

notify-send -t 5000 -a "FocusNotifier" "Installed!"
