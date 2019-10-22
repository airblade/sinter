#!/usr/bin/env bash
#
# Tests based on the Pure Bash Bible's.
# https://github.com/dylanaraps/pure-bash-bible/blob/master/test.sh


test_filename() {
  result="$(filename '/path/to/foo.rb')"
  assert_equals "foo.rb" "$result"

  result="$(filename 'foo.rb')"
  assert_equals "foo.rb" "$result"
}


test_extension() {
  result="$(extension 'foo.rb')"
  assert_equals "rb" "$result"

  result="$(extension 'foo')"
  assert_equals "" "$result"
}


test_shebang() {
  result="$(shebang 'test.sh')"
  assert_equals "bash" "$result"

  result="$(shebang 'README.markdown')"
  assert_equals "" "$result"
}


test_is_ruby() {
  is_ruby "Gemfile"
  assert_equals 0 $?

  is_ruby "" "rb"
  assert_equals 0 $?

  is_ruby "" "" "ruby"
  assert_equals 0 $?

  is_ruby foo
  assert_equals 1 $?
}


test_lint_ruby_syntax_ok() {
  echo 'puts "foo"' > testfile.rb
  lint_ruby testfile.rb >/dev/null
  assert_equals 0 $?
}


test_lint_ruby_syntax_error() {
  echo 'puts "foo' > testfile.rb
  lint_ruby testfile.rb 2>/dev/null
  assert_equals 1 $?
}


test_sinter_syntax_ok() {
  echo 'puts "foo"' > testfile.rb
  result="$(sinter testfile.rb)"
  assert_equals 0 $?
  assert_equals "syntax ok" "$result"

  result="$(sinter -q testfile.rb)"
  assert_equals 0 $?
  assert_equals "" "$result"
}


test_sinter_syntax_error() {
  echo 'puts "foo' > testfile.rb
  result="$(sinter testfile.rb 2>test.stderr)"
  assert_equals 1 $?
  assert_equals "syntax error" "$result"
  assert_equals "testfile.rb:1: unterminated string meets end of file" "$(cat test.stderr)"

  result="$(sinter -q testfile.rb)"
  assert_equals 1 $?
  assert_equals "" "$result"
}


test_linters() {
  IFS=$'\n' read -d "" -ra result < <(linters)
  assert_equals "bash" "${result[0]}"
}


test_no_linter() {
  result="$(sinter README.markdown)"
  assert_equals 2 $?
  assert_equals "no linter for README.markdown" "$result"

  result="$(sinter -q README.markdown)"
  assert_equals 2 $?
  assert_equals "" "$result"
}


assert_equals() {
  if [[ "$1" == "$2" ]]; then
    ((pass+=1))
    status=$'\e[32m✔'
  else
    ((fail+=1))
    status=$'\e[31m✖'
    local err="(\"$1\" != \"$2\")"
  fi

  printf ' %s\e[m | %s\n' "$status" "${FUNCNAME[1]/test_} $err"
}


main() {
  trap 'rm testfile.* test.stderr' EXIT

  # Run shellcheck and source the code.
  shellcheck -s bash sinter || exit 1
  . sinter > /dev/null

  head="-> Running tests on sinter..."
  printf '\n%s\n%s\n' "$head" "${head//?/-}"

  # Generate the list of tests to run.
  IFS=$'\n' read -d "" -ra funcs < <(declare -F)
  for func in "${funcs[@]//declare -f }"; do
    [[ "$func" == test_* ]] && "$func";
  done

  comp="Completed $((fail+pass)) tests. ${pass:-0} passed, ${fail:-0} failed."
  printf '%s\n%s\n\n' "${comp//?/-}" "$comp"

  # If a test failed, exit with '1'.
  ((fail>0)) || exit 0 && exit 1
}

main "$@"
