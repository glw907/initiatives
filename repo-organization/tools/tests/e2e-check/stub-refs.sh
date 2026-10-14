#!/usr/bin/env bash
# Stub refs: print $STUB_REFS_OUT and exit $STUB_REFS_RC (default 0).
printf '%b' "${STUB_REFS_OUT:-}"
exit "${STUB_REFS_RC:-0}"
