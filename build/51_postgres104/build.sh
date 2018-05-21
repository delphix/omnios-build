#
# Copyright (c) 2018 by Delphix. All rights reserved.
#

VER=10.4
PKG=omniti/database/5.1/postgresql-104
export DLPX51_POSTGRES_PKG=omniti/database/5.1/postgresql-104
export DLPX51_POSTGRES_PREFIX=/opt/5.1/pgsql${VER//./}
source ../postgres104/build.sh
