//
//  ProductPair.swift
//  FoodViewer
//
//  Created by arnaud on 17/02/2018.
//  Copyright © 2018 Hovering Above. All rights reserved.
//

import Foundation
import UIKit

class ProductPair {
    
    internal struct Notification {
        //static let BarcodeDoesNotExistKey = "ProductPair.Notification.BarcodeDoesNotExist.Key"
        //static let SearchStringKey = "OFFProducts.Notification.SearchString.Key"
        //static let SearchOffsetKey = "OFFProducts.Notification.SearchOffset.Key"
        //static let SearchPageKey = "OFFProducts.Notification.SearchPage.Key"
        static let BarcodeKey = "ProductPair.Notification.Barcode.Key"
        static let ErrorKey = "ProductPair.Notification.Error.Key"
        static let RemoteStatusKey = "ProductPair.Notification.RemoteStatus.Key"
        static let ProductPairUpdatedKey = "ProductPair.Notification.Updated.Key"
        static let ImageTypeCategoryKey = "ProductPair.Notification.ImageTypeCategory.Key"
        static let ImageIDKey = "ProductPair.Notification.ImageID.Key"
    }

    /// The barcode identifies a product and thus a productPair
    /// it can not be nil !!!!
    public var barcodeType: BarcodeType = .undefined("not set", nil)
    
    // If false, then the use can not update this product
    // This is useful for the sample products and the mostRecent product
    public var updateIsAllowed = true
    
    /// A comment that can be added by the user. It will not be uploaded to OFF. It will be stored locally in the history. It is unaffected by any update from OFF, or local edits and removals.
    public var comment: String?

    // This defines the type of this product, such as .food, .beauty or .petFood
    //var productType: ProductType = .food
    
    // The product as it is stored on the OFF-servers
    // If the product is not downloaded or does not exist, it is nil
    var remoteProduct: FoodProduct? = nil {
        didSet {
            if ( remoteProduct != nil && oldValue == nil ) || ( remoteProduct == nil && oldValue != nil ) {
                let userInfo = [Notification.BarcodeKey: barcodeType.asString] as [String : Any]

                DispatchQueue.main.async(execute: { () -> Void in
                    NotificationCenter.default.post(name: .ProductPairUpdated, object:nil, userInfo: userInfo)
                })
            }
            if remoteProduct != nil {
                remoteStatus = .available(barcodeType.asString)
            }
        }
    }
    
    // The remote status described the relation with the OFF server
    var localStatus: ProductFetchStatus = .initialized {
        didSet {
            // only do something if there is a change
            if localStatus.rawValue != oldValue.rawValue {
                let userInfo = [Notification.BarcodeKey: barcodeType.asString,
                                Notification.RemoteStatusKey: localStatus.rawValue] as [String : Any]
                DispatchQueue.main.async(execute: { () -> Void in
                    NotificationCenter.default.post(name: .ProductPairLocalStatusChanged, object:nil, userInfo: userInfo)
                })
            }
        }
    }
    
    /// Indicates if product data is available
    var status: ProductFetchStatus {
        switch localStatus {
        case .available, .updated:
            return localStatus
        default:
            return remoteStatus
        }
    }
    
    /// Return the product which has info
    var product: FoodProduct? {
        return localProduct ?? remoteProduct
    }
    
    // The product as it is created or changed by the user
    // If the user did not do anything, it is nil
    var localProduct: FoodProduct? = nil {
        didSet {
            if ( localProduct != nil && oldValue == nil ) || ( localProduct == nil && oldValue != nil ) {
                let userInfo = [Notification.BarcodeKey: barcodeType.asString] as [String : Any]
                DispatchQueue.main.async(execute: { () -> Void in
                    NotificationCenter.default.post(name: .ProductPairUpdated, object:nil, userInfo: userInfo)
                })
            }

            if localProduct != nil {
                localStatus = .available(barcodeType.asString)
                if localProduct?.primaryLanguageCode == nil {
                    localProduct?.primaryLanguageCode = remoteProduct?.primaryLanguageCode ?? Locale.interfaceLanguageCode
                }
            } else {
                localStatus = .initialized
            }
        }
    }
    
