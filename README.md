#  Base32Encoder 
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage) [![Build Status](https://travis-ci.org/markrenaud/Base32Encoder.svg?branch=master)](https://travis-ci.org/markrenaud/Base32Encoder) [![codecov](https://codecov.io/gh/markrenaud/Base32Encoder/branch/master/graph/badge.svg)](https://codecov.io/gh/markrenaud/Base32Encoder)

Base32Encoder is a pure Swift library that encodes Data to a Base32 String, and decodes a Base32String to Data.

## About
Encodes data as per the [RFC 3548 / RFC 4648] specification for Base32 data encodings.  

This library was written for a project that required encoding of *small* data packets and to learn *bit bashing*.  This means the code is written for learning and has not been optimized for elegance or performance.

## Installation

### Carthage
Simply add the requirement to your Cartfile:
`github "markrenaud/Base32Encoder"`

### Manually
Copy `Base32.swift` to your project

## Usage

If the Base32Encoder was installed as a library, you must import it (this can be skipped if it was manually added to your project).
`import Base32Encoder`

You can then encode data (and optionally pad as per [RFC 3548 2.2 - Padding of encoded data](https://tools.ietf.org/html/rfc3548#section-2.2))
```swift
let data = "hi".data(using: .ascii)!
let base32 = Base32.encode(data: data) // = "NBUQ"
let base32padded = Base32.encode(data: data, padding: true) // = "NBUQ===="
```
And decode Base32 strings back to dataf
```swift
let decodeBase32Data = Base32.decode(string: "NBUQ")
let decodedString = String(data: decodeBase32DataPadded!, encoding: .ascii) // = "hi"
```


Or you can use the Data and String extensions
```swift
let base32 = data.base32String(padded: true) // = "NBUQ===="
```

```swift
if let decoded = try? "NBUQ====".decodeBase32(padded: true) {
    let string = String(data: decoded, encoding: .ascii)    // = "hi"
}
```

## Licence
This project is licensed under the MIT license.  See the [LICENCE](LICENSE) file for more info.
