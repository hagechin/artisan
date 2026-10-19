# Native libraries in the h.coffee Apple Silicon bundle

This inventory records the non-system native libraries copied into `Contents/Frameworks` by the 2026-10-19 Apple Silicon build. The Python package inventory in the sibling `third-party-python` directory covers package-owned binary extensions and their vendored notices. Do not substitute this inventory for checking the actual output of a later build.

| Bundled binary | Source used for this build | License / notice |
| --- | --- | --- |
| `libcrypto.4.dylib`, `libssl.4.dylib` | Homebrew OpenSSL 4.0.3 | Apache License 2.0; `OpenSSL-LICENSE.txt`; [source](https://github.com/openssl/openssl) |
| `libmpdec.4.dylib` | Homebrew mpdecimal 4.0.1 | mpdecimal BSD-style terms; `mpdecimal-COPYRIGHT.txt`; [source](https://www.bytereef.org/mpdecimal/) |
| `libsnap7.dylib`, `snap7/lib/libsnap7.dylib` | Snap7 1.4.2 / python-snap7 package | LGPL 3.0 and incorporated GPL 3.0; `Snap7-LGPL-3.0.txt`, `GPL-3.0.txt`; [source](https://github.com/SCADACS/snap7) |
| `libusb-1.0.dylib` | Homebrew libusb 1.0.26 | LGPL 2.1; `libusb-LGPL-2.1.txt`; [source](https://github.com/libusb/libusb) |
| `libzstd.1.dylib` | Homebrew Zstandard 1.5.7 | BSD license; `zstd-LICENSE.txt`; [source](https://github.com/facebook/zstd) |
| `libsqlite3.dylib` | Homebrew SQLite 3.53.4 | [SQLite public-domain statement](https://www.sqlite.org/copyright.html); no license text is required by SQLite. |

The LGPL libraries are loaded as separate dynamic libraries. Their upstream source URLs are provided above. Original Artisan and h.coffee source are supplied alongside the build. System-provided Apple frameworks are not redistributed in this bundle.
