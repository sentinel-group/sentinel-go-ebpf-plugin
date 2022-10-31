# The development version of clang is distributed as the 'clang' binary,
# while stable/released versions have a version number attached.
# Pin the default clang to a stable version.
CLANG ?= clang-14
STRIP ?= llvm-strip-14
OBJCOPY ?= llvm-objcopy-14
CFLAGS := -O2 -g -Wall -Werror $(CFLAGS)

# Obtain an absolute path to the directory of the Makefile.
# Assume the Makefile is in the root of the repository.
REPODIR := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
UIDGID := $(shell stat -c '%u:%g' ${REPODIR})

# Prefer podman if installed, otherwise use docker.
# Note: Setting the var at runtime will always override.
CONTAINER_ENGINE ?= $(if $(shell command -v podman), podman, docker)
CONTAINER_RUN_ARGS ?= $(if $(filter ${CONTAINER_ENGINE}, podman), --log-driver=none, --user "${UIDGID}")

IMAGE := $(shell cat ${REPODIR}/testdata/docker/IMAGE)
VERSION := $(shell cat ${REPODIR}/testdata/docker/VERSION)

clean:
	-$(RM) testdata/*.elf
	-$(RM) btf/testdata/*.elf

format:
	find . -type f -name "*.c" | xargs clang-format -i

# $BPF_CLANG is used in go:generate invocations.
generate: export BPF_CLANG := $(CLANG)
generate: export BPF_CFLAGS := $(CFLAGS)
generate:
	go generate ./...

%-el.elf: %.c
	$(CLANG) $(CFLAGS) -target bpfel -c $< -o $@
	$(STRIP) -g $@

%-eb.elf : %.c
	$(CLANG) $(CFLAGS) -target bpfeb -c $< -o $@
	$(STRIP) -g $@