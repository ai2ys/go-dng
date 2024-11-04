# Common and global things for the makefiles

CXXFLAGS    = -pipe -O0 -ggdb
LDFLAGS     = -ljpeg -lz -lpthread -ldl 
ARFLAGS     = crs
MAKEFLAGS   = --no-print-directory

DNGSDK      = dng_sdk_$(VERSION_DNG_SDK_)

DNG_LIB     = libdng.a
XMP_LIB     = libxmp.a
