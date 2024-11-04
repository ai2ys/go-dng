# This makefile pulls down the source code, tweaks it, and then
# calls make on other makefiles (in ../build) to build things

include ../build/common.make

all: fetch libs dng_validate
	ls -l ./bin
	@echo "\n*** success ***\n"


DNGSDK_FILE = dng_sdk_$(VERSION_DNG_SDK_).zip
ZLIB_FILE   = zlib-1.2.13.tar.gz

ZLIB        = zlib-1.2.13
EXPAT       = libexpat


# Targets to fetch / unpack / tweak source code for linux
#
$(DNGSDK_FILE):
	wget https://download.adobe.com/pub/adobe/dng/dng_sdk_$(VERSION_DNG_SDK_).zip

$(ZLIB_FILE):
	wget https://www.zlib.net/fossils/zlib-1.2.13.tar.gz

dngsdk: $(DNGSDK_FILE)
	unzip $(DNGSDK_FILE)

zlib: $(ZLIB_FILE)
	tar zxf $(ZLIB_FILE)
	cp $(ZLIB)/*.[ch] $(DNGSDK)/xmp/toolkit/third-party/zlib

expat:
	git clone https://github.com/libexpat/libexpat.git
	cp  $(EXPAT)/expat/lib/* $(DNGSDK)/xmp/toolkit/XMPCore/third-party/expat/public/lib/

patch:
	sed -i '31i #include <cstring>' $(DNGSDK)/xmp/toolkit/source/XMPStream_IO.cpp
	rm $(DNGSDK)/xmp/toolkit/source/Host_IO-Win.cpp
	rm $(DNGSDK)/xmp/toolkit/XMPFiles/source/PluginHandler/OS_Utils_Mac.cpp
	rm $(DNGSDK)/xmp/toolkit/XMPFiles/source/PluginHandler/OS_Utils_WIN.cpp

fetch: dngsdk zlib expat patch


# Targets to build the libraries
#
libxmp:
	cd $(DNGSDK)/xmp/toolkit; \
	make -f ../../../../build/xmp.make $(XMP_LIB)
	cp $(DNGSDK)/xmp/toolkit/$(XMP_LIB) ./lib

libdng:
	cd $(DNGSDK)/dng_sdk/source; \
	make -f ../../../../build/dng.make $(DNG_LIB)
	cp $(DNGSDK)/dng_sdk/source/$(DNG_LIB) ./lib
	cp $(DNGSDK)/dng_sdk/source/*.h ./include

libs: libxmp libdng


# Target to build Adobe's command line tool, dng_validate
#
dng_validate:
	cd $(DNGSDK)/dng_sdk/source; \
	make -f ../../../../build/dng.make dng_validate
	mv $(DNGSDK)/dng_sdk/source/dng_validate ./bin

clean:
	rm -rf $(DNGSDK) $(EXPAT) $(ZLIB) 

realclean: clean
	rm -rf $(DNGSDK_FILE) $(ZLIB_FILE) ./lib/* ./bin/* ./include/*
