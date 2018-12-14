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
# Copyright 2018 OmniTI Computer Consulting, Inc.  All rights reserved.
# Use is subject to license terms.
#

#
# Copyright (c) 2018 by Delphix. All rights reserved.
#

# Load support functions
. ../../lib/functions.sh

PROG=nginx
VER=1.15.7
PKG=web/nginx
SUMMARY="$PROG - A web server which can also be used as a reverse proxy, load balancer, mail proxy and HTTP cache."
DESC="$SUMMARY"

BUILD_DEPENDS_IPS="system/library/gcc-5-runtime"
RUN_DEPENDS_IPS="$DEPENDS_IPS"

PREFIX=/opt/nginx
reset_configure_opts
CC="gcc"

CONFIGURE_OPTS_32="--prefix=$PREFIX
    --with-http_ssl_module
    --with-http_sub_module
    --with-http_auth_request_module
    --with-http_realip_module
    --add-module=$(realpath $SRCDIR/files/headers-more-nginx-module-0.33)
    --with-debug"

CONFIGURE_OPTS_64="--prefix=$PREFIX
    --with-http_ssl_module
    --with-http_sub_module
    --with-http_auth_request_module
    --with-http_realip_module
    --with-cc-opt='-m64'
    --with-ld-opt='-m64'
    --add-module=$(realpath $SRCDIR/files/headers-more-nginx-module-0.33)
    --with-debug"

copy_man_page() {
    logcmd mkdir -p $DESTDIR/usr/share/man/man1
    logcmd cp $TMPDIR/$BUILDDIR/man/nginx.8 $DESTDIR/usr/share/man/man1
}

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
copy_man_page
make_isa_stub
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:
