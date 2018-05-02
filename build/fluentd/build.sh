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
# Copyright (c) 2018 by Delphix. All rights reserved.
#
# Load support functions
. ../../lib/functions.sh
. ../../lib/gem-functions.sh

PROG=fluentd    # App name
VER=1.2.0       # App version
VERHUMAN=$VER   # Human-readable version
PKG=application/fluentd            # Package name (e.g. library/foo)

SUMMARY="Fluentd"
DESC="$SUMMARY $VER"

BUILD_DEPENDS_IPS="runtime/ruby-25"
DEPENDS_IPS="runtime/ruby-25"

REMOVE_PREVIOUS=1

RUNTIME_RUBY_VER=2.5.1
PREFIX="/opt/ruby/$RUNTIME_RUBY_VER"

GEM_DEPENDS="fluent-plugin-splunk-http-eventcollector-0.3.0"

install_smf() {
    FLUENTD_CONF_DIR=$DESTDIR/etc/fluent
    FLUENTD_MANIFEST_DIR=$DESTDIR/lib/svc/manifest/site
    FLUENTD_METHOD_DIR=$DESTDIR/lib/svc/method

    logmsg "Installing SMF components"
    logcmd mkdir -p $FLUENTD_MANIFEST_DIR
    logcmd mkdir -p $FLUENTD_METHOD_DIR
    logcmd mkdir -p $FLUENTD_CONF_DIR
    logcmd cp $SRCDIR/files/fluentd.xml $FLUENTD_MANIFEST_DIR/delphix_fluentd.xml || \
		logerr "--- Failed to copy SMF manifest file"
    logcmd cp $SRCDIR/files/svc-fluentd $FLUENTD_METHOD_DIR/svc-fluentd || \
		logerr "--- Failed to copy SMF method file"
    logcmd cp $SRCDIR/files/fluent.conf.template $FLUENTD_CONF_DIR/fluent.conf || \
		logerr "--- Failed to copy fluentd template conf file"
}


init
download_source
prep_build
build
install_smf
make_isa_stub
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:
