//
//  RNTMapstedNavigateView.swift
//  Sample
//
//  Created by Jiaxiang Wang on 2023/12/22.
//  Copyright © 2023 Mapsted. All rights reserved.
//

import UIKit
import MapstedCore
import MapstedMap
import MapstedMapUi
import LocationMarketing

class RNTMapstedNavigateView: UIView {
    
    private var containerVC: ContainerViewController?
    private var mapsVC: MapstedMapUiViewController?
    private var spinnerView: UIActivityIndicatorView!
    var mapPlaceholderView: UIView!
    //var _propertyId: Int = 504
    var _propertyId: Int = 0 // for real property
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
          if (!self.initSuccess) {
              self.handleSuccess()
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

    let Logger = DebugLog()
    //MARK: -
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        createSubViews()
    }

    init (labelText: String) {
        super.init(frame: .zero)
        createSubViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        createSubViews()
    }
    // Unload property and map
    func removePropertyAndResourcesBeforeDownload() {
        MapstedMapApi.shared.removeProperty(propertyId: self.propertyId)
        CoreApi.PropertyManager.unload(propertyId: self.propertyId, listener: self)
        MapstedMapApi.shared.unloadMapResources()
    }
    // Creating subview
    private func createSubViews() {
        self.mapPlaceholderView = UIView(frame: self.frame);
        //self.mapPlaceholderView.backgroundColor = UIColor.gray;
        addSubview(self.mapPlaceholderView);
      self.spinnerView = UIActivityIndicatorView(frame: CGRect(origin: CGPoint(x: (self.frame.size.width - 20)/2, y: (self.frame.size.height - 20)/2), size: CGSize(width: 20, height: 20)))
        addSubview(self.spinnerView)
        self.containerVC = ContainerViewController();
        showSpinner()
        Logger.Log("Initialize", CoreApi.hasInit())
        if CoreApi.hasInit() {
          DispatchQueue.main.async {
              self.Logger.Log("already init success", "")
              self.addMapView()
          }
        }
        else {
            Logger.Log("MapstedMapApi", "")
            MapstedMapApi.shared.setUp(prefetchProperties: false, callback: self)
        }
    }
    
