#!/bin/bash

echo "post-install: Starting diskmonitor."
supervisorctl start diskmonitor

echo "post-install: Nothing left to do."

