#!/bin/sh
set -e
# The "G" stands for "G"lobally-unique mail (or "G"it mail, if you prefer)
# Since Git 2.46 (following pull request 'ps/config-subcommands'),
# git-config(1) prefers to be called as `get' instead of `--get'.
# This is still too new of a feature in my opinion (in particular,
# the CSL machines are stuck on Git 2.43.0), so I am sticking to
# the old syntax -- for as long as it won't break, and as long as
# I have to use systems with a pre-2.46 git(1) binary.
Gmail=$(git config gitweb.commit-email)
(
	export GIT_AUTHOR_EMAIL=$Gmail GIT_COMMITTER_EMAIL=$Gmail
	~/tree/utils/store-meta "$@" -- . refs/info/view
)
git commit-tree \
	-p refs/info/self \
	-p refs/info/view \
	refs/info/self^{tree} \
	-m 'Change my view!' \
> MERGE_HEAD
trap 'rm -f MERGE_HEAD' EXIT
git update-ref refs/info/self MERGE_HEAD
