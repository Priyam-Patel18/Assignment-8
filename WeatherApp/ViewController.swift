//
//  ViewController.swift
//  WeatherApp
//
//  Created by PRIYAM PATEL on 01/04/24.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var windSpeedLabel: UILabel!
    
    
    let GPSManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        GPSManager.delegate = self
        GPSManager.requestWhenInUseAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            GPSManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            getDataFromAPI(lat: location.coordinate.latitude, lon: location.coordinate.longitude) { [weak self] result in
                switch result {
                case .success(let success):
                    DispatchQueue.main.async {
                        self?.updateUI(data: success)
                    }
                case .failure(let failure):
                    print(failure)
                }
            }
        }
    }
    
    func getDataFromAPI(lat: Double, lon: Double, completion: @escaping (Result<WeatherData, Error>) -> ()) {
        guard let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?lat=\(lat)&lon=\(lon)&appid=11236f9599cc5b465ed891b6d43d862c&units=metric") else { return }
        URLSession.shared.dataTask(with: URLRequest(url: url)) { jsonData, _, error in
            guard let jsonData = jsonData else { return }
            do {
                let weatherData = try JSONDecoder().decode(WeatherData.self, from: jsonData)
                completion(.success(weatherData))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }
    
    func updateUI(data: WeatherData) {
        cityLabel.text = data.name ?? ""
        descriptionLabel.text = data.weather?.first?.description ?? ""
        if let weatherurl = URL(string: "https://openweathermap.org/img/wn/\(data.weather?.first?.icon ?? "")@2x.png") {
            imageView.load(url: weatherurl)
        }
        humidityLabel.text = "Humidity: \(data.main?.humidity ?? 0)%"
        windSpeedLabel.text = "Wind: \(data.wind?.speed ?? 0) Km/h"
        temperatureLabel.text = "\(Int(data.main?.temp ?? 0))°C"
    }
    
   
}


extension UIImageView {
 func load(url: URL) {
     DispatchQueue.global().async { [weak self] in
         if let data = try? Data(contentsOf: url) {
             if let image = UIImage(data: data) {
                 DispatchQueue.main.async {
                     self?.image = image
                 }
             }
         }
     }
 }
}


