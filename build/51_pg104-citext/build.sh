#
# Copyright (c) 2018 by Delphix. All rights reserved.
#

VER=10.4
PKG=omniti/database/5.1/postgresql-104/citext
export DLPX51_CITEXT_PKG=omniti/database/5.1/postgresql-104/citext
export DLPX51_CITEXT_PREFIX=/opt/5.1/pgsql${VER//./}
source ../pg104-citext/build.sh
