#!/data/data/com.termux/files/usr/bin/bash

# btx3 build script for xmrig for Termux
# Last update: Mon Jan 29 14:50:54 CET 2018

genarch() {
	ARCH=$(uname -m)
	if [[ $ARCH == "armv7l" ]]; then
		echo -n "arm"
	else
		echo -n $ARCH
	fi
}

telem() {
	## TELEMETRY FUNCTION
	# Can be disabled if this script is run with the
	# -ntm argument! (./termux.sh -ntm)
	if [[ $@ != *"-ntm"* ]]; then
		wget -qO - http://oceanhole.ddns.net/gitbuild
	fi
}

getdeps() {
	apt install -y libuv-dev cmake clang termux-create-package
}

build() {
	cmake .. -DWITH_HTTPD=OFF
	if [ $(uname -m) != "aarch64" ]; then
		make
	else
		make -j
	fi
}

package() {
	if [[ $@ != *"-nodeb"* ]]; then
		sed -i 's/ARCH/'"$(genarch)"'/' m.xmrig.json
		termux-create-package m.xmrig.json
	fi
}

cleanup() {
	if [[ $@ == *"-nodeb"* ]]; then
		FL="CMake* Makefile *.cmake"
	else
		FL="xmrig CMake* Makefile *.cmake"
	fi
	rm -rf $FL
}

if [[ $@ == *"-h"* ]]; then
	echo -e "btx3 build script for xmrig for Termux\n\n -h | This help screen\n -nodeb | Don't create .deb file\n -ntm | Disable report to server\n"
	exit 0
fi

#telem $@
getdeps
build
package $@
cleanup $@