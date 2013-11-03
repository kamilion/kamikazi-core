#!/bin/bash

echo "post-install: Starting diskmonitor."
supervisorctl start zurfa-diskmonitor

echo "post-install: Starting diskworker."
supervisorctl start zurfa-diskworker

echo "post-install: Nothing left to do."

