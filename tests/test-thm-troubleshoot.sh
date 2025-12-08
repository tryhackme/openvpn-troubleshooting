#!/bin/bash
# Test script for thm-troubleshoot
# Run on a test VM (Ubuntu) with a valid TryHackMe .ovpn config
#
# Prerequisites:
#   - Place your .ovpn config as: ./test.ovpn
#   - Run from the repo root: sudo ./tests/test-thm-troubleshoot.sh

set -e

SCRIPT="./thm-troubleshoot"
OVPN_FILE="./test.ovpn"
OVPN_MODIFIED="./a-test-modified.ovpn"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

pass() { echo -e "${GREEN}✓ PASS${NC}: $1"; }
fail() { echo -e "${RED}✗ FAIL${NC}: $1"; exit 1; }
skip() { echo -e "${YELLOW}⊘ SKIP${NC}: $1"; }
info() { echo -e "${YELLOW}→${NC} $1"; }

cleanup() {
    info "Cleaning up..."
    sudo killall openvpn 2>/dev/null || true
    sudo iptables -D OUTPUT -p udp --dport 1194 -m length --length 1201: -j DROP 2>/dev/null || true
    rm -f "$OVPN_MODIFIED" /tmp/auth.txt 2>/dev/null || true
    # Restore original if it was backed up
    [ -f "${OVPN_FILE}.bak" ] && mv "${OVPN_FILE}.bak" "$OVPN_FILE" 2>/dev/null || true
}

trap cleanup EXIT

echo "========================================"
echo "  TryHackMe Troubleshoot Script Tests"
echo "========================================"
echo ""

# Check prerequisites
if [ ! -f "$SCRIPT" ]; then
    fail "Script not found: $SCRIPT (run from repo root)"
fi

if [ ! -f "$OVPN_FILE" ]; then
    fail "Test ovpn file not found. Please place your .ovpn config as: $OVPN_FILE"
fi

if [ "$EUID" -ne 0 ]; then
    fail "Please run as root: sudo $0"
fi

# Detect distro
if command -v apt >/dev/null 2>&1; then
    DISTRO="ubuntu"
elif command -v pacman >/dev/null 2>&1; then
    DISTRO="arch"
elif command -v dnf >/dev/null 2>&1; then
    DISTRO="fedora"
else
    DISTRO="unknown"
fi
info "Detected distro: $DISTRO"
echo ""

########################################
# Test 1: Version flag
########################################
echo "--- Test 1: Version flag ---"
VERSION_OUT=$($SCRIPT --version 2>&1)
if echo "$VERSION_OUT" | grep -q "TryHackMe VPN Troubleshoot"; then
    pass "--version outputs version info"
else
    fail "--version did not output expected text"
fi
echo ""

########################################
# Test 2: OpenVPN installation (Ubuntu only)
########################################
echo "--- Test 2: OpenVPN installation ---"
if [[ "$DISTRO" == "ubuntu" ]]; then
    # Remove OpenVPN if installed
    if command -v openvpn >/dev/null 2>&1; then
        info "Removing OpenVPN for install test..."
        apt remove -y openvpn >/dev/null 2>&1
    fi
    
    if command -v openvpn >/dev/null 2>&1; then
        skip "Could not remove OpenVPN for install test"
    else
        info "Running script to test OpenVPN installation..."
        # Answer Y to install, then n to not connect (we just want to test install)
        OUTPUT=$(echo -e "Y\nn" | timeout 60 $SCRIPT 2>&1 || true)
        
        if command -v openvpn >/dev/null 2>&1; then
            pass "OpenVPN was installed successfully"
        else
            fail "OpenVPN was not installed"
            echo "Output: $OUTPUT"
        fi
    fi
else
    skip "OpenVPN install test only runs on Ubuntu (detected: $DISTRO)"
fi
echo ""

########################################
# Test 3: Inline auth-user-pass detection (OpenVPN 2.5)
########################################
echo "--- Test 3: Inline auth-user-pass detection ---"
OVPN_VERSION=$(openvpn --version 2>&1 | head -1 | grep -oP 'OpenVPN \K[0-9]+\.[0-9]+' || echo "unknown")
if [[ "$OVPN_VERSION" == "2.5" ]]; then
    info "OpenVPN $OVPN_VERSION detected - testing inline auth detection"
    cleanup
    
    # Only test if the config has inline auth
    if grep -q "<auth-user-pass>" "$OVPN_FILE"; then
        OUTPUT=$(yes 2>/dev/null | timeout 60 $SCRIPT 2>&1 || true)
        if echo "$OUTPUT" | grep -q "does not support inline authentication"; then
            pass "Detected inline auth-user-pass incompatibility"
        else
            fail "Did not detect inline auth-user-pass issue"
            echo "Output was:"
            echo "$OUTPUT" | head -30
        fi
    else
        skip "Config does not have inline <auth-user-pass> block"
    fi
else
    skip "OpenVPN version is $OVPN_VERSION (need 2.5 to test inline auth detection)"
fi
echo ""

########################################
# Test 4: Successful connection
########################################
echo "--- Test 4: Successful connection ---"
info "Stopping any running OpenVPN..."
killall openvpn 2>/dev/null || true
sleep 2

info "Creating compatible config..."
cp "$OVPN_FILE" "$OVPN_MODIFIED"

# Extract credentials for OpenVPN 2.5 compatibility (if inline auth exists)
if grep -q "<auth-user-pass>" "$OVPN_MODIFIED"; then
    sed -n '/<auth-user-pass>/,/<\/auth-user-pass>/p' "$OVPN_MODIFIED" | grep -v "auth-user-pass" > /tmp/auth.txt
    chmod 600 /tmp/auth.txt
    sed -i '/<auth-user-pass>/,/<\/auth-user-pass>/d' "$OVPN_MODIFIED"
    sed -i 's|^auth-user-pass$|auth-user-pass /tmp/auth.txt|' "$OVPN_MODIFIED"
fi

# Remove any previous MTU settings
sed -i '/^# Added by the thm-troubleshoot/,/^tun-mtu/d' "$OVPN_MODIFIED" 2>/dev/null || true

# Hide original so script finds our modified config
mv "$OVPN_FILE" "${OVPN_FILE}.bak"

info "Running script (this takes ~60s)..."
OUTPUT=$(yes 2>/dev/null | timeout 120 $SCRIPT 2>&1 || true)

# Restore original
mv "${OVPN_FILE}.bak" "$OVPN_FILE"

if echo "$OUTPUT" | grep -q "You are connected to the TryHackMe VPN"; then
    pass "Script completed successfully"
    
    if echo "$OUTPUT" | grep -q "192.168.x.x"; then
        pass "Detected correct IP range"
    else
        fail "Did not report correct IP range"
    fi
    
    if echo "$OUTPUT" | grep -q "MTU value OK\|MTU set at"; then
        pass "MTU check completed"
    else
        fail "MTU check did not complete"
    fi
else
    fail "Script did not complete successfully"
    echo "Output was:"
    echo "$OUTPUT"
fi
echo ""

########################################
# Test 5: MTU detection (constrained network)
########################################
echo "--- Test 5: MTU detection (constrained network) ---"
info "Stopping any running OpenVPN..."
killall openvpn 2>/dev/null || true
sleep 2

info "Adding iptables rule to simulate 1200 MTU..."
iptables -A OUTPUT -p udp --dport 1194 -m length --length 1201: -j DROP

# Reset config
cp "$OVPN_FILE" "$OVPN_MODIFIED"
if grep -q "<auth-user-pass>" "$OVPN_MODIFIED"; then
    sed -n '/<auth-user-pass>/,/<\/auth-user-pass>/p' "$OVPN_MODIFIED" | grep -v "auth-user-pass" > /tmp/auth.txt
    chmod 600 /tmp/auth.txt
    sed -i '/<auth-user-pass>/,/<\/auth-user-pass>/d' "$OVPN_MODIFIED"
    sed -i 's|^auth-user-pass$|auth-user-pass /tmp/auth.txt|' "$OVPN_MODIFIED"
fi

# Hide original so script finds our modified config
mv "$OVPN_FILE" "${OVPN_FILE}.bak" 2>/dev/null || true

info "Running script with constrained MTU (this takes ~90s)..."
OUTPUT=$(yes 2>/dev/null | timeout 180 $SCRIPT 2>&1 || true)

# Restore original
mv "${OVPN_FILE}.bak" "$OVPN_FILE" 2>/dev/null || true

if echo "$OUTPUT" | grep -q "MTU not working with the original value"; then
    pass "Detected MTU issue"
    
    if echo "$OUTPUT" | grep -q "MTU set at"; then
        pass "Applied MTU fix"
        
        # Verify the MTU lines are actually in the file
        if grep -q "# Added by the thm-troubleshoot script" "$OVPN_MODIFIED" && \
           grep -q "tun-mtu" "$OVPN_MODIFIED"; then
            pass "MTU settings correctly written to .ovpn file"
            info "File header:"
            head -5 "$OVPN_MODIFIED"
        else
            fail "MTU settings not found in .ovpn file"
            info "File header:"
            head -10 "$OVPN_MODIFIED"
        fi
    else
        fail "Did not apply MTU fix"
    fi
else
    fail "Did not detect MTU issue"
    echo "Output was:"
    echo "$OUTPUT" | grep -i mtu
fi

# Remove iptables rule
iptables -D OUTPUT -p udp --dport 1194 -m length --length 1201: -j DROP 2>/dev/null || true
echo ""

echo "========================================"
echo "  All tests completed!"
echo "========================================"

