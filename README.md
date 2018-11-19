[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg)](https://github.com/gumob/TLDExtractSwift)
[![Version](http://img.shields.io/cocoapods/v/TLDExtract.svg)](http://cocoadocs.org/docsets/TLDExtract)
[![Platform](http://img.shields.io/cocoapods/p/TLDExtract.svg)](http://cocoadocs.org/docsets/TLDExtract)
[![Build Status](https://travis-ci.com/gumob/TLDExtractSwift.svg?branch=master)](https://travis-ci.com/gumob/TLDExtractSwift)
[![codecov](https://codecov.io/gh/gumob/TLDExtractSwift/branch/master/graph/badge.svg)](https://codecov.io/gh/gumob/TLDExtractSwift)
![Language](https://img.shields.io/badge/Language-Swift%204.2-orange.svg)
![Packagist](https://img.shields.io/packagist/l/doctrine/orm.svg)

# TLDExtractSwift
<code>TLDExtract</code> is a pure Swift library to allows you to get the public suffix of a domain name using [the Public Suffix List](http://www.publicsuffix.org).<br/>

## What are domains?

Domain names are the unique, human-readable Internet addresses of websites. They are made up of three parts: a top-level domain (a.k.a. TLD), a second-level domain name, and an optional subdomain.

<img src="Metadata/domain-diagram.svg" alt="drawing" width="480"/>

## Requirements

- iOS 9.3 or later
- macOS 10.12 or later
- tvOS 12.0 or later
- Swift 4.2
- Python 2.7 or Python 3

<small>* No plans to support tvOS 11 or earlier for now</small>


## Installation

### Carthage

Add the following to your `Cartfile` and follow [these instructions](https://github.com/Carthage/Carthage#adding-frameworks-to-an-application).

```
github "gumob/TLDExtractSwift"
```

### CocoaPods

To integrate TLDExtract into your project, add the following to your `Podfile`.

```ruby
platform :ios, '9.3'
use_frameworks!

pod 'TLDExtractSwift'
```
## Usage

### Initialization:

Basic initialization code. Exceptions will not be raised unless [the Public Suffix List on the server](https://publicsuffix.org/list/public_suffix_list.dat) is broken.
```swift
import TLDExtract

guard let extractor = try! TLDExtract()
```

A safer initialization code to avoid errors caused by the Public Suffix List.
```swift
import TLDExtract

do {
    let extractor = try TLDExtract()
} catch {
    // Handle the exception
}
```
### Extraction

Extract an url
```swift
let result = extractor.parse("https://www.github.com/gumob/TLDExtract")

result.rootDomain        // Optional("github.com")
result.topLevelDomain    // Optional("com")
result.secondLevelDomain // Optional("github")
result.subDomain         // Optional("www")
```

Extract a hostname
```swift
let result = extractor.parse("gumob.com")

result.rootDomain        // Optional("gumob.com")
result.topLevelDomain    // Optional("com")
result.secondLevelDomain // Optional("gumob")
result.subDomain         // nil
```

Extract IDN TLD
```swift
let result = extractor.parse("www.ラーメン.寿司.co.jp")

result.rootDomain        // Optional("寿司.co.jp")
result.topLevelDomain    // Optional("co.jp")
result.secondLevelDomain // Optional("寿司")
result.subDomain         // Optional("www.ラーメン")
```

Extract a punycoded hostname (Same as above)
```swift
let result = extractor.parse("www.xn--4dkp5a8a.xn--sprr0q.co.jp")

result.rootDomain        // Optional("xn--sprr0q.co.jp")
result.topLevelDomain    // Optional("co.jp")
result.secondLevelDomain // Optional("xn--sprr0q")
result.subDomain         // Optional("www.xn--4dkp5a8a")
```

If you pass a wrong host name, the result will return nil
```swift
let result = extractor.parse("com")

result.rootDomain        // nil
result.topLevelDomain    // nil
result.secondLevelDomain // nil
result.subDomain         // nil
```


## Copyright

TLDExtract is released under MIT license, which means you can modify it, redistribute it or use it however you like.
