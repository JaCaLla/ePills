//
//  MarkDownParser.swift
//
//  Created by Javier Calatrava on 16/09/2019.
//

import Down
import Foundation

@objc class MarkDownParser: NSObject {

    @objc public static func getAttributedStringFor(text: String,
                                                    bodyColor: UIColor,
                                                    bodyFont: UIFont,
                                                    boldColor: UIColor? = nil,
                                                    boldFont: UIFont? = nil,
                                                    linkColor: UIColor? = nil,
                                                    linkFont: UIFont? = nil,
                                                    params: String? = nil,
                                                    urlKey: String? = nil) -> NSAttributedString {

        let down = Down(markdownString: text)
        do {
            let markDownStyle = MarkDownStyle(bodyColor: bodyColor,
                                              bodyFont: bodyFont,
                                              boldColor: boldColor,
                                              boldFont: boldFont,
                                              linkColor: linkColor,
                                              linkFont: linkFont,
                                              params: params,
                                              urlKey: urlKey)
            return try down.toAttributedString(styler: markDownStyle)
        } catch {
            return NSAttributedString()
        }
    }

    // Note:
    // This convenience method was implemented because there are no default function parameters in Obj-C.
    // Once its dependency were no longer necessary, then should be removed.
    @objc public static func getAttributedStringFor(text: String,
                                                    bodyColor: UIColor,
                                                    bodyFont: UIFont,
                                                    linkColor: UIColor,
                                                    linkFont: UIFont) -> NSAttributedString {
        return getAttributedStringFor(text: text,
                                      bodyColor: bodyColor,
                                      bodyFont: bodyFont,
                                      boldColor: nil,
                                      boldFont: nil,
                                      linkColor: linkColor,
                                      linkFont: linkFont,
                                      params: nil,
                                      urlKey: nil)
    }

    // Note:
    // This convenience method was implemented because there are no default function parameters in Obj-C.
    // Once its dependency were no longer necessary, then should be removed.
    @objc public static func getAttributedStringFor(text: String,
                                                    bodyColor: UIColor,
                                                    bodyFont: UIFont) -> NSAttributedString {

        return getAttributedStringFor(text: text,
                                      bodyColor: bodyColor,
                                      bodyFont: bodyFont,
                                      boldColor: nil,
                                      boldFont: nil,
                                      linkColor: nil,
                                      linkFont: nil,
                                      params: nil,
                                      urlKey: nil)
    }

    // Note:
    // This convenience method was implemented because there are no default function parameters in Obj-C.
    // Once its dependency were no longer necessary, then should be removed.
    @objc public static func getAttributedStringFor(text: String,
                                                    bodyColor: UIColor,
                                                    bodyFont: UIFont,
                                                    boldColor: UIColor,
                                                    boldFont: UIFont) -> NSAttributedString {
        return getAttributedStringFor(text: text,
                                      bodyColor: bodyColor,
                                      bodyFont: bodyFont,
                                      boldColor: boldColor,
                                      boldFont: boldFont,
                                      linkColor: nil,
                                      linkFont: nil,
                                      params: nil,
                                      urlKey: nil)
    }

    @objc public static func getAttributedStringFor(text: String,
                                                    bodyColor: UIColor,
                                                    bodyFont: UIFont,
                                                    boldColor: UIColor,
                                                    boldFont: UIFont,
                                                    linkColor: UIColor,
                                                    linkFont: UIFont) -> NSAttributedString {
        return getAttributedStringFor(text: text,
                                      bodyColor: bodyColor,
                                      bodyFont: bodyFont,
                                      boldColor: boldColor,
                                      boldFont: boldFont,
                                      linkColor: linkColor,
                                      linkFont: linkFont,
                                      params: nil,
                                      urlKey: nil)
    }

}

class MarkDownStyle: Styler {

    private var bodyColor: UIColor = UIColor.white
    private var bodyFontPointSize: CGFloat = 0.0
    private var boldColor: UIColor?
    private var boldFontPointSize: CGFloat?
    private var linkColor: UIColor?
    private var linkFontPointSize: CGFloat?
    private var linkFont: UIFont?
    private var params: String?
    private var urlKey: String?

    init(bodyColor: UIColor,
         bodyFont: UIFont,
         boldColor: UIColor?,
         boldFont: UIFont?,
         linkColor: UIColor? = nil,
         linkFont: UIFont? = nil,
         params: String? = nil,
         urlKey: String? = nil) {
        self.bodyColor = bodyColor
        self.bodyFontPointSize = bodyFont.pointSize
        self.boldColor = boldColor
        self.boldFontPointSize = boldFont?.pointSize
        self.linkColor = linkColor
        self.linkFontPointSize = linkFont?.pointSize
        self.linkFont = linkFont
        self.params = params
        self.urlKey = urlKey
    }

