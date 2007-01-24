# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/allegro/allegro-4.2.0-r2.ebuild,v 1.2 2006/11/01 08:51:16 nyhm Exp $

inherit flag-o-matic eutils

DESCRIPTION="cross-platform multimedia library, tweaked for GP2X"
HOMEPAGE="http://alleg.sourceforge.net/"
SRC_URI="mirror://sourceforge/alleg/${P}.tar.gz"

LICENSE="Allegro"
SLOT="0"
# Tuned for GP2X, not tested elsewhere!
KEYWORDS="~arm"
IUSE="X alsa arts doc esd fbcon mmx oss sse svga tetex"

RDEPEND="alsa? ( media-libs/alsa-lib )
	esd? ( media-sound/esound )
	arts? ( kde-base/arts )
	alsa? ( media-libs/alsa-lib )
	X? ( x11-libs/libX11
		x11-libs/libXcursor
		x11-libs/libXext
		x11-libs/libXpm
		x11-libs/libXt
		x11-libs/libXxf86dga
		x11-libs/libXxf86vm )
	svga? ( media-libs/svgalib )"
DEPEND="${RDEPEND}
	tetex? ( virtual/tetex )
	X? ( x11-proto/xextproto
		x11-proto/xf86dgaproto
		x11-proto/xf86vidmodeproto
		x11-proto/xproto )"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch \
		"${FILESDIR}"/${P}-exec-stack.patch \
		"${FILESDIR}"/${P}-flags.patch \
		"${FILESDIR}"/gp2xallegro-0.3.diff \
		"${FILESDIR}"/allegro-joybuttons.patch

}

src_compile() {
	filter-flags -fPIC -fprefetch-loop-arrays
	econf \
		--enable-lgp2x \
		--enable-static \
		--disable-modules \
		--disable-shared \
		$(use_enable oss ossdigi) \
		$(use_enable alsa alsadigi) \
		$(use_enable esd esddigi) \
		$(use_enable arts artsdigi) \
		$(use_with X x) \
		$(use_enable X xwin-shm) \
		$(use_enable X xwin-vidmode) \
		$(use_enable X xwin-dga) \
		$(use_enable X xwin-dga2) \
		$(use_enable fbcon) \
		$(use_enable svga svgalib) \
		|| die

	emake -j1 CFLAGS="${CFLAGS}" || die "emake failed"

	if use tetex ; then
		addwrite /var/lib/texmf
		addwrite /usr/share/texmf
		addwrite /var/cache/fonts
		emake docs-dvi docs-ps || die
	fi
}

src_install() {
	addpredict /usr/share/info
	emake -j1 DESTDIR="${D}" \
		install \
		|| die "emake install failed"

	# Different format versions of the Allegro documentation
	dodoc AUTHORS CHANGES THANKS readme.txt todo.txt
	use tetex && dodoc docs/allegro.{dvi,ps}
	use doc && dodoc examples/*
	dohtml docs/html/*
	docinto txt
	dodoc docs/txt/*.txt
	docinto rtf
	dodoc docs/rtf/*.rtf
	docinto build
	dodoc docs/build/*.txt
}

pkg_postinst() {
	ewarn "\"revdep-rebuild\" must be run now for applications already"
	ewarn "using allegro to continue to work."
	ewarn "revdep-rebuild is part of the gentoolkit package."
	ewarn "(Run \"emerge gentoolkit\" if revdep-rebuild isn't already"
	ewarn " available on your system.)"
	ewarn
}