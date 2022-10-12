 //
//  ProductsArray.swift
//  FoodViewer
//
//  Created by arnaud on 07/04/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import Foundation
import UIKit
 
class OFFProducts {
    
    // This class is implemented as a singleton
    // The productsArray is only needed by the ProductsViewController
    // Unfortunately moving to another VC deletes the products, so it must be stored somewhere more permanently.
    // The use of a singleton limits thus the number of file loads
    
    internal struct Notification {
        static let BarcodeDoesNotExistKey = "OFFProducts.Notification.BarcodeDoesNotExist.Key"
        static let BarcodeKey = "OFFProducts.Notification.Barcode.Key"
        static let ErrorKey = "OFFProducts.Notification.Error.Key"
        static let ImageTypeCategoryKey = "OFFProducts.Notification.ImageTypeCategory.Key"
    }
    
    static let manager = OFFProducts()
    
    // The index of the latest product that was added (scanned or typed)
    var currentScannedProduct: Int? = nil
    
    private var currentProductType: ProductType {
        return .food
    }
    
    init() {
        // Initialize the products, multiple options are possible:
        // - there is no history, the user usese the app the first time for instance -> show a sample product
        // - there are products in the history file
        //      check first if the most recent product has been stored and load that one
        //      then load the rest of the history products
        loadAll()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    //  Contains all the fetch results for all product types
    private var allProductPairs: [ProductPair] = []
    
    private var productPairList: [ProductPair] = []
    
    private func loadAll() {
        // define the public set of products
        setCurrentProductPairs()
    }

    var count: Int {
        return productPairList.count
    }
    
    func resetCurrentProductPairs() {
        setCurrentProductPairs()
    }

    private func setCurrentProductPairs() {
        var list: [ProductPair] = []
        for productPair in allProductPairs {
            // TODO: Is this needed? The idea is to only selectd the right productType,
            // but do I not already know that?
            switch productPair.remoteStatus {
               case .available:
                if let producttype = productPair.remoteProduct?.type?.rawValue {
                    if producttype == currentProductType.rawValue {
                        list.append(productPair)
                    }
                }
            default:
                list.append(productPair)
            }
        }
        // If there is nothing on the list add the sample product
        if list.isEmpty {
            //loadSampleProductPair()
            // TODO: Must be for the type!!!!
            //list.append(sampleProductPair)
        }
        self.productPairList = list
    }

    private func loadProductPairRange(around index: Int) {
        let range = 8
        let lowerBound = index - Int(range/2) < 0 ? 0 : index - Int(range/2)
        let upperBound = index + Int(range/2) < allProductPairs.count ? index + Int(range/2) : allProductPairs.count - 1
        for ind in lowerBound...upperBound {
            allProductPairs[ind].preFetch()
        }
    }
    
    func removeAllProductPairs() {
        allProductPairs = []
    }
    
    func removeProductPair(at index: Int) {
        allProductPairs.remove(at: index)
        resetCurrentProductPairs()
    }


//
//  MARK: ProductPair Element Functions
//
    func productPair(at index: Int) -> ProductPair? {
        guard index >= 0 && index < count else { return nil }
        return productPairList[index]
    }
    
    @discardableResult
    func loadProductPair(at index: Int) -> ProductPair? {
        guard index >= 0 && index < count else { return nil }
        loadProductPairRange(around: index)
        return productPairList[index]
    }
    
    func productPair(for barcode: BarcodeType) -> ProductPair? {
        if let index = indexOfProductPair(with: barcode){
            return productPair(at: index)
        }
        return nil
    }
    
    func indexOfProductPair(with barcodeType: BarcodeType?) -> Int? {
        guard let validbarcodeType = barcodeType else { return nil }
        return allProductPairs.firstIndex(where: { $0.barcodeType.asString == validbarcodeType.asString })
    }
    
    func index(of productPair: ProductPair?) -> Int? {
        guard let validProductPair = productPair else { return nil }
        return allProductPairs.firstIndex(where: { $0.barcodeType.asString == validProductPair.barcodeType.asString })
    }
    
    func createProduct(with barcodeType: BarcodeType) -> Int {
        if let existingIndex = indexOfProductPair(with: barcodeType) {
            // check if the product does not exist
            return existingIndex
        }
        // The product does not exist yet.
        
        // if the first one is a sample product remove it
        if allProductPairs.count == 1 {
            switch allProductPairs[0].barcodeType {
            case .sample:
                allProductPairs = []
            default:
                break
            }
        }
        // Create the productPair
        allProductPairs.insert(ProductPair(barcodeType: barcodeType, comment: nil), at: 0)
        // and start fetching
        allProductPairs[0].newFetch()
        
        // recalculate the productPairs
        setCurrentProductPairs()
        // Inform the viewControllers that the product list is larger
        let userInfo = [Notification.BarcodeKey: allProductPairs[0].barcodeType.asString]
        NotificationCenter.default.post(name: .ProductListExtended, object:nil, userInfo: userInfo)
        return 0
    }
    
    func createProductPair(with barcodeType: BarcodeType) -> ProductPair? {
        // get the index of the existing productPair
        if let validIndex = indexOfProductPair(with: barcodeType) {
            currentScannedProduct = validIndex
            loadProductPair(at: validIndex)
            return productPair(at: validIndex)
        } else {
            let validIndex = createProduct(with: barcodeType)
            // create a new productPair
            currentScannedProduct = validIndex
            loadProductPair(at: validIndex)
            return productPair(at: validIndex)
        }
    }
    
    func fetchProduct(with barcodeType: BarcodeType) {
        if let index = indexOfProductPair(with: barcodeType) {
            // The product exists
            allProductPairs[index].newFetch()
        }
    }
    
    //TODO: This can be replaced with the JSON encoder
    
    func reload(productPair: ProductPair?) {
        productPair?.reload()
    }
    
    func reloadAll() {
        //sampleProductFetchStatus = .initialized
        // reset the current list of products
        allProductPairs = []
        loadAll()
    }
    
}

// Notification definitions

extension Notification.Name {
    static let ProductListExtended = Notification.Name("OFFProducts.Notification.ProductListExtended")
    static let ProductNotAvailable = Notification.Name("OFFProducts.Notification.ProductNotAvailable")
    static let FirstProductLoaded = Notification.Name("OFFProducts.Notification.FirstProductLoaded")
    static let HistoryIsLoaded = Notification.Name("OFFProducts.Notification.HistoryIsLoaded")
    static let ProductLoadingError = Notification.Name("OFFProducts.Notification.ProductLoadingError")
    static let OFFProductsImageDeleteSuccess = Notification.Name("OFFProducts.Notification.ImageDeleteSuccess")
}


