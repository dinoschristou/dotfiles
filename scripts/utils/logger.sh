#!/bin/bash

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly WHITE='\033[1;37m'
readonly NC='\033[0m' # No Color

# Log levels
readonly LOG_ERROR=1
readonly LOG_WARN=2
readonly LOG_INFO=3
readonly LOG_DEBUG=4

# Default log level
LOG_LEVEL=${LOG_LEVEL:-$LOG_INFO}

# Dry run mode
DRY_RUN_MODE=${DRY_RUN_MODE:-false}

log_error() {
    if [[ $LOG_LEVEL -ge $LOG_ERROR ]]; then
        echo -e "${RED}[ERROR]${NC} $*" >&2
    fi
}

log_warn() {
    if [[ $LOG_LEVEL -ge $LOG_WARN ]]; then
        echo -e "${YELLOW}[WARN]${NC} $*" >&2
    fi
}

log_info() {
    if [[ $LOG_LEVEL -ge $LOG_INFO ]]; then
        echo -e "${BLUE}[INFO]${NC} $*"
    fi
}

log_success() {
    if [[ $LOG_LEVEL -ge $LOG_INFO ]]; then
        echo -e "${GREEN}[SUCCESS]${NC} $*"
    fi
}

log_debug() {
    if [[ $LOG_LEVEL -ge $LOG_DEBUG ]]; then
        echo -e "${PURPLE}[DEBUG]${NC} $*" >&2
    fi
}

log_step() {
    if [[ $LOG_LEVEL -ge $LOG_INFO ]]; then
        if [[ "$DRY_RUN_MODE" == "true" ]]; then
            echo -e "${CYAN}[DRY-RUN STEP]${NC} $*"
        else
            echo -e "${CYAN}[STEP]${NC} $*"
        fi
    fi
}

log_dry_run() {
    if [[ "$DRY_RUN_MODE" == "true" ]]; then
        echo -e "${YELLOW}[DRY-RUN]${NC} Would execute: $*"
    fi
}

log_header() {
    if [[ $LOG_LEVEL -ge $LOG_INFO ]]; then
        echo
        echo -e "${WHITE}=================================================================================${NC}"
        echo -e "${WHITE} $*${NC}"
        echo -e "${WHITE}=================================================================================${NC}"
        echo
    fi
}