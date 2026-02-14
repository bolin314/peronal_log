import CoreLocation
import Foundation

@MainActor
public final class LocationService: NSObject, ObservableObject {
    @Published public var latitude: Double?
    @Published public var longitude: Double?
    @Published public var authorizationStatus: CLAuthorizationStatus = .notDetermined

    private let manager = CLLocationManager()
    private var continuation: CheckedContinuation<CLLocation?, Never>?

    public override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }

    public func requestPermission() {
        manager.requestWhenInUseAuthorization()
    }

    public func requestLocation() async -> (latitude: Double, longitude: Double)? {
        requestPermission()

        let location = await withCheckedContinuation { (continuation: CheckedContinuation<CLLocation?, Never>) in
            self.continuation = continuation
            manager.requestLocation()
        }

        guard let location else { return nil }

        let lat = location.coordinate.latitude
        let lon = location.coordinate.longitude
        latitude = lat
        longitude = lon
        return (latitude: lat, longitude: lon)
    }
}

extension LocationService: @preconcurrency CLLocationManagerDelegate {
    nonisolated public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        Task { @MainActor in
            continuation?.resume(returning: location)
            continuation = nil
        }
    }

    nonisolated public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in
            continuation?.resume(returning: nil)
            continuation = nil
        }
    }

    nonisolated public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        Task { @MainActor in
            authorizationStatus = status
        }
    }
}
