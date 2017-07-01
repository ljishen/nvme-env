# SPDK (Storage Performance Development Kit) Docker Image

[![](https://images.microbadger.com/badges/image/ljishen/spdk.svg)](http://microbadger.com/images/ljishen/spdk)

Simple image built following the official [SPDK Documentation](https://github.com/spdk/spdk).

## Usage

```bash
docker run -ti \
        --privileged \
        -v /lib/modules:/lib/modules
        ljishen/spdk
```