    override func layoutSubviews() {
        Logger.Log("==>self.frame", self.frame)
      self.mapPlaceholderView.frame = self.frame
      self.spinnerView.frame = CGRect(origin: CGPoint(x: (self.frame.size.width - 20)/2, y: (self.frame.size.height - 20)/2), size: CGSize(width: 20, height: 20))
        mapsVC?.view.bounds = self.bounds;
        mapsVC?.view.frame = self.frame;
        containerVC?.view.bounds = self.bounds;
        containerVC?.view.frame = self.frame;

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
    
    //MARK: - Intialize and add MapView and display property
    
    func addMapView() {
        //Logger.Log("MapstedMapApi", mapsVC ?? "nil")
        if mapsVC == nil {
            if let mapsVC = MapstedMapUiViewController.shared as? MapstedMapUiViewController {
                mapsVC.setAlertDelegate(alertDelegate: self)
                self.mapsVC = mapsVC
                self.mapsVC?.view.frame = self.frame
                self.mapsVC?.view.bounds = self.bounds
                self.containerVC?.addController(controller: mapsVC, yOffset: 0, isNew: false)
                self.containerVC?.view.frame = self.frame
                self.containerVC?.view.bounds = self.bounds
                self.mapPlaceholderView.addSubview(self.containerVC!.view)

                self.containerVC?.didMove(toParent: self.findViewController())
                //self.mapsVC?.didMove(toParent: self.findViewController())
            }
        }
        if (self.propertyId != 0) {
            self.handleSuccess()
        }
    }
    
    func getGeoFenceNotifications() {
        //Add self
        CoreApi.GeofenceManager.addListener(self)
        /**
         //Remove Listener
         //LocMarketingApi.shared.removeGeofenceEventListener(listener: self)
         */
        
    }
    
    func displayProperty(propertyId: Int, completion: (() -> ())? = nil) {
        MapstedMapApi.shared.downloadPackage(propertyId: propertyId)
        // For showing the store map view instead of the world map
        let _ = MapstedMapApi.shared.centerOnProperty(propertyId: propertyId)
        //MapstedMapApi.shared.removeProperty(propertyId: propertyId)

        //zoom to property
        self.mapsVC?.showLoadingSpinner(text: "Loading...")
        hideSpinner()
        print("===propertyId: \(propertyId)")

        //let propertyId = propertyInfo.getPropertyId()
        self.mapsVC?.selectAndDrawProperty(propertyId: propertyId, callback: {[weak self] status in
              DispatchQueue.main.async {
                  self?.mapsVC?.hideLoadingSpinner()
                  if status {
                      self?.mapsVC?.displayPropertyOnMap {
                          completion?()
                      }
                  }
                  else {
                      self?.Logger.Log("Problem with status on select and draw", status)
                  }
              }
        })
    }
    
    //Method to handle success scenario after SDK initialized
    fileprivate func handleSuccess() {
      self.initSuccess = true
//        let propertyInfos = CoreApi.PropertyManager.getAll()
//        Logger.Log("propertyInfos", propertyInfos)
//        if propertyInfos.count > 0 {
//            let firstProperty = propertyInfos[0]
//            Logger.Log("firstProperty", firstProperty)
            self.displayProperty(propertyId: self.propertyId) {
                //let propertyId = firstProperty.propertyId
                //self.Logger.Log("displayProperty", propertyId)
//                self.findEntityByName(name: "Washrooms", propertyId: propertyId)
//
//                self.getCategories(propertyId: propertyId)
//
//                self.searchPOIs(propertyId: propertyId)
//
//                //Search for POIS with filter
//                self.searchPOIsWithCategoryFilter(propertyId: propertyId, categoryId: "abc123")
//
//                self.chooseFromEntities(name: "lounge", propertyId: propertyId)
            }
//        }
//        else {
//            self.Logger.Log("No properties found", "")
//        }
    }
    
    //MARK: - Utility Methods
    
    //How to search for entities by name from CoreApi
    fileprivate func findAllEntities(propertyId: Int) {
        let matchedEntities = CoreApi.PropertyManager.getSearchEntities(propertyId: propertyId)
        self.Logger.Log("Getting all search entities in", propertyId)
        for match in matchedEntities {
            self.Logger.Log("##Found ", "\(match.displayName) = \(match.entityId) in \(propertyId)")
        }
    }
    
    //How to request a list of nearby entities from CoreApi
    fileprivate func findNearbyEntities() {
        CoreApi.LocationManager.getNearbyEntities { listOfEntityZoneDistances in
            self.Logger.Log("Found ", "\(listOfEntityZoneDistances.count) nearby entities")
            for entityZoneDistance in listOfEntityZoneDistances {
                let zone = entityZoneDistance.getZone()
                let distance = entityZoneDistance.getDistance()
                self.Logger.Log("Found ", "\(zone.entityId()) - \(distance)")
            }
            
        }
    }
    
    //How to search for entities by name from CoreApi
    fileprivate func findEntityByName(name: String, propertyId: Int) {
        let matchedEntities = CoreApi.PropertyManager.findEntityByName(name: name, propertyId: propertyId)
        self.Logger.Log("Matches ", "\(matchedEntities.count) for \(name) in \(propertyId)")
        for match in matchedEntities {
            self.Logger.Log("Match ", "\(match.displayName) = \(match.entityId)")
        }
    }
    
    fileprivate func chooseFromEntities(name: String, propertyId: Int) {
        let matchedEntities = CoreApi.PropertyManager.findEntityByName(name: name, propertyId: propertyId)
        guard !matchedEntities.isEmpty else { return }
        self.Logger.Log("chooseFromEntities ", matchedEntities)
        mapsVC?.showEntityChooser(entities: matchedEntities, name: name)

    }
    
    
    fileprivate func searchPOIsWithCategoryFilter(propertyId: Int, categoryId: String) {
        let categoryFilter = PoiFilter.Builder().addFilter(
            PoiIntersectionFilter.Builder()
                .addCategory(id: categoryId)
                .build())
            .build()
        
        CoreApi.PropertyManager.searchPOIs(filter: categoryFilter, propertyId: propertyId, completion: { (searchables: [ISearchable] ) in
            
            let resultCount = searchables.count
            self.Logger.Log("Found ", "\(resultCount) items")
            for searchable in searchables.filter({$0.subcategoryUids.contains(categoryId)}) {
                
                for zone in searchable.entityZones {
                    //Entity Zone with propertyId, buildingId, floorId, entityId
                }
                for location in searchable.locations {
                    //Locations with x, y, z as well as propertyId, buildingId, floorId
                }
                
                for entity: ISearchable in searchable.entities {
                    self.Logger.Log("Found entity with ", " \(entity.displayName) - \(entity.entityId)")
                }
            }
            
            self.mapsVC?.showEntityChooser(entities: searchables, name: categoryId)
        })
    }

    //How to search for Points of Interest with filters using CoreApi.PropertyManager
    fileprivate func searchPOIs(propertyId: Int) {
        let floorFilter = PoiFilter.Builder().addFilter(
            PoiIntersectionFilter.Builder()
                .addFloor(id: 942)
                .build())
            .build()
        
        CoreApi.PropertyManager.searchPOIs(filter: floorFilter, propertyId: propertyId, completion: { (searchables: [ISearchable] ) in
            for searchable in searchables {
                self.Logger.Log("#SearchPOI: Found", " \(searchable.displayName) - Items: \(searchable.entities.count)")
            }
            
            
        })
        
        let categoryFilter = PoiFilter.Builder().addFilter(
            PoiIntersectionFilter.Builder()
                .addCategory(id: "5ff77d3a83919e8624ce0bdc") //Washroom
                .build())
            .build()
        
        CoreApi.PropertyManager.searchPOIs(filter: categoryFilter, propertyId: propertyId, completion: { (searchables: [ISearchable] ) in
            for searchable in searchables {
                self.Logger.Log("#SearchPOI: Found", " \(searchable.displayName)")
            }
            
            
        })
    }
    
    //How to filter entities using PoiFilter
    fileprivate func findEntityByNameAndCheckFilters(name: String, propertyId: Int) {
        let matchedEntities = CoreApi.PropertyManager.findEntityByName(name: name, propertyId: propertyId)
        self.Logger.Log("Matched", " \(matchedEntities.count) for \(name) in \(propertyId)")
        //Create filter for floor 941 and categories "5ff77d3a83919e8624ce0bdc" OR
        let poiFilter1 = PoiFilter.Builder().addFilter(
            PoiIntersectionFilter.Builder()
                .addCategory(id: "60b79e15f889e01204d40923")
                .build())
            .build()

        for match in matchedEntities.filter({poiFilter1.includePoi(searchable: $0)}) {
            self.Logger.Log("#Match: ", "\(match.displayName) = \(match.entityId) - \(match.floorId) - \(match.categoryUid) - \(match.buildingId)")
        }
        
        for match in matchedEntities.filter({!poiFilter1.includePoi(searchable: $0)}) {
            self.Logger.Log("#Match Not:", " \(match.displayName) = \(match.entityId) - \(match.floorId) - \(match.categoryUid) - \(match.buildingId)")
        }
        
        
        //Filter only floor 942
        let poiFilter2 = PoiFilter.Builder().addFilter(
            PoiIntersectionFilter.Builder()
                .addFloor(id: 942)
                .build())
            .build()
        
        for match in matchedEntities.filter({poiFilter2.includePoi(searchable: $0)}) {
            self.Logger.Log("#Match: ", "\(match.displayName) = \(match.entityId) - \(match.floorId) - \(match.categoryUid) - \(match.buildingId)")
        }
        
        for match in matchedEntities.filter({!poiFilter2.includePoi(searchable: $0)}) {
            self.Logger.Log("#Match Not:", " \(match.displayName) = \(match.entityId) - \(match.floorId) - \(match.categoryUid) - \(match.buildingId)")
        }
        
        self.Logger.Log("#Mathces for Filter 3", "")
        //Create filter for floor 941 and categories "5ff77d3a83919e8624ce0bdc" (washroom)
        let poiFilter3 = PoiFilter.Builder()
            .addFilter(
                PoiIntersectionFilter
                .Builder()
                .addFloor(id: 941)
                .addCategory(id: "5ff77d3a83919e8624ce0bdc")
                .build()
            )
            .addFilter(
                PoiIntersectionFilter
                .Builder()
                .addFloor(id: 942)
                .addCategory(id: "5ff77d3883919e8624ce0bc4")
                .build()
            )
            
            .build()
        
        for match in matchedEntities.filter({poiFilter3.includePoi(searchable: $0)}) {
            self.Logger.Log("#Match: ", "\(match.displayName) = \(match.entityId) - \(match.floorId) - \(match.categoryUid) - \(match.buildingId)")
        }
        
        for match in matchedEntities.filter({!poiFilter3.includePoi(searchable: $0)}) {
            self.Logger.Log("#Match Not:", " \(match.displayName) = \(match.entityId) - \(match.floorId) - \(match.categoryUid) - \(match.buildingId)")
        }
        
    }
    
    fileprivate func getCategories(propertyId: Int) {
        CoreApi.PropertyManager.getCategories(propertyId: propertyId, callback: { result in
            guard let result = result else {
                return
                
            }
            let categories = result.getAllCategories()
            print("#Category.getAllCategories : Found \(categories.count)")
            self.Logger.Log("#Category.getAllCategories :", "Found \(categories.count)")
            
            let roots = result.getRootCategories()
            self.Logger.Log("#Category.getRootCategories : Found", roots.count)
            
            if let category = categories.randomElement() {
                self.Logger.Log("#Category random element ", " \(category.id) - \(category.name)")
                if let checked = result.findById(uuid: category.id) {
                    self.Logger.Log("#Category chec", "\(category.id) - \(category.name) MATCHES \(checked.id) - \(checked.name)")
                }
                
                for parent in result.getParentCategories(uuid: category.id)  {
                    self.Logger.Log("#Category.Parent ", "\(parent.id) - \(parent.name) of \(category.id) - \(category.name)")
                }
                for ancestor in result.getAncestorCategories(uuid: category.id)  {
                    self.Logger.Log("#Category.Ancestor", "\(ancestor.id) - \(ancestor.name) of \(category.id) - \(category.name)")
                }
                for descendant in result.getDescendantCategories(uuid: category.id) {
                    self.Logger.Log("#Category.Descendant ", "\(descendant.id) - \(descendant.name) of \(category.id) - \(category.name)")
                }
            }
            
            let name = "washroom"
            let washrooms = result.findByName(name: name)
            for washroom in washrooms {
                print("#Category.findByName(\"\(name)\") matched by \(washroom.id) = \(washroom.name)")
                self.Logger.Log("#Category.findByName(\"\(name)\") matched by", "matched by \(washroom.id) = \(washroom.name)")
            }
        })
        
    }
    
    //How to request estimated distance from current user location using CoreApi
    fileprivate func estimateDistanceFromCurrentLocation(propertyId: Int) {
        let entities = CoreApi.PropertyManager.findEntityByName(name: "Appl", propertyId: propertyId)
        if let destination = entities.first as? MNSearchEntity {
            let useStairs = false
            let routeOptions = MNRouteOptions(useStairs,
                                              escalators: true,
                                              elevators: true,
                                              current: true,
                                              optimized: true)
            
            CoreApi.RoutingManager.requestEstimateFromCurrentLocation(destination: destination,
                                                                      routeOptions: routeOptions,
                                                                      completion: { distTime in
                
                if let distanceTime = distTime {
                    self.Logger.Log("Estimated distance is", distanceTime.distanceInMeters)
                    self.Logger.Log("Estimated time is", distanceTime.timeInMinutes)
                }
            })
        }
    }
    
    
    //How to request estimated distance from CoreApi
    fileprivate func estimateDistance(propertyId: Int) {
        let entities = CoreApi.PropertyManager.findEntityByName(name: "an", propertyId: propertyId)
        if let from = entities.first as? MNSearchEntity, let to = entities[1...].randomElement() as? MNSearchEntity {
            let useStairs = false
            let routeOptions = MNRouteOptions(useStairs,
                                              escalators: true,
                                              elevators: true,
                                              current: false,
                                              optimized: true)
            self.Logger.Log("Estimating distance from", "\(from.displayName) to \(to.displayName)")
            CoreApi.RoutingManager.requestEstimate(start: from,
                                                   destination: to,
                                                   routeOptions: routeOptions,
                                                   completion: { distTime in
                if let distanceTime = distTime {
                    self.Logger.Log("Estimated distance is", "\(distanceTime.distanceInMeters) meter(s)")
                    self.Logger.Log("Estimated time is", "\(distanceTime.timeInMinutes) minute(s)")
                }
            })
        }
    }
    
    fileprivate func allEntities(propertyId: Int) {
        let entities = CoreApi.PropertyManager.getSearchEntities(propertyId: propertyId)
        for entity in entities {
            self.Logger.Log("#Entity:", "\(entity.entityId) = \(entity.displayName)")
        }
    }
    
    
    fileprivate func selectEntities(propertyId: Int) {
        let entities = CoreApi.PropertyManager.findEntityByName(name: "Apple", propertyId: propertyId)
        if let firstMatch = entities.first {
            self.Logger.Log("Selecting ... ", "\(firstMatch.entityId) = \(firstMatch.displayName)")
            MapstedMapApi.shared.selectEntity(entity: firstMatch)
        }
        /*
        DispatchQueue.main.asyncAfter(deadline: .now() + 20.0) {
            print("Deselecting ....")
            MapstedMapApi.shared.deselectEntity()
        }
         */
    }
    fileprivate func makeRouteRequests(propertyId: Int) {
        let entities = CoreApi.PropertyManager.findEntityByName(name: "Appl", propertyId: propertyId)
        let otherEntities = CoreApi.PropertyManager.getSearchEntities(propertyId: propertyId)
        if let firstMatch = entities.first,
            let randomDestination1 = otherEntities.randomElement(),
            let randomDestination2 = otherEntities.randomElement(){
            
            
            self.makeRouteRequest(start: firstMatch,
                                  fromCurrentLocation: false,
                                  destinations: [randomDestination1, randomDestination2])
            
        }
        
        
    }
    
    fileprivate func makeRouteRequest(start: ISearchable?, fromCurrentLocation: Bool, destinations: [ISearchable]) {
        let optimizedRoute = true
        let useStairs = false
        let useEscalators = true
        let useElevators = true
        
        let routeOptions = MNRouteOptions(useStairs,
                                          escalators: useEscalators,
                                          elevators: useElevators,
                                          current: fromCurrentLocation,
                                          optimized: optimizedRoute)
        
        let start = start as? MNSearchEntity
        let pois = destinations.compactMap({$0 as? MNSearchEntity})
        
                
            //Build a route request
        var routeRequest: MNRouteRequest?
        routeRequest = MNRouteRequest(routeOptions: routeOptions,
                                      destinations:pois,
                                      startEntity: fromCurrentLocation ? nil : start)
        
        
        if let routeRequest = routeRequest {
            
                //@Daniel: Let's put this in async queue
            DispatchQueue.global(qos: .userInteractive).async {
                CoreApi.RoutingManager.requestRoute(request: routeRequest, routingRequestCallback: self)
            }
        }
    }
}

//MARK: - Core Init Callback methods
extension RNTMapstedNavigateView : CoreInitCallback {
    func onSuccess() {
        //Once the Map API Setup is complete, Setup the Mapview
        DispatchQueue.main.async {
            self.Logger.Log("onSuccess", "")
            self.addMapView()
        }
    }
    
