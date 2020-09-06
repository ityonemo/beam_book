#!/bin/sh

zig build-exe zim.zig
zig build-exe examine.zig

cd erlang
erlc example1.erl

