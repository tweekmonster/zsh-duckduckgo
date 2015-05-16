
function ddg() {
    query=""
    read -t 0 query  # Get stdin if it's there
    quiet=0

    if [[ "$1" == "-q" ]]; then
        quiet=1
        1=(${(@)[2,$#]})
    fi

    [[ -z $query ]] && query="$*"

    if [[ $query == <-> && ${#query} == 10 ]]; then
        query="unixtime ${query}"
    fi

    if [[ $query == "" && $# == 0 ]]; then
        [[ $quiet == 0 ]] && cat <<'EOF'
Perform a quick query with Duck Duck Go
This can get responses from most goodies: https://github.com/duckduckgo/zeroclickinfo-goodies/tree/master/lib/DDG/Goodie

Examples:
    - 5000000000 bytes in mib
    - unix time 1431647998
    - my location
    - zapp brannigan quote
    - permissions 1755
    - random password strong 26
EOF
        return 1
    fi

    if [[ -z $query ]]; then
        [[ $quiet == 0 ]] && echo "No query"
        return 1
    fi

    duck_url="http://api.duckduckgo.com/?format=json&no_html=1"
    failed=0
    resp=$(curl -sG "${duck_url}" --data-urlencode "q=${query}") || failed=1
    if [[ $failed != 0 ]]; then
        [[ $quiet == 0 ]] && echo 'No duck'
        return 1
    fi

    if [[ ! $resp =~ '"Type":"(A|E)"' ]]; then
        [[ $quiet == 0 ]] && echo 'No dice'
        return 1
    fi

    if [[ ! $resp =~ '"Answer":"([^"]*)"' ]]; then
        [[ $quiet == 0 ]] && echo 'Could not find answer!'
        echo "${resp}" 1>&2
        return 1
    fi

    answer="${match}"

    if [[ -z $answer ]]; then
        [[ $quiet == 0 ]] && echo "Empty response :("
        return 1
    fi

    [[ $quiet == 0 ]] && echo 'Answer from duckduckgo.com:'

    if [[ $answer =~ '^Unix Epoch' ]]; then
        lines=("${(s/ | /)answer}")
        [[ $quiet == 0 ]] && echo -n "${fg[blue]}"
        echo "${(j:\n:)lines}" | column -t -s '='
        [[ $quiet == 0 ]] && echo -n "${reset_color}"
        return 0
    fi

    lines=("${(s/\n/)answer}")

    if [[ $query =~ "^unicode" ]]; then
        lines=("${(s/, /)answer}")
    fi

    for line in $lines; do
        [[ $quiet == 0 ]] && echo -n "  ${fg[blue]}"
        echo -n "${line%% \(random*}"
        [[ $quiet == 0 ]] || echo ""
        [[ $quiet == 0 ]] && echo "${reset_color}"
    done
}

