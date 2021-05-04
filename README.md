# Drone Nomad runner

This Drone runner will place a Nomad job for each pipeline step, through the [drone-runner-docker](https://github.com/drone-runners/drone-runner-docker).

The Nomad client on which the allocation would be placed should have the following attributes to avoid being filtered by the constraints that this runner sets:

- `cpu.arch = "amd64"`
- `kernel.name = "linux"`

## ⚠  WARNING ⚠

I changed the Nomad driver from Docker to Podman, since I am using a Nomad deployment which uses that runtime instead. That being said, if you haven't got in your cluster any Nomad client which uses the [nomad-driver-podman](https://github.com/hashicorp/nomad-driver-podman) plugin, the Jobs scheduled by drone will stay pending.

I created this fork for my **personal** needs, therefore I am not willing to give support on it, especially because it's a corner use-case for this Drone runner.

## Usage

To use this runner, simply define and run a Nomad Job that contains a "Drone runner" task which uses the container image [drone-runner-nomad-podman](https://hub.docker.com/repository/docker/procsiab/drone-runner-nomad-podman), like the following:

```hcl
task "drone-runner" {
    driver = "podman"
    env {
        # Connection parameters
        DRONE_RPC_PROTO="http"
        DRONE_RPC_HOST="${NOMAD_ADDR_server}"
        DRONE_RPC_SECRET="123456789abcdefgh"
        # Nomad config
        DRONE_JOB_DATACENTER="dc1"
        NOMAD_ADDR="http://127.0.0.1:4646"
        # Runner agent settings
        DRONE_RUNNER_CAPACITY="1"
        DRONE_RUNNER_MAX_PROCS="3"
        DRONE_RUNNER_NAME="podman-runner1"
        # Logging
        DRONE_DEBUG="true"
        DRONE_TRACE="true"
        DRONE_RPC_DUMP_HTTP="true"
        DRONE_RPC_DUMP_HTTP_BODY="true"
    }
    config {
        image = "docker.io/procsiab/drone-runner-nomad-podman:0.1-linux-amd64"
        volumes = [
            "/run/user/{{common_nomad_uid}}/podman/podman.sock:/var/run/podman.sock"
        ]
        network_mode = "slirp4netns"
        ports = ["runner"]
    }
    resources {
        cpu    = 480
        memory = 200
    }
}
```

### Notes

The notable *workaround* to make the `drone-runner-docker` run under Nomad through the Podman driver, is to mount the Podman socket as the Docker socket inside the runner's container.

Also, it is necessary to change the environment variables `DRONE_JOB_DATACENTER` and `NOMAD_ADDR`, if the Nomad cluster is declared with a different datacenter and the Nomad client service is listening on an interface different that localhost (the values in the code snippet above are the default).

The environment variables under the comment "Logging" can be commented out, as they are only useful to investigate and share an issue.

Finally, as I'm using a rootless environment with Podman, I'm using the `slirp4netns` network driver, which is also different to manage rather than `bridge` or `host` network modes.
