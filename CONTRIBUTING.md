# Contributing to Astronoby

By participating in this project, you agree to follow the [code of conduct].

[code of conduct]: https://github.com/rhannequin/astronoby/blob/main/CODE_OF_CONDUCT.md

Here are some ways *you* can contribute:

* by reporting bugs
* by suggesting new features
* by writing or editing documentation
* by writing specifications
* by writing code (**no patch is too small** : fix typos, add comments, etc.)
* by refactoring code
* by closing [issues]
* by reviewing patches

[issues]: https://github.com/rhannequin/astronoby/issues

## Submitting an Issue

* We use the [GitHub issue tracker][issues] to track bugs and features.
* Before submitting a bug report or feature request, check to make sure it hasn't
  already been submitted.
* When submitting a bug report, please include any other details that may be
  necessary to reproduce the bug, including your gem version, Ruby version, and
  operating system.

## Cleaning up issues

* Issues that have no response from the submitter will be closed after 30 days.
* Issues will be closed once they're assumed to be fixed or answered. If the
  maintainer is wrong, it can be opened again.
* If your issue is closed by mistake, please understand and explain the issue.
  We will happily reopen the issue.

## Submitting a Pull Request

1. [Fork][fork] the [official repository][repo].
1. [Create a topic branch.][branch]
1. Implement your feature or bug fix.
1. Add, commit, and push your changes.
1. [Submit a pull request.][pr]

### Notes

* Please add tests if you changed code. Contributions without tests won't be accepted.
* If you don't know how to add tests, please put in a PR and leave a comment
  asking for help. We love helping!
* Please don't update the Gem version.

## Setting up

```sh
bin/setup
```

## Running the test suite

The default rake task will run the full test suite:

```sh
bundle exec rake
```

To run an individual rspec test, you can provide a path and line number:

```sh
bundle exec rspec spec/path/to/spec.rb:123
```

## Formatting

Use [standard] to automatically format your code:

```sh
bundle exec standardrb --fix
```

[repo]: https://github.com/rhannequin/astronoby/tree/main
[fork]: https://help.github.com/articles/fork-a-repo/
[branch]: https://help.github.com/articles/creating-and-deleting-branches-within-your-repository/
[pr]: https://help.github.com/articles/using-pull-requests/
[standard]: https://github.com/testdouble/standard

Inspired by https://github.com/thoughtbot/factory_bot/blob/main/CONTRIBUTING.md
