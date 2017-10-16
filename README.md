# hubzero-workspace-testenv
An environment for testing the programs that make up the hubzero workspace

# Building the environment

The Makefile's ```all``` target can be used to build the docker container
template named ```workspace```, which is the base image that can be used for
developing and testing the programs that make up the workspace.

```
make all
```

# Accessing the environment

Users can ssh into the enviornment by using one of three accounts:
| Username |  Password |
|:--------:|:---------:|
| root     | root      |
| apps     | apps      |
| guest    | guest     |

Most of the time, you probably want to use the ```guest``` account. It is an
unpriviledged user that tries to replicate the environment of a application
user.

```
make workspace-container
ssh -p 4028 guest@localhost
```

# Running commands in the environment

When using the ```docker run``` command to launch the container, commands are
run as the ```guest``` user. The SESSION environment variable is hard coded to
19151 and SESSIONDIR and RESULTSDIR directories are created. The PATH
environment variable is also set. An X Virtual Frame Buffer is started to run
the command. For more details, see entry.sh in the repository.

Example of running a command:

1. ```echo ${HOME}```
```
docker run -i -t --rm \
    --name invokeapp-test-container \
    workspace \
    echo \${HOME}
```

2. Running invokeapp tests cases
```
docker run -i -t --rm \
    -v `pwd`:/opt/invokeapp \
    --name invokeapp-test-container \
    workspace \
    /usr/local/bin/pytest -s /opt/invokeapp/test_container_invokeapp.py
```
