# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils gnome2 versionator
MY_PN=$(get_version_component_range 1-2)

DESCRIPTION="Guake is a drop-down terminal for Gnome"
HOMEPAGE="http://guake-terminal.org/"
SRC_URI="http://guake-terminal.org/releases/${MY_PN}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=">=dev-lang/python-2.4
	dev-python/gnome-python
	dev-python/notify-python
	x11-libs/vte"

pkg_setup() {
	if ! built_with_use x11-libs/vte python ; then
		eerror "You must rebuild x11-libs/vte with python USE flag."
		die
	fi
}

src_unpack() {
	unpack ${A}
	cd "${S}"

	epatch "${FILESDIR}"/${P}-empty-path.patch
}
