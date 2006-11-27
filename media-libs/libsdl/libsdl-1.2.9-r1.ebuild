# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/libsdl/libsdl-1.2.9-r1.ebuild,v 1.12 2006/04/08 00:19:15 flameeyes Exp $

inherit flag-o-matic toolchain-funcs eutils libtool

DESCRIPTION="Simple Direct Media Layer, with Hardware Acceleration for GP2X"
HOMEPAGE="http://www.libsdl.org/"
SRC_URI="http://cafarelli.fr/gp2x/SDL-${PV}-paeryn.tar.gz"

LICENSE="LGPL-2"
SLOT="0"
# Tuned for GP2X, not tested elsewhere!
KEYWORDS="~arm"
# WARNING:
# if you have the noaudio, novideo, nojoystick, or noflagstrip use flags
# in USE and something breaks, you pick up the pieces.  Be prepared for
# bug reports to be marked INVALID.
IUSE="oss alsa esd arts nas X dga xv xinerama fbcon directfb ggi svga aalib opengl libcaca noaudio novideo nojoystick noflagstrip"

RDEPEND="!noaudio? ( >=media-libs/audiofile-0.1.9 )
	alsa? ( media-libs/alsa-lib )
	esd? ( >=media-sound/esound-0.2.19 )
	arts? ( kde-base/arts )
	nas? (
		media-libs/nas
		|| ( (
			x11-libs/libXt
			x11-libs/libXext
			x11-libs/libX11 )
		virtual/x11 ) )
	X? (
		|| ( (
			x11-libs/libXt
			x11-libs/libXext
			x11-libs/libX11 )
		virtual/x11 ) )
	directfb? ( >=dev-libs/DirectFB-0.9.19 )
	ggi? ( >=media-libs/libggi-2.0_beta3 )
	svga? ( >=media-libs/svgalib-1.4.2 )
	aalib? ( media-libs/aalib )
	libcaca? ( >=media-libs/libcaca-0.9-r1 )
	opengl? ( virtual/opengl )"
DEPEND="${RDEPEND}
	nas? (
		|| ( (
			x11-proto/xextproto
			x11-proto/xproto )
		virtual/x11 ) )
	X? (
		|| ( (
			x11-proto/xextproto
			x11-proto/xproto )
		virtual/x11 ) )
	x86? ( dev-lang/nasm )"

S=${WORKDIR}/SDL-${PV}-paeryn

src_unpack() {
	unpack ${A}
	cd "${S}"

	epatch "${FILESDIR}"/1.2.8-nobuggy-X.patch #30089
	epatch "${FILESDIR}"/libsdl-1.2.8-libcaca.patch #40224
	epatch "${FILESDIR}"/libsdl-1.2.8-sdl-config.patch
	epatch "${FILESDIR}"/libsdl-1.2.8-no-cxx.patch
	epatch "${FILESDIR}"/1.2.8-gcc4.patch
	epatch "${FILESDIR}"/${P}-gcc-mmx.patch #104437
	epatch "${FILESDIR}"/libsdl-1.2.9-no-exec-stack.patch
	epatch "${FILESDIR}"/libsdl-1.2.9-PIC-hermes-cpuid.patch
	epatch "${FILESDIR}"/libsdl-1.2.9-PIC-SDL_stretch.patch
	epatch "${FILESDIR}"/libsdl-1.2.9-PIC-hermes-call-dont-jump.patch
	epatch "${FILESDIR}"/libsdl-1.2.9-PIC-load-mmx-masks-from-stack.patch
	[[ $(gcc-major-version) != "2" ]] && epatch "${FILESDIR}"/libsdl-1.2.9-PIC-yuv-mmx.patch
	epatch "${FILESDIR}"/${P}-sdl-blit-mmx-check.patch #104533
	epatch "${FILESDIR}"/${P}-DirectFB-updates.patch
	epatch "${FILESDIR}"/${P}-endian-cvs-updates.patch

	./autogen.sh || die "autogen failed"
	elibtoolize
	epunt_cxx
}

src_compile() {
	local myconf=
	if [[ $(tc-arch) != "x86" ]] ; then
		myconf="${myconf} --disable-nasm"
	else
		myconf="${myconf} $(use_enable x86 nasm)"
	fi
	use noflagstrip || strip-flags
	use noaudio && myconf="${myconf} --disable-audio"
	use novideo \
		&& myconf="${myconf} --disable-video" \
		|| myconf="${myconf} --enable-video-dummy"
	use nojoystick && myconf="${myconf} --disable-joystick"

	local directfbconf="--disable-video-directfb"
	if use directfb ; then
		# since DirectFB can link against SDL and trigger a
		# dependency loop, only link against DirectFB if it
		# isn't broken #61592
		echo 'int main(){}' > directfb-test.c
		$(tc-getCC) directfb-test.c -ldirectfb 2>/dev/null \
			&& directfbconf="--enable-video-directfb" \
			|| ewarn "Disabling DirectFB since libdirectfb.so is broken"
	fi

	myconf="${myconf} ${directfbconf}"

	econf \
		--disable-dependency-tracking \
		--disable-rpath \
		--enable-events \
		--enable-cdrom \
		--enable-threads \
		--enable-timers \
		--enable-endian \
		--enable-file \
		--enable-cpuinfo \
		$(use_enable oss) \
		$(use_enable alsa) \
		$(use_enable esd) \
		$(use_enable arts) \
		$(use_enable nas) \
		$(use_enable X video-x11) \
		$(use_enable dga) \
		$(use_enable xv video-x11-xv) \
		$(use_enable xinerama video-x11-xinerama) \
		$(use_enable dga video-dga) \
		$(use_enable fbcon video-fbcon) \
		$(use_enable ggi video-ggi) \
		$(use_enable svga video-svga) \
		$(use_enable aalib video-aalib) \
		$(use_enable libcaca video-caca) \
		$(use_enable opengl video-opengl) \
		$(use_with X x) \
		${myconf} || die
	emake || die "emake failed"
}

src_install() {
	make DESTDIR="${D}" install || die "make install failed"
	dodoc BUGS CREDITS README README.GP2X README-SDL.txt README.CVS TODO WhatsNew
	dohtml -r ./
}
