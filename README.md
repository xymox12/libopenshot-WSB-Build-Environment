# Build Windows libopenshot in a Windows Sandbox (wsb)

LibOpenShot Repo and Windows Build docs: https://github.com/OpenShot/libopenshot

These are notes of modifications/cahnges that allowed me to build the library. The tests are still reporting errors so treat this as a WIP. 

1. Download MSYS2 and GIT installers into the folder alongside the wsb file
2. Change filenames & paths in wsb and ps1 file to match the location of these files.
2. Clone the libopenshot repositories to the wsb shared folder
3. The Windows SDK
   
   Downloading the offline version allows us to persist this large download between sandboxes. Once this has been done once, when starting new sandbox environments you only need to complete the final step.
   
	- Download the SDK launcher to the wsb shared folder: https://developer.microsoft.com/en-us/windows/downloads/sdk-archive/
	- In the host, launch  winsdksetup and choose to download. Download the SDK files to your "shared-path"/Windows_Kit
	- In the sandbox, browse to the Window_Kit folder and launch the winsdksetup within it
	- Choose (1) to install this time.

4. Mintty causes problems when run inside the sandbox. I tend to run MSYS2's bash via Powershell. The powershell script will log you in when the wsb is launched.  You can log in manually in a Sandbox Powershell shell using:
```
& "C:\msys64\usr\bin\bash.exe" -l -i
```
5.  Replace the pacman packages install step with:
 ```
pacman -S --needed --disable-download-timeout base-devel git mingw-w64-x86_64-python mingw-w64-x86_64-toolchain mingw-w64-x86_64-ffmpeg mingw-w64-x86_64-swig mingw-w64-x86_64-cmake mingw-w64-x86_64-doxygen mingw-w64-x86_64-zeromq mingw-w64-x86_64-python-qtpy  mingw-w64-x86_64-python-pip mingw-w64-x86_64-python-pyzmq mingw-w64-x86_64-rust mingw-w64-x86_64-cppzmq mingw-w64-x86_64-python-cx-freeze mingw-w64-x86_64-opencv mingw-w64-x86_64-catch  mingw-w64-x86_64-babl mingw-w64-x86_64-qt5-base mingw-w64-x86_64-qt5-svg mingw-w64-x86_64-imagemagick
```
Note: Many of the optional packages are included. Ruby (optional) has been removed as it causes conflicts when building libopenshot. Python is Python 3.12.10, and I do not follow the python downgrade step. 

6. `pip3 install httplib2 tinys3 github3.py==0.9.6 requests`
7. unittest and resvg are both git cloned to the shared directory e.g. /c/shared
8. Unittest: 
    - Change the cmake_minimum_required to 3.5 in CMakeLists.txt
		```
		diff --git a/CMakeLists.txt b/CMakeLists.txt
		index b4c75c9..5fd520d 100644
		--- a/CMakeLists.txt
		+++ b/CMakeLists.txt
		@@ -1,4 +1,4 @@
		-cmake_minimum_required(VERSION 3.0)
		+cmake_minimum_required(VERSION 3.5)
		project(UnitTest++ VERSION 2.1.0)

		option(UTPP_USE_PLUS_SIGN
		```
  - then run the build steps in the main doc:
	```
	cd unittest-cpp/builds
	cmake -G "MSYS Makefiles" -DCMAKE_MAKE_PROGRAM=mingw32-make -DCMAKE_INSTALL_PREFIX:PATH=/usr ../ 
	make
	make install
	```
9. Resvg: we need to revert to a version with the capi folder:
    -  git reset --hard v0.9.1
	-  A error happens if we do not include QPainterPath in bindings/resvg-qt/cpp/qt_capi.cpp
		```
		diff --git a/bindings/resvg-qt/cpp/qt_capi.cpp b/bindings/resvg-qt/cpp/qt_capi.cpp
		index cabda9d1..2a184b25 100644
		--- a/bindings/resvg-qt/cpp/qt_capi.cpp
		+++ b/bindings/resvg-qt/cpp/qt_capi.cpp
		@@ -3,6 +3,7 @@
		#include <QPainter>
		#include <QImageWriter>
		#include <QDebug>
		+#include <QPainterPath>

		#include "qt_capi.hpp"
		```
    - Build as per the main documentation... except the copy command for the dll is replaced by:
	 ```
	 cp target/release/resvg.dll /usr/bin
     cp target/release/libresvg.dll.a /usr/lib
	 ```
	- Continue as per docs with:
	```
	mkdir -p /usr/include/resvg/
	cp capi/include/*.h /usr/include/resvg/
	```

10. ASIO: Download and extract to the shared folder

11. Environmental variables are created in the MSYS2 bash shell. For the sake of simplicity, Windows paths are used:

	```
	export RESVGDIR='C:\msys64\usr'
	export UNITTEST_DIR='C:\msys64\usr'
	export LIBOPENSHOT_AUDIO_DIR='C:\msys64\usr'
	export ASIO_SDK_DIR='C:\shared\asiosdk_2.3.3_2019-06-14\common'
	export DXSDK_DIR='C:\Program Files (x86)\Microsoft SDKs'
	```

12. Build libopenshot-audio as described in docs.
    - `export LIBOPENSHOT_AUDIO_DIR='C:\msys64\usr'`  

13. Build libopenshot - Before following the instructions we need to modify 2 files in the libopenshot repo to prevent the build failing:

## src/AudioLocation.h

```
diff --git a/src/AudioLocation.h b/src/AudioLocation.h
index 415f5b10..e1194572 100644
--- a/src/AudioLocation.h
+++ b/src/AudioLocation.h
@@ -13,6 +13,7 @@
#ifndef OPENSHOT_AUDIOLOCATION_H
#define OPENSHOT_AUDIOLOCATION_H

+#include <cstdint>

namespace openshot
{
``` 

## src/CMakeLists.txt:

```
diff --git a/src/CMakeLists.txt b/src/CMakeLists.txt
index 6713d5a9..11875133 100644
--- a/src/CMakeLists.txt
+++ b/src/CMakeLists.txt
@@ -233,6 +233,7 @@ if (ENABLE_MAGICK)

	# Link with ImageMagick library
	target_link_libraries(openshot PUBLIC ImageMagick::Magick++)
+       target_link_libraries(openshot PUBLIC MagickCore-7.Q16HDRI)

	set(HAVE_IMAGEMAGICK TRUE CACHE BOOL "Building with ImageMagick support" FORCE)
	mark_as_advanced(HAVE_IMAGEMAGICK)
```

This should build now. 

	
 
	



