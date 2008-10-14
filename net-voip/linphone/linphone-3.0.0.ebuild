# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-voip/linphone/linphone-2.1.1.ebuild,v 1.2 2008/04/23 21:25:24 maekke Exp $

inherit eutils

DESCRIPTION="Voice Over IP phone (internet phone which uses SIP)"
HOMEPAGE="http://www.linphone.org/"
SRC_URI="http://download.savannah.nongnu.org/releases/${PN}/stable/sources/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="1"
KEYWORDS="~amd64 ~ppc ~x86"
IUSE="alsa arts console gsm gtk ilbc ipv6 portaudio video xv"
# XXX: Should "video" be split into ffmpeg/libsdl ?  They are two distinct
#      things: libsdl is just for video display while ffmpeg is just for
#      video capture ... but does anyone actually want a one-way linphone ?

RDEPEND="dev-libs/glib
	dev-perl/XML-Parser
	net-dns/bind-tools
	>=net-libs/libosip-3.0.3
	>=net-libs/libeXosip-3.0.3
	>=media-libs/speex-1.1.12
	gsm? ( >=media-sound/gsm-1.0.12-r1 )
	x86? ( xv? ( dev-lang/nasm ) )
	gtk? (
		>=x11-libs/gtk+-2
		gnome-base/libglade
	)
	alsa? ( media-libs/alsa-lib )
	arts? ( kde-base/arts )
	ilbc? ( dev-libs/ilbc-rfc3951 )
	video? (
		>=media-libs/libsdl-1.2.10
		media-video/ffmpeg
		>=media-libs/libtheora-1.0_alpha7
	)
	portaudio? ( >=media-libs/portaudio-19_pre )"
DEPEND="${RDEPEND}
	dev-util/pkgconfig"
# use the bundled ortp until newer versions leave package.mask
#	>=net-libs/ortp-0.9.0
# media-libs/gsm-1.0.12 fails on amd64 due to bug #192736

src_unpack() {
	unpack ${A}
	cd "${S}"

	epatch "${FILESDIR}"/linphone-2.0.1-speexdsp.patch #205893
	epatch "${FILESDIR}"/${P}-configure-gsm.patch
}

src_compile() {
	export ac_cv_path_DOXYGEN=false
	econf \
		--disable-manual \
		--disable-strict \
		--libdir=/usr/$(get_libdir)/linphone \
		--libexecdir=/usr/$(get_libdir)/linphone/exec \
		$(use_enable console console_ui) \
		$(use_enable gtk gtk_ui) \
		$(use_with ilbc) \
		$(use_enable ipv6) \
		$(use_enable alsa) \
		$(use_enable gsm) \
		$(use_enable video) \
		$(use_enable portaudio) \
		$(use_enable x86 truespeech) \
		|| die "Unable to configure"
		#--enable-external-ortp \
		#$(use_enable arts artsc) seems to break configure for SPEEX
	emake || die "Unable to make"
}

src_install () {
	emake DESTDIR="${D}" install || die "Failed to install"
	dodoc AUTHORS BUGS ChangeLog INSTALL NEWS README README.arm TODO

	# don't install mediastreamer/ortp includes, docs and pkgconfig files
	# to avoid conflicts with net-libs/ortp
	rm -r "${D}"/usr/include/{mediastreamer2,ortp} || die
	rm -r "${D}"/usr/$(get_libdir)/linphone/pkgconfig/{mediastreamer,ortp}.pc || die
	mv "${D}"/usr/$(get_libdir)/{linphone/,}pkgconfig || die
}
