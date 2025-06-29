#!/bin/bash

# User interaction utilities

# Ask yes/no question
ask_yes_no() {
    local question="$1"
    local default="${2:-}"
    local response

    while true; do
        if [[ "$default" == "y" ]]; then
            read -p "$question [Y/n]: " response
            response=${response:-y}
        elif [[ "$default" == "n" ]]; then
            read -p "$question [y/N]: " response
            response=${response:-n}
        else
            read -p "$question [y/n]: " response
        fi

        case "$response" in
            [Yy]|[Yy][Ee][Ss])
                return 0
                ;;
            [Nn]|[Nn][Oo])
                return 1
                ;;
            *)
                echo "Please answer yes or no."
                ;;
        esac
    done
}

# Select from menu
select_from_menu() {
    local title="$1"
    shift
    local options=("$@")
    local choice

    echo "$title"
    for i in "${!options[@]}"; do
        echo "  $((i+1)). ${options[$i]}"
    done

    while true; do
        read -p "Select option [1-${#options[@]}]: " choice
        if [[ "$choice" =~ ^[0-9]+$ ]] && [[ $choice -ge 1 ]] && [[ $choice -le ${#options[@]} ]]; then
            echo "${options[$((choice-1))]}"
            return $((choice-1))
        else
            echo "Invalid selection. Please choose 1-${#options[@]}."
        fi
    done
}

# Multi-select from menu
multi_select_from_menu() {
    local title="$1"
    shift
    local options=("$@")
    local selected=()
    local choice

    echo "$title"
    echo "Enter numbers separated by spaces (e.g., '1 3 5') or 'all' for all options:"
    for i in "${!options[@]}"; do
        echo "  $((i+1)). ${options[$i]}"
    done

    while true; do
        read -p "Select options: " choice
        
        if [[ "$choice" == "all" ]]; then
            selected=("${options[@]}")
            break
        fi

        selected=()
        local valid=true
        for num in $choice; do
            if [[ "$num" =~ ^[0-9]+$ ]] && [[ $num -ge 1 ]] && [[ $num -le ${#options[@]} ]]; then
                selected+=("${options[$((num-1))]}")
            else
                echo "Invalid selection: $num"
                valid=false
                break
            fi
        done

        if [[ "$valid" == true ]]; then
            break
        fi
    done

    printf '%s\n' "${selected[@]}"
}

# Show progress bar
show_progress() {
    local current="$1"
    local total="$2"
    local width=50
    local percentage=$((current * 100 / total))
    local completed=$((current * width / total))
    local remaining=$((width - completed))

    printf "\r["
    printf "%${completed}s" | tr ' ' '='
    printf "%${remaining}s" | tr ' ' '-'
    printf "] %d%% (%d/%d)" "$percentage" "$current" "$total"
}

# Pause for user input
pause() {
    local message="${1:-Press any key to continue...}"
    read -n 1 -s -r -p "$message"
    echo
}

# Get user input with default
get_input() {
    local prompt="$1"
    local default="$2"
    local response

    if [[ -n "$default" ]]; then
        read -p "$prompt [$default]: " response
        echo "${response:-$default}"
    else
        read -p "$prompt: " response
        echo "$response"
    fi
}

# Get user input with validation
get_input_with_validation() {
    local prompt="$1"
    local validation_func="$2"
    local default="$3"
    local response

    while true; do
        if [[ -n "$default" ]]; then
            read -p "$prompt [$default]: " response
            response="${response:-$default}"
        else
            read -p "$prompt: " response
        fi

        if [[ -n "$response" ]] && $validation_func "$response"; then
            echo "$response"
            return 0
        fi
    done
}

# Validate email format
validate_email() {
    local email="$1"
    if [[ "$email" =~ ^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$ ]]; then
        return 0
    else
        echo "Invalid email format. Please enter a valid email address."
        return 1
    fi
}

# Validate non-empty input
validate_non_empty() {
    local input="$1"
    if [[ -n "$input" ]]; then
        return 0
    else
        echo "Input cannot be empty."
        return 1
    fi
}