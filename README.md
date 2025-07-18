# Ungoogled Chromium for Void Linux  
Ungoogled Chromium template and builds for Void Linux, based on the void-packages [chromium][1] template.

![GitHub release (latest by date)](https://img.shields.io/github/v/release/xJayMorex/ungoogled-chromium-void?style=flat-square)

## Content Overview

- [**Building from sources**](#building-from-source)
- [**Binary release**](#binary-release)
    - [Available builds](#available-builds)
    - [Installing the binary package](#installing-the-binary-package)
- [**Troubleshooting**](#troubleshooting)
    - [Musl crashes mitigation](#musl-crashes-mitigation)
    - [General tweaks](#general-tweaks)
- [**Credits**](#credits)

## Building from source

> **Note**
>
> *Consult void-packages [documentation][2] for more information about setting it up.*
>
> [*Quick start*][2a]
>
> [*Building packages natively for the musl C library*][2b]

The lazy way:

```shell
git clone --depth=1 https://github.com/xJayMorex/ungoogled-chromium-void.git
cd ungoogled-chromium-void
./build.sh
```

## Binary release

```shell
./xbps-src show-options ungoogled-chromium
=> ungoogled-chromium-135.0.7049.52_1: the following build options are set:
   clang: Use clang to build (ON)
   libcxx: Use bundled libc++ (ON)
   pipewire: Enable support for screen sharing for WebRTC via PipeWire (ON)
   pulseaudio: Enable support for the PulseAudio sound server (ON)
   vaapi: Enable support for VA-API (ON)
   debug: Build with debug symbols (OFF)
   drumbrake: WebAssembly Interpreter (OFF)
   lto: Enable Link Time Optimization (OFF)
   sndio: Enable support for the sndio sound server (OFF)
```

### Available builds

Available builds:

- x86_64
- x86_64-musl
- aarch64

### Installing the binary package

#### Method 1 - manual update

Download the `xbps` package from the [releases](//github.com/xJayMorex/ungoogled-chromium-void/releases) page, index and install the package:

```shell
xbps-rindex -a *.xbps
sudo xbps-install -vR $PWD ungoogled-chromium
```

#### Method 2 - updates handled by xbps-install

Add the releases page as a repository:

```shell
cat << EOF > /etc/xbps.d/20-ungoogled-chromium.conf
repository=https://github.com/xJayMorex/ungoogled-chromium-void/releases/latest/download
EOF
xbps-install -Su ungoogled-chromium
```

First `xbps-install -S` run it will ask to import the repository key, same as [8e:9c:f9:9a:cd:77:2a:3c:25:54:61:c1:36:25:f0:4f.plist](void-packages/common/repo-keys/8e:9c:f9:9a:cd:77:2a:3c:25:54:61:c1:36:25:f0:4f.plist).

## Troubleshooting

- Although it is not included in the run dependencies, `gtk+3` package must be installed.
- To enable VAAPI add `--enable-features=VaapiVideoDecoder` to `CHROME_FLAGS` [environment variable][3].  
  More info [vaapi.md][4]. Also check [Void Handbook][5] in case of problems.
- For VAAPI `--disable-features=UseChromeOSDirectVideoDecoder` might also be needed.  
  Check in `chrome://gpu` if `Video Decode: Hardware accelerated`.

### Musl crashes mitigation

- Make sure you have `dbus` running (on glibc it doesn't matter).  
  Symptoms: crashes, pages stalling and refusing to load until browser restart, plugin crashes.
- Try adding `--js-flags=--jitless` to `CHROME_FLAGS`. If nothing else, it's a security hardening option.

### General tweaks

- Lower ram usage: `--renderer-process-limit=2` [renderer-process-limit][6].
- Reduce disk activity: `--disk-cache-size=1 --v8-cache-options=none` [disk-cache-size][7], [v8-cache-options][8].
- Dark Mode: `chrome://flags/#enable-force-dark`.
- Global media controls can cause crashes either by opening or closing it, as described in this [issue][9].  
  Either avoid using the feature or disable it completely (`--disable-features=GlobalMediaControls`).

## Credits

- [Ungoogled Chromium](//github.com/ungoogled-software/ungoogled-chromium)
- [Ungoogled Chromium Void upstream](//github.com/DAINRA/ungoogled-chromium-void)
- [The Void source packages collection](//github.com/void-linux/void-packages)
- [The Void (Linux) distribution](//voidlinux.org/)

[1]:  //github.com/void-linux/void-packages/blob/master/srcpkgs/chromium
[2]:  //github.com/void-linux/void-packages/#readme
[2a]: //github.com/void-linux/void-packages/#quick-start
[2b]: //github.com/void-linux/void-packages/#building-for-musl
[3]:  //wiki.archlinux.org/title/Environment_variables
[4]:  //chromium.googlesource.com/chromium/src/+/refs/heads/main/docs/gpu/vaapi.md
[5]:  //docs.voidlinux.org/config/graphical-session/graphics-drivers/intel.html
[6]:  //peter.sh/experiments/chromium-command-line-switches/#renderer-process-limit
[7]: //peter.sh/experiments/chromium-command-line-switches/#disk-cache-size
[8]: //peter.sh/experiments/chromium-command-line-switches/#v8-cache-options
[9]: //bugs.chromium.org/p/chromium/issues/detail?id=1314342
