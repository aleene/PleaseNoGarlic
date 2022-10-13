//
//  TranslatableStrings.swift
//  PleaseNoGarlic
//
//  Created by Arnaud Leene on 10/10/2022.
//

import Foundation

struct TranslatableStrings {
    static let Additives = NSLocalizedString("Additives", comment: "Text to indicate the additives of a product.")

    static let AdditiveSpecific = NSLocalizedString("Additve %@", comment: "Text to indicate a specific additive.")

    static let Available = NSLocalizedString("Available", comment: "Text in a TagListView, when tags are available the product data.")
    static let Calories = NSLocalizedString("Calories", comment: "Title of third segment in switch, which lets the user select between joule, kilo-calories or Calories")
    static let Categories = NSLocalizedString("Categories", comment: "Text to indicate the product belongs to a category.")

    static let CategorySpecific = NSLocalizedString("Category %@", comment: "Text to indicate a specific additive.")

    static let Consent = NSLocalizedString("Please No Garlic helps you to assess whether a food product contains garlic. The assesment is based on the data of Open Food Facts and the garlic free community. Producers however do change recipes before we catch them. So be VERY CAREFUL. If your are alergic do NOT trust Please No Garlic.", comment: "Text to explain the risks.")
    
    static let ConsentAcceptance = NSLocalizedString("I understand the risks", comment: "Button text for user to accept the risks.")
    static let DailyValue = NSLocalizedString("Daily Value", comment: "Title of third segment in switch, which lets the user select between per daily value (per 100 mg/ml / per serving / per daily value)")

    static let Gram = NSLocalizedString("gram (g)", comment: "Standard weight unit.")
    static let Ingredients = NSLocalizedString("Ingredients", comment: "Text to indicate the ingredients of a product.")

    static let IngredientSpecific = NSLocalizedString("Ingredient %@", comment: "Text to indicate a specific ingredient.")

    static let Initialized = NSLocalizedString("Initialized", comment: "String presented in a tagView if nothing has happened yet")
    static let Joule = NSLocalizedString("Joules", comment: "Title of first segment in switch, which lets the user select between joules, kilo-calories or Calories")
    static let KiloCalorie = NSLocalizedString("Kilocalories", comment: "Title of second segment in switch, which lets the user select between joule, kilo-calories or Calories")
    static let Labels = NSLocalizedString("Labels", comment: "Generic string for labels on product")

    static let Microgram = NSLocalizedString("microgram (µm)", comment: "Standard weight unit divided by million.")
    static let Milligram = NSLocalizedString("milligram (mg)", comment: "Standard weight unit divided by thousand.")

    static let NoCategoryDefined = NSLocalizedString("No category defined", comment: "Text in a tableview cell, when no category is defined.")

    static let NoCountryDefined = NSLocalizedString("no country defined", comment: "Text for language of product, when there is no country defined.")

    static let NoLanguageDefined = NSLocalizedString("no language defined", comment: "Text for language of product, when there is no language defined.")

    static let NoName = NSLocalizedString("no name specified", comment: "Text for productname, when no productname is available in the product data.")
    static let None = NSLocalizedString("none", comment: "Text for a cell, when no status title has been provided, such as 'completed', etc.")

    static let NotFilled = NSLocalizedString("Not filled", comment: "Text in a TagListView, when the json provided an empty string.")

    static let NotSearchable = NSLocalizedString("Not searchable", comment: "Text in a search TagListView, when tags can not be set up.")
    static let NoTraceDefined = NSLocalizedString("no trace defined", comment: "Text for language of product, when there is no trace defined.")

    static let NoTranslation = NSLocalizedString("No translation", comment: "Text in a pickerView, when no translated text is available")
    static let OtherNutritionalSubstances = NSLocalizedString("Other Nutritional Substances", comment: "Tableview section header, which list the detected other nutritional substances in an ingredients list.")

    static let Percentage = NSLocalizedString("percentage (%)", comment: "Fraction of total by volume")
    static let PerServing = NSLocalizedString("Serving", comment: "Text of 2nd segment of a SegmentedControl, indicating the model of the nutrient values, i.e. the values are indicated per serving and in mg")
    static let PerDailyValue = NSLocalizedString("Daily value", comment: "Text of 3rd segment of a SegmentedControl, indicating the model of the nutrient values, i.e. the values are indicated per serving and in daily value percentage")
    static let PerKilogram = NSLocalizedString("Kilogram", comment: "Text of 4rd segment of a SegmentedControl, indicating the model of the nutrient values, i.e. the values are indicated per kilogram or liter")
    static let Per100mgml = NSLocalizedString("100g/ml", comment: "Text of 1st segment of a SegmentedControl, indicating the model of the nutrient values, i.e. per standard 100g or 100 ml")

    static let PointCamera = NSLocalizedString("Scan barcode", comment: "Text of a label, which explains the user to point the camera of his device to a barcode to start working (do not exceed 30 letters).")
    static let PreparationPrepared = NSLocalizedString("Prepared", comment: "Text to indicate a preparartion type (Prepared) related to the nutritional values.")
    static let PreparationUnprepared = NSLocalizedString("Unprepared", comment: "Text to indicate a preparartion type (Unprepared) related to the nutritional values.")

    static let Product = NSLocalizedString("Product", comment: "Title of a segmented control.")

    static let ProductIsLoaded = NSLocalizedString("Product is loaded", comment: "String presented in a tagView if the product has been loaded")
    static let ProductLoadingFailed = NSLocalizedString("Product loading failed", comment: "String presented in a tagView if the product loading has failed")

    static let ProductIsUpdated = NSLocalizedString("Product is updated", comment: "String presented in a tagView if the product is updated")

    static let ProductLoading = NSLocalizedString("Product loading", comment: "String presented in a tagView if the product is currently being loaded")
    static let ProductNotAvailable = NSLocalizedString("Product not available", comment: "String presented in a tagView if no product is available on OFF")

    static let ProductNotLoaded = NSLocalizedString("Product not loaded", comment: "String to indicate a product has not yet been retrieved from OFF yet and is only locally available")
    
    static let TapToDismiss = NSLocalizedString("Tap to dismiss and scan again", comment: "Text to indicate what the user shod to get rid of the assessment view.")
    static let Traces = NSLocalizedString("Traces", comment: "Text to indicate the traces of a product.")

    static let Unknown = NSLocalizedString("Unknown", comment: "Text in a TagListView, when the field in the json was not present.")


}
