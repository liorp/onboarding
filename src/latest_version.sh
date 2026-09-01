#!/bin/bash

set -euo pipefail

awk '/^v[0-9]+\.[0-9]+\.[0-9]+$/' | sort -V | tail -n 1
