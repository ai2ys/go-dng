# The DNG SDK for linux & go

Adobe's DNG SDK comes with only partial support for building on Linux.
The makefiles in this repo will fetch, patch, and compile version 1.7.1 of the
SDK on Linux (tested on Ubuntu 23.04), building the SDK as two static
libraries that end up in `./sdk/lib` and `./sdk/include`.

It also compiles the SDK's `dng_validate` command, so you can use it
on Linux.

## Building the SDK on Linux

```sh
sudo apt update && apt install \
    build-essential \
    zlib1g-dev \
    libexpat1-dev \
    libjpeg-dev

git clone https://github.com/abworrall/go-dng.git
cd go-dng

cd ./sdk
make

./bin/dng_validate -v your.dng
```

Indebted to https://github.com/yanburman/dng_sdk, who did all the work
for v1.4

Caveats:
- the makefiles aren't smart
- completely ignores all the CMake stuff in the bundled XML library

## Using the SDK from Go

This repo contains a Go wrapper around the lib, that will load and
DNG-develop a DNG file, and present it as a standard golang
`image.Image`.

There isn't a way to make `go get` work automatically with this
package, as building the SDK libs require running a makefile. So there
are a few steps ...

- step 1: build the SDK, as per the section above.
- step 2: tell the go toolchain where to find the freshly built SDK
- step 3: now you can `go get github.com/abworrall/go-dng` and it will work

```sh
sudo apt install build-essentials zlib1g-dev libexpat1-dev

# Step 1: build the SDK
git clone https://github.com/abworrall/go-dng.git
cd go-dng
cd ./sdk
make
export SDK=`pwd`

# Step 2: tell the go toolchain where the SDK is
export CGO_CPPFLAGS=-I${SDK}/include
export CGO_LDFLAGS=-L${SDK}/lib

# Step 3: use go toolchain to install package, develop, etc
cd ~/my_repos/my_package/
go get github.com/abworrall/go-dng
go run foo/bar
```

You can install the lib & includes into your system dirs or anywhere
else; just make sure the go toolchain can find them.

If you see an error like this when running your go code, or one about
missing `dng` or `xmp` libraries, then the go toolchain can't find the
SDK includes:

```
$ go test
# github.com/abworrall/go-dng/pkg/dng
dng-wrapper.cpp:3:10: fatal error: dng_color_space.h: No such file or directory
    3 | #include "dng_color_space.h"
      |          ^~~~~~~~~~~~~~~~~~~
compilation terminated.
```

Caveats for the go wrapper:
- the Go bindings of the API are very incomplete, but easy to extend
- the DNG SDK is in C++, so everything needs to be wrapped into plain old C
- there will be memory leaks, esp in the image handling

### Working with rendered data

The DNG development process will render the image into sRGB, doing
white balance correction, camera color correction, etc.

```go
import "github.com/abworrall/go-dng/pkg/dng"

func main() {
  img := dng.Image{}
  //img.WhiteBalanceTemp = 5500; // Can override the white reference

  img.Load("my.dng") // `img` is an image.Image

  // See cmd/go-dng-validate/go-dng-validate.go for a longer example
}
```

## Working with Stage 3 data

The SDK provides access to image data at a few points in the
development process. Stage 1 is the raw sensor readings, stage 2 is
linearized but not-yet-demosaiced.

The stage 3 data is useful; it's been linearized and demosaiced, but
color corrections not yet applied - the stage 3 RGB values are in camera-native
space. You can also retrieve some color correction values from the
DNG, that account for the camera's development profile.

```go
import "github.com/abworrall/go-dng/pkg/dng"

func main() {
  img := dng.Image{ImageKind: dng.ImageStage3}
  img.Load("my.dng")

  // RGB representing a neutral white color, given the white reference point
  asShotNeutral := img.CameraWhite()

  // Matrix mapping camera native colors to 'profile connection space', CIEXYZ
  kindaForwardMatrix := img.CameraToPCS()
}
```
