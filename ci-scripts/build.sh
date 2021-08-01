#!/bin/sh

_die() {
  echo "FATAL ERROR: $*" >&2
  exit 1
}

_functions() {
  find . \
    -type d \
    -maxdepth 1 \
    -mindepth 1 \
    ! -name ci-scripts \
    ! -name '.[a-z0-9]*' \
    -print0 \
  | xargs -0 -n1 basename
}

_repo_top() {
  git rev-parse --show-toplevel || _die "git rev-parse --show-toplevel"
}

_build_one() {
  thistag="$ECR_PREFIX/$1:$2"
  echo "### BUILDING $thistag" >&2
  cd "$top/$1" || _die "cd $top/$1"
  docker build \
    --platform=linux/amd64 \
    --tag "$thistag" \
    --file ../Dockerfile . \
    || _die "$1: docker build failed"
    docker push "$thistag" || _die "$1: docker push failed"
}

_build_all_branch_ref() {
  for fn in $(_functions) ; do
    cd "$top/$fn" || _die "cd $top/$fn"
    _build_one "$fn" "$1" "$2"
  done
}

top="$(_repo_top)"
if [ -n "$BUILDKITE_TAG" ] ; then
  fn=$(echo "$BUILDKITE_TAG" | awk -F'\.' '{ print $1 }')
  version=$(echo "$BUILDKITE_TAG" | awk -vOFS=. -F '\.' '{for(i=2;i<=NF;i++){ printf("%s",( (i>2) ? OFS : "" ) $i) } ; }')
  _build_one "$fn" "$version"
else
  if [ -n "$BUILDKITE_BRANCH" ] ; then
    _build_all_branch_ref "$BUILDKITE_BRANCH"
  else
    _die "BUILDKITE_BRANCH and BUILDKITE_TAG are both unset, giving up"
  fi
fi

