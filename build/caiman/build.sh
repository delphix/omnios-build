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

SHELL=/usr/bin/bash
export SHELL
SKIP_ROOT_CHECK=1
if [[ -n "$SUDO_USER" ]]; then
    echo "Don't run under sudo, just build as you"
    exit
fi

# Load support functions
. ../../lib/functions.sh

PROG=caiman
VER=$RELVER
PKG=caiman
SUMMARY="$PROG"
DESC="$SUMMARY"

#all of the ips depends should be available from OmniTI repos

BUILD_DEPENDS_IPS="developer/sunstudio12.1 system/boot/wanboot system/boot/wanboot/internal developer/build/onbld system/library developer/versioning/git developer/swig"

GIT=git

PKGSERVER=$PKGSRVR
PKGPREFIX=""
PREFIX=""
BUILDDIR=$PROG-$VER
CODEMGR_WS=$TMPDIR/$BUILDDIR/caiman
ON_CLOSED_BINS="$CODEMGR_WS/closed"
export ON_CLOSED_BINS

CAIMAN_CODEMGR_SEDSTRING="s/CODEMGR_WS=.*/CODEMGR_WS=`echo $CODEMGR_WS | sed 's/\//\\\\\//g'`/g"
CAIMAN_PKG_REDIST="PKGPUBLISHER_REDIST=omnios; export PKGPUBLISHER_REDIST;"
CAIMAN_PKG_BRANCH="PKGVERS_BRANCH=$PVER; export PKGVERS_BRANCH;"

sunstudio_location() {
    logmsg "Ensuring that Sun Studio is where Caiman thinks it is..."
    if [[ -d /opt/SUNWspro ]]; then
	logmsg "--- fake SUNWspro directory exists, good"
    else
	logmsg "--- making fake SUNWspro directory"
	logcmd mkdir -p /opt/SUNWspro || \
	    logerr "--- Error: failed to make directory"
    fi
    if [[ -L /opt/SUNWspro/sunstudio12.1 ]]; then
	logmsg "--- sunstudio12.1 link exists, good"
    else
	logmsg "--- soft-linking to /opt/sunstudio12.1"
        logcmd ln -s /opt/sunstudio12.1 /opt/SUNWspro/sunstudio12.1 || \
            logerr "--- Failed: ln -s /opt/sunstudio12.1/ /opt/SUNWspro"
    fi
}

#In order for the clone to work while running as root, you must have ssh'ed into the box with agent forwarding turned on.  Also the sudo'er file must either have the default, group, or user set to allow SSL_AUTH_SOCK.

clone_source(){
    logmsg "Creating build dir $TMPDIR/$BUILDDIR"
    logcmd mkdir -p $TMPDIR/$BUILDDIR || logerr "Failed to create build directory"
    logmsg "Entering $TMPDIR/$BUILDDIR"
    pushd $TMPDIR/$BUILDDIR > /dev/null 
    if [[ -d caiman ]]; then
        logmsg "Removing existing cloned repo"
        logcmd rm -rf caiman
    fi
    logmsg "Cloning OMNI caiman Source..."
    logcmd  $GIT clone anon@src.omniti.com:~omnios/core/caiman || \
        logerr "Failed to $GIT clone repo"
    logmsg "Leaving $TMPDIR/$BUILDDIR"
    popd > /dev/null 
}

modify_build_script() {
    logmsg "Entering $CODEMGR_WS"
    pushd $CODEMGR_WS > /dev/null
    logmsg "Changing omnios.sh variables to what we want them to be..."
    logcmd cp usr/src/tools/env/omnios.sh . || \
        logerr "Could not copy build environment"
    logcmd /usr/bin/sed -I -e $CAIMAN_CODEMGR_SEDSTRING omnios.sh || \
        logerr "/usr/bin/sed failed"
    logcmd `echo $CAIMAN_PKG_REDIST >> omnios.sh`
    logcmd `echo $CAIMAN_PKG_BRANCH >> omnios.sh`
    logmsg "Leaving $CODEMGR_WS"
    popd > /dev/null

}

closed_bins() {
    logmsg "Entering $CODEMGR_WS"
    pushd $CODEMGR_WS > /dev/null
    logmsg "Getting Closed Source Bins..."
    for bin in on-closed-bins.i386.tar.bz2 on-closed-bins-nd.i386.tar.bz2 ; do
        if [[ ! -f $bin ]]; then
	    get_resource illumos-gate/$bin || logerr "Unable to get $bin"
        fi
        logcmd tar xpf $bin
    done
    logmsg "Leaving $CODEMGR_WS"
    popd > /dev/null
}

build_pkgs() {
    logmsg "Entering $CODEMGR_WS"
    pushd $CODEMGR_WS > /dev/null
    logmsg "Building caiman pkgs..."
    # Use -W to avoid warnings making nightly.sh fail.
    logcmd /opt/onbld/bin/nightly -W omnios.sh || logerr "Nightly failed"
    logmsg "Leaving $CODEMGR_WS"
    popd > /dev/null
}

push_pkgs() {
    logmsg "Entering $CODEMGR_WS"
    pushd $CODEMGR_WS > /dev/null
    logmsg "Pushing caiman pkgs to $PKGSERVER..."
    logcmd pkgrecv -s packages/i386/nightly-nd/repo.redist/ -d $PKGSERVER 'pkg:/*'
    logmsg "Leaving $CODEMGR_WS"
    popd > /dev/null
}

init
prep_build
sunstudio_location
clone_source
modify_build_script
closed_bins
build_pkgs
push_pkgs
clean_up
