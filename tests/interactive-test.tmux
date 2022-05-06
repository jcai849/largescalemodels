split-window ssh hadoop1 R --interactive
select-layout tiled
send-keys 'largerscale::locator("hadoop1", 9000L, verbose=T)' Enter
split-window ssh hadoop1 R --interactive
send-keys 'largerscale::worker("hadoop1", 9001L, "hadoop1", 9000L, verbose=T)' Enter
split-window ssh hadoop2 R --interactive
select-layout tiled
send-keys 'largerscale::worker("hadoop2", 9001L, "hadoop1", 9000L, verbose=T)' Enter
split-window ssh hadoop3 R --interactive
select-layout tiled
send-keys 'largerscale::worker("hadoop3", 9001L, "hadoop1", 9000L, verbose=T)' Enter
split-window ssh hadoop4 R --interactive
select-layout tiled
send-keys 'largerscale::worker("hadoop4", 9001L, "hadoop1", 9000L, verbose=T)' Enter
split-window ssh hadoop5 R --interactive
select-layout tiled
send-keys 'largerscale::worker("hadoop5", 9001L, "hadoop1", 9000L, verbose=T)' Enter
split-window ssh hadoop6 R --interactive
select-layout tiled
send-keys 'largerscale::worker("hadoop6", 9001L, "hadoop1", 9000L, verbose=T)' Enter
split-window ssh hadoop7 R --interactive
select-layout tiled
send-keys 'largerscale::worker("hadoop7", 9001L, "hadoop1", 9000L, verbose=T)' Enter
split-window ssh hadoop8 R --interactive
select-layout tiled
send-keys 'largerscale::worker("hadoop8", 9001L, "hadoop1", 9000L, verbose=T)' Enter
run-shell 'sleep 2'
select-pane -t0; send-keys 'R' Enter 'source("taxi.R", echo=T)' Enter