    // The remote status described the relation with the OFF server
    var remoteStatus: ProductFetchStatus = .initialized {
        didSet {
            // only do something if there is a change
            if remoteStatus.rawValue != oldValue.rawValue {
                let userInfo = [Notification.BarcodeKey: barcodeType.asString,
                                Notification.RemoteStatusKey: remoteStatus.rawValue] as [String : Any]
                DispatchQueue.main.async(execute: { () -> Void in
                    NotificationCenter.default.post(name: .ProductPairRemoteStatusChanged, object:nil, userInfo: userInfo)
                })
            }
        }
    }
//
// MARK: - Initialization functions
//
    init(remoteStatus: ProductFetchStatus, type: ProductType) {
        self.barcodeType = BarcodeType(barcodeString: remoteStatus.description, type: .food)
        self.remoteStatus = remoteStatus
    }
    
    //  This sets a remote product directly
    init(product: FoodProduct) {
        self.barcodeType = product.barcode
        self.remoteProduct = product
        // ensure there is a languageCode
        if self.remoteProduct?.primaryLanguageCode == nil {
            self.remoteProduct?.primaryLanguageCode = self.localProduct?.primaryLanguageCode ?? Locale.interfaceLanguageCode
        }
        // as the product is set, the status is available
        self.remoteStatus = .available(product.barcode.asString)
    }

    //init(with barcodeTuple: (String,String) ) {
    //    self.barcodeType = BarcodeType(value: barcodeTuple.0)
    //    self.remoteStatus = .productNotLoaded(barcodeType.asString)
    //    self.productType = ProductType.init(string:barcodeTuple.1)
    //}
    
    convenience init(barcodeString: String, type: ProductType) {
        self.init(barcodeType: BarcodeType(barcodeString: barcodeString, type: type), comment: nil)
    }

    convenience init(barcodeString: String, comment: String?, type: ProductType) {
        self.init(barcodeType: BarcodeType(barcodeString: barcodeString, type: type), comment: comment)
    }

    init(barcodeType: BarcodeType, comment: String?) {
        self.barcodeType = barcodeType
        self.remoteStatus = .initialized
        self.comment = comment
    }

//
// MARK: Unique variables
//
    /// The name of the local product otherwise the remote product
    var name: String? {
        return remoteProduct?.name ?? localProduct?.name
    }
    
    /// The interpreted categories of the local product otherwise the remote product
    var categoriesInterpreted: Tags? {
        return localProduct?.categoriesInterpreted ?? remoteProduct?.categoriesInterpreted
    }
    
    var categoriesTranslated: Tags? {
        return localProduct?.categoriesTranslated ?? remoteProduct?.categoriesTranslated
    }
    
    /// The interpreted countries of the local product otherwise the remote product
    var countriesInterpreted: Tags? {
        return localProduct?.countriesInterpreted ?? remoteProduct?.countriesInterpreted
    }
    
    /// The interpreted traces of the local product otherwise the remote product
    var tracesInterpreted: Tags? {
        return localProduct?.tracesInterpreted ?? remoteProduct?.tracesInterpreted
    }

    var brand: String? {
        return localProduct?.brandsOriginal.tag(at: 0) ?? remoteProduct?.brandsOriginal.tag(at: 0)
    }
    
    var primaryLanguageCode: String {
        return localProduct?.primaryLanguageCode ?? remoteProduct?.primaryLanguageCode ??  Locale.interfaceLanguageCode
    }
    
    var regionURL: URL? {
        return remoteProduct?.regionURL ?? localProduct?.regionURL
    }
        
    /// The languages found on the product expressed as two character languageCodes ("en").
    var languageCodes: [String]? {
        return localProduct?.languageCodes ?? remoteProduct?.languageCodes
    }
    
    /// Has the product  nutrition facts defined?
    var hasNutritionFacts: Bool? {
        // The local product overrides the remote product
        return localProduct?.hasNutritionFacts ?? remoteProduct?.hasNutritionFacts
    }
    
    /// initialize the local product for editing
    func initLocalProduct() {
        if localProduct == nil {
            if let barcodeType = remoteProduct?.barcode {
                let test = FoodProduct(with: barcodeType)
                localProduct = test
            } else {
                localProduct = FoodProduct(with: barcodeType)
            }
        }

    }
    // tags in the local product should contain edited and nwe tags
    var folksonomyTags: [FSNM.Tag]? {
        return remoteProduct?.folksonomyTags
    }

    var hasAdditives: Bool {
        if let hasTags = localProduct?.additivesOriginal.hasTags,
            hasTags {
            return true
        }
        if let hasTags = remoteProduct?.additivesInterpreted.hasTags,
            hasTags {
            return true
        }
        return false
    }

    var hasAllergens: Bool {
        if let hasTags = remoteProduct?.allergensInterpreted.hasTags,
            hasTags {
            return true
        }
        return false
    }

