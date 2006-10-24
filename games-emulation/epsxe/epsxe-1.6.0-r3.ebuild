# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/games-emulation/epsxe/epsxe-1.6.0-r3.ebuild,v 1.8 2006/09/18 00:11:09 mr_bones_ Exp $

inherit games

DESCRIPTION="ePSXe Playstation Emulator"
HOMEPAGE="http://www.epsxe.com/"
SRC_URI="http://www.epsxe.com/files/epsxe${PV//.}lin.zip"

LICENSE="freedist"
SLOT="0"
KEYWORDS="-* ~amd64 x86"
IUSE="opengl"
RESTRICT="strip" # For some strange reason, strip truncates the whole file

DEPEND="app-arch/unzip"
RDEPEND=">=dev-libs/glib-1.2
	=x11-libs/gtk+-1.2*
	=sys-libs/ncurses-5*
	=sys-libs/zlib-1*
	net-misc/wget
	x11-misc/imake
	!amd64? (games-emulation/psemu-peopsspu
	|| (
		opengl? ( games-emulation/psemu-gpupetemesagl )
		games-emulation/psemu-peopssoftgpu
	))
	amd64? (app-emulation/emul-linux-x86-gtklibs)"

S=${WORKDIR}

src_install() {
	local dir=${GAMES_PREFIX_OPT}/${PN}
	dogamesbin "${FILESDIR}"/epsxe
	sed -i \
		-e "s:GAMES_PREFIX_OPT:${GAMES_PREFIX_OPT}:" \
		-e "s:GAMES_LIBDIR:${GAMES_LIBDIR}:" \
		"${D}${GAMES_BINDIR}/epsxe" \
		|| die "sed failed"
	exeinto "${dir}"
	insinto "${dir}"
	doexe epsxe || die "doexe failed"
	doins keycodes.lst || die "doins failed"
	insinto "${GAMES_LIBDIR}/psemu/cheats"
	doins cheats/* || die "doins failed"
	dodoc docs/*
	games_make_wrapper epsxe ./epsxe "${dir}" "${dir}"
	prepgamesdirs
}
