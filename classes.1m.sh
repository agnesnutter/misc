#!/bin/bash

# File should be saved with .1m extension for SwiftBar to run every minute

# <xbar.title>Class break warning</xbar.title>
# <xbar.version>v1.0</xbar.version>
# <xbar.author>Tuesday Mueller-Harder</xbar.author>
# <xbar.author.github>agnesnutter</xbar.author.github>
# <xbar.desc>Provides an indicator in the menu bar warning when the hallways and campus are more likely to be crowded.</xbar.desc>
# <xbar.image>https://github.com/agnesnutter/misc/classes.1m.sh</xbar.image>
# <xbar.dependencies>bash</xbar.dependencies>

next_class_minutes=999999  # Global variable for time display

# Function to convert time to minutes since midnight
time_to_minutes() {
    hour=${1%:*}    # Remove leading zeros
    minute=${1#*:}  # Remove leading zeros
    # Remove leading zeros while converting to decimal
    hour=$((10#$hour))
    minute=$((10#$minute))
    echo $((hour * 60 + minute))
}

# Get current time in minutes since midnight
current_time=$(date +%H:%M)
current_minutes=$(time_to_minutes "$current_time")
day_of_week=$(date +%u) # 1-5 is Monday-Friday

# Class start times
MWF_TIMES=(
    "09:00"
    "10:00"
    "11:00"
    "12:00"
    "13:00"
    "14:00"
    "15:00"
)

TTH_TIMES=(
    "09:00"
    "10:30"
    "12:00"
    "13:00"
    "14:30"
)

# Function to check proximity to next class
check_class_proximity() {
    local class_times=("$@")

    # Find the next class start time
    for time in "${class_times[@]}"; do
        time_mins=$(time_to_minutes "$time")
        if [ $time_mins -gt $current_minutes ]; then
            if [ $time_mins -lt $next_class_minutes ]; then
                next_class_minutes=$time_mins
            fi
        fi
    done

    # If no more classes today
    if [ $next_class_minutes -eq 999999 ]; then
        echo ":figure.stairs.circle.fill:"
        return
    fi

    # Calculate time until next class
    time_until=$((next_class_minutes - current_minutes))

    if [ $time_until -gt 20 ]; then
        echo ":figure.stairs.circle.fill:"      # Neutral - gray
    elif [ $time_until -gt 10 ]; then
        echo ":figure.stairs.circle.fill: | sfcolor=gold"    # Warning - yellow
    elif [ $time_until -gt 0 ]; then
        echo ":figure.stairs.circle.fill: | sfcolor=red"       # Urgent - red
    elif [ $time_until -gt -5 ]; then
        echo ":figure.stairs.circle.fill: | sfcolor=darkorange"    # Just started - orange
    else
        echo ":figure.stairs.circle.fill:"      # Normal time - gray
    fi
}

# Main logic
case $day_of_week in
    1|3|5)  # Monday, Wednesday, Friday
        check_class_proximity "${MWF_TIMES[@]}"
        ;;
    2|4)    # Tuesday, Thursday
        check_class_proximity "${TTH_TIMES[@]}"
        ;;
    *)      # Weekend
        echo ":figure.stairs.circle.fill:"
        ;;
esac

echo "---"  # SwiftBar separator for dropdown menu

# Get and display time info
if (( next_class_minutes != 999999 )); then
    time_until=$((next_class_minutes - current_minutes))
    if (( time_until > 20 )); then
        echo "Normal class time"
    elif (( time_until > 10 )); then
        current_class_end=$((next_class_minutes - 10))
        minutes_until_end=$((current_class_end - current_minutes))
        echo "Current class ends in $minutes_until_end minutes"
    elif (( time_until > 0 )); then
        next_class_time=$(printf "%02d:%02d" $((next_class_minutes/60)) $((next_class_minutes%60)))
        echo "Next class: $next_class_time ($time_until minutes)"
    else
        echo "Class started $((time_until * -1)) minutes ago"
    fi
else
    echo "No more classes today"
fi

echo "Refresh | refresh=true"
