#
# Copyright (c) 2018 by Delphix. All rights reserved.
#

VER=10.4
PKG=omniti/database/5.1/postgresql-104/vacuumlo
export DLPX51_VACUUMLO_PKG=omniti/database/5.1/postgresql-104/vacuumlo
export DLPX51_VACUUMLO_PREFIX=/opt/5.1/pgsql${VER//./}
source ../pg104-vacuumlo/build.sh
