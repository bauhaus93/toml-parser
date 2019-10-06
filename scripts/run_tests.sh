#!/bin/sh

cd build && \
make -j8 && \
./toml_parser < ../tests/test.toml
