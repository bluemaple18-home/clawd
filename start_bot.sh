#!/bin/bash
cd "$(dirname "$0")"
echo "Starting Clawdbot..."
npm start -- gateway --allow-unconfigured
