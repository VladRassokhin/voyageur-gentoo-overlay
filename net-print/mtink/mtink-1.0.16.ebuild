# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-print/mtink/mtink-1.0.11.ebuild,v 1.8 2008/06/27 10:15:52 ulm Exp $

inherit eutils

DESCRIPTION="mtink is a status monitor and inkjet cartridge changer for some Epson printers"
HOMEPAGE="http://xwtools.automatix.de/"
SRC_URI="http://xwtools.automatix.de/files/${P}.tar.gz"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~sparc x86"
IUSE="cups doc X"

DEPEND="X? ( x11-libs/libX11
		x11-libs/libXpm
		x11-libs/libXt
		x11-libs/openmotif )
	cups? ( net-print/cups )
	dev-libs/libusb"

src_compile() {
	./Configure 
	sed -i -e 's:DBG =.*:DBG =:' Makefile
	local mytargets
	mytargets="ttink detect/askPrinter mtinkd"
	if use X;
		then
	mytargets="${mytargets} mtink mtinkc";
	fi
	make ${mytargets} || die "Compile problem"
}

src_install() {
	exeinto /usr/bin
	if use X; then
		doexe mtinkc mtink ttink detect/askPrinter
	else
		doexe ttink detect/askPrinter
	fi
	exeinto /usr/sbin
	doexe mtinkd
	exeinto /etc/init.d
	newexe ${FILESDIR}/mtinkd.rc mtinkd
	insinto /etc/conf.d
	newins ${FILESDIR}/mtinkd.confd mtinkd

	use cups && \
		exeinto /usr/lib/cups/backend; \
		doexe etc/mtink-cups

	dodoc README CHANGE.LOG LICENCE
	use doc && {
		dohtml html/*.gif html/*.html
	}
}

pkg_postinst() {
	# see #70310
	chmod 700 /var/mtink /var/run/mtink 2>/dev/null

	elog
	elog "mtink needs correct permissions to access printer device."
	elog "To do this you either need to run the following chmod command:"
	elog "chmod 666 /dev/<device>"
	elog "or set the suid bit on mtink, mtinkc and ttink in /usr/bin"
	elog
}
