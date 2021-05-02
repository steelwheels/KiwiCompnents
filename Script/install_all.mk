# install_all.mk

build_mk = ../Script/build.mk

all:
	(cd Resource/Library && make)
	(cd Project  && make -f $(build_mk))

