#!/bin/sh
erlc worker.erl && erl -noshell -s worker run
