# Sinter

Sinter checks files for syntax errors.  You can call it directly (on the command line, inside Vim, etc) or from a git pre-commit hook.  It is not a style checker.

There are zillions of syntax-checking pre-commit hooks already.  However all the ones I saw require modifying the hook whenever you modify your syntax checks.  This is annoying to do even once, let alone when you have many repos.

With Sinter you never need to modify your hooks (after the initial installation), nor even `sinter` itself.  To extend your syntax checks with a new filetype, just drop in a new linter.  Sinter will automatically find it.


## Features

- Call directly or from pre-commit hook.
- Your pre-commit hook never changes once installed.
- The pre-commit hook lists all files with syntax errors, not just the first.
- Trivial to extend with new file types.


## Installation

Clone the `sinter` repo.

Put the `sinter` script somewhere on your path.  I symlink it into my `~/bin` directory which is on my path:

    ln -nfs /path/to/sinter/repo/sinter ~/bin/

Copy or symlink the `pre-commit` script into your repo's `/git/hooks` directory, or install as a git template.  If you already have a pre-commit hook, you'll find it easy to combine the two manually.

The linters have these dependencies:

Linter | Dependency |
-------|------------|
bash | bash |
css | csslint |
haml | haml |
javascript | eslint |
ruby | ruby |
sass | sass-lint |
slim | slimrb |
vimscript | [vint](https://github.com/Kuniwak/vint) |
yaml | ruby |


## Usage

To check a file:

    sinter [-q] FILE

If `FILE` is syntactically correct sinter will output `syntax ok`.  The exit code is 0.

If `FILE` has syntax errors sinter will output `syntax error` on stdout and the errors on stderr.  The exit code is 1.

If sinter doesn't know how to check `FILE` it will output `no linter for FILE`.  The exit code is 2.

The `-q` flag suppresses output.

To list the linters:

    sinter --linters

To skip the pre-commit hook when committing:

    git commit --no-verify
    git commit -n

To check existing code:

    git ls-files -z                         |
    xargs -0 file --mime                    |  # only process text files
    awk -F":[ ]*" '$2 ~ /^text/ {print $1}' |  # ditto
    xargs -n1 sinter

Inside Vim:

    nnoremap <leader>s :!sinter %<CR>


## Linters

Linters reside in the `linters/` directory.

To add a new linter write a script that:

- is named for the file type it checks;
- implements `is_foo()`:
  - it receives the filename, extension, and shebang as arguments
  - it must exit with success or failure;
- implements `lint_foo()`:
  - it receives the full file path as an argument;
  - it should write any syntax errors to stderr;
  - it must exit with success or failure.

You do not need to update `sinter` or your pre-commit hooks.

To remove a linter, just delete it.  You do not need to update `sinter` or your pre-commit hooks.


## Credits

[ochtra](https://github.com/kvz/ochtra) was the best commit hook I found, but I wanted something which could be run standalone and didn't require updating the hook itself whenever I extended the syntax checks.


## Intellectual property

Copyright Andrew Stewart, AirBlade Software.

