zsh_greeting() {
    hour=$(date +"%H")

    if (( hour < 12 )); then
        time_of_day="🌅 Good morning"
    elif (( hour < 18 )); then
        time_of_day="🌞 Good afternoon"
    else
        time_of_day="🌜 Good evening"
    fi

    quotes=(
        "Keep pushing forward!"
        "Stay focused!"
        "Believe in yourself!"
        "Make today amazing!"
        "Embrace the journey!"
        "One step at a time!"
    )
    quote=${quotes[RANDOM % ${#quotes[@]}]}

    date_info=$(date "+📅 %A, %B %d, %Y")

    echo
    echo "$time_of_day"
    echo "$date_info"
    echo "💡 $quote"
    echo
}

if [[ -o interactive ]]; then
    zsh_greeting
fi