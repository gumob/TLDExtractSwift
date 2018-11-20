//
//  TLDExtractTests.swift
//  TLDExtractTests
//
//  Created by kojirof on 2018/11/16.
//  Copyright © 2018 Gumob. All rights reserved.
//

import XCTest
@testable import TLDExtract

class TLDExtractTests: XCTestCase {

    var tldExtractor: TLDExtract!

    override func setUp() {
        super.setUp()
        tldExtractor = try? TLDExtract()
    }

    func testMeasureSetupTime() {
        self.measure {
            _ = try? TLDExtract()
        }
    }

    func testPSLParser() {
        XCTAssertNoThrow(try TLDExtract())
        XCTAssertThrowsError(try PSLParser().parse(data: Data()))
        XCTAssertThrowsError(try PSLParser().parse(data: nil))
    }

    func testPSLPriority() {
        let exception0: PSLData = PSLData(raw: "!city.yokohama.jp")
        let exception1: PSLData = PSLData(raw: "!www.ck")
        let wildcard0: PSLData = PSLData(raw: "*.yokohama.jp")
        let wildcard1: PSLData = PSLData(raw: "*.ck")

        XCTAssertTrue(exception0 > exception1)
        XCTAssertTrue(exception0 >= exception1)
        XCTAssertFalse(exception0 < exception1)
        XCTAssertFalse(exception0 <= exception1)

        XCTAssertTrue(exception0 == exception0)
        XCTAssertTrue(exception1 == exception1)

        XCTAssertTrue(wildcard0 == wildcard0)
        XCTAssertTrue(wildcard1 == wildcard1)

        XCTAssertFalse(wildcard0 == wildcard1)

        XCTAssertFalse(exception0 == exception1)

        XCTAssertFalse(exception0 == wildcard0)
        XCTAssertFalse(exception0 == wildcard1)

        XCTAssertFalse(exception1 == wildcard0)
        XCTAssertFalse(exception1 == wildcard1)
    }

    func testMeasureExtractable() {
        self.measure {
            testExtractableURL()
            testExtractableString()
        }
    }

    func testMeasureParser() {
        self.measure {
            testParser(quick: false)
        }
    }

    func testMeasureParserQuick() {
        self.measure {
            testParser(quick: true)
        }
    }

