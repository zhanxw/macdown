# MacDown

[![Build DMG](https://github.com/zhanxw/macdown/actions/workflows/build-dmg.yml/badge.svg)](https://github.com/zhanxw/macdown/actions/workflows/build-dmg.yml)

MacDown is an open source Markdown editor for macOS, released under the MIT
License. This fork adds native Apple Silicon support, keeps Intel support,
and fixes a crash when creating document toolbars. It requires macOS 12 or later.

The original project is [MacDownApp/macdown](https://github.com/MacDownApp/macdown).

## Install

1. Open the [Build DMG workflow](https://github.com/zhanxw/macdown/actions/workflows/build-dmg.yml)
   and select a successful run for `master`.
2. Download the `MacDown-universal-dmg` artifact (GitHub sign-in is required)
   and unzip it.
3. Open `MacDown-universal.dmg` and drag **MacDown.app** to **Applications**.

The DMG contains a universal app for Apple Silicon and Intel. Builds are
ad-hoc signed, without Apple notarization or a Developer ID certificate;
macOS may block the downloaded app until you approve it in **System Settings →
Privacy & Security**. Only approve builds you trust. The artifact also includes
a SHA-256 checksum file.

Upstream downloads and the Homebrew cask are separate from this fork and do
not include these changes. The app's existing updater still uses the upstream
feed; obtain updated builds of this fork from the workflow artifacts.

## Screenshot

![screenshot](assets/screenshot.png)

## License

MacDown is released under the terms of MIT License. You may find the content of the license [here](http://opensource.org/licenses/MIT), or inside the `LICENSE` directory.

You may find full text of licenses about third-party components in the `LICENSE` directory, or the **About MacDown** panel in the application.

The following editor themes and CSS files are extracted from [Mou](http://mouapp.com), courtesy of Chen Luo:

* Mou Fresh Air
* Mou Fresh Air+
* Mou Night
* Mou Night+
* Mou Paper
* Mou Paper+
* Tomorrow
* Tomorrow Blue
* Tomorrow+
* Writer
* Writer+
* Clearness
* Clearness Dark
* GitHub
* GitHub2

## Development

### Requirements

* macOS 12 or later (Apple Silicon or Intel)
* Full Xcode with the macOS SDK, selected with `xcode-select`
* Ruby 3.2 or later and Bundler 4 (the system Ruby is too old)
* Node.js 18 or later and npm

On Apple Silicon, Homebrew Ruby can be installed and selected with:

```sh
brew install ruby
export PATH="$(brew --prefix ruby)/bin:$PATH"
```

### Environment Setup

Run these commands in the repository root:

```sh
git submodule update --init --recursive
bundle config set --local path vendor/bundle
bundle install
bundle exec pod install
npm ci --prefix Tools/GitHub-style-generator
make -C Dependency/peg-markdown-highlight
```

Open `MacDown.xcworkspace` in Xcode, or build a locally signed native app:

```sh
./Tools/build-native.sh
open Build/Build/Products/Release/MacDown.app
```

The resulting app runs natively on the Mac used to build it, without Rosetta
on Apple Silicon. You can copy it to Applications when ready. Local builds
use ad-hoc signing; distributing to other Macs requires Developer ID signing
and notarization.

Release builds in Xcode use the standard architectures (`arm64` and `x86_64`).
To build both explicitly from the command line:

```sh
xcodebuild -workspace MacDown.xcworkspace -scheme MacDown \
  -configuration Release -derivedDataPath Build \
  ONLY_ACTIVE_ARCH=NO 'ARCHS=arm64 x86_64' CODE_SIGN_IDENTITY=- build
```

The deployment target is macOS 12 throughout the app and source dependencies.
Sparkle 1.27.3 supplies a universal framework while preserving the existing
updater API. The stylesheet generator uses Dart Sass instead of the obsolete
native `node-sass` extension.

### Automated DMG builds

[`.github/workflows/build-dmg.yml`](.github/workflows/build-dmg.yml) runs on pushes
to `master` or `main`, `v*` tags, pull requests, and manual **Run workflow** requests.
It installs the locked dependencies, runs the tests with Release optimization
on ARM64, builds both architectures, verifies the code signature and CPU
architectures, and packages the app with an Applications shortcut.

DMGs and checksums are retained as workflow artifacts for 30 days; test results
are retained for 7 days. Tag builds also produce artifacts; the workflow does
not create GitHub releases. No signing credentials are required.

After building the universal app with the command above, package it locally:

```sh
./Tools/package-dmg.sh
```

The output is `Build/DMG/MacDown-universal.dmg`. To package a native build instead:

```sh
./Tools/build-native.sh
./Tools/package-dmg.sh Build/Build/Products/Release/MacDown.app Build/DMG/MacDown-native.dmg
```

### Translation

Please help translation on [Transifex](https://www.transifex.com/macdown/macdown/).

![Transifex translation percentage](https://www.transifex.com/projects/p/macdown/resource/macdownxliff/chart/image_png/)

## Discussion

[![Gitter](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/MacDownApp/macdown)

Join our [Gitter channel](https://gitter.im/MacDownApp/macdown) if you have any problems with MacDown. Any suggestions are welcomed, too!

You can also [file an issue directly](https://github.com/MacDownApp/macdown/issues/new) on GitHub if you prefer so. But please, **search first to make sure no-one has reported the same issue already** before opening one yourself. MacDown does not update in your computer immediately when we make changes, so something you experienced might be known, or even fixed in the development version.

MacDown depends a lot on other open source projects, such as [Hoedown](https://github.com/hoedown/hoedown) for Markdown-to-HTML rendering, [Prism](http://prismjs.com) for syntax highlighting (in code blocks), and [PEG Markdown Highlight](https://github.com/ali-rantakari/peg-markdown-highlight) for editor highlighting. If you find problems when using those particular features, you can also consider reporting them directly to upstream projects as well as to MacDown’s issue tracker. I will do what I can if you report it here, but sometimes it can be more beneficial to interact with them directly.

## Tipping

If you find MacDown suitable for your needs, please consider [giving me a tip through PayPal](http://macdown.uranusjr.com/faq/#donation). Or, if you prefer to buy me a drink *personally* instead, just [send me a tweet](https://twitter.com/uranusjr) when you visit [Taipei, Taiwan](http://en.wikipedia.org/wiki/Taipei), where I live. I look forward to meeting you!