    // MARK: - Styler
    func style(document str: NSMutableAttributedString) {
        // Nothing to do with this delegated method
    }

    func style(blockQuote str: NSMutableAttributedString) {
        // Nothing to do with this delegated method
    }

    func style(list str: NSMutableAttributedString) {
        // Nothing to do with this delegated method
    }

    func style(item str: NSMutableAttributedString) {
        // Nothing to do with this delegated method
    }

    func style(codeBlock str: NSMutableAttributedString, fenceInfo: String?) {
        // Nothing to do with this delegated method
    }

    func style(htmlBlock str: NSMutableAttributedString) {
        // Nothing to do with this delegated method
    }

    func style(customBlock str: NSMutableAttributedString) {
        // Nothing to do with this delegated method
    }

    func style(paragraph str: NSMutableAttributedString) {
        // Nothing to do with this delegated method
    }

    func style(heading str: NSMutableAttributedString, level: Int) {
        // Nothing to do with this delegated method
    }

    func style(thematicBreak str: NSMutableAttributedString) {
        // Nothing to do with this delegated method
    }

    func style(text str: NSMutableAttributedString) {
        // Nothing to do with this delegated method
        str.addAttribute(NSAttributedString.Key.foregroundColor,
                         value: self.bodyColor,
                         range: NSRange(location: 0, length: str.length))
        let font = UIFont.systemFont(ofSize: self.bodyFontPointSize)
        str.addAttribute(NSAttributedString.Key.font,
                         value: font,
                         range: NSRange(location: 0, length: str.length))
    }

    func style(softBreak str: NSMutableAttributedString) {
        // Nothing to do with this delegated method
    }

    func style(lineBreak str: NSMutableAttributedString) {
        // Nothing to do with this delegated method
    }

    func style(code str: NSMutableAttributedString) {
        // Nothing to do with this delegated method
    }

    func style(htmlInline str: NSMutableAttributedString) {
        // Nothing to do with this delegated method
    }

    func style(customInline str: NSMutableAttributedString) {
        // Nothing to do with this delegated method
    }

    func style(emphasis str: NSMutableAttributedString) {
        // Nothing to do with this delegated method
    }

    func style(strong str: NSMutableAttributedString) {
        str.addAttribute(NSAttributedString.Key.foregroundColor,
                         value: self.boldColor ?? self.bodyColor,
                         range: NSRange(location: 0, length: str.length))
        let font = UIFont.boldSystemFont(ofSize: self.boldFontPointSize ?? self.bodyFontPointSize)
        str.addAttribute(NSAttributedString.Key.font,
                         value: font,
                         range: NSRange(location: 0, length: str.length))
    }

    func style(link str: NSMutableAttributedString, title: String?, url: String?) {
        guard let uwpLinkFontPointSize = linkFontPointSize,
            let uwpLinkColor = linkColor else { return }
        str.addAttribute(NSAttributedString.Key.foregroundColor,
                         value: uwpLinkColor,
                         range: NSRange(location: 0, length: str.length))
        let font = UIFont.systemFont(ofSize: uwpLinkFontPointSize)
        str.addAttribute(NSAttributedString.Key.font,
                         value: font,
                         range: NSRange(location: 0, length: str.length))
        let range = NSRange(location: 0, length: str.length)
//        if let urlFromConfig = APIUrlsManager.urlString(urlKey) {
//            let urlWithParams = handleUrlParams(url: urlFromConfig, params: params)
//            str.addAttribute(NSAttributedString.Key.link, value: urlWithParams, range: range)
//            str.addAttribute(NSAttributedString.Key.underlineStyle, value: 1, range: range)
//        } else {
            if let uwp = url {
                str.addAttribute(NSAttributedString.Key.link, value: uwp, range: range)
                str.addAttribute(NSAttributedString.Key.underlineStyle, value: 1, range: range)
                let font = self.linkFont ?? UIFont.systemFont(ofSize: self.bodyFontPointSize)
                str.addAttribute(NSAttributedString.Key.font, value: font, range: range)
            }
 //       }
    }

    func style(image str: NSMutableAttributedString, title: String?, url: String?) {
        // Nothing to do with this delegated method
    }

    var listPrefixAttributes: [NSAttributedString.Key: Any] = [:]

    fileprivate func handleUrlParams(url: String, params: String?) -> String {
        var urlWithParams = url
        if let urlParams = params {
            urlWithParams += urlParams
        } else {
//            if let language = Utils.currentLanguageCode() as String? {
//                urlWithParams += "/?device=ios&lang=\(language)"
//            } else {
                urlWithParams += "/?device=ios&lang=ES"
//            }
        }
        return urlWithParams
    }

}
