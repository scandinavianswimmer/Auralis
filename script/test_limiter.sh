#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p build/limiter-regression
swiftc Sources/Vorssaint/Services/Audio/BoostLimiter.swift Tools/LimiterRecoveryRegression.swift -o build/limiter-regression/after
build/limiter-regression/after
