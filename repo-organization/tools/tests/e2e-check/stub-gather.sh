#!/usr/bin/env bash
# Stub gather-dotfiles.sh: print the initiative records a session in $PWD should see.
# STUB_GATHER_DROP names one id to leave out.
case $PWD in
  */drafter) out="drafter repo-organization" ;;
  */.dotfiles) out="drafter workstation-secrets repo-organization" ;;
  *) out="repo-organization" ;;
esac
for id in $out; do [[ $id == "${STUB_GATHER_DROP:-}" ]] || echo "## Initiative: $id"; done
