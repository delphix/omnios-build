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
# Copyright (c) 2014 by Delphix. All rights reserved.
#

# Load support functions
. ../../lib/functions.sh

PROG=jdk-7
VER=65
BUILDDIR=jdk1.7.0_$VER
VERHUMAN=$VER
PKG=developer/java/jdk-7
SUMMARY="Java Platform Standard Edition Development"
DESC="The Java Platform Standard Edition Development Kit (JDK) includes both the runtime environment (Java virtual machine, the Java platform classes and supporting files) and development tools (compilers, debuggers, tool libraries and other tools). The JDK is a development environment for building applications, applets and components that can be deployed with the Java Platform Standard Edition Runtime Environment."

BUILD_DEPENDS_IPS=pkg:/archiver/gnu-tar
RUN_DEPENDS_IPS=

init
prep_build

pushd $TMPDIR >/dev/null || logerr "Unable to cd to $TMPDIR."

get_resource jdk-7/jdk-7u$VER-solaris-i586.tar.gz || \
    logerr "jdk-7u$VER-solaris-i586.tar.gz not found"
get_resource jdk-7/jdk-7u$VER-solaris-x64.tar.gz || \
    logerr "jdk-7u$VER-solaris-x64.tar.gz not found"
get_resource jdk-7/UnlimitedJCEPolicyJDK7.zip || \
    logerr "UnlimitedJCEPolicyJDK7.zip not found"

mkdir $DESTDIR/opt || logerr "Unable to mkdir $DESTDIR/opt."

# As per the docs, install 32-bit jdk then 64-bit jdk.
gtar -z -x -C $DESTDIR/opt -f jdk-7u$VER-solaris-i586.tar.gz || \
    logerr "x86 untar failed"
gtar -z -x -C $DESTDIR/opt -f jdk-7u$VER-solaris-x64.tar.gz || \
    logerr "x64 untar failed"

# Install java7 unlimited strength crypto.
unzip -p UnlimitedJCEPolicyJDK7.zip UnlimitedJCEPolicy/US_export_policy.jar > \
    $DESTDIR/opt/$BUILDDIR/jre/lib/security/US_export_policy.jar || \
    logerr "US export install failed"
unzip -p UnlimitedJCEPolicyJDK7.zip UnlimitedJCEPolicy/local_policy.jar > \
    $DESTDIR/opt/$BUILDDIR/jre/lib/security/local_policy.jar || \
    logerr "local install failed"

# Remove files w/ X11 dependencies.
for file in \
   bin/amd64/appletviewer \
   bin/amd64/policytool \
   bin/appletviewer \
   bin/javaws \
   bin/policytool \
   jre/bin/amd64/policytool \
   jre/bin/javaws \
   jre/bin/policytool \
   jre/lib/amd64/libfontmanager.so \
   jre/lib/amd64/libjawt.so \
   jre/lib/amd64/libsplashscreen.so \
   jre/lib/amd64/libt2k.so \
   jre/lib/amd64/xawt/libmawt.so \
   jre/lib/i386/libfontmanager.so \
   jre/lib/i386/libjavaplugin_jni.so \
   jre/lib/i386/libjavaplugin_nscp.so \
   jre/lib/i386/libjavaplugin_oji.so \
   jre/lib/i386/libjavaplugin.so \
   jre/lib/i386/libjawt.so \
   jre/lib/i386/libsplashscreen.so \
   jre/lib/i386/libsunwjdga.so \
   jre/lib/i386/libt2k.so \
   jre/lib/i386/xawt/libmawt.so \
   jre/plugin/i386/ns4/libjavaplugin.so \
   jre/plugin/i386/ns7/libjavaplugin_oji.so
do
    rm $DESTDIR/opt/$BUILDDIR/$file || \
      logerr "Unable to rm $DESTDIR/opt/$BUILDDIR/$file."
done

popd >/dev/null

make_package
clean_up