    /// Test TLDExtractable.
    func testExtractableURL(file: StaticString = #file, line: UInt = #line) {
        /// URL
        checkTLDExtractable(URL(string: "http://example.com"), "example.com")
        checkTLDExtractable(URL(string: "https://example.com"), "example.com")

        checkTLDExtractable(URL(string: "http://www.example.com"), "www.example.com")
        checkTLDExtractable(URL(string: "https://www.example.com"), "www.example.com")

        checkTLDExtractable(URL(string: "http://example.com/a/b/"), "example.com")
        checkTLDExtractable(URL(string: "http://example.com/a/b/index.html"), "example.com")

        /// URL without scheme
        checkTLDExtractable(URL(string: "//example.com"), "example.com")
        checkTLDExtractable(URL(string: "//example.com/a/b/"), "example.com")
        checkTLDExtractable(URL(string: "//example.com/a/b/index.html"), "example.com")

        /// URL with localhost
        checkTLDExtractable(URL(string: "http://localhost"), "localhost")
        checkTLDExtractable(URL(string: "//localhost"), "localhost")
        checkTLDExtractable(URL(string: "localhost"), "localhost")

        /// Only URL scheme
        checkTLDExtractable(URL(string: "http"), "http")
        checkTLDExtractable(URL(string: "http:"), nil)
        checkTLDExtractable(URL(string: "http://"), nil)

        /// Only TLD
        checkTLDExtractable(URL(string: "com"), "com")

        /// Hostname only
        checkTLDExtractable(URL(string: "example.com"), "example.com")
        checkTLDExtractable(URL(string: "www.example.com"), "www.example.com")

        /// IDNA
        checkTLDExtractable(URL(unicodeString: "表参道.青山.ファッション"), "表参道.青山.ファッション")
        checkTLDExtractable(URL(unicodeString: "//表参道.青山.ファッション"), "表参道.青山.ファッション")
        checkTLDExtractable(URL(unicodeString: "http://表参道.青山.ファッション"), "表参道.青山.ファッション")
        checkTLDExtractable(URL(unicodeString: "http://表参道.青山.ファッション/横浜/ヤンキー/"), "表参道.青山.ファッション")
        checkTLDExtractable(URL(unicodeString: "青山.ファッション/川崎/チンピラ/"), "青山.ファッション")
        checkTLDExtractable(URL(unicodeString: "ファッション/埼玉/ダサイタマ/"), "ファッション")
        /// Same as above, but punycoded
        checkTLDExtractable(URL(string: "xn--8nr183j17e.xn--rht138k.xn--bck1b9a5dre4c"), "xn--8nr183j17e.xn--rht138k.xn--bck1b9a5dre4c")
        checkTLDExtractable(URL(string: "//xn--8nr183j17e.xn--rht138k.xn--bck1b9a5dre4c"), "xn--8nr183j17e.xn--rht138k.xn--bck1b9a5dre4c")
        checkTLDExtractable(URL(string: "http://xn--8nr183j17e.xn--rht138k.xn--bck1b9a5dre4c"), "xn--8nr183j17e.xn--rht138k.xn--bck1b9a5dre4c")
        checkTLDExtractable(URL(string: "http://xn--8nr183j17e.xn--rht138k.xn--bck1b9a5dre4c/xn--4cw21e/xn--nckyfvbwb/"), "xn--8nr183j17e.xn--rht138k.xn--bck1b9a5dre4c")
        checkTLDExtractable(URL(string: "xn--rht138k.xn--bck1b9a5dre4c/xn--8ltrs/xn--7ckvb7cub/"), "xn--rht138k.xn--bck1b9a5dre4c")
        checkTLDExtractable(URL(string: "xn--bck1b9a5dre4c/xn--5js045d/xn--eck7a5ab7m/"), "xn--bck1b9a5dre4c")
    }

    func testExtractableString(file: StaticString = #file, line: UInt = #line) {
        /// URL
        checkTLDExtractable("http://example.com", "example.com")
        checkTLDExtractable("https://example.com", "example.com")

        checkTLDExtractable("http://www.example.com", "www.example.com")
        checkTLDExtractable("https://www.example.com", "www.example.com")

        checkTLDExtractable("http://example.com/a/b/", "example.com")
        checkTLDExtractable("http://example.com/a/b/index.html", "example.com")

        /// URL without scheme
        checkTLDExtractable("//example.com", "example.com")
        checkTLDExtractable("//example.com/a/b/", "example.com")
        checkTLDExtractable("//example.com/a/b/index.html", "example.com")

        /// URL with localhost
        checkTLDExtractable("http://localhost", "localhost")
        checkTLDExtractable("//localhost", "localhost")
        checkTLDExtractable("localhost", "localhost")

        /// Only URL scheme
        checkTLDExtractable("http", "http")
        checkTLDExtractable("http:", nil)
        checkTLDExtractable("http://", nil)

        /// Only TLD
        checkTLDExtractable("com", "com")

        /// Hostname only
        checkTLDExtractable("example.com", "example.com")
        checkTLDExtractable("www.example.com", "www.example.com")

        /// IDNA
        checkTLDExtractable("表参道.青山.ファッション", "表参道.青山.ファッション")
        checkTLDExtractable("//表参道.青山.ファッション", "表参道.青山.ファッション")
        checkTLDExtractable("http://表参道.青山.ファッション", "表参道.青山.ファッション")
        checkTLDExtractable("http://表参道.青山.ファッション/横浜/ヤンキー/", "表参道.青山.ファッション")
        checkTLDExtractable("青山.ファッション/川崎/チンピラ/", "青山.ファッション")
        checkTLDExtractable("ファッション/埼玉/ダサイタマ/", "ファッション")
        /// Same as above, but punycoded
        checkTLDExtractable("xn--8nr183j17e.xn--rht138k.xn--bck1b9a5dre4c", "xn--8nr183j17e.xn--rht138k.xn--bck1b9a5dre4c")
        checkTLDExtractable("//xn--8nr183j17e.xn--rht138k.xn--bck1b9a5dre4c", "xn--8nr183j17e.xn--rht138k.xn--bck1b9a5dre4c")
        checkTLDExtractable("http://xn--8nr183j17e.xn--rht138k.xn--bck1b9a5dre4c", "xn--8nr183j17e.xn--rht138k.xn--bck1b9a5dre4c")
        checkTLDExtractable("http://xn--8nr183j17e.xn--rht138k.xn--bck1b9a5dre4c/xn--4cw21e/xn--nckyfvbwb/", "xn--8nr183j17e.xn--rht138k.xn--bck1b9a5dre4c")
        checkTLDExtractable("xn--rht138k.xn--bck1b9a5dre4c/xn--8ltrs/xn--7ckvb7cub/", "xn--rht138k.xn--bck1b9a5dre4c")
        checkTLDExtractable("xn--bck1b9a5dre4c/xn--5js045d/xn--eck7a5ab7m/", "xn--bck1b9a5dre4c")
    }

