#!/bin/sh

R -e 'largescalechunks::locator_node("localhost", 9000L)' &

for i in `seq 1 22`; do
	command=`printf 'largescalechunks::worker_node("localhost", %dL, "localhost", 9000L)' $(($i + 9000))`
	R -e "$command" &
done
