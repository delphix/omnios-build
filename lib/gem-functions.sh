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

# Adapted from ms branch build/chef/build.sh

DEPENDS_IPS="runtime/ruby-25"
BUILD_DEPENDS_IPS="gnu-coreutils"

GEM_BIN=/usr/bin/gem
RUBY_VER=2.5.0

# Place your ordered list of dependencies in this var

GEM_DEPENDS=""

# Optionally, provide a gemrc in your build dir/files/gemrc.

build() {
    logmsg "Building Ruby Gem..."

    if [[ -e $SRCDIR/files/gemrc ]]; then
        GEMRC=$SRCDIR/files/gemrc
    else
        GEMRC=$MYDIR/gemrc
    fi

    pushd $TMPDIR/$BUILDDIR > /dev/null
    GEM_HOME=${DESTDIR}${PREFIX}/lib/ruby/gems/${RUBY_VER}
    export GEM_HOME
    RUBYLIB=${DESTDIR}${PREFIX}/lib/ruby:${DESTDIR}${PREFIX}/lib/site_ruby/${RUBY_VER}
    export RUBYLIB
    GEM_BIN_DIR=${DESTDIR}${PREFIX}/bin
    export GEM_BIN_DIR
    logmsg "--- gem install $PROG-$VER"
    logcmd $GEM_BIN --config-file $GEMRC install \
         -r --no-rdoc --no-ri -w -n ${GEM_BIN_DIR} -i ${GEM_HOME} -v $VER $PROG || \
        logerr "Failed to gem install $PROG-$VER"
    for i in $GEM_DEPENDS; do
      GEM=${i%-[0-9.]*}
      GVER=${i##[^0-9.]*-}
      logmsg "--- gem install $GEM-$GVER"
      logcmd $GEM_BIN --config-file $GEMRC install \
        -r --no-rdoc --no-ri -w -n ${GEM_BIN_DIR} -i ${GEM_HOME} -v $GVER $GEM || \
        logerr "Failed to install $GEM-$GVER"
    done
    logmsg "--- Fixing include paths on binaries"
    for i in $GEM_BIN_DIR/*; do
      sed -e "/require 'rubygems'/ a\\
Gem.use_paths(Gem.dir, [\"/opt/ruby/2.5.1/lib/ruby/gems/${RUBY_VER}\"])\\
Gem.refresh\\
" $i >$i.tmp
      mv $i.tmp $i
      chmod +x $i
    done
    popd > /dev/null
}

download_source() {
    # Just make the temp build dir
    logcmd mkdir -p $TMPDIR/$PROG-$VER
}

#
# Patches a given Gem-version (argument)
# - assumes that the Gem is already installed via build() above
# - patch filename in series should have the given Gem-version prefix
#
patch_gem() {
    GEM_NAME=$1
    if [[ -z $GEM_NAME ]]; then
        logmsg "--- Gem name to be patched is not specified"
	return 1
    fi

    if ! check_for_patches "in order to apply them"; then
        logmsg "--- Not applying any gem patches"
    else
        logmsg "Checking gem patches for ${GEM_NAME}"
        GEMS_DIR=${DESTDIR}${PREFIX}/lib/ruby/gems/${RUBY_VER}/gems
        if [[ ! -d $GEMS_DIR/$GEM_NAME ]]; then
          logmsg "--- Gem ${GEM_NAME} directory not found"
          return 1
        fi

        # Read the series file for patch filenames
        exec 3<"$SRCDIR/$PATCHDIR/series" # Open the series file with handle 3
        pushd $GEMS_DIR/$GEM_NAME > /dev/null
        logmsg "Parsing series file for ${GEM_NAME}"
        while read LINE <&3 ; do
	    GEM=${LINE%-[0-9.]*}
	    GVER=${LINE//[^0-9.]/}
	    GVER=${GVER%.}
	    if [[ "${GEM_NAME}" == "${GEM}-${GVER}" ]]; then
		logmsg "Applying gem patches for ${GEM_NAME}"
                # Split Line into filename+args
		patch_file $LINE
	    fi
        done
        popd > /dev/null
        exec 3<&- # Close the file
    fi
    return 0
}
