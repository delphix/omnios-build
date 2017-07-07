#!/usr/bin/bash
#
# CDDL HEADER START
#
# This file and its contents are supplied under the terms of the
# Common Development and Distribution License ("CDDL"), version 1.0.
# You may only use this file in accordance with the terms of version
# 1.0 of the CDDL.
#
# A full copy of the text of the CDDL should have accompanied this
# source.  A copy of the CDDL is also available via the Internet at
# http://www.illumos.org/license/CDDL.
#
# CDDL HEADER END
#
#
# Copyright (c) 2017 by Delphix. All rights reserved.
#
# Load support functions
. ../../lib/functions.sh

PROG=mosh       # App name
VER=1.3.0       # App version
VERHUMAN=$VER   # Human-readable version
PKG=network/mosh # Package name (without prefix)
SUMMARY="$PROG - The mobile shell replacement for SSH"
DESC="$SUMMARY"

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
make_isa_stub
make_package
clean_up
