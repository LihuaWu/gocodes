#!/bin/sh
set -e # Exit immediately if a command exits with a non-zero status.

# --- Configuration ---
BINARY_NAME="./http-client"
DEFAULT_URL="https://www.google.com"

# --- Functions ---
run_default() {
	URL=${1:-$DEFAULT_URL}
	shift
	echo "--- Building application (cgo) ---"
	make build
	echo "\n--- Running application ---"
	$BINARY_NAME "$@" "$URL"
}

run_netgo() {
	URL=${1:-$DEFAULT_URL}
	shift
	echo "--- Building application (netgo) ---"
	make build-netgo
	echo "\n--- Running application (netgo) ---"
	$BINARY_NAME "$@" "$URL"
}

run_debug() {
	URL=${1:-$DEFAULT_URL}
	shift
	echo "--- Building application (cgo) ---"
	make build
	echo "\n--- Running with GODEBUG enabled ---"
	GODEBUG=netdns=1,http1trace=1,http2debug=2 $BINARY_NAME "$@" "$URL"
}

run_debug_netgo() {
	URL=${1:-$DEFAULT_URL}
	shift
	echo "--- Building application (netgo) ---"
	make build-netgo
	echo "\n--- Running with GODEBUG enabled (netgo) ---"
	GODEBUG=netdns=1,http1trace=1,http2debug=2 $BINARY_NAME "$@" "$URL"
}

run_strace() {
	URL=${1:-$DEFAULT_URL}
	shift
	echo "--- Building application (cgo) ---"
	make build
	echo "\n--- Tracing network system calls with strace ---"
	strace -e trace=network $BINARY_NAME "$@" "$URL"
}

usage() {
	echo "Usage: $0 <command> [URL] [FLAGS...]"
	echo ""
	echo "Commands:"
	echo "  run         Build and run the application."
	echo "  netgo       Build and run the application with the pure Go resolver."
	echo "  debug       Run with verbose GODEBUG logging."
	echo "  debug_netgo Run the netgo build with verbose GODEBUG logging."
	echo "  strace      Run and trace network system calls with strace."
	echo ""
	echo "Arguments:"
	echo "  URL         (Optional) The URL to request. Defaults to '$DEFAULT_URL'."
	echo "  FLAGS       (Optional) Flags to pass to the program, e.g., -http2=false."
}

# --- Main Logic ---
COMMAND=$1

if [ -z "$COMMAND" ]; then
	usage
	exit 1
fi

shift # Remove the command from the argument list

case $COMMAND in
run) run_default "$@" ;;
netgo) run_netgo "$@" ;;
debug) run_debug "$@" ;;
debug_netgo) run_debug_netgo "$@" ;;
strace) run_strace "$@" ;;
*)
	usage
	exit 1
	;;
esac