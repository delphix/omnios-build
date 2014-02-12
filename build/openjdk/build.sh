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
# Copyright 2011-2013 OmniTI Computer Consulting, Inc.  All rights reserved.
# Use is subject to license terms.
# Copyright (c) 2014 by Delphix. All rights reserved.
#
# Load support functions
. ../../lib/functions.sh

PROG=openjdk
VER=0.5.11
UPDATE=21
BUILD=30
VERHUMAN="jdk7u${UPDATE}-b${BUILD}"

# Mercurial hash from jdk7u repo marking the desired update/build
# taken from http://hg.openjdk.java.net/jdk7u/jdk7u/file/tip/.hgtags
HGREV=450e8dde919df278fe75ae95e0eb0a6464f5bc41

PKG=
SUMMARY="OpenJDK 7.0 Dev. Tools (1.7.0_21)"
DESC="$SUMMARY"

BUILDARCH=32
DESTDIR=
DATETIME=`TZ=UTC /usr/bin/date +"%Y%m%dT%H%M%SZ"`

BUILD_DEPENDS_IPS="developer/sunstudio12.1 system/header/header-audio developer/versioning/mercurial runtime/java omniti/developer/build/ant omniti/library/freetype2"
RUN_DEPENDS_IPS="system/library shell/bash system/library/c++/sunpro library/unixodbc system/library/math"

REPO="http://hg.openjdk.java.net/jdk7u/jdk7u"
PATH=/opt/sunstudio12.1/bin:/opt/omni/bin:${PATH}
export PATH

ALT_BOOTDIR="/usr/java"
ALT_COMPILER_PATH="/opt/sunstudio12.1/bin"
ALT_CUPS_HEADERS_PATH="$TMPDIR/cups/include"
ALT_OPENWIN_HOME="$TMPDIR/openwin/X11"

DUPS_LIST=
J2RE_INSTALLTMP=
J2SDK_INSTALLTMP=

download_hg() {
    pushd $TMPDIR > /dev/null
    if [[ -d $BUILDDIR ]]; then
        logmsg "Removing existing checkout"
        logcmd rm -rf $BUILDDIR
    fi
    logmsg "Checking code out from $REPO"
    logcmd hg clone $REPO $BUILDDIR
    if [[ -n "$HGREV" ]]; then
        logmsg "--- updating to $HGREV"
        pushd $BUILDDIR > /dev/null
        logcmd hg checkout $HGREV
        popd > /dev/null
    fi
}

install_cups_headers() {
    logmsg "Installing CUPS headers for build"
    pushd $TMPDIR > /dev/null
    get_resource cups/cups-headers.tar.gz || \
        logerr "--- Failed to download cups-headers tarball"
    extract_archive cups-headers.tar.gz || \
        logerr "--- Failed to extract cups-headers tarball"
    popd > /dev/null
}

install_x11_headers() {
    logmsg "Installing openwin bits for build"
    pushd $TMPDIR > /dev/null
    get_resource Xstuff/openwin.tar.gz || \
        logerr "--- Failed to download openwin tarball"
    extract_archive openwin.tar.gz || \
        logerr "--- Failed to extract openwin tarball"
    popd > /dev/null
}

fetch_source() {
    logmsg "Fetching JDK source"
    pushd $TMPDIR/$BUILDDIR > /dev/null
    logcmd sh ./get_source.sh
    popd > /dev/null
}

