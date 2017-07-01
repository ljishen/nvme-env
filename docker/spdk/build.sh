#!/usr/bin/env bash

set -e

./configure && \
	make && \
	scripts/setup.sh && \
	/bin/bash
