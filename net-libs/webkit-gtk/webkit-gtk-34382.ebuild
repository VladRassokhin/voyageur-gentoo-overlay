# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=1

inherit autotools

DESCRIPTION="Open source web browser engine"
HOMEPAGE="http://www.webkit.org/"
MY_P="WebKit-r${PV}"
SRC_URI="http://nightly.webkit.org/files/trunk/src/${MY_P}.tar.bz2"

LICENSE="LGPL-2 LGPL-2.1 BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~ppc"
IUSE="coverage debug dom-storage gstreamer hildon pango soup sqlite +svg +svg-experimental +xslt"

S="${WORKDIR}/${MY_P}"

RDEPEND=">=x11-libs/gtk+-2.8
	dev-libs/icu
	>=net-misc/curl-7.15
	media-libs/jpeg
	media-libs/libpng
	dev-libs/libxml2
	sqlite? ( >=dev-db/sqlite-3 )
	gstreamer? (
		>=media-libs/gst-plugins-base-0.10
		>=gnome-base/gnome-vfs-2.0
		)
	soup? ( >=net-libs/libsoup-2.23 )
	xslt? ( dev-libs/libxslt )"

DEPEND="${RDEPEND}
	dev-util/gperf
	dev-util/pkgconfig"

src_unpack() {
	unpack ${A}
	cd "${S}"

	# Fix path for Gentoo plugins path
	sed -i -e 's#"browser"#"nsbrowser"#' WebCore/plugins/gtk/PluginDatabaseGtk.cpp || die "sed failed"
	sed -i -e 's#/browser/#/nsbrowser/#' WebCore/plugins/qt/PluginDatabaseQt.cpp || die "sed failed"

	eautoreconf
}

src_compile() {
	local myconf
		use pango && myconf="${myconf} --with-font-backend=pango"
		use soup && myconf="${myconf} --with-http-backend=soup"

	econf \
		$(use_enable sqlite database) \
		$(use_enable sqlite icon-database) \
		$(use_enable dom-storage) \
		$(use_enable gstreamer video) \
		$(use_enable svg-experimental) \
		$(use_enable svg) \
		$(use_enable debug) \
		$(use_with hildon) \
		$(use_enable xslt) \
		$(use_enable coverage) \
		${myconf} \
		|| die "configure failed"

	emake || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "Install failed"
}