    /// Common PSL Unit Test case.
    /// Source: https://raw.githubusercontent.com/publicsuffix/list/master/tests/test_psl.txt
    func testParser(quick: Bool) {
        NSLog("Quick option is \(quick ? "enabled" : "disabled").")

        /// nil input.
        checkPublicSuffix(nil, nil, nil, nil, nil, quick: quick)

        /// Mixed case.
        checkPublicSuffix("COM", nil, nil, nil, nil, quick: quick)
        checkPublicSuffix("example.COM", "example.com", "com", "example", nil, quick: quick)
        checkPublicSuffix("WwW.example.COM", "example.com", "com", "example", "www", quick: quick)

        /// Leading dot.
        /// Listed, but non - Internet, TLD.
        checkPublicSuffix("local", nil, nil, nil, nil, quick: quick)
        checkPublicSuffix("example.local", nil, nil, nil, nil, quick: quick)
        checkPublicSuffix("b.example.local", nil, nil, nil, nil, quick: quick)
        checkPublicSuffix("a.b.example.local", nil, nil, nil, nil, quick: quick)

        /// TLD with only 1 rule.
        checkPublicSuffix("biz", nil, nil, nil, nil, quick: quick)
        checkPublicSuffix("domain.biz", "domain.biz", "biz", "domain", nil, quick: quick)
        checkPublicSuffix("b.domain.biz", "domain.biz", "biz", "domain", "b", quick: quick)
        checkPublicSuffix("a.b.domain.biz", "domain.biz", "biz", "domain", "a.b", quick: quick)

        /// TLD with some 2-level rules.
        checkPublicSuffix("com", nil, nil, nil, nil, quick: quick)
        checkPublicSuffix("example.com", "example.com", "com", "example", nil, quick: quick)
        checkPublicSuffix("b.example.com", "example.com", "com", "example", "b", quick: quick)
        checkPublicSuffix("a.b.example.com", "example.com", "com", "example", "a.b", quick: quick)
        checkPublicSuffix("uk.com", nil, nil, nil, nil, quick: quick)
        checkPublicSuffix("example.uk.com", "example.uk.com", "uk.com", "example", nil, quick: quick)
        checkPublicSuffix("b.example.uk.com", "example.uk.com", "uk.com", "example", "b", quick: quick)
        checkPublicSuffix("a.b.example.uk.com", "example.uk.com", "uk.com", "example", "a.b", quick: quick)
        checkPublicSuffix("test.ac", "test.ac", "ac", "test", nil, quick: quick)

        /// TLD with only 1 (wildcard, quick: quick) rule.
        checkPublicSuffix("mm", nil, nil, nil, nil, quick: quick)
        checkPublicSuffix("c.mm", nil, nil, nil, nil, quick: quick)
        if quick {
            /// Wildcards and exception data with quick option always returns nil
            checkPublicSuffix("b.c.mm", nil, nil, nil, nil, quick: quick)
            checkPublicSuffix("a.b.c.mm", nil, nil, nil, nil, quick: quick)
        } else {
            checkPublicSuffix("b.c.mm", "b.c.mm", "c.mm", "b", nil, quick: quick)
            checkPublicSuffix("a.b.c.mm", "b.c.mm", "c.mm", "b", "a", quick: quick)
        }

        /// More complex TLD.
        checkPublicSuffix("jp", nil, nil, nil, nil, quick: quick)
        checkPublicSuffix("test.jp", "test.jp", "jp", "test", nil, quick: quick)
        checkPublicSuffix("www.test.jp", "test.jp", "jp", "test", "www", quick: quick)
        checkPublicSuffix("ac.jp", nil, nil, nil, nil, quick: quick)
        checkPublicSuffix("test.ac.jp", "test.ac.jp", "ac.jp", "test", nil, quick: quick)
        checkPublicSuffix("www.test.ac.jp", "test.ac.jp", "ac.jp", "test", "www", quick: quick)
        checkPublicSuffix("kyoto.jp", nil, nil, nil, nil, quick: quick)
        checkPublicSuffix("test.kyoto.jp", "test.kyoto.jp", "kyoto.jp", "test", nil, quick: quick)
        checkPublicSuffix("ide.kyoto.jp", nil, nil, nil, nil, quick: quick)
        checkPublicSuffix("b.ide.kyoto.jp", "b.ide.kyoto.jp", "ide.kyoto.jp", "b", nil, quick: quick)
        checkPublicSuffix("a.b.ide.kyoto.jp", "b.ide.kyoto.jp", "ide.kyoto.jp", "b", "a", quick: quick)
        if quick {
            /// The results of wildcards and exceptions depend on the quick option
            checkPublicSuffix("c.kobe.jp", "kobe.jp", "jp", "kobe", "c", quick: quick)
            checkPublicSuffix("b.c.kobe.jp", "kobe.jp", "jp", "kobe", "b.c", quick: quick)
            checkPublicSuffix("a.b.c.kobe.jp", "kobe.jp", "jp", "kobe", "a.b.c", quick: quick)
            checkPublicSuffix("city.kobe.jp", "kobe.jp", "jp", "kobe", "city", quick: quick)
            checkPublicSuffix("www.city.kobe.jp", "kobe.jp", "jp", "kobe", "www.city", quick: quick)
        } else {
            checkPublicSuffix("c.kobe.jp", nil, nil, nil, nil, quick: quick)
            checkPublicSuffix("b.c.kobe.jp", "b.c.kobe.jp", "c.kobe.jp", "b", nil, quick: quick)
            checkPublicSuffix("a.b.c.kobe.jp", "b.c.kobe.jp", "c.kobe.jp", "b", "a", quick: quick)
            checkPublicSuffix("city.kobe.jp", "city.kobe.jp", "kobe.jp", "city", nil, quick: quick)
            checkPublicSuffix("www.city.kobe.jp", "city.kobe.jp", "kobe.jp", "city", "www", quick: quick)
        }

        /// TLD with a wildcard rule and exceptions.
        if quick {
            /// Wildcards and exception data with quick option always returns nil
            checkPublicSuffix("ck", nil, nil, nil, nil, quick: quick)
            checkPublicSuffix("test.ck", nil, nil, nil, nil, quick: quick)
            checkPublicSuffix("b.test.ck", nil, nil, nil, nil, quick: quick)
            checkPublicSuffix("a.b.test.ck", nil, nil, nil, nil, quick: quick)
            checkPublicSuffix("www.ck", nil, nil, nil, nil, quick: quick)
            checkPublicSuffix("www.www.ck", nil, nil, nil, nil, quick: quick)
        } else {
            checkPublicSuffix("ck", nil, nil, nil, nil, quick: quick)
            checkPublicSuffix("test.ck", nil, nil, nil, nil, quick: quick)
            checkPublicSuffix("b.test.ck", "b.test.ck", "test.ck", "b", nil, quick: quick)
            checkPublicSuffix("a.b.test.ck", "b.test.ck", "test.ck", "b", "a", quick: quick)
            checkPublicSuffix("www.ck", "www.ck", "ck", "www", nil, quick: quick)
            checkPublicSuffix("www.www.ck", "www.ck", "ck", "www", "www", quick: quick)
        }

        /// US K12.
        checkPublicSuffix("us", nil, nil, nil, nil, quick: quick)
        checkPublicSuffix("test.us", "test.us", "us", "test", nil, quick: quick)
        checkPublicSuffix("www.test.us", "test.us", "us", "test", "www", quick: quick)
        checkPublicSuffix("ak.us", nil, nil, nil, nil, quick: quick)
        checkPublicSuffix("test.ak.us", "test.ak.us", "ak.us", "test", nil, quick: quick)
        checkPublicSuffix("www.test.ak.us", "test.ak.us", "ak.us", "test", "www", quick: quick)
        checkPublicSuffix("k12.ak.us", nil, nil, nil, nil, quick: quick)
        checkPublicSuffix("test.k12.ak.us", "test.k12.ak.us", "k12.ak.us", "test", nil, quick: quick)
        checkPublicSuffix("www.test.k12.ak.us", "test.k12.ak.us", "k12.ak.us", "test", "www", quick: quick)

        /// IDN labels.
        checkPublicSuffix("食狮.com.cn", "食狮.com.cn", "com.cn", "食狮", nil, quick: quick)
        checkPublicSuffix("食狮.公司.cn", "食狮.公司.cn", "公司.cn", "食狮", nil, quick: quick)
        checkPublicSuffix("www.食狮.公司.cn", "食狮.公司.cn", "公司.cn", "食狮", "www", quick: quick)
        checkPublicSuffix("shishi.公司.cn", "shishi.公司.cn", "公司.cn", "shishi", nil, quick: quick)
        checkPublicSuffix("公司.cn", nil, nil, nil, nil, quick: quick)
        checkPublicSuffix("食狮.中国", "食狮.中国", "中国", "食狮", nil, quick: quick)
        checkPublicSuffix("www.食狮.中国", "食狮.中国", "中国", "食狮", "www", quick: quick)
        checkPublicSuffix("shishi.中国", "shishi.中国", "中国", "shishi", nil, quick: quick)
        checkPublicSuffix("中国", nil, nil, nil, nil, quick: quick)
        /// Same as above, but punycoded.
        checkPublicSuffix("xn--85x722f.com.cn", "xn--85x722f.com.cn", "com.cn", "xn--85x722f", nil, quick: quick)
        checkPublicSuffix("xn--85x722f.xn--55qx5d.cn", "xn--85x722f.xn--55qx5d.cn", "xn--55qx5d.cn", "xn--85x722f", nil, quick: quick)
        checkPublicSuffix("www.xn--85x722f.xn--55qx5d.cn", "xn--85x722f.xn--55qx5d.cn", "xn--55qx5d.cn", "xn--85x722f", "www", quick: quick)
        checkPublicSuffix("shishi.xn--55qx5d.cn", "shishi.xn--55qx5d.cn", "xn--55qx5d.cn", "shishi", nil, quick: quick)
        checkPublicSuffix("xn--55qx5d.cn", nil, nil, nil, nil, quick: quick)
        checkPublicSuffix("xn--85x722f.xn--fiqs8s", "xn--85x722f.xn--fiqs8s", "xn--fiqs8s", "xn--85x722f", nil, quick: quick)
        checkPublicSuffix("www.xn--85x722f.xn--fiqs8s", "xn--85x722f.xn--fiqs8s", "xn--fiqs8s", "xn--85x722f", "www", quick: quick)
        checkPublicSuffix("shishi.xn--fiqs8s", "shishi.xn--fiqs8s", "xn--fiqs8s", "shishi", nil, quick: quick)
        checkPublicSuffix("xn--fiqs8s", nil, nil, nil, nil, quick: quick)

        /// Japanese IDN labels.
        checkPublicSuffix("忍者.jp", "忍者.jp", "jp", "忍者", nil, quick: quick)
        checkPublicSuffix("サムライ.忍者.jp", "忍者.jp", "jp", "忍者", "サムライ", quick: quick)
        checkPublicSuffix("www.サムライ.忍者.jp", "忍者.jp", "jp", "忍者", "www.サムライ", quick: quick)
        checkPublicSuffix("ラーメン.寿司.co.jp", "寿司.co.jp", "co.jp", "寿司", "ラーメン", quick: quick)
        checkPublicSuffix("www.ラーメン.寿司.co.jp", "寿司.co.jp", "co.jp", "寿司", "www.ラーメン", quick: quick)
        checkPublicSuffix("餃子.食品", "餃子.食品", "食品", "餃子", nil, quick: quick)
        checkPublicSuffix("チャーハン.餃子.食品", "餃子.食品", "食品", "餃子", "チャーハン", quick: quick)
        checkPublicSuffix("www.チャーハン.餃子.食品", "餃子.食品", "食品", "餃子", "www.チャーハン", quick: quick)
        checkPublicSuffix("青山.ファッション", "青山.ファッション", "ファッション", "青山", nil, quick: quick)
        checkPublicSuffix("表参道.青山.ファッション", "青山.ファッション", "ファッション", "青山", "表参道", quick: quick)
        checkPublicSuffix("www.表参道.青山.ファッション", "青山.ファッション", "ファッション", "青山", "www.表参道", quick: quick)
        checkPublicSuffix("www.おしゃれ.表参道.青山.ファッション", "青山.ファッション", "ファッション", "青山", "www.おしゃれ.表参道", quick: quick)
        checkPublicSuffix("日本", nil, nil, nil, nil, quick: quick)
        /// Same as above, but punycoded.
        checkPublicSuffix("xn--c6t203e.jp", "xn--c6t203e.jp", "jp", "xn--c6t203e", nil, quick: quick)
        checkPublicSuffix("xn--eck7azimb.xn--c6t203e.jp", "xn--c6t203e.jp", "jp", "xn--c6t203e", "xn--eck7azimb", quick: quick)
        checkPublicSuffix("www.xn--eck7azimb.xn--c6t203e.jp", "xn--c6t203e.jp", "jp", "xn--c6t203e", "www.xn--eck7azimb", quick: quick)
        checkPublicSuffix("xn--4dkp5a8a.xn--sprr0q.co.jp", "xn--sprr0q.co.jp", "co.jp", "xn--sprr0q", "xn--4dkp5a8a", quick: quick)
        checkPublicSuffix("www.xn--4dkp5a8a.xn--sprr0q.co.jp", "xn--sprr0q.co.jp", "co.jp", "xn--sprr0q", "www.xn--4dkp5a8a", quick: quick)
        checkPublicSuffix("xn--i8st94l.xn--jvr189m", "xn--i8st94l.xn--jvr189m", "xn--jvr189m", "xn--i8st94l", nil, quick: quick)
        checkPublicSuffix("xn--7ck2a9c3czb.xn--i8st94l.xn--jvr189m", "xn--i8st94l.xn--jvr189m", "xn--jvr189m", "xn--i8st94l", "xn--7ck2a9c3czb", quick: quick)
        checkPublicSuffix("www.xn--7ck2a9c3czb.xn--i8st94l.xn--jvr189m", "xn--i8st94l.xn--jvr189m", "xn--jvr189m", "xn--i8st94l", "www.xn--7ck2a9c3czb", quick: quick)
        checkPublicSuffix("xn--rht138k.xn--bck1b9a5dre4c", "xn--rht138k.xn--bck1b9a5dre4c", "xn--bck1b9a5dre4c", "xn--rht138k", nil, quick: quick)
        checkPublicSuffix("xn--8nr183j17e.xn--rht138k.xn--bck1b9a5dre4c", "xn--rht138k.xn--bck1b9a5dre4c", "xn--bck1b9a5dre4c", "xn--rht138k", "xn--8nr183j17e", quick: quick)
        checkPublicSuffix("www.xn--8nr183j17e.xn--rht138k.xn--bck1b9a5dre4c", "xn--rht138k.xn--bck1b9a5dre4c", "xn--bck1b9a5dre4c", "xn--rht138k", "www.xn--8nr183j17e", quick: quick)
        checkPublicSuffix("www.xn--t8j0ayjlb.xn--8nr183j17e.xn--rht138k.xn--bck1b9a5dre4c", "xn--rht138k.xn--bck1b9a5dre4c", "xn--bck1b9a5dre4c", "xn--rht138k", "www.xn--t8j0ayjlb.xn--8nr183j17e", quick: quick)
        checkPublicSuffix("xn--wgv71a", nil, nil, nil, nil, quick: quick)
    }

