# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/embassy.eclass,v 1.17 2008/11/03 22:17:50 ribosome Exp $

# Creator of the original eclass
# Author Olivier Fisette <ofisette@gmail.com>
#
# Author of the next generation eclass
# Justin Lecher <jlec@gentoo.org>

# @ECLASS: emboss.eclass
# @MAINTAINER:
# sci-biology@gentoo.org
# jlec@gentoo.org
# @BLURB: Use this to easy install EMBOSS and EMBASSY programs (EMBOSS add-ons).
# @DESCRIPTION:
# The inheriting ebuild must set EAPI=4 and provide EBO_DESCRIPTION before the inherit line.
# KEYWORDS should be set. Additionally "(R|P)DEPEND"encies and other standard
# ebuild Variables can be extended (FOO+="BAR").
# The inheriting ebuild's name must begin with "emboss" or "embassy".
# Default installation of following DOCS="AUTHORS ChangeLog NEWS README"
#
# Example:
#
# EAPI="4"
#
# EBO_DESCRIPTION="applications from the CBS group"
#
# inherit emboss
#
# KEYWORDS="~amd64 ~ppc ~x86 ~amd64-linux ~x86-linux ~ppc-macos"


# @ECLASS-VARIABLE: EBO_DESCRIPTION
# @DESCRIPTION:
# Should be set. Completes the generic description of the embassy module as follows:
#
# EMBOSS integrated version of ${EBO_DESCRIPTION},
# e.g.
# "EMBOSS integrated version of applications from the CBS group"
#
# Defaults to the upstream name of the module.

# @ECLASS-VARIABLE: EBO_EAUTORECONF
# @DESCRIPTION:
# Set to 'no', if you don't want eautoreconf to be run after patching.
: ${EBO_EAUTORECONF:="yes"}

# @ECLASS-VARIABLE: EBO_EXTRA_ECONF
# @DEFAULT_UNSET
# @DESCRIPTION:
# Extra config options passed to econf, similar to EXTRA_ECONF.

case ${EAPI:-0} in
	4) ;;
	*) die "this eclass doesn't support < EAPI 4" ;;
esac

inherit autotools eutils multilib

HOMEPAGE="http://emboss.sourceforge.net/"
LICENSE="LGPL-2 GPL-2"

SLOT="0"
IUSE="mysql pdf png postgres static-libs X"

DEPEND="
	dev-libs/expat
	dev-libs/libpcre:3
	sci-libs/plplot
	sys-libs/zlib
	mysql? ( dev-db/mysql )
	pdf? ( media-libs/libharu )
	png? ( media-libs/gd[png] )
	postgres? ( dev-db/postgresql-base )
	X? ( x11-libs/libXt )"
RDEPEND="${DEPEND}"

if [[ ${PN} == embassy-* ]]; then
	# The EMBASSY package name, retrieved from the inheriting ebuild's name
	EN=${PN:8}
	# The full name and version of the EMBASSY package (excluding the Gentoo
	# revision number)
	EF=$(echo ${EN} | tr "[:lower:]" "[:upper:]")-${PV}
	: ${EBO_DESCRIPTION:=${EN}}
	DESCRIPTION="EMBOSS integrated version of ${EBO_DESCRIPTION}"
	SRC_URI="ftp://emboss.open-bio.org/pub/EMBOSS/${EF}.tar.gz -> embassy-${EN}-${PV}.tar.gz"
	DEPEND+=" >=sci-biology/emboss-6.3.1_p4[mysql=,pdf=,png=,postgres=,static-libs=,X=]"

	S="${WORKDIR}"/${EF}
fi

DOCS="AUTHORS ChangeLog NEWS README"

# @FUNCTION: emboss_src_prepare
# @DESCRIPTION:
# Does following things
#
#  1. Patches with "${FILESDIR}"/${PF}.patch, of present
#  2. Runs eautoreconf, unless EBO_EAUTORECONF is set to no
#

emboss_src_prepare() {
	[[ -f "${FILESDIR}"/${PF}.patch ]] && epatch "${FILESDIR}"/${PF}.patch
	[[ ${EBO_EAUTORECONF} == yes ]] && eautoreconf
}

# @FUNCTION: emboss_src_prepare
# @DESCRIPTION:
# runs econf with following options. Extra options can be passed by setting EBO_EXTRA_ECONF
#
#  $(use_with X x)
#  $(use_with png pngdriver)
#  $(use_with pdf hpdf)
#  $(use_with mysql mysql)
#  $(use_with postgres postgresql)
#  $(use_enable static-libs static)
#  --enable-large
#  --without-java
#  --enable-systemlibs
#  ${EBO_EXTRA_ECONF}

emboss_src_configure() {
	econf \
		$(use_with X x) \
		$(use_with png pngdriver) \
		$(use_with pdf hpdf) \
		$(use_with mysql mysql) \
		$(use_with postgres postgresql) \
		$(use_enable static-libs static) \
		--enable-large \
		--without-java \
		--enable-systemlibs \
		--docdir="${EPREFIX}/usr/share/doc/${PF}/" \
		${EBO_EXTRA_ECONF}
}

EXPORT_FUNCTIONS src_prepare src_configure
