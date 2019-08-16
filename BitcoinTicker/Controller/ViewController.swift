//
//  ViewController.swift
//  BitcoinTicker
//
//  Created by Angela Yu on 23/01/2016.
//  Copyright © 2016 London App Brewery. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    let baseURL = "https://apiv2.bitcoinaverage.com/indices/global/ticker/BTC"
    let currencyArray = ["Select a currency","AUD", "BRL","CAD","CNY","EUR","GBP","HKD","IDR","ILS","INR","JPY","MXN","NOK","NZD","PLN","RON","RUB","SEK","SGD","USD","ZAR"]
    let currencySymbolArray = [" ","$", "R$", "$", "¥", "€", "£", "$", "Rp", "₪", "₹", "¥", "$", "kr", "$", "zł", "lei", "₽", "kr", "$", "$", "R"]
    
    var currencySelected = ""
    var finalURL = ""
    
    let bitcoinDataModel = BitcoinDataModel()

    //Pre-setup IBOutlets
    @IBOutlet weak var bitcoinPriceLabel: UILabel!
    @IBOutlet weak var currencyPicker: UIPickerView!
    @IBOutlet weak var lowPriceLabel: UILabel!
    @IBOutlet weak var highPriceLabel: UILabel!
    @IBOutlet weak var dailyVariationLabel: UILabel!
    @IBOutlet weak var weeklyVariationLabel: UILabel!
    @IBOutlet weak var monthlyVariationLabel: UILabel!
    @IBOutlet weak var yearlyVariationLabel: UILabel!
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        currencyPicker.delegate = self
        currencyPicker.dataSource = self
        
        lowPriceLabel.text = ""
        highPriceLabel.text = ""
        dailyVariationLabel.text = ""
        weeklyVariationLabel.text = ""
        monthlyVariationLabel.text = ""
        yearlyVariationLabel.text = ""
        
    }

    
    //TODO: Place your 3 UIPickerView delegate methods here
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return currencyArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {

        return currencyArray[row]
        
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        finalURL = baseURL + currencyArray[row]
        currencySelected = currencySymbolArray[row]
        getBitcoinData(url: finalURL)
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        var label: UILabel
        
        if let view = view as? UILabel {
            label = view
        } else {
            label = UILabel()
        }
        label.textColor = .white
        label.textAlignment = .center
        
        label.text = currencyArray[row]
        
        return label
        
    }
    
    //MARK: - Networking
    /***************************************************************/
    
    func getBitcoinData(url: String) {
        
        Alamofire.request(url, method: .get)
            .responseJSON { response in
                if response.result.isSuccess {

                    print("Sucess! Got currency data")
                    let bitcoinJSON : JSON = JSON(response.result.value!)

                    self.updateBitcoinData(json: bitcoinJSON)

                } else {
                    print("Error: \(String(describing: response.result.error))")
                    self.bitcoinPriceLabel.text = "Connection Issues"
                    self.highPriceLabel.text = "-"
                    self.lowPriceLabel.text = "-"
                    self.dailyVariationLabel.text = "-"
                    self.weeklyVariationLabel.text = "-"
                    self.monthlyVariationLabel.text = "-"
                    self.yearlyVariationLabel.text = "-"
                }
            }

    }

    //MARK: - JSON Parsing
    /***************************************************************/
    
    func updateBitcoinData(json : JSON) {
        
        if let bitcoinResult = json["ask"].double {
            
            bitcoinDataModel.bitcoinPrice = bitcoinResult
            
            bitcoinDataModel.highPrice = json["high"].double!
            
            bitcoinDataModel.lowPrice = json["low"].double!
            
            bitcoinDataModel.dailyVariation = json["changes"]["percent"]["day"].double!
            
            bitcoinDataModel.weeklyVariation = json["changes"]["percent"]["week"].double!
            
            bitcoinDataModel.monthlyVariation = json["changes"]["percent"]["month"].double!
            
            bitcoinDataModel.yearlyVariation = json["changes"]["percent"]["year"].double!
            
            updateUIWithData()
            
        } else {
            bitcoinPriceLabel.text = "Price unavailable"
        }
        
    }
    
    func updateUIWithData() {
        
        bitcoinPriceLabel.text = "1 BTC = " + String(bitcoinDataModel.bitcoinPrice) + " " + currencySelected
        lowPriceLabel.text = String(bitcoinDataModel.lowPrice)
        highPriceLabel.text = String(bitcoinDataModel.highPrice)
        dailyVariationLabel.text = String(bitcoinDataModel.dailyVariation) + " %"
        weeklyVariationLabel.text = String(bitcoinDataModel.weeklyVariation) + " %"
        monthlyVariationLabel.text = String(bitcoinDataModel.monthlyVariation) + " %"
        yearlyVariationLabel.text = String(bitcoinDataModel.yearlyVariation) + " %"
        
        if bitcoinDataModel.dailyVariation < 0 {
            dailyVariationLabel.textColor = .red
        } else {
            dailyVariationLabel.textColor = .green
        }
        
        if bitcoinDataModel.weeklyVariation < 0 {
            weeklyVariationLabel.textColor = .red
        } else {
            weeklyVariationLabel.textColor = .green
        }
        
        if bitcoinDataModel.monthlyVariation < 0 {
            monthlyVariationLabel.textColor = .red
        } else {
            monthlyVariationLabel.textColor = .green
        }
        
        if bitcoinDataModel.yearlyVariation < 0 {
            yearlyVariationLabel.textColor = .red
        } else {
            yearlyVariationLabel.textColor = .green
        }
        
    }
    
}

