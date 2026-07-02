# AGENTS.md

## Policyfile migration notes

* This cookbook uses `Policyfile.rb` for local and CI dependency resolution. Keep
  test cookbook recipes available as named run lists so Kitchen suites preserve
  the old Berkshelf run-list behavior.
* `yum-epel` is sourced from GitHub because Supermarket resolution can return
  HTTP 403 during CI solves. The current `sous-chefs/yum-epel` cookbook is
  resource-first and does not ship `recipes/default.rb`; use the `yum_epel`
  resource in test recipes instead of `include_recipe 'yum-epel'`.
* MariaDB package suites use `mirror.mariadb.org`. The mirror redirector can
  return transient metadata or RPM download failures when the large integration
  matrix fans out too aggressively, especially across `10.11` RHEL-family jobs.
  Keep CI matrix parallelism capped rather than removing otherwise valid
  platform coverage for transient mirror errors.
