#!/bin/bash

# Cluster Detection Script
# Detects whether we are running on JUNO or IRIS cluster
# Sets CLUSTER environment variable for use by other scripts
#
# Usage: source getClusterName.sh [-q]
#        -q : quiet mode, don't echo cluster name

# Try environment variable first, fallback to network detection
CDC_JOINED_ZONE=${CDC_JOINED_ZONE:-"UNKNOWN"}

if [ "$CDC_JOINED_ZONE" == "UNKNOWN" ]; then
    # Network-based detection using subnet analysis
    # JUNO cluster uses 10.0.x.x subnet on bondpriv interface
    SUBNET=$(ifconfig | fgrep -C 1 bondpriv | fgrep inet | awk '{print $2}' | cut -f-2 -d.)

    if [ "$SUBNET" == "10.0" ]; then
        CLUSTER=JUNO
    elif [ "$SUBNET" == "10.1" ]; then
        # Add IRIS subnet detection if different
        CLUSTER=IRIS
    else
        # Unknown network - could add hostname-based fallback here
        CLUSTER="UNKNOWN"
    fi
else
    # Environment variable-based detection
    # Parse CDC_JOINED_ZONE for cluster name (format: CN=clustername)
    ZONE=$(echo $CDC_JOINED_ZONE | tr ',' '\n' | fgrep CN= | fgrep -iv zone | head -1)

    if [ "$ZONE" != "" ]; then
        CLUSTER=$(echo $ZONE | cut -f2 -d=)
    else
        CLUSTER="UNKNOWN"
    fi
fi

# Export for use by sourcing scripts
export CLUSTER

# Print cluster name unless quiet mode requested
if [ "$1" != "-q" ]; then
    echo $CLUSTER
fi
