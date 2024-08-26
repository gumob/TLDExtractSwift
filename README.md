[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg)](https://github.com/gumob/TLDExtractSwift)
[![Version](http://img.shields.io/cocoapods/v/TLDExtract.svg)](http://cocoadocs.org/docsets/TLDExtract)
[![Platform](http://img.shields.io/cocoapods/p/TLDExtract.svg)](http://cocoadocs.org/docsets/TLDExtract)
[![Build Status](https://travis-ci.com/gumob/TLDExtractSwift.svg?branch=master)](https://travis-ci.com/gumob/TLDExtractSwift)
[![codecov](https://codecov.io/gh/gumob/TLDExtractSwift/branch/master/graph/badge.svg)](https://codecov.io/gh/gumob/TLDExtractSwift)
![Language](https://img.shields.io/badge/Language-Swift%204.2-orange.svg)
![Packagist](https://img.shields.io/packagist/l/doctrine/orm.svg)

# TLDExtract
<code>TLDExtract</code> is a pure Swift library to allows you to get the public suffix of a domain name using [the Public Suffix List](http://www.publicsuffix.org). You can find alternatives for other languages at [publicsuffix.org](https://publicsuffix.org/learn/).<br/>

## What are domains?

Domain names are the unique, human-readable Internet addresses of websites. They are made up of three parts: a top-level domain (a.k.a. TLD), a second-level domain name, and an optional subdomain.

<img src="Metadata/domain-diagram.svg" alt="drawing" width="480" style="width:100%; max-width: 480px;"/>

## Feature

- Extract root domain, top level domain, second level domain, subdomain from url and hostname
- Foundation URL and String support
- IDNA support
- Multi platform support

## Requirements

- macOS 10.13 or later
- iOS 12.0 or later
- tvOS 12.0 or later
- watchOS 4.0 or later
- visionOS 1.0 or later
- Swift 5.0 or later

## Installation

### Carthage

Add the following to your `Cartfile` and follow [these instructions](https://github.com/Carthage/Carthage#adding-frameworks-to-an-application).

```
github "gumob/TLDExtractSwift" ~> 3.0   # macOS, iOS, tvOS, watchOS, visionOS, and Swift 5
github "gumob/TLDExtractSwift" ~> 2.0   # macOS, iOS, tvOS, and Swift 5
github "gumob/TLDExtractSwift" ~> 1.0   # macOS, iOS, tvOS, and Swift 4
```

Do not forget to include Punycode.framework. Otherwise it will fail to build the application.<br/>

<img src="Metadata/carthage-xcode-config.jpg" alt="drawing" width="480" style="width:100%; max-width: 480px;"/>

### CocoaPods

To integrate TLDExtract into your project, add the following to your `Podfile`.

```ruby
platform :ios, '9.3'
use_frameworks!

pod 'TLDExtract', '~> 3.0'   # macOS, iOS, tvOS, watchOS, visionOS, and Swift 5.0
pod 'TLDExtract', '~> 2.0'   # macOS, iOS, tvOS, and Swift 5.0
pod 'TLDExtract', '~> 1.0'   # macOS, iOS, tvOS, and Swift 4.2
```

## Usage

### Initialization

Basic initialization code. Exceptions will not be raised unless [the Public Suffix List on the server](https://publicsuffix.org/list/public_suffix_list.dat) is broken.
```swift
import TLDExtract

let extractor = try! TLDExtract()
```

A safer initialization code to avoid errors by using the frozen Public Suffix List:<br/>
```swift
import TLDExtract

let extractor = try! TLDExtract(useFrozenData: true)
```
*The Public Suffix List is updated every time the framework is built. By setting userFrozenData to true, TLDExtract loads data which checked out from the repository.

### Extraction

#### Passing argument as String

Extract an url:

```swift
let urlString: String = "https://www.github.com/gumob/TLDExtract"
guard let result: TLDResult = extractor.parse(urlString) else { return }

print(result.rootDomain)        // Optional("github.com")
print(result.topLevelDomain)    // Optional("com")
print(result.secondLevelDomain) // Optional("github")
print(result.subDomain)         // Optional("www")
```

Extract a hostname:

```swift
let hostname: String = "gumob.com"
guard let result: TLDResult = extractor.parse(hostname) else { return }

print(result.rootDomain)        // Optional("gumob.com")
print(result.topLevelDomain)    // Optional("com")
print(result.secondLevelDomain) // Optional("gumob")
print(result.subDomain)         // nil
```

Extract an unicode hostname:

```swift
let hostname: String = "www.ラーメン.寿司.co.jp"
guard let result: TLDResult = extractor.parse(hostname) else { return }

print(result.rootDomain)        // Optional("寿司.co.jp")
print(result.topLevelDomain)    // Optional("co.jp")
print(result.secondLevelDomain) // Optional("寿司")
print(result.subDomain)         // Optional("www.ラーメン")
```

Extract a punycoded hostname (Same as above):

```swift
let hostname: String = "www.xn--4dkp5a8a.xn--sprr0q.co.jp")"
guard let result: TLDResult = extractor.parse(hostname) else { return }

print(result.rootDomain)        // Optional("xn--sprr0q.co.jp")
print(result.topLevelDomain)    // Optional("co.jp")
print(result.secondLevelDomain) // Optional("xn--sprr0q")
print(result.subDomain)         // Optional("www.xn--4dkp5a8a")
```

#### Passing argument as Foundation URL

Extract an unicode url: <br/>
URL class in Foundation Framework does not support unicode URLs by default. You can use URL extension as a workaround
```swift
let urlString: String = "http://www.ラーメン.寿司.co.jp"
let url: URL = URL(unicodeString: urlString)
guard let result: TLDResult = extractor.parse(url) else { return }

print(result.rootDomain)        // Optional("www.ラーメン.寿司.co.jp")
print(result.topLevelDomain)    // Optional("co.jp")
print(result.secondLevelDomain) // Optional("寿司")
print(result.subDomain)         // Optional("www.ラーメン")
```

Encode an url by passing argument as percent encoded string (Same as above):
```swift
let urlString: String = "http://www.ラーメン.寿司.co.jp".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
let url: URL = URL(string: urlString)
print(urlString)                // http://www.%E3%83%A9%E3%83%BC%E3%83%A1%E3%83%B3.%E5%AF%BF%E5%8F%B8.co.jp

guard let result: TLDResult = extractor.parse(url) else { return }

print(result.rootDomain)        // Optional("www.ラーメン.寿司.co.jp")
print(result.topLevelDomain)    // Optional("co.jp")
print(result.secondLevelDomain) // Optional("寿司")
print(result.subDomain)         // Optional("www.ラーメン")
```

Encode an unicode url by using [`Punycode`](https://github.com/gumob/Punycode) Framework:

```swift
import Punycode

let urlString: String = "http://www.ラーメン.寿司.co.jp".idnaEncoded!
let url: URL = URL(string: urlString)
print(urlString)                // http://www.xn--4dkp5a8a.xn--sprr0q.co.jp

guard let result: TLDResult = extractor.parse(url) else { return }

print(result.rootDomain)        // Optional("xn--sprr0q.co.jp")
print(result.topLevelDomain)    // Optional("co.jp")
print(result.secondLevelDomain) // Optional("xn--sprr0q")
print(result.subDomain)         // Optional("www.xn--4dkp5a8a")
```

## Copyright

TLDExtract is released under MIT license, which means you can modify it, redistribute it or use it however you like.