    func checkTLDExtractable(_ input: TLDExtractable?,
                             _ expected: String?,
                             file: StaticString = #file, line: UInt = #line) {
        let result: String? = input?.hostname
        logTLDExtractable(input, result, expected)
        XCTAssertEqual(result, expected, file: file, line: line)
    }

    func checkPublicSuffix(_ host: String?,
                           _ expectedRootDomain: String?,
                           _ expectedTopLevelDomain: String?,
                           _ expectedSecondDomain: String?,
                           _ expectedSubDomain: String?,
                           quick: Bool = false,
                           file: StaticString = #file, line: UInt = #line) {
        guard let host = host else { return }
        let result: TLDResult? = tldExtractor.parse(input: host.lowercased(), quick: quick)

//        logTLDResult(host, expectedRootDomain, expectedTopLevelDomain, expectedSecondDomain, expectedSubDomain, result)

        XCTAssertEqual(result?.rootDomain, expectedRootDomain, file: file, line: line)
        XCTAssertEqual(result?.topLevelDomain, expectedTopLevelDomain, file: file, line: line)
        XCTAssertEqual(result?.secondLevelDomain, expectedSecondDomain, file: file, line: line)
        XCTAssertEqual(result?.subDomain, expectedSubDomain, file: file, line: line)
    }

