thoughtbot.social is a fork of [Mastodon](https://github.com/mastodon/mastodon). It includes customizations for thoughtbot's purposes. We endeavor to keep the core code up to date with the latest upstream release while layering in our basic tweaks for thoughtbot.social

Mastodon is licenced under the AGPL and more details can be found on [the upstream README](https://github.com/mastodon/mastodon/blob/main/README.md).

## Summary of customizations
* Increase character limit for posts from 500 to 5000 characters
* Bump limit for avatar / header image to 10 megabytes
* Strip out github actions workflows for tests / linting
  - these run upstream and we don't need this in our CICD pipeline
* Kubernetes manifest details in `./deploy`
  - this utilizes thoughtbot's [Rails helm chart](https://github.com/thoughtbot/helm-charts/tree/main/charts/helm-rails)
  - contains info for loading AWS secrets, establishing necessary containers / jobs to run Mastodon
  - this is currently a work in progress
* flightctl convenience tool for accessing AWS / Kubernetes environment running the application

## Production Details
Currently deployed branch: v4.2.3-thoughtbot
This matches the v4.2.3 release from upstream Mastodon codebase, but includes thoughtbot's customizations

## Flightctl
`./bin/flightctl` is a tool for accessing the kubernetes / AWS environment for the cluster that contains the thoughtbot.social application. More documentation can be found [here](https://github.com/thoughtbot/flightctl). This is a convenience tool to login to AWS via single sign-on and access various application resources in the Kubernetes environment using [kubectl](https://kubernetes.io/docs/reference/kubectl/).

## Mastodon release upgrade overview
* [Upstream documentation](https://docs.joinmastodon.org/admin/upgrading/) for release upgrading
* [List of releases](https://github.com/mastodon/mastodon/releases) for Mastodon (including upgrade notes / changelog)

The general process for updgrading to latest upstream Mastodon release involves:
* checking out the relevant upstream release tag (eg: v4.2.3)
* merging in thoughtbot customizations from our latest release branch (eg: v4.1.0-thoughtbot)
* establishing a new branch that corresponds to the upstream tag (eg: v4.2.3-thoughtbot)
* deploy that branch to the relevant environment
  - this is currently a manual process but will be automated with Github CICD pipeline going forward

### Release upgrade details
The merging of thoughtbot customizations can be a bit messy. While the changes are very manageable, I've run into some conflicts that have made a straightforward merge more complicated. As a fallback, create a patch and apply that to the new thoughtbot release branch based off the latest upstream tag; eg:

```bash
git checkout v4.2.6 # this tag doesn't really exist (as of this writing)
# create new thoughtbot flavored branch based off upstream tag
git checkout -b v4.2.6-thoughtbot
# Generate a patch of previous release customizations
git diff v4.2.3 v4.2.3-thoughtbot -- . ':!.github' > customizations.patch
git apply customizations.patch
rm customizations.patch
```

These tasks will be soon be automated with the CICD pipeline and related kubernetes jobs, but to detail the current manual process... ssh into the production server as root user (access details in 1password) and run:

```bash
# switch to directory with Mastodon codebase
cd /home/mastodon/live
su - mastodon
# fetch latest upstream / origin branches & tags
git pull
# obviously change to appropriate branch
git checkout v4.2.3-thoughtbot
# install latest ruby version (may not be necessary; but good to check)
rbenv install
bundle install
yarn install --frozen-lockfile
RAILS_ENV=production bundle exec rails assets:precompile
RAILS_ENV=production bundle exec rake db:migrate
# switch back to root user
exit
# restart Mastodon processes
systemctl restart mastodon-sidekiq
systemctl reload mastodon-web
systemctl restart mastodon-streaming
```
