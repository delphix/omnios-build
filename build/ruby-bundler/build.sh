#!/usr/bin/bash
#
# CDDL HEADER START
#
# The contents of this file are subject to the terms of the
# Common Development and Distribution License, Version 1.0 only
# (the "License").  You may not use this file except in compliance
# with the License.
#
# You can obtain a copy of the license at usr/src/OPENSOLARIS.LICENSE
# or http://www.opensolaris.org/os/licensing.
# See the License for the specific language governing permissions
# and limitations under the License.
#
# When distributing Covered Code, include this CDDL HEADER in each
# file and include the License file at usr/src/OPENSOLARIS.LICENSE.
# If applicable, add the following below this CDDL HEADER, with the
# fields enclosed by brackets "[]" replaced with your own identifying
# information: Portions Copyright [yyyy] [name of copyright owner]
#
# CDDL HEADER END
#
#
# Copyright 2011-2012 OmniTI Computer Consulting, Inc.  All rights reserved.
# Use is subject to license terms.
#
# Copyright (c) 2018 by Delphix. All rights reserved.
#
# Load support functions
. ../../lib/functions.sh
. ../../lib/gem-functions.sh

PROG=bundler      # App name
VER=1.16.1        # App version
VERHUMAN=$VER   # Human-readable version
PKG=library/ruby/bundler            # Package name (e.g. library/foo)
SUMMARY="Bundler: a gem to bundle gems"      # One-liner, must be filled in
DESC="$SUMMARY - $VER"         # Longer description, must be filled in

BUILD_DEPENDS_IPS="runtime/ruby-25"
DEPENDS_IPS="runtime/ruby-25"

REMOVE_PREVIOUS=1

RUNTIME_RUBY_VER=2.5.1
PREFIX="/opt/ruby/$RUNTIME_RUBY_VER"

init
download_source
patch_source
prep_build
build
make_isa_stub
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:
