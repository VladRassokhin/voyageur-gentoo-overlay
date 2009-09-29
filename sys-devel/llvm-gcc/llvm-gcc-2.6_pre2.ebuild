# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=2
inherit multilib

LLVM_GCC_VERSION=4.2
MY_PV=${LLVM_GCC_VERSION}-${PV/_pre*}

DESCRIPTION="LLVM C front-end"
HOMEPAGE="http://llvm.org"
#SRC_URI="http://llvm.org/releases/${PV}/${PN}-${MY_PV}.source.tar.gz"
SRC_URI="http://llvm.org/prereleases/${PV/_pre*}/pre-release${PV/*_pre}/${PN}-${MY_PV}.source.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2"
SLOT=0
KEYWORDS="~amd64 ~x86"
IUSE="bootstrap fortran nls objc objc++ test"

RDEPEND=">=sys-devel/llvm-$PV"
DEPEND="${RDEPEND}
	>=sys-apps/texinfo-4.2-r4
	>=sys-devel/binutils-2.18
	>=sys-devel/bison-1.875
	test? ( dev-util/dejagnu )"

S=${WORKDIR}/llvm-gcc${MY_PV}.source/obj

src_prepare() {
	#we keep the directory structure suggested by README.LLVM,
	mkdir -p "${S}"
}

src_configure() {
	# Target options are handled by econf

	EXTRALANGS=""
	use fortran && EXTRALANGS="${EXTRALANGS},fortran"
	use objc && EXTRALANGS="${EXTRALANGS},objc"
	use objc++ && EXTRALANGS="${EXTRALANGS},obj-c++"

	ECONF_SOURCE="${WORKDIR}"/llvm-gcc${MY_PV}.source econf --prefix=/usr/$(get_libdir)/${PN}/${MY_PV} \
		--program-prefix=${PN}-${MY_PV}- \
		--enable-llvm=/usr --enable-languages=c,c++${EXTRALANGS} \
		|| die "configure failed"
}

src_compile() {
	BUILDOPTIONS="LLVM_VERSION_INFO=${MY_PV}"
	use bootstrap && BUILDOPTIONS="${BUILDOPTIONS} bootstrap"
	emake ${BUILDOPTIONS} || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "installation failed"
	rm -rf "${D}"/usr/share/man/man7
	if ! use nls; then
		einfo "nls USE flag disabled, not installing locale files"
		rm -rf "${D}"/usr/share/locale
	fi
}
