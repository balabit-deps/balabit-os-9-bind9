#!/bin/sh

# Copyright (C) Internet Systems Consortium, Inc. ("ISC")
#
# SPDX-License-Identifier: MPL-2.0
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0.  If a copy of the MPL was not distributed with this
# file, you can obtain one at https://mozilla.org/MPL/2.0/.
#
# See the COPYRIGHT file distributed with this work for additional
# information regarding copyright ownership.

dir=$(dirname "$0")
. "$dir/conf.sh"

systest=$1
status=0

export SYSTESTDIR="${TOP_SRCDIR}/bin/tests/system/${systest}"

get_core_dumps() {
    find "$SYSTESTDIR/" \( -name 'core' -or -name 'core.*' -or -name '*.core' \) ! -name '*.gz' ! -name '*.txt' | sort
}

core_dumps=$(get_core_dumps | tr '\n' ' ')
assertion_failures=$(find "$SYSTESTDIR/" -name named.run -exec grep "assertion failure" {} + | wc -l)
sanitizer_summaries=$(find "$SYSTESTDIR/" -name 'tsan.*' | wc -l)
if [ -n "$core_dumps" ]; then
    status=1
    echoinfo "I:$systest:Core dump(s) found: $core_dumps"
    get_core_dumps | while read -r coredump; do
        echoinfo "D:$systest:backtrace from $coredump:"
        echoinfo "D:$systest:--------------------------------------------------------------------------------"
        binary=$(gdb --batch --core="$coredump" 2>/dev/null | sed -ne "s|Core was generated by \`\([^' ]*\)[' ].*|\1|p")
        if [ ! -f "${binary}" ]; then
            binary=$(find "${TOP_BUILDDIR}" -path "*/.libs/${binary}" -type f)
        fi
        "${TOP_BUILDDIR}/libtool" --mode=execute gdb \
                                  -batch \
                                  -ex bt \
                                  -core="$coredump" \
                                  -- \
                                  "$binary" 2>/dev/null | sed -n '/^Core was generated by/,$p' | cat_d
        echoinfo "D:$systest:--------------------------------------------------------------------------------"
        coredump_backtrace="${coredump}-backtrace.txt"
        echoinfo "D:$systest:full backtrace from $coredump saved in $coredump_backtrace"
        "${TOP_BUILDDIR}/libtool" --mode=execute gdb \
                                  -batch \
                                  -command=run.gdb \
                                  -core="$coredump" \
                                  -- \
                                  "$binary" > "$coredump_backtrace" 2>&1
        echoinfo "D:$systest:core dump $coredump archived as $coredump.gz"
        gzip -1 "${coredump}"
    done
elif [ "$assertion_failures" -ne 0 ]; then
    status=1
    echoinfo "I:$systest:$assertion_failures assertion failure(s) found"
    find "$SYSTESTDIR/" -name 'tsan.*' -exec grep "SUMMARY: " {} + | sort -u | cat_d
elif [ "$sanitizer_summaries" -ne 0 ]; then
    status=1
    echoinfo "I:$systest:$sanitizer_summaries sanitizer report(s) found"
fi

exit $status