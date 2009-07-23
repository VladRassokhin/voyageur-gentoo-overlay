# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

inherit eutils distutils subversion

# No real source tarball... Use svn to get distutils
ESVN_REPO_URI="https://forge.betavine.net/svn/vodafonemobilec/tags/${P}"

DESCRIPTION="Vodafone Mobile Connect Card driver for Linux"
HOMEPAGE="https://forge.betavine.net/projects/vodafonemobilec/"
SRC_URI=""

LICENSE="GPL"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}
	>=dev-lang/python-2.5
	dev-python/twisted-conch
	dev-python/pyserial
	dev-python/pytz
	net-dialup/wvdial
	sys-apps/usb_modeswitch"