build32() {
    pushd $TMPDIR/$BUILDDIR > /dev/null
    logmsg "Building 32-bit"
    export ISALIST="$ISAPART"
    $MAKE sanity \
        MILESTONE="fcs" \
        BUILD_NUMBER=b$BUILD \
        JDK_UPDATE_VERSION=$UPDATE \
        ARCH_DATA_MODEL=32 \
        BUILD_HEADLESS_ONLY=true \
        BUILD_HEADLESS=true \
        FULL_DEBUG_SYMBOLS=0 \
        ENABLE_FULL_DEBUG_SYMBOLS=0 \
        ALT_BOOTDIR=$ALT_BOOTDIR \
        ALT_COMPILER_PATH=$ALT_COMPILER_PATH \
        ALT_CUPS_HEADERS_PATH=$ALT_CUPS_HEADERS_PATH \
        ALT_UNIXCCS_PATH=/usr/bin \
        ALT_FREETYPE_HEADERS_PATH=/opt/omni/include \
        ALT_FREETYPE_LIB_PATH=/opt/omni/lib \
        ALT_OPENWIN_HOME=$ALT_OPENWIN_HOME || \
            logerr "--- make sanity failed"

    $MAKE all \
        MILESTONE="fcs" \
        BUILD_NUMBER=b$BUILD \
        JDK_UPDATE_VERSION=$UPDATE \
        ARCH_DATA_MODEL=32 \
        BUILD_HEADLESS_ONLY=true \
        BUILD_HEADLESS=true \
        FULL_DEBUG_SYMBOLS=0 \
        ENABLE_FULL_DEBUG_SYMBOLS=0 \
        ALT_BOOTDIR=$ALT_BOOTDIR \
        ALT_COMPILER_PATH=$ALT_COMPILER_PATH \
        ALT_CUPS_HEADERS_PATH=$ALT_CUPS_HEADERS_PATH \
        ALT_UNIXCCS_PATH=/usr/bin \
        ALT_FREETYPE_HEADERS_PATH=/opt/omni/include \
        ALT_FREETYPE_LIB_PATH=/opt/omni/lib \
        ALT_OPENWIN_HOME=$ALT_OPENWIN_HOME || \
            logerr "--- make failed"
    popd > /dev/null
    unset ISALIST
    export ISALIST
}

# j2re and j2sdk both deliver duplicate files. generate a list of these files
# so that the j2sdk package doesn't try to install files that are already being
# delivered by j2re
find_j2re_j2sdk_dups() {
    logmsg "Generating list of duplicate files in the JRE and SDK"
    pushd $TMPDIR/$BUILDDIR/build/solaris-i586 > /dev/null

    J2RE_LIST=`mktemp /tmp/openjdk-j2re-list.XXXXX`
    J2SDK_LIST=`mktemp /tmp/openjdk-j2sdk-list.XXXXX`
    DUPS_LIST=`mktemp /tmp/openjdk-dups-list.XXXXX`

    cd j2re-image
    find . -type f > $J2RE_LIST
    find . -type l >> $J2RE_LIST
    cd ..

    cd j2sdk-image
    find . -type f > $J2SDK_LIST
    find . -type l >> $J2SDK_LIST
    cd ..

    cat $J2RE_LIST $J2SDK_LIST | sort | uniq -d > $DUPS_LIST
    rm $J2RE_LIST $J2SDK_LIST

    popd > /dev/null
}