    /// For debugging
    func logTLDExtractable(_ input: TLDExtractable?,
                           _ result: String?,
                           _ expected: String?) {

        print("----------------------------")
        print("input:            \(input ?? "nil")")
        print("result:           \(result ?? "nil")")
        print("expected:         \(expected ?? "nil")")
        print("")
    }

    func logTLDResult(_ host: String?,
                      _ expectedRootDomain: String?,
                      _ expectedTopLevelDomain: String?,
                      _ expectedSecondDomain: String?,
                      _ expectedSubDomain: String?,
                      _ result: TLDResult?) {
        guard let host = host else { return }
        let hostStr: String = host.padding(toLength: 20, withPad: " ", startingAt: 0)

        let expectedRootStr: String = "\(expectedRootDomain ?? "nil")".padding(toLength: 20, withPad: " ", startingAt: 0)
        let expectedTopStr: String = "\(expectedTopLevelDomain ?? "nil")".padding(toLength: 20, withPad: " ", startingAt: 0)
        let expectedSecondStr: String = "\(expectedSecondDomain ?? "nil")".padding(toLength: 20, withPad: " ", startingAt: 0)
        let expectedSubStr: String = "\(expectedSubDomain ?? "nil")".padding(toLength: 20, withPad: " ", startingAt: 0)

        let resultRootStr: String = "\(result?.rootDomain ?? "nil")".padding(toLength: 20, withPad: " ", startingAt: 0)
        let resultTopStr: String = "\(result?.topLevelDomain ?? "nil")".padding(toLength: 20, withPad: " ", startingAt: 0)
        let resultSecondStr: String = "\(result?.secondLevelDomain ?? "nil")".padding(toLength: 20, withPad: " ", startingAt: 0)
        let resultSubStr: String = "\(result?.subDomain ?? "nil")".padding(toLength: 20, withPad: " ", startingAt: 0)

        print("----------------------------")
        print("hostStr:             \(hostStr)")
        print("Root domain:         \(expectedRootStr) => \(resultRootStr)")
        print("Top level domain:    \(expectedTopStr) => \(resultTopStr)")
        print("Second level domain: \(expectedSecondStr) => \(resultSecondStr)")
        print("Sub domain:          \(expectedSubStr) => \(resultSubStr)")
    }
}
