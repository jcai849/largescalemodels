#! /bin/sh

tmux new-session \; source-file interactive-test-"${1}".tmux
