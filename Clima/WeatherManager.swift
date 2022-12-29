//
//  WeatherManager.swift
//  Clima
//
//  Created by User on 23/10/22.
//  Copyright © 2022 App Brewery. All rights reserved.
//

import Foundation
import CoreLocation

protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel)
    func didFailWithError(error: Error)
}

struct WeatherManager{
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=61695f716d5db757dcb92bd057dc1ce7&units=metric"
    
    var delegate: WeatherManagerDelegate?
    
    func fetchWeather(cityName: String){
        let urlString = "\(weatherURL)&q=\(cityName)"
        performRequest(with: urlString)
    }
    
    func fetchWeather(longitude: CLLocationDegrees,latitude: CLLocationDegrees){
        let urlString = "\(weatherURL)&lat=\(latitude)&lon=\(longitude)"
        performRequest(with: urlString)
    }
    
    //MARK: - request url
    
    func performRequest(with urlString: String){
        //        1. create a URL
        //        2. create a URL session
        //        3. give the session a Task
        //        4. start the task
        if let url = URL(string: urlString){
            
            //        2. create a URL session
            let session = URLSession(configuration: .default)
            
            //        3. give the session a Task
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil{
                    delegate?.didFailWithError(error: error!)
                    return
                }
                if let safeData = data {
                    //                    let dataString = String(data: safeData, encoding: .utf8)
                    //                    print(dataString)
                    if let weather = parseJSON(safeData){
                        delegate?.didUpdateWeather(self,weather: weather)
                    }
                }
            }
            
            //        4. start the task
            task.resume()
        }
        
    }
    
    func parseJSON(_ weatherData: Data)->WeatherModel?{
        let decoder = JSONDecoder()
        do{
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            //            print(decodedData.main.temp)
            //            print(decodedData.weather[0].description)
            let id = decodedData.weather[0].id
            let city = decodedData.name
            let temp = decodedData.main.temp
            let weather = WeatherModel(conditionId: id, cityName: city, temperature: temp)
            //            print(weather.conditionName)
            //            print(weather.temp)
            return weather
        }catch{
            delegate?.didFailWithError(error: error)
            return nil
        }
        
    }
    
}
