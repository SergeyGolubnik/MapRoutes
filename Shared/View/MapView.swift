//
//  MapView.swift
//  MapRoutes (iOS)
//
//  Created by Balaji on 03/01/21.
//

import SwiftUI
import MapKit

struct MapView: UIViewRepresentable {
    @EnvironmentObject var mapData: MapViewModel
    
    func makeCoordinator() -> Coordinator {
        return MapView.Coordinator()
    }
    
    func makeUIView(context: Context) -> MKMapView {
        
        let view = mapData.mapView
        
        view.showsUserLocation = true
        view.delegate = context.coordinator
        let longPressed = UILongPressGestureRecognizer(target: context.coordinator,
                                                       action: #selector(context.coordinator.tapHandler(_:)))
        
        
        view.addGestureRecognizer(longPressed)
        return view
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {

    }
    
    class Coordinator: NSObject, MKMapViewDelegate, UIGestureRecognizerDelegate {
        var data = MapViewModel()
        var place: Place?
        let mapView = MKMapView()
        var gRecognizer = UITapGestureRecognizer()
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            
            // Custom Pins....
            
            // Excluding User Blue Circle...
            
            if annotation.isKind(of: MKUserLocation.self){return nil}
            else{
                let pinAnnotation = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "PIN_VIEW")
                pinAnnotation.tintColor = .red
                pinAnnotation.animatesDrop = true
                pinAnnotation.canShowCallout = true
                
                return pinAnnotation
            }
        }
        @objc func tapHandler(_ gesture: UITapGestureRecognizer) {
            self.data.places.removeAll()
            if (gesture.state == UITapGestureRecognizer.State.ended) {
                return
            }
            // position on the screen, CGPoint
            let location = gRecognizer.location(in: gesture.view)
            // position on the map, CLLocationCoordinate2D
            let coordinate = (gesture.view as? MKMapView)?.convert(location, toCoordinateFrom: gesture.view)
            guard let coordinate = coordinate else {return}
            let locationTap = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            print(coordinate)
            CLGeocoder().reverseGeocodeLocation(locationTap) { (placemarks, error) -> Void in
                if error != nil {
                    
                    
                    print("Κάτι δεν πήγε καλά με το GPS!")
                    
                } else {
                    
                    if let validPlacemark = placemarks?[0]{
//                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        self.data.places = [Place(placemark: validPlacemark)]
                            self.place = Place(placemark: validPlacemark)
                            
                            self.data.selectPlace(place: self.place!)
                            
//                        }
                    }
                    
                }
                
            }
            
            
        }
        
    }
}
