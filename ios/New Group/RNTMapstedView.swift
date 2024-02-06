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
import MapstedMapUi

@objc class RNTMapstedView: UIView {

    var spinnerView: UIActivityIndicatorView!
    var mapPlaceholderView: UIView!
    let screen_width = UIScreen.main.bounds.width
    let screen_height = UIScreen.main.bounds.height
    var _propertyId: Int = 0
    var initSuccess: Bool = false
    @objc var onLoadCallback: RCTBubblingEventBlock?
    @objc var onSelectLocation: RCTBubblingEventBlock?
    @objc var onUnloadCallback: RCTBubblingEventBlock?

    @objc var propertyId: Int {
      get {
        return self._propertyId
      }
      set (newVal) {
        if (self.propertyId != newVal) {
          self._propertyId = newVal
          if (self.initSuccess) {
            DispatchQueue.main.async {
              self.setupUI()
            }
          }
        }
      }
    }
  
    @objc var unloadMap: Bool {
      get {
        return false
      }
      set (newVal) {
        if (newVal == true) {
          print("===>unload map")
          removePropertyAndResourcesBeforeDownload()
        }
      }
    }
    
    //View controller in charge of map view
    private let mapViewController = MNMapViewController()
    
    //MARK: - init
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
        self.spinnerView = UIActivityIndicatorView(frame: CGRect(origin: CGPoint(x: (self.bounds.size.width - 20)/2, y: (self.bounds.size.height - 20)/2), size: CGSize(width: 20, height: 20)))
        addSubview(self.spinnerView)
        
        showSpinner()
        // Set up mapsted
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
      self.spinnerView.frame = CGRect(origin: CGPoint(x: (self.bounds.size.width - 20)/2, y: (self.bounds.size.height - 20)/2), size: CGSize(width: 20, height: 20))
      mapViewController.view.bounds = CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height);
      mapViewController.view.frame = CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height);
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
        self.findViewController()?.addChild(mapViewController)
        mapViewController.view.translatesAutoresizingMaskIntoConstraints = false
        mapViewController.view.bounds = CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height);
        mapViewController.view.frame = CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height);
        self.mapPlaceholderView.addSubview(mapViewController.view)
        addParentsConstraints(view: mapViewController.view)
        mapViewController.didMove(toParent: self.findViewController())
        // Add map click listener
        MapstedMapApi.shared.addMapTileEventListenerDelegate(delegate: self)
        MapstedMapApi.shared.addMapVectorElementListenerDelegate(delegate: self)
        MapstedMapApi.shared.addMapListenerDelegate(delegate: self)
        //Added handleSuccess once MapView is ready to avoid any plotting issues.
        downloadPropertyAndDraw()
    }
    // Download property
    func downloadPropertyAndDraw() {
        // unload resource and property before download to show the store map view instead of the world map
        //removePropertyAndResourcesBeforeDownload()
        if (self.propertyId != 0) {
            print("Download property \(self.propertyId)")
            self.startDownload(propertyId: self.propertyId)
        }
    }
    
    func startDownload(propertyId: Int) {
        MapstedMapApi.shared.downloadPackage(propertyId: propertyId)
        // For showing the store map view instead of the world map
        let _ = MapstedMapApi.shared.centerOnProperty(propertyId: propertyId)
        CoreApi.PropertyManager.startDownload(propertyId: propertyId, propertyDownloadListener: self)
    }
    // Unload property and map
    func removePropertyAndResourcesBeforeDownload() {
        MapstedMapApi.shared.removeProperty(propertyId: self.propertyId)
        CoreApi.PropertyManager.unload(propertyId: self.propertyId, listener: self)
        MapstedMapApi.shared.unloadMapResources()
    }
    
    //MARK: - Download Property and Draw Property on Success
    //Handler for initialization notification
    fileprivate func handleSuccess() {
        self.initSuccess = true
        DispatchQueue.main.async {
          if self.propertyId != 0 {
            self.setupUI()
          }
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
          // remove property first in case draw again
            //MapstedMapApi.shared.removeProperty(propertyId: propertyId)
            MapstedMapApi.shared.drawProperty(isSelected: true, propertyData: propertyData)
            if let propertyInfo = PropertyInfo(propertyId: propertyId) {
                MapstedMapApi.shared.mapView()?.moveToLocation(mercator: propertyInfo.getCentroid(), zoom: 18, duration: 0.2)
                completion();
                if (self.onLoadCallback != nil) {
                  self.onLoadCallback!(["isSuccess": true])
                }
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
        if (self.onLoadCallback != nil) {
            self.onLoadCallback!(["isSuccess": false, "errorMessage": "Failed with \(errorCode)"])
        }
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
        self.onLoadCallback!(["isSuccess": false, "errorMessage": "Failed to download \(propertyId)"])
    }
    
    func onFailureWithBuilding(propertyId: Int, buildingId: Int) {
        print("Failed to download \(propertyId) - \(buildingId)")
    }
    
    func onProgress(propertyId: Int, percentage: Float) {
        print("Downloaded \(percentage * 100)% of \(propertyId)")
    }
}

/*
*Your view controller hosting the Mapsted map viewcontroller will
*automatically receive map event notifications if it conforms to the
*MNMapListenerDelegate delegate. When user taps on the map outside any
*vector elements, outsideBuildingTapped gets called with the tap position
*and the tap type.
*/
extension RNTMapstedView: MNMapListenerDelegate {
    func onMapMoved() {
      print("===Map moved")
    }
    
    func onMapStable() {
      print("===Map stable")
    }
    
    func onMapIdle() {
      print("===Map idle")
    }
    
    func onMapInteraction() {
      print("===Map interaction")
    }
  
    func outsideBuildingTapped(tapPos: MNMercator, tapType: MapstedMapApi.TapType) {
        DispatchQueue.main.async {
            if tapType == .eSingle {
                //handle single tap
            }
            else if tapType == .eLong {
                //handle long tap
            }
            else if tapType == .eDouble {
                //handle double tap
            }
        }
    }
}

//MARK: - Map click Listener Callback methods
extension RNTMapstedView: MNMapVectorElementListenerDelegate {
    func onPolygonTapped(polygon: MNMapPolygon, tapType: MapstedMap.MapstedMapApi.TapType, tapPos: MNMercator) {
    }
    
    func onEntityTapped(entity: MNMapEntity, tapType: MapstedMap.MapstedMapApi.TapType, tapPos: MNMercator) {
        
        DispatchQueue.main.async {
            let locationInfo = "Entity Name: \(entity.name) - PropertyId: \(entity.propertyId()) - EntityId: \(entity.entityId()) - BuildingId: \(entity.buildingId()) - FloorId: \(entity.floorId())"
            print(locationInfo)
            MapstedMapApi.shared.selectSearchEntity(entity: entity, showPopup: false)
            if (self.onSelectLocation != nil) {
              self.onSelectLocation!(["locationInfo": locationInfo])
            }
        }
    }
    
    func onBalloonClicked(searchEntity: MNSearchEntity) {
    }
    
    func onMarkerTapped(markerName: String, markerType: String) {
    }
}
//MARK: - Map click Vector Tile Event Listener Callback methods
extension RNTMapstedView: MNMapVectorTileEventListenerDelegate {
    public func onTileBalloonClicked(searchEntity: MNSearchEntity) {
        self.onBalloonClicked(searchEntity: searchEntity)
    }
    
    public func onTileMarkerTapped(markerName: String, markerType: String) {
        self.onMarkerTapped(markerName: markerName, markerType: markerType)
    }

    public func onTileEntityTapped(entity: MNMapEntity, tapType: MapstedMapApi.TapType, tapPos: MNMercator) {
        self.onEntityTapped(entity: entity, tapType: tapType, tapPos: tapPos)
    }
    
    public func onTilePolygonTapped(polygon: MNMapPolygon, tapType: MapstedMapApi.TapType, tapPos: MNMercator) {
        self.onPolygonTapped(polygon: polygon, tapType: tapType, tapPos: tapPos)
    }
}

//MARK: - Property Action Complete Listener
extension RNTMapstedView : PropertyActionCompleteListener {
    func completed(action: MapstedCore.PropertyAction, propertyId: Int, sucessfully: Bool, error: Error?) {
        print("Property: \(propertyId) Unloaded successfully: \(sucessfully) - error: \(String(describing: error))")
        // self.removeFromSuperview()
        if (self.onUnloadCallback != nil) {
          self.onUnloadCallback!(["isSuccess": true])
        }
    }
}

