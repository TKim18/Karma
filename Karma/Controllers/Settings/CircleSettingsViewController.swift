//
//  CircleSettingsViewController.swift
//  Karma
//
//  Created by Timothy Taeho Kim on 4/8/18.
//  Copyright © 2018 Olya Danylova. All rights reserved.
//

import UIKit
import FirebaseDynamicLinks

class CircleSettingsViewController: UIViewController {

    static let DYNAMIC_LINK_DOMAIN = "https://g63p3.app.goo.gl"
    
    enum Params: String {
        case link = "Link Value"
        case source = "Source"
        case medium = "Medium"
        case campaign = "Campaign"
        case term = "Term"
        case content = "Content"
        case bundleID = "App Bundle ID"
        case fallbackURL = "Fallback URL"
        case minimumAppVersion = "Minimum App Version"
        case customScheme = "Custom Scheme"
        case iPadBundleID = "iPad Bundle ID"
        case iPadFallbackURL = "iPad Fallback URL"
        case appStoreID = "AppStore ID"
        case affiliateToken = "Affiliate Token"
        case campaignToken = "Campaign Token"
        case providerToken = "Provider Token"
        case packageName = "Package Name"
        case androidFallbackURL = "Android Fallback URL"
        case minimumVersion = "Minimum Version"
        case title = "Title"
        case descriptionText = "Description Text"
        case imageURL = "Image URL"
        case otherFallbackURL = "Other Platform Fallback URL"
    }
    
    var dictionary = [Params: UITextField]()
    var longLink: URL?
    var shortLink: URL?
    
    @IBOutlet weak var linkLabel : UILabel!
    
    @IBAction func generateLink(sender: Any) {
        // general link params
//        let iden = Bundle.main.bundleIdentifier
//        dictionary[.link]?.text = iden
//        guard let linkString = "com.Wesleyan.Karma" else {
//            print("Link can not be empty!")
//            return
//        }
        
        let linkString = "https://wesleyan.edu/Karma"
        
        guard let link = URL(string: linkString) else { return }
        let components = DynamicLinkComponents(link: link, domain: CircleSettingsViewController.DYNAMIC_LINK_DOMAIN)
        
        // analytics params
        let analyticsParams = DynamicLinkGoogleAnalyticsParameters(
            source: dictionary[.source]?.text ?? "", medium: dictionary[.medium]?.text ?? "",
            campaign: dictionary[.campaign]?.text ?? "")
        analyticsParams.term = dictionary[.term]?.text
        analyticsParams.content = dictionary[.content]?.text
        components.analyticsParameters = analyticsParams
        
        if let bundleID = dictionary[.bundleID]?.text {
            // iOS params
            let iOSParams = DynamicLinkIOSParameters(bundleID: bundleID)
            iOSParams.fallbackURL = dictionary[.fallbackURL]?.text.flatMap(URL.init)
            iOSParams.minimumAppVersion = dictionary[.minimumAppVersion]?.text
            iOSParams.customScheme = dictionary[.customScheme]?.text
            iOSParams.iPadBundleID = dictionary[.iPadBundleID]?.text
            iOSParams.iPadFallbackURL = dictionary[.iPadFallbackURL]?.text.flatMap(URL.init)
            iOSParams.appStoreID = dictionary[.appStoreID]?.text
            components.iOSParameters = iOSParams
            
            // iTunesConnect params
            let appStoreParams = DynamicLinkItunesConnectAnalyticsParameters()
            appStoreParams.affiliateToken = dictionary[.affiliateToken]?.text
            appStoreParams.campaignToken = dictionary[.campaignToken]?.text
            appStoreParams.providerToken = dictionary[.providerToken]?.text
            components.iTunesConnectParameters = appStoreParams
        }
        
        // social tag params
        let socialParams = DynamicLinkSocialMetaTagParameters()
        socialParams.title = dictionary[.title]?.text
        socialParams.descriptionText = dictionary[.descriptionText]?.text
        socialParams.imageURL = dictionary[.imageURL]?.text.flatMap(URL.init)
        components.socialMetaTagParameters = socialParams
        
        // OtherPlatform params
        let otherPlatformParams = DynamicLinkOtherPlatformParameters()
        otherPlatformParams.fallbackUrl = dictionary[.otherFallbackURL]?.text.flatMap(URL.init)
        components.otherPlatformParameters = otherPlatformParams
        
        longLink = components.url
        var longLinkString = longLink?.absoluteString ?? ""
        longLinkString = String(longLinkString.dropFirst(8))
        longLink = URL(string: longLinkString)
        
        // linkLabel.text = longLink?.absoluteString ?? ""
        // [END buildFDLLink]
        // Handle longURL.
        
        // [START shortLinkOptions]
        let options = DynamicLinkComponentsOptions()
        options.pathLength = .unguessable
        components.options = options
        // [END shortLinkOptions]
        // [START shortenLink]
        components.shorten { (shortURL, warnings, error) in
            // Handle shortURL.
            if let error = error {
                print(error.localizedDescription)
                return
            }
            self.shortLink = shortURL
            print(self.shortLink?.absoluteString ?? "")
            
            self.linkLabel.text = self.shortLink?.absoluteString ?? ""
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }



}
