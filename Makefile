PWD := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

all: workspace

# TEMPLATES

workspace:
	docker build -t="$@" .


# CONTAINERS

workspace-container:
	docker stop $@ || true
	docker rm $@ || true
	ssh-keygen -f "${HOME}/.ssh/known_hosts" -R [localhost]:4028
	docker run -i -t -d \
	  -e DISPLAY=${DISPLAY} \
	  -e XAUTHORITY=/tmp/.docker.xauth \
	  -v ${PWD}opt:/opt \
	  -v /tmp/.X11-unix:/tmp/.X11-unix \
	  -p 4028:22 \
	  --name $@ \
	  workspace
