# install_all.mk

build_mk = ../Script/build.mk

all:
	(cd Project  && make -f $(build_mk))
	
