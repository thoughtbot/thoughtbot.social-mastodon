# thoughtbot.social

This is a fork of [Mastodon][], with some thoughtbot customizations.

See [the upstream README][] for everything else.

[Mastodon]: https://github.com/mastodon/mastodon
[the upstream readme]: https://github.com/mastodon/mastodon/blob/main/README.md

## Customizations

* Character limit has been increased from 500 to 5000,
* Account avatar and headers have been bumped from 2 to 10 megabytes,
* We don't run the existing GitHub Actions workflows (as we trust upstream),
* We've got Kubernetes manifests in `deploy`, using the [thoughtbot Helm
  chart][helm-chart],
* We use [Flightctl][] for managing AWS & Kubernetes access,

[helm-chart]: https://github.com/thoughtbot/helm-charts/tree/main/charts/helm-rails
[Flightctl]: https://github.com/thoughtbot/flightctl

## Syncing with Upstream

To keep up-to-date, we rebase our customizations on top of the most recent
release tag.

You'll want a local remote to referencing upstream:

```sh
git remote add upstream https://github.com/mastodon/mastodon.git
```

Then:

```sh
git fetch upstream
git rebase v4.2.10
git push -f origin main
```

## Deploying

We run our instance on a Digital Ocean droplet. The deployment doesn't diverge
much from the [non-Docker steps in the release notes][releases].

You can login using the SSH key, which is stored in the thoughtbot 1Password
vault.

Backup the database, then run through these steps:

```sh
# switch to the mastodon user and jump to that directory
su - mastodon
cd /home/mastodon/live
# fetch latest upstream / origin branches & tags
git fetch
git reset origin/main --hard
# upgrade dependencies
rbenv install
bundle install
yarn install --frozen-lockfile
# prep the assets
RAILS_ENV=production bundle exec rails assets:precompile
# run the migrations
RAILS_ENV=production bundle exec rake db:migrate
# switch back to root user
exit
# restart processes
systemctl restart mastodon-sidekiq
systemctl reload mastodon-web
systemctl restart mastodon-streaming
```

[releases]: https://github.com/mastodon/mastodon/releases
