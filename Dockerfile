FROM scientificlinux/sl:6

# To drop the output RPMs in /tmp:
#
# docker run --rm -it -v /tmp:/output osg-jglobus 

RUN yum -y install https://repo.opensciencegrid.org/osg/3.3/osg-3.3-el6-release-latest.rpm
RUN yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-6.noarch.rpm
RUN yum -y install yum-plugin-priorities

RUN yum -y install GConf2 alsa-lib atk avahi-libs cairo copy-jdk-configs cups-libs dbus-glib fontconfig fontpackages-filesystem freetype gdk-pixbuf2 giflib gsm gtk2 hicolor-icon-theme hwdata jasper-libs libICE libSM libX11 libX11-common libXau libXcomposite libXcursor libXdamage libXext libXfixes libXfont libXft libXi libXinerama libXrandr libXrender libXtst libXxf86vm libasyncns libdrm libfontenc libjpeg-turbo libogg libpciaccess libpng libsndfile libthai libtiff libvorbis libxcb libxshmfence mesa-libEGL mesa-libGL mesa-libgbm  pango pcsc-lite-libs \
perl perl-File-Temp perl-Pod-Escapes perl-Pod-Simple perl-Time-HiRes perl-libs perl-parent pixman polkit pulseaudio-libs tcp_wrappers-libs ttmkfdir tzdata-java xorg-x11-font-utils xorg-x11-fonts-Type1

RUN echo -e "[jpackage]\nname=jpackage\nbaseurl=http://mirrors.ibiblio.org/jpackage/6.0/generic/free\nenabled=1\ngpgcheck=0\npriority=95" > /etc/yum.repos.d/jpackage.repo

COPY apache-commons-logging-1.1.1-18.jpp6.noarch.rpm /tmp/
RUN yum -y localinstall /tmp/apache-commons-logging-1.1.1-18.jpp6.noarch.rpm 
RUN yum  -y --exclude=xml-commons-apis --setopt=obsoletes=0 install velocity msv msv-xsdlib ant apache-commons-collections apache-commons-discovery apache-commons-lang autoconf axis bouncycastle emi-trustmanager emi-trustmanager-axis java-1.7.0-openjdk-devel jetty-client jetty-continuation jetty-deploy jetty-http jetty-io jetty-security jetty-server jetty-servlet jetty-util jetty-webapp jetty-xml joda-time jpackage-utils log4j privilege-xacml slf4j voms-api-java wsdl4j xalan-j2 xml-security

RUN yum -y install osg-build koji

RUN yum -y install http://koji.chtc.wisc.edu/kojifiles/packages/maven22/2.2.1/23.4.1.osg.el6/noarch/maven22-2.2.1-23.4.1.osg.el6.noarch.rpm

RUN adduser -u 501 user -m
RUN usermod -a -G mock user

USER user
WORKDIR /home/user

RUN svn co https://vdt.cs.wisc.edu/svn/native/redhat/branches/osg-3.3/bestman2
RUN svn co https://vdt.cs.wisc.edu/svn/native/redhat/branches/osg-3.3/jglobus
#RUN cd; git clone https://github.com/jglobus/JGlobus.git; mv JGlobus jglobus-git

COPY protocols.patch jglobus/osg
COPY spec.patch jglobus/osg
RUN cd jglobus/osg; patch -p0 < spec.patch

#RUN echo "type=git url=/home/burt/jglobus-git name=jglobus tag=2.1.0.9bh hash=foo" > ~/jglobus/upstream/git_export.source

RUN mkdir /home/user/output 

CMD osg-build rpmbuild jglobus && cp jglobus/_build_results/*.rpm /home/user/output

