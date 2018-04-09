//
//    Base32EncoderTests.swift
//
//    MIT License
//
//    Copyright (c) 2018 Mark Renaud
//
//    Permission is hereby granted, free of charge, to any person obtaining a copy
//    of this software and associated documentation files (the "Software"), to deal
//    in the Software without restriction, including without limitation the rights
//    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//    copies of the Software, and to permit persons to whom the Software is
//    furnished to do so, subject to the following conditions:
//
//    The above copyright notice and this permission notice shall be included in all
//    copies or substantial portions of the Software.
//
//    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//    SOFTWARE.

import XCTest
@testable import Base32Encoder

class Base32EncoderTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    // Mark: - Test overall encoding
    func testEncodeHello() {
        let data = "hello".data(using: .ascii)!
        
        XCTAssertEqual(Base32.encode(data: data, padding: false), "NBSWY3DP")
        XCTAssertEqual(Base32.encode(data: data, padding: true), "NBSWY3DP")
    }
    
    func testEncodeZ() {
        let data = "Z".data(using: .ascii)!
        
        XCTAssertEqual(Base32.encode(data: data, padding: false), "LI")
        XCTAssertEqual(Base32.encode(data: data, padding: true), "LI======")
    }
    
    
    func testEncodeLongString() {
        let data = "what the! GET OUT OF HERE & +".data(using: .ascii)!
        
        XCTAssertEqual(Base32.encode(data: data, padding: false), "O5UGC5BAORUGKIJAI5CVIICPKVKCAT2GEBEEKUSFEATCAKY")
        XCTAssertEqual(Base32.encode(data: data, padding: true), "O5UGC5BAORUGKIJAI5CVIICPKVKCAT2GEBEEKUSFEATCAKY=")
        
    }
    
    // Mark: - Test helper components
    
    
    func testOctetsForQuintet() {
        /*
         0           1        2         Octet Index
         +---------+----------+---------+
         |01234 567|01 23456 7|0123 4567|   Octets Offset
         +---------+----------+---------+
         |01110 110|11 00000 1|1111 1010|   Octet Data Bits
         +---------+----------+---------+
         |< 1 > < 2| > < 3 > <|.4 > < 5.|>  Quintets
         +---------+----------+---------+-+
         |01110|110 11|00000|1 1111|1010  | Quintent Data Bits
         +-----+------+-----+------+------+
         0     1      2      3    4      Quintet Index
         */
        
        //        let dataBytes:[UInt8] = [0b01110110, 0b11000001, 0b11111010]
        //        let data = Data(dataBytes)
        
        let quintet0Meta = Base32.octetsForQuintet(0)
        XCTAssertEqual(quintet0Meta.octet1Index, 0)
        XCTAssertEqual(quintet0Meta.octet2Index, nil)
        XCTAssertEqual(quintet0Meta.bitOffset, 0)
        
        let quintet1Meta = Base32.octetsForQuintet(1)
        XCTAssertEqual(quintet1Meta.octet1Index, 0)
        XCTAssertEqual(quintet1Meta.octet2Index, 1)
        XCTAssertEqual(quintet1Meta.bitOffset, 5)
        
        let quintet2Meta = Base32.octetsForQuintet(2)
        XCTAssertEqual(quintet2Meta.octet1Index, 1)
        XCTAssertEqual(quintet2Meta.octet2Index, nil)
        XCTAssertEqual(quintet2Meta.bitOffset, 2)
        
        let quintet3Meta = Base32.octetsForQuintet(3)
        XCTAssertEqual(quintet3Meta.octet1Index, 1)
        XCTAssertEqual(quintet3Meta.octet2Index, 2)
        XCTAssertEqual(quintet3Meta.bitOffset, 7)
        
        let quintet4Meta = Base32.octetsForQuintet(4)
        XCTAssertEqual(quintet4Meta.octet1Index, 2)
        XCTAssertEqual(quintet4Meta.octet2Index, 3) // note: this does not exist in above example, but is correct for function
        XCTAssertEqual(quintet4Meta.bitOffset, 4)
        
    }
    
    func testCombineUInt8() {
        let aLeading:UInt8   = 0b10100011
        let aTrailing:UInt8  =         0b11001100
        let aCombined:UInt16 = 0b1010001111001100
        
        let bLeading:UInt8   = 0b00000000
        let bTrailing:UInt8  =         0b11111111
        let bCombined:UInt16 = 0b0000000011111111
        
        let cLeading:UInt8   = 0b11110000
        let cTrailing:UInt8  =         0b00001111
        let cCombined:UInt16 = 0b1111000000001111
        
        let dLeading:UInt8   = 0b00001111
        let dTrailing:UInt8  =         0b11110000
        let dCombined:UInt16 = 0b000111111110000
        
        XCTAssertEqual(Base32.combineUInt8(leadingByte: aLeading, trailingByte: aTrailing), aCombined)
        XCTAssertEqual(Base32.combineUInt8(leadingByte: bLeading, trailingByte: bTrailing), bCombined)
        XCTAssertEqual(Base32.combineUInt8(leadingByte: cLeading, trailingByte: cTrailing), cCombined)
        XCTAssertEqual(Base32.combineUInt8(leadingByte: dLeading, trailingByte: dTrailing), dCombined)
    }
    
    func testGetBitValue() {
        let bits16:UInt16 = 0b0111010011110100
        
        /*
         16-bit     = 0111010011110100         = 0b0111010011110100 -> 29940
         desired    = ---10100--------         = 0b10100            -> 20
         */
        
        XCTAssertEqual(Base32.getBitValue(numberOfBits: 5, from: bits16, offset: 3), UInt16(0b10100))
        
        /*
         16-bit     = 0111010011110100         = 0b0111010011110100 -> 29940
         desired    = -------------100         = 0b100              -> 4
         */
        
        XCTAssertEqual(Base32.getBitValue(numberOfBits: 3, from: bits16, offset: 13), UInt16(0b100))
    }
    
    func testdataTo5BitValueArray() {
        
        /*
         Example 8-bit byte data:
         [01110100] [11110111]
         
         Broken into 5-bits
         |01110 100|11 11011 1|
         |01110|100 11|11011|1 0000|
         ^^^^ padding 0s
         
         */
        
        let bytesA:[UInt8] = [0b01110100, 0b11110111]
        let dataA = Data(bytesA)
        let expectedA:[UInt8] = [0b01110, 0b10011, 0b11011, 0b10000]
        
        XCTAssertEqual(Base32.dataTo5BitValueArray(data: dataA), expectedA)
        
        /*
         Example 8-bit byte data:
         [11111111]
         
         Broken into 5-bits
         |11111 111|
         |11111|111 00|
         ^^ padding 0s
         */
        
        let bytesB:[UInt8] = [0b11111111]
        let dataB = Data(bytesB)
        let expectedB:[UInt8] = [0b11111, 0b11100]
        
        XCTAssertEqual(Base32.dataTo5BitValueArray(data: dataB), expectedB)
    }
    
    func testDataExtenstion() {
        let data = "Z".data(using: .ascii)!
        XCTAssertEqual(data.base32String(), "LI")
        XCTAssertEqual(data.base32String(padded: true), "LI======")
    }
    
}