make_install_j2re() {
    J2RE_INSTALLTMP=`mktemp -d /tmp/openjdk_j2re_install_XXXXX`
    JAVA_INSTALL_ROOT=$J2RE_INSTALLTMP/usr/java

    logmsg "Installing JRE to $J2RE_INSTALLTMP"

    # make our base directories under /usr
    logcmd mkdir -p $JAVA_INSTALL_ROOT
    logcmd mkdir -p $J2RE_INSTALLTMP/usr/bin
    logcmd mkdir -p $J2RE_INSTALLTMP/usr/share/man/man1
    logcmd mkdir -p $J2RE_INSTALLTMP/usr/share/man/ja/man1
    logcmd mkdir -p $J2RE_INSTALLTMP/usr/share/man/ja_JP.PCK/man1
    logcmd mkdir -p $J2RE_INSTALLTMP/usr/share/man/ja_JP.UTF-8/man1

    # we end up with no jre/ directory in the j2re-image
    # directory, which is comically busted. fix that so packages
    # expecting things in a jre/ directory find them there.
    pushd $TMPDIR/$BUILDDIR/build/solaris-i586/j2re-image > /dev/null
    logcmd mkdir -p jre
    logcmd mv bin lib jre

    # and make sure that there are files in the bin/ directory
    logcmd mkdir bin
    logcmd cp jre/bin/* bin/

    # copy in our JRE files
    tar cf - . | (cd $JAVA_INSTALL_ROOT && tar xvf -)
    popd > /dev/null

    # set up /usr/java symlink
    pushd $J2RE_INSTALLTMP/usr >/dev/null
    logcmd ln -s ./java jre
    popd > /dev/null

    # set up java symlinks into /usr/bin
    pushd $J2RE_INSTALLTMP/usr/bin > /dev/null
    logcmd ln -s ../java/bin/* .
    popd > /dev/null

    # set up java symlinks into /usr/share/man
    pushd $J2RE_INSTALLTMP/usr/share/man > /dev/null
    cd man1 && logcmd ln -s ../../../java/man/man1/* . && cd ..
    cd ja/man1 && logcmd ln -s ../../../../java/man/ja/man1/* . && cd ../..
    cd ja_JP.PCK/man1 && logcmd ln -s ../../../../java/man/ja_JP.PCK/man1/* . && cd ../..
    cd ja_JP.UTF-8/man1 && logcmd ln -s ../../../../java/man/ja_JP.UTF-8/man1/* . && cd ../..
    popd > /dev/null
}

make_install_j2sdk() {
    J2SDK_INSTALLTMP=`mktemp -d /tmp/openjdk_j2sdk_install_XXXXX`
    JAVA_INSTALL_ROOT=$J2SDK_INSTALLTMP/usr/java

    logmsg "Installing SDK to $J2SDK_INSTALLTMP"

    # make our base directories under /usr
    logcmd mkdir -p $JAVA_INSTALL_ROOT
    logcmd mkdir -p $J2SDK_INSTALLTMP/usr/bin
    logcmd mkdir -p $J2SDK_INSTALLTMP/usr/share/man/man1
    logcmd mkdir -p $J2SDK_INSTALLTMP/usr/share/man/ja/man1
    logcmd mkdir -p $J2SDK_INSTALLTMP/usr/share/man/ja_JP.PCK/man1
    logcmd mkdir -p $J2SDK_INSTALLTMP/usr/share/man/ja_JP.UTF-8/man1

    # copy in our SDK files
    pushd $TMPDIR/$BUILDDIR/build/solaris-i586/j2sdk-image > /dev/null
    tar cf - . | (cd $JAVA_INSTALL_ROOT && tar xvf -)
    popd > /dev/null

    # kill off duplicate files
    find_j2re_j2sdk_dups

    pushd $JAVA_INSTALL_ROOT > /dev/null
    if [ -f $DUPS_LIST ]; then
        logmsg "Removing duplicate files from the SDK"
        for i in `cat $DUPS_LIST`; do
            rm -f $i
        done
    else
        logerr "--- No duplicates list found. This is a problem."
    fi

    rm $DUPS_LIST
    popd > /dev/null

    # set up java symlinks into /usr/bin
    pushd $J2SDK_INSTALLTMP/usr/bin > /dev/null
    logcmd ln -s ../java/bin/* .
    popd > /dev/null

    # set up java symlinks into /usr/share/man
    pushd $J2SDK_INSTALLTMP/usr/share/man > /dev/null
    cd man1 && logcmd ln -s ../../../java/man/man1/* . && cd ..
    cd ja/man1 && logcmd ln -s ../../../../java/man/ja/man1/* . && cd ../..
    cd ja_JP.PCK/man1 && logcmd ln -s ../../../../java/man/ja_JP.PCK/man1/* . && cd ../..
    cd ja_JP.UTF-8/man1 && logcmd ln -s ../../../../java/man/ja_JP.UTF-8/man1/* . && cd ../..
    popd > /dev/null
}

save_function clean_up clean_up_orig
clean_up() {
    clean_up_orig
    logmsg "Removing temporary stuff we installed"
    logcmd rm -rf $TMPDIR/cups
    logcmd rm -rf $TMPDIR/openwin
    logcmd rm -rf $J2RE_INSTALLTMP
    logcmd rm -rf $J2SDK_INSTALLTMP
}

init
download_hg
fetch_source
patch_source
#prep_build
install_cups_headers
install_x11_headers
build
make_install_j2re
make_install_j2sdk

# Build up a full VER for the package with all the numeric components
# The update number doesn't appear to zero-pad, but the build does
#VER=${VER}.${UPDATE}.${BUILD#0}

PKG=runtime/java
SUMMARY="Open-source implementation of the seventh edition of the Java SE Platform"
DESC="$SUMMARY"
DESTDIR=$J2RE_INSTALLTMP

# Assemble the runtime/java package
make_package

PKG=developer/java/jdk
SUMMARY="Open-source implementation of the seventh edition of the Java SDK"
DESC="$SUMMARY"
RUN_DEPENDS_IPS=runtime/java
DESTDIR=$J2SDK_INSTALLTMP

# Assemble the developer/java/jdk package
make_package

# Clean up our mess
clean_up

# Vim hints
# vim:ts=4:sw=4:et:
