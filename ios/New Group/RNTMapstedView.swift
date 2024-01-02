//
//  RCNMapViewTest.swift
//  Sample
//
//  Created by Jiaxiang Wang on 2023/11/14.
//  Copyright © 2023 Mapsted. All rights reserved.
//

import UIKit
import Foundation
import CoreLocation
import MapstedCore
import MapstedMap
@objc class RNTMapstedView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    var spinnerView: UIActivityIndicatorView!
    var mapPlaceholderView: UIView!
    let screen_width = UIScreen.main.bounds.width
    let screen_height = UIScreen.main.bounds.height
    var _title: String = ""

    @objc var title: String {
      get {
        return self._title
      }
      set (newVal) {
        self._title = newVal
      }
    }
    
        //View controller in charge of map view
    private let mapViewController = MNMapViewController()
    
    //MARK: -
    @objc override init(frame: CGRect) {
        super.init(frame: frame)
        createSubViews()
    }

    @objc init (labelText: String) {
        super.init(frame: .zero)
        createSubViews()
    }

    @objc required init?(coder: NSCoder) {
        super.init(coder: coder)
        createSubViews()
    }
    
    // Creating subview
    private func createSubViews() {

        self.mapPlaceholderView = UIView(frame: self.frame);
        self.mapPlaceholderView.backgroundColor = UIColor.white;
        addSubview(self.mapPlaceholderView);
      self.spinnerView = UIActivityIndicatorView(frame: CGRect(origin: CGPoint(x: (self.frame.size.width - 20)/2, y: (self.frame.size.height - 20)/2), size: CGSize(width: 20, height: 20)))
        addSubview(self.spinnerView)
        
        showSpinner()
        if CoreApi.hasInit() {
            print("===>init success!")
            self.onSuccess()
        }
        else {
            print("===>init failed!")
            MapstedMapApi.shared.setUp(prefetchProperties: false, callback: self)
        }
    }
  
      override func layoutSubviews() {
        self.mapPlaceholderView.frame = self.frame
        self.spinnerView.frame = CGRect(origin: CGPoint(x: (self.frame.size.width - 20)/2, y: (self.frame.size.height - 20)/2), size: CGSize(width: 20, height: 20))
        mapViewController.view.bounds = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height);
        mapViewController.view.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height);
  
      }
    
    //MARK: - Show & Hide Spinner
    
        //Start progress indicator
    func showSpinner() {
        DispatchQueue.main.async {
            self.spinnerView?.startAnimating()
        }
    }
    
        //Stop progress indicator
    func hideSpinner() {
        DispatchQueue.main.async {
            self.spinnerView?.stopAnimating()
        }
    }
    
    //MARK: - Setup UI
    
        //Method to do UI setup
    func setupUI() {
            //Whether or not you want to show compass
        MapstedMapMeta.showCompass = true
        
            //UI Stuff
        //addChild(mapViewController)
        mapViewController.view.translatesAutoresizingMaskIntoConstraints = false
        mapViewController.view.bounds = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height);
        mapViewController.view.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height);
        self.mapPlaceholderView.addSubview(mapViewController.view)
        addParentsConstraints(view: mapViewController.view)
        mapViewController.didMove(toParent: self.findViewController())
        
        //addSubview(mapViewController.view)
        //Added handleSuccess once MapView is ready to avoid any plotting issues.
        let propertyId = 504
        self.startDownload(propertyId: propertyId)
    }
    
    func startDownload(propertyId: Int) {
        CoreApi.PropertyManager.startDownload(propertyId: propertyId, propertyDownloadListener: self)
    }
    
    //MARK: - Download Property and Draw Property on Success
        //Handler for initialization notification
    fileprivate func handleSuccess() {
        
        DispatchQueue.main.async {
            self.setupUI()
        }
        
        
    }
    
        //Helper method to draw property.
    func drawProperty(propertyId: Int, completion: @escaping (() -> Void)) {
        
        guard let propertyData = CoreApi.PropertyManager.getCached(propertyId: propertyId) else {
            print("No property Data")
            self.hideSpinner()
            return
        }
        DispatchQueue.main.async {
            MapstedMapApi.shared.drawProperty(isSelected: true, propertyData: propertyData)
            if let propertyInfo = PropertyInfo(propertyId: propertyId) {
                MapstedMapApi.shared.mapView()?.moveToLocation(mercator: propertyInfo.getCentroid(), zoom: 18, duration: 0.2)
                completion();
            }
            self.hideSpinner()
        }
    }
    
    //MARK: - Utility Method
    
    //How to search for entities by name from CoreApi
    fileprivate func findEntityByName(name: String, propertyId: Int) {
        let matchedEntities = CoreApi.PropertyManager.findEntityByName(name: name, propertyId: propertyId)
        print("Matched \(matchedEntities.count) for \(name) in \(propertyId)")
        for match in matchedEntities {
            print("Match \(match.displayName) = \(match.entityId)")
        }
    }
}

//MARK: - UI Constraints Helper method
extension RNTMapstedView {
        //Helper method
    func addParentsConstraints(view: UIView?) {
        guard let superview = view?.superview else {
            return
        }
        
        guard let view = view else {return}
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let viewDict: [String: Any] = Dictionary(dictionaryLiteral: ("self", view))
        let horizontalLayout = NSLayoutConstraint.constraints(
            withVisualFormat: "|[self]|", options: NSLayoutConstraint.FormatOptions.directionLeadingToTrailing, metrics: nil, views: viewDict)
        let verticalLayout = NSLayoutConstraint.constraints(
            withVisualFormat: "V:|[self]|", options: NSLayoutConstraint.FormatOptions.directionLeadingToTrailing, metrics: nil, views: viewDict)
        superview.addConstraints(horizontalLayout)
        superview.addConstraints(verticalLayout)
    }
}

//MARK: - Core Init Callback methods
extension RNTMapstedView : CoreInitCallback {
    func onSuccess() {
        //Once the Map API Setup is complete, Setup the Mapview
        self.handleSuccess()
    }
    
    func onFailure(errorCode: EnumSdkError) {
        print("Failed with \(errorCode)")
    }
    
    func onStatusUpdate(update: EnumSdkUpdate) {
        print("OnStatusUpdate: \(update)")
    }
    
    func onStatusMessage(messageType: StatusMessageType) {
        //Handle message
    }
}

//MARK: - Property Download Listener Callback methods
extension RNTMapstedView : PropertyDownloadListener {
    func onSuccess(propertyId: Int) {
        self.drawProperty(propertyId: propertyId, completion: {
            self.findEntityByName(name: "ar", propertyId: propertyId)
        })
    }
    
    func onSuccess(propertyId: Int, buildingId: Int) {
        print("Successfully downloaded \(propertyId) - \(buildingId)")
    }
    
    func onFailureWithProperty(propertyId: Int) {
        print("Failed to download \(propertyId)")
    }
    
    func onFailureWithBuilding(propertyId: Int, buildingId: Int) {
        print("Failed to download \(propertyId) - \(buildingId)")
    }
    
    func onProgress(propertyId: Int, percentage: Float) {
        print("Downloaded \(percentage * 100)% of \(propertyId)")
    }

}

