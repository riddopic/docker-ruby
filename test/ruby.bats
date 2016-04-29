#!/usr/bin/env bats

setup() {
  docker history "$REGISTRY/$REPOSITORY:$TAG" >/dev/null 2>&1
  export IMG="$REGISTRY/$REPOSITORY:$TAG"
  export RUBY_VERSION=$RUBY_VERSION
  export MAX_SIZE=200000
}

@test "checking image size" {
  run docker run $IMG bash -c "[[ \"\$(du -d0 / 2>/dev/null | awk '{print \$1; print > \"/dev/stderr\"}')\" -lt \"$MAX_SIZE\" ]]"
  [ $status -eq 0 ]
}

@test "It should use Ruby $RUBY_VERSION" {
  run docker run $IMG bash -c "ruby -v | grep $RUBY_VERSION"
  [ $status -eq 0 ]
}

@test "It should execute Ruby code" {
  run docker run $IMG bash -c "ruby -e \"puts 'Hello'\" | grep Hello"
}

@test "It should install Bundler" {
  run docker run $IMG bash -c "which bundler"
}

@test "It should be protected against CVE-2014-2525" {
  run docker run $IMG bash -c "ruby -rpsych -e 'p Psych.libyaml_version[2] > 5' | grep true"
}