    func onFailure(errorCode: EnumSdkError) {
        self.Logger.Log("Failed with", errorCode)
    }
    
    func onStatusUpdate(update: EnumSdkUpdate) {
        self.Logger.Log("OnStatusUpdate", update)
    }
    
    func onStatusMessage(messageType: StatusMessageType) {
        
    }
}

//MARK: - Routing Request Callback methods
extension RNTMapstedNavigateView: RoutingRequestCallback {
    func onSuccess(routeResponse: MNRouteResponse) {
        MapstedMapApi.shared.handleRouteResponse(routeResponse: routeResponse)
    }
    
    func onError(errorCode: Int, errorMessage: String, alertIds: [String]) {
        MapstedMapApi.shared.handleRouteError(errorCode: errorCode, errorMessage: errorMessage, alertIds: alertIds)
    }
    
    
}

extension RNTMapstedNavigateView: GeofenceEventListener {
    func onGeofenceEvent(propertyId: Int, triggerId: String) {
        self.Logger.Log("Go GeofenceEvent for", "\(propertyId) with Trigger: \(triggerId)")
    }
}

//MARK: - MN Alert Delegate methods
extension RNTMapstedNavigateView : MNAlertDelegate {
    func showAlerts() {
    }
    
    func loadingAlerts() -> Bool {
        return false
    }
}
//MARK: - Property Action Complete Listener
extension RNTMapstedNavigateView : PropertyActionCompleteListener {
    func completed(action: MapstedCore.PropertyAction, propertyId: Int, sucessfully: Bool, error: Error?) {
        print("Property: \(propertyId) Unloaded successfully: \(sucessfully) - error: \(String(describing: error))")
        // self.removeFromSuperview()
        if (self.onUnloadCallback != nil) {
          self.onUnloadCallback!(["isSuccess": true])
        }
    }
}

