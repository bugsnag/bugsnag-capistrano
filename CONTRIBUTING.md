# Contribution Guide

## Development Dependencies

Install dependencies for testing using bundler:
```shell
bundle install --with test
```

## Running the Tests

Run the tests using:

```shell
bundle exec rake
```

This tests Capistrano 3 functionality, without using Bugsnag to make the deployment call.  To test Capistrano 2 functionality set the environment variable `CAP_2_TEST` to `true` and re-install and run the tests.

In order to test using the main Bugsnag notifier to send the deployment notification, include the group `bugsnag` in the install command:
```shell
bundle install --with test bugsnag
```

## Building/Running Example Apps

Instructions on running the example apps can be found within the `README.md` files within the respective folders.

## Submitting a Change

* [Fork](https://help.github.com/articles/fork-a-repo) the
  [notifier on github](https://github.com/bugsnag/bugsnag-capistrano)
* Commit and push until you are happy with your contribution
* Run the tests with and ensure all pass
* [Submit a pull request](https://help.github.com/articles/using-pull-requests)
* Thank you!

----

## Release Guidelines

If you're a member of the core team, follow these instructions for releasing
bugsnag-capistrano.

### Every time

* Compile new features, enhancements, and fixes into the CHANGELOG.
* Update the project version using [semantic versioning](http://semver.org).
  Specifically:

  > Given a version number MAJOR.MINOR.PATCH, increment the:
  >
  > 1. MAJOR version when you make incompatible API changes,
  > 2. MINOR version when you add functionality in a backwards-compatible
  >    manner
  > 3. PATCH version when you make backwards-compatible bug fixes.
  >
  > Additional labels for pre-release and build metadata are available as
  > extensions to the MAJOR.MINOR.PATCH format.

* Add a git tag with the new version of the library
* Commit and push your changes and tag
* Create a new release on [the Github repository](https://github.com/bugsnag/bugsnag-capistrano)
* Release to RubyGems

    ```
    gem build bugsnag-capistrano.gemspec
    gem push bugsnag-capistrano-[version].gem
    ```

* Update docs.bugsnag.com with any new content
