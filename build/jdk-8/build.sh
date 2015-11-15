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
# Copyright (c) 2015 by Delphix. All rights reserved.
#

# Load support functions
. ../../lib/functions.sh

PROG=jdk-8
VER=60
BUILDDIR=jdk1.8.0_$VER
VERHUMAN=$VER
PKG=developer/java/jdk-8
SUMMARY="Java Platform Standard Edition Development"
DESC="The Java Platform Standard Edition Development Kit (JDK) includes both the runtime environment (Java virtual machine, the Java platform classes and supporting files) and development tools (compilers, debuggers, tool libraries and other tools). The JDK is a development environment for building applications, applets and components that can be deployed with the Java Platform Standard Edition Runtime Environment."

BUILD_DEPENDS_IPS=pkg:/archiver/gnu-tar
RUN_DEPENDS_IPS=

init
prep_build

pushd $TMPDIR >/dev/null || logerr "Unable to cd to $TMPDIR."

get_resource jdk-8/jdk-8u$VER-solaris-x64.tar.gz || \
    logerr "jdk-8u$VER-solaris-x64.tar.gz not found"
get_resource jdk-8/jce_policy-8.zip || \
    logerr "jce_policy-8.zip not found"

mkdir $DESTDIR/opt || logerr "Unable to mkdir $DESTDIR/opt."

gtar -z -x -C $DESTDIR/opt -f jdk-8u$VER-solaris-x64.tar.gz || \
    logerr "x64 untar failed"

# Install java8 unlimited strength crypto.
unzip -p jce_policy-8.zip UnlimitedJCEPolicyJDK8/US_export_policy.jar \
    >$DESTDIR/opt/$BUILDDIR/jre/lib/security/US_export_policy.jar || \
    logerr "US export install failed"
unzip -p jce_policy-8.zip UnlimitedJCEPolicyJDK8/local_policy.jar \
    >$DESTDIR/opt/$BUILDDIR/jre/lib/security/local_policy.jar || \
    logerr "local install failed"

# Remove files w/ X11 dependencies.
for file in \
	bin/appletviewer \
	bin/amd64/appletviewer \
	bin/policytool \
	bin/amd64/policytool \
	jre/bin/policytool \
	jre/bin/amd64/policytool \
	jre/lib/amd64/libawt_xawt.so \
	jre/lib/amd64/libjawt.so \
	jre/lib/amd64/libsplashscreen.so \
	lib/amd64/libjawt.so
do
	rm $DESTDIR/opt/$BUILDDIR/$file || \
	    logerr "Unable to rm $DESTDIR/opt/$BUILDDIR/$file."
done

#
# Special case for JDK 8 Update 60:
#   jre/lib/amd64/libt2k.so depends on jre/lib/amd64/libawt_xawt.so and
#   jre/lib/amd64/libawt_xawt.so has several X11 dependencies
#
# The JDK containes two implementations of the AWT library dependency
# (i.e., both libraries have the same external symbols):
#   jre/lib/amd64/libawt_xawt.so
#   jre/lib/amd64/libawt_headless.so
#
# For DxOS, libt2k.so should use libawt_headless.so instead of
# libawt_xawt.so since the later has X11 dependencies.
#
# The fix is to link libawt_headless.so into the file system namespace
# at the location LD will look for the libawt_xawt.so dependency.
#
# NOTE: This is corrected in JDK 8 Update 66. In that release,
# libt2k.so depends on libawt_headless.so
#
if [ 60 -eq $VER ]; then
	ln -s libawt_headless.so $DESTDIR/opt/$BUILDDIR/jre/lib/amd64/libawt_xawt.so || \
	    logerr "Unable to create symlink for libawt_xawt.so"
fi

popd >/dev/null

make_package
clean_up
