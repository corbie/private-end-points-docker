#!/bin/sh -u

BASE_DIR=$(cd $(dirname "$0") && pwd -P)
SCRIPT_NAME=$(basename "$0")

fail() {
    echo "$@" >&2
    exit 1
}

usage() {
    cat <<EOI
Usage: $SCRIPT_NAME [ARGUMENTS] [DOCKER ARGS]
(e.g.)

OPTIONS:
    -b|--branch REPO      Override branch for PEP client repo
    -e|--env ENV          Env to build/push (dev, stage, prod) (default: $env)
    -h|--help             This information
    -t|--tag TAG          Override image tag
    -p|--push             Automatically push to Docker hub

EXAMPLE:

  \$ $SCRIPT_NAME -e stage -b jkf
EOI
}

# args
env='prod'
branch=
push=0
docker_args=(--rm)
user_tag=

while [ $# -gt 0 ]; do
    arg="$1"
    shift
    case "$arg" in 
        --branch|-b)
            [ $# -gt 0 ] || fail "Missing arg to --env|-e"
            branch="$1"
            shift
            ;;
        --env|-e)
            [ $# -gt 0 ] || fail "Missing arg to --env|-e"
            env="$1"
            [ "$env" = 'dev' -o "$env" = 'stage' -o "$env" = 'prod' ] \
                || fail "Unknown env: '$env'; 'dev', 'stage' or 'prod' expected."
            shift
            ;;
        --push|-p)
            push=1
            ;;
        --tag|-t)
            [ $# -gt 0 ] || fail "Missing arg to --tag|-t"
            user_tag="$1"
            shift
            ;;
        --help|-h)
            usage
            exit
            ;;
        *)
            docker_args[${#docker_args[*]}]="$arg"
            ;;
    esac
done


which docker 2>&1 || fail "Failed to locate 'docker' binary"
cd "$BASE_DIR" || fail "Failed to CD to our base dir?"
# any cruft?
cruft="$(find . -name .\*.sw? | wc -l | awk '{print $1}')"
[ $cruft -gt 0 ] && echo "$cruft swap file(s) lurk; lets keep things clean"


tag="encryptme/pep"
if [ "$env" = 'dev' ]; then
    tag="$tag-dev"
    [ -n "$branch" ] || fail "Must specify branch to use for 'dev'"
elif [ "$env" = 'stage' ]; then
    tag="$tag-stage"
    [ -n "$branch" ] || branch='stage'
else
    [ -n "$branch" ] || branch='master'
fi
[ -n "$user_tag" ] && tag="$user_tag"

echo "Building '$tag' for '$env' with PEP client repo branch '$branch'"
echo
echo '           ----======----'
docker build . -t "$tag" \
    --build-arg repo_branch="$branch" \
    "${docker_args[@]}" \
    || fail "Failed to build '$tag' with repo branch '$branch'"
echo '           ----======----'
echo
echo

if [ $push -eq 1 ]; then
    docker push "$tag" || fail "Failed to push '$tag'"
else
    echo "Skipped 'docker push \"$tag\"'"
fi


exit 0
