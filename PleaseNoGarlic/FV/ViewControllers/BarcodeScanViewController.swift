//
//  BarcodeScanViewController.swift
//  FoodViewer
//
//  Created by arnaud on 14/02/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit
import AVFoundation

class BarcodeScanViewController: UIViewController, UITextFieldDelegate, KeyboardDelegate {
    
    //private let preferences = Preferences.manager
    
    private var currentBarcode: String = ""
    
    /// Thi sets up the diet to be used
    private let dietKey = SelectedDietsDefaults.manager.selected[0]

    private var timer = Timer()
    
    private func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(scanBarcodes), userInfo: nil, repeats: false)
    }
    
    // This variable defined the languageCode that must be used to display the product data
    // This is either the languageCode selected by the user or the best match for the current product
    private var displayLanguageCode: String? {
        return scannedProductPair?.product?.matchedLanguageCode(codes: Locale.preferredLanguageCodes)
    }

    
    @IBOutlet weak var searchTextField: UITextField! {
        didSet {
            setupProductType()
            searchTextField.delegate = self
        }
    }
    @IBOutlet weak var assessmentImage: UIImageView!
    {
        didSet {
            assessmentImage.image = UIImage.init(systemName: "hand.wave")
    }
        
    }
    
    @IBOutlet weak var tapToDismissLabel: UILabel! {
        didSet {
            tapToDismissLabel?.text = "Tap to dismiss and scan again"
        }
    }
    @IBOutlet weak var consentView: UIView!
    
    @IBOutlet weak var consentTextLabel: UILabel! {
        didSet {
            consentTextLabel?.text = "Please No Garlic helps you to assess whether a food product contains garlic. The assesment is based on the data of Open Food Facts and the garlic free community. Producers however do change recipes before we catch them. So be VERY CAREFUL. If your are alergic do NOT trust Please No Garlic"
        }
    }
    @IBOutlet weak var consentButton: UIButton! {
        didSet {
            consentButton?.titleLabel?.text = "I understand the risks"
        }
    }
    
    @IBAction func consentButtonTapped(_ sender: UIButton) {
        consentView.isHidden = true
    }
    
    @IBOutlet weak var productNameBarButtonItem: UIBarButtonItem! {
        didSet {
            productNameBarButtonItem.title = "No product detected"
        }
    }
        
    @IBOutlet weak var productView: UIView!
    
    @IBOutlet weak var scanView: UIView!
        
    func initializeCustomKeyboard() {
        // initialize custom keyboard
        let keyboardView = Keyboard(frame: CGRect(x: 0, y: 0, width: 0, height: 300))
        
        searchTextField?.inputView = keyboardView
        
        // the view controller will be notified by the keyboard whenever a key is tapped
        keyboardView.delegate = self
    }
    
    var activeTextField = UITextField()

    func keyWasTapped(_ character: String) {
        // check if we have a valid character (number)
        if character.isNumeric() {
            activeTextField.insertText(character)
            searchTextField.text = activeTextField.text
        }
    }
    
    func backspace() {
        activeTextField.deleteBackward()
        searchTextField.text = activeTextField.text
    }
    
    func enter() {
        view.endEditing(true)
        if var validBarcode = activeTextField.text,
            !validBarcode.isEmpty {
            // needed to go from UPC-12 to EAN-12
            if validBarcode.count == 12 {
                validBarcode = "0" + validBarcode
            }
            self.scannedProductPair = self.products.createProductPair(with: BarcodeType(barcodeString: validBarcode, type: .food))
            showProductData()
        }
    }
    
    func resetSearch() {
        self.searchTextField?.text = ""
        self.activeTextField.text = ""
    }
    
    fileprivate var products = OFFProducts.manager
    
    fileprivate var scannedProductPair: ProductPair? = nil {
        didSet {
            // this can happen off the main queue
            DispatchQueue.main.async(execute: {
                self.setupViews()
            })
        }
    }
    
    @objc func scanBarcodes() {
        self.scanner?.barcodesHandler = { barcodes in
            for barcode in barcodes {
                // Is this a new barcode, then star loading the data?
                if let validBarcode = barcode.stringValue,
                    validBarcode != self.currentBarcode
                {
                    self.currentBarcode = validBarcode
                    self.scannedProductPair = self.products.createProductPair(with: BarcodeType(typeCode: barcode.type.rawValue, value: validBarcode, type: .food))
                    print("Barcode found: type= " +  barcode.type.rawValue + " value=" + self.currentBarcode)
                    // create this barcode in the history and launch to fetch
                    DispatchQueue.main.async(execute: {
                            self.startTimer()
                            // show the product data
                            self.showProductData()
                    })
                }
            }
        }
    }
    
    @objc func showProductData() {
        if let validFetchResult = scannedProductPair?.remoteStatus  {
                switch validFetchResult {
                case .available, .updated:
                    setupViews()
            case .loading:
                    setupViews()
            case .productNotAvailable:
                setupViews()
            case .loadingFailed(let error):
                print("BarcodeScanViewController ", error)
                setupViews()
            default:
                break
            }
        } else {
            // There is no valid productPair
            setupViews()
        }
    }

    private func setupProductType() {
        
        productNameBarButtonItem?.title = TranslatableStrings.PointCamera
                
        productView?.backgroundColor = UIColor.black
    }
        
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    private func setupViews() {
            if scannedProductPair == nil {
                scanViewIsHidden = false
            } else {
                switch self.scannedProductPair!.remoteStatus {
                case .available, .updated:
                    scanViewIsHidden = true
                    if let validProduct = scannedProductPair?.remoteProduct {
                        productNameBarButtonItem?.title = validProduct.name
                        print(dietKey)
                        // check the diet against the product
                        if let validConclusion = Diets.manager.conclusion(validProduct, forDietWith: dietKey) {
                            switch validConclusion {
                            case -3:
                                productView.backgroundColor = .systemPurple
                                assessmentImage.image = UIImage.init(systemName: "snowflake")

                            case -2:
                                productView.backgroundColor = .systemRed
                                assessmentImage.image = UIImage.init(systemName: "xmark`")

                            case -1:
                                productView.backgroundColor = .systemOrange
                                assessmentImage.image = UIImage.init(systemName: "minus.circle")

                            case 0:
                                productView.backgroundColor = .systemYellow
                                assessmentImage.image = UIImage.init(systemName: "questionmark.circle")

                            case 1:
                                productView.backgroundColor = .systemMint
                                assessmentImage.image = UIImage.init(systemName: "smiley")

                            case 2:
                                productView.backgroundColor = .systemGreen
                                assessmentImage.image = UIImage.init(systemName: "suit.heart")

                            case 3:
                                productView.backgroundColor = .systemBlue
                                assessmentImage.image = UIImage.init(systemName: "bolt.heart")

                            default:
                                productView.backgroundColor = .systemGray
                                assessmentImage.image = UIImage.init(systemName: "pencil.circle")

                            }
                        }
                    }
                case .loading:
                    scanViewIsHidden = true
                    productView?.backgroundColor = .lightGray
                    assessmentImage.image = UIImage.init(systemName: "icloud.and.arrow.down")

                default:
                    scanViewIsHidden = false
                }
            }
    }
    
    // toggle the visibility of the scanView and the productView
    private var scanViewIsHidden: Bool = false {
        didSet {
            productView?.isHidden = !scanViewIsHidden
            scanView?.isHidden = scanViewIsHidden
        }
    }
    
    var scanner: RSCodeReaderViewController? = nil
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "RSCodeReaderViewControllerSegue" {
            if let vc = segue.destination as? RSCodeReaderViewController {
                scanner = vc
            }
        }
    }
    @objc func doubleTapOnProductView() {
        productView?.isHidden = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //is already done by the system
        //performSegue(withIdentifier: "RSCodeReaderViewControllerSegue", sender: self)
        scanBarcodes()
        setupProductType()
        setupViews()
        
        let doubleTapGestureRecognizer = UITapGestureRecognizer.init(target: self, action:#selector(BarcodeScanViewController.doubleTapOnProductView))
        doubleTapGestureRecognizer.numberOfTapsRequired = 1
        doubleTapGestureRecognizer.numberOfTouchesRequired = 1
        doubleTapGestureRecognizer.cancelsTouchesInView = false
        doubleTapGestureRecognizer.delaysTouchesBegan = true      //Important to add
        productView?.addGestureRecognizer(doubleTapGestureRecognizer)

        initializeCustomKeyboard()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector:#selector(BarcodeScanViewController.showProductData), name:.ProductPairRemoteStatusChanged, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(BarcodeScanViewController.showProductData), name:.ProductPairLocalStatusChanged, object:nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if let validGestureRecognizers = productView?.gestureRecognizers {
            for gesture in validGestureRecognizers {
                if let doubleTapGesture = gesture as? UITapGestureRecognizer,
                    doubleTapGesture.numberOfTapsRequired == 1,
                    doubleTapGesture.numberOfTouchesRequired == 1 {
                    productView?.removeGestureRecognizer(gesture)
                }
            }
        }
        NotificationCenter.default.removeObserver(self)

        super.viewDidDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
    }

}

// MARK: - UITabBarControllerDelegate Functions

extension BarcodeScanViewController: UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        // The user tapped on one of the tabs, so the selected/scanned product will be reset.
        scannedProductPair = nil
        products.currentScannedProduct = nil
    }
    
}
