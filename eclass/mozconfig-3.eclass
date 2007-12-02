# Copyright 1999-2004 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $
#
# mozconfig.eclass: the new mozilla.eclass

inherit multilib flag-o-matic mozcoreconf-3

IUSE="debug gnome ipv6 xinerama"
# xprint - disabled, see https://bugzilla.mozilla.org/show_bug.cgi?id=368844

RDEPEND="|| ( ( x11-libs/libXrender
		x11-libs/libXt
		x11-libs/libXmu
		)
		virtual/x11
	)
	>=media-libs/jpeg-6b
	>=media-libs/libpng-1.2.1
	dev-libs/expat
	app-arch/zip
	app-arch/unzip
	>=www-client/mozilla-launcher-1.42
	>=x11-libs/gtk+-2.8.6
	>=dev-libs/glib-2.8.2
	>=x11-libs/pango-1.10.1
	>=dev-libs/libIDL-0.8.0
	gnome? ( >=gnome-base/gnome-vfs-2.3.5
		>=gnome-base/libgnomeui-2.2.0 )
	!<x11-base/xorg-x11-6.7.0-r2
	>=x11-libs/cairo-1.4.2"

DEPEND="${RDEPEND}
	xinerama? ( || ( x11-proto/xineramaproto virtual/x11 ) )
	"
#	xprint? ( || ( x11-proto/printproto virtual/x11 ) )"

mozconfig_config() {
	mozconfig_use_enable ipv6
	mozconfig_use_enable xinerama
#	mozconfig_use_enable xprint

	# We use --enable-pango to do truetype fonts, and currently pango
	# is required for it to build
	mozconfig_annotate gentoo --disable-freetype2

	if use debug; then
		mozconfig_annotate +debug \
			--enable-debug \
			--enable-tests \
			--disable-reorder \
			--enable-debugger-info-modules=ALL_MODULES
	else
		mozconfig_annotate -debug \
			--disable-debug \
			--disable-tests \
			--enable-reorder \

		# Currently --enable-elf-dynstr-gc only works for x86 and ppc,
		# thanks to Jason Wever <weeve@gentoo.org> for the fix.
		if use x86 || use ppc && [[ ${enable_optimize} != -O0 ]]; then
			mozconfig_annotate "${ARCH} optimized build" --enable-elf-dynstr-gc
		fi
	fi

	if ! use gnome; then
		mozconfig_annotate -gnome --disable-gnomevfs
		mozconfig_annotate -gnome --disable-gnomeui
	fi
}