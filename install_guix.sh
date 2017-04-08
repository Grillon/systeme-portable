#!/usr/bin/env bash
#quick & dirty
function download {
	echo "$0 has begun"
	cd /tmp
	wget  https://alpha.gnu.org/gnu/guix/guix-binary-0.12.0.x86_64-linux.tar.xz.sig
	wget https://alpha.gnu.org/gnu/guix/guix-binary-0.12.0.x86_64-linux.tar.xz
}
function verify {
	echo "$0 has begun"
	gpg --keyserver pgp.mit.edu --recv-keys BCA689B636553801C3C62150197A5888235FACAC
	gpg --verify guix-binary-0.12.0.system.tar.xz.sig
}
function install {
	echo "$0 has begun"
	echo "you have to do log as root"
	read a
	cd /tmp
	tar --warning=no-timestamp -xf \
		guix-binary-0.12.0.system.tar.xz
	mv var/guix /var/ && mv gnu /
}
function setRootProfile {
	echo "$0 has begun"
	ln -sf /var/guix/profiles/per-user/root/guix-profile \
		~root/.guix-profile
	ln -s ~root/.guix-profile/lib/systemd/system/guix-daemon.service \
		/etc/systemd/system/
}
function setUsersProfile {
	echo "$0 has begun"
	groupadd --system guixbuild
	for i in `seq -w 1 10`;
	do
		useradd -g guixbuild -G guixbuild           \
			-d /var/empty -s `which nologin`    \
			-c "Guix build user $i" --system    \
			guixbuilder$i;
	done
}
function startGuix {
	echo "$0 has begun"
	systemctl start guix-daemon && systemctl enable guix-daemon
}
function makeItAvailable {
	echo "$0 has begun"
	mkdir -p /usr/local/bin
	cd /usr/local/bin
	ln -s /var/guix/profiles/per-user/root/guix-profile/bin/guix
	mkdir -p /usr/local/share/info
	cd /usr/local/share/info
	for i in /var/guix/profiles/per-user/root/guix-profile/share/info/* ;
	do ln -s $i ; done
}
function activateHydraSubstitute {
	echo "$0 has begun"
	guix archive --authorize < ~root/.guix-profile/share/guix/hydra.gnu.org.pub
}
function installLocales {
	echo "$0 has begun"
	guix package -i glibc-locales
	export GUIX_LOCPATH=$HOME/.guix-profile/lib/locale
	#think I have to put it in .profile
}
function whatAboutNscd {
	echo "$0 has begun"
	echo "you should look at https://www.gnu.org/software/guix/manual/html_node/Application-Setup.html#Application-Setup"
}
function asianFonts {
	echo "$0 has begun"
	guix package -i font-adobe-source-han-sans:cn
	xset +fp ~/.guix-profile/share/fonts/truetype
	xlsfonts
}
function certificates {
	echo "$0 has begun"
	guix package -i nss-certs
}
function update {
	echo "Don\'t forget to update with \"guix pull\""
}
while getopts ":dcui" opt; do
	case $opt in
		\?)
			echo "Invalid option: -$OPTARG" >&2
			exit 1
			;;
		d)
			echo "download & verify"
			download && verify && exit 0
			exit 1
			;;
		c)
			echo "install certificate manager"
			certificates && exit 0
			exit 1
			;;
		u)
			echo "update guix"
			update && exit 0
			exit 1
			;;
		i) 
			echo "installation complete"
			install && setRootProfile && setUsersProfile && startGuix && makeItAvailable \
				&& activateHydraSubstitute && installLocales && whatAboutNscd && asianFonts && exit 0
			exit 1
			;;
	esac
done