    var hasMinerals: Bool {
        if let hasTags = localProduct?.minerals.hasTags,
            hasTags {
            return true
        }
        if let hasTags = remoteProduct?.minerals.hasTags,
            hasTags {
            return true
        }
        return false
    }

    var hasNucleotides: Bool {
        if let hasTags = localProduct?.nucleotides.hasTags,
            hasTags {
            return true
        }
        if let hasTags = remoteProduct?.nucleotides.hasTags,
            hasTags {
            return true
        }
        return false
    }

    var hasOtherNutritionalSubstances: Bool {
        if let hasTags = localProduct?.otherNutritionalSubstances.hasTags,
            hasTags {
            return true
        }
        if let hasTags = remoteProduct?.otherNutritionalSubstances.hasTags,
            hasTags {
            return true
        }
        return false
    }

    var hasTraces: Bool {
        if let hasTags = localProduct?.tracesOriginal.hasTags,
            hasTags {
            return true
        }
        if let hasTags = remoteProduct?.tracesOriginal.hasTags,
            hasTags {
            return true
        }
        return false
    }

    var hasVitamins: Bool {
        if let hasTags = localProduct?.vitamins.hasTags,
            hasTags {
            return true
        }
        if let hasTags = remoteProduct?.vitamins.hasTags,
            hasTags {
            return true
        }
        return false
    }
    
    func preFetch() {
        switch remoteStatus {
        case .available, .productNotAvailable, .loadingFailed, .loading:
            break
        default:
            newFetch()
        }
    }
    
    func newFetch() {
        fetch(shouldBeReloaded: false)
    }
    
    func reload() {
        fetch(shouldBeReloaded: true)
    }
        
    private func fetch(shouldBeReloaded: Bool) {
        // only start fetch if we are not already busy loading
            switch remoteStatus {
            case .loading:
                break
            default:
                let request = OpenFoodFactsRequest()
                remoteStatus = .loading(barcodeType.asString)
                request.fetchProduct(for:self.barcodeType, shouldBeReloaded:shouldBeReloaded) { (completion: ProductFetchStatus) in
                    let fetchResult = completion
                    switch fetchResult {
                    case .success(let product):
                        if product.barcode.asString == self.barcodeType.asString {
                            // if this was the stored most recent product, the local version can be deleted
                            switch self.barcodeType {
                            case .mostRecent:
                                self.barcodeType = product.barcode
                                self.localProduct = nil
                                 self.updateIsAllowed = true
                            default:
                                break
                            }
                            self.remoteProduct = product
                            // Check if all elements of the local product have been updated
                            switch self.localStatus {
                            case .updated:
                                // Then the local product can be removed
                                self.localProduct = nil
                            default: break
                            }
                        }
                    
                    case .loadingFailed(let barcodeString):
                         self.remoteStatus = .loadingFailed(barcodeString)
                        // I could try to check the local off database here
                        // This uses the CSV-database to allow for network less avaluation
                        // TBD
                        //OFFDatabase.manager.product(for: barcodeString) { (product: FoodProduct?) in
                        //    if let validProduct = product {
                        //        self.remoteProduct = validProduct
                        //    }
                       // }
                        self.initLocalProduct()
                        //self.localProduct?.nameLanguage[self.localProduct?.primaryLanguageCode ?? Locale.interfaceLanguageCode] = "New local product"
                    case .productNotAvailable(let barcodeString):
                        self.remoteStatus = .productNotAvailable(barcodeString)
                        // If we create a local product here we do not longer now that it is an unavailable product
                        self.initLocalProduct()
                        //self.localProduct?.nameLanguage[self.localProduct?.primaryLanguageCode ?? Locale.interfaceLanguageCode] = "New product"
                        // create an empty product with the required barcode on off
                        //self.upload()
                    
                    default: break
                    }
                }
        }
    }
    
}

// Notification definitions

extension Notification.Name {
    static let ProductUpdateSucceeded = Notification.Name("ProductPair.Notification.ProductUpdateSucceeded")
    static let ProductUpdateFailed = Notification.Name("ProductPair.Notification.ProductUpdateFailed")
    static let ProductPairUpdated = Notification.Name("ProductPair.Notification.ProductPairUpdated")
    static let ProductPairLocalStatusChanged = Notification.Name("ProductPair.Notification.LocalStatusChanged")
    static let ProductPairRemoteStatusChanged = Notification.Name("ProductPair.Notification.RemoteStatusChanged")
    static let ProductPairImageUploadSuccess = Notification.Name("ProductPair.Notification.ImageUploadSuccess")
    static let ProductPairImageDeleteSuccess = Notification.Name("ProductPair.Notification.ImageDeleteSuccess")
}



