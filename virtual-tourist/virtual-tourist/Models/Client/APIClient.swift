//
//  APIClient.swift
//  virtual-tourist
//
//  Created by RhaXiel on 6/8/22.
//

import Foundation

class APIClient {
    static let apiKey = "YOUR_API_KEY"
    
    enum Endpoints {
        static let base = "https://www.flickr.com/services/rest/?method=flickr.photos.search"
        static let radius = 20 //A valid radius used for geo queries, greater than zero and less than 20 miles (or 32 kilometers), for use with point-based geo queries. The default value is 5 (km).
        
        case searchLocationPhotos(SearchRequestParams)
        
        var stringValue: String {
            switch self {
                case .searchLocationPhotos(let params): return Endpoints.base + paramBuilder(params: params)
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
        
        func paramBuilder(params: SearchRequestParams) -> String {
            return "&api_key=\(APIClient.apiKey)&lat=\(params.lat)&lon=\(params.lon)&radius=\(Endpoints.radius)&per_page=\(params.per_page)&page=\(params.page)&format=\(params.format)&nojsoncallback=\(params.nojsoncallback)&extras=url_m"
        }
        
    }
    
    class func randomizePageNumber(totalPicsAvailable: Int, maxNumPicsdisplayed: Int) -> Int {
        let flickrLimit = 4000
        let numberPages = min(totalPicsAvailable, flickrLimit) / maxNumPicsdisplayed
        let randomPageNum = Int.random(in: 0...numberPages)
        print("totalPicsAvaible is \(totalPicsAvailable), numPage is \(numberPages)",
             "randomPageNum is \(randomPageNum)" )
        
        return randomPageNum
    }
    
    class func taskForGETRequest<ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void) -> URLSessionDataTask {
        print("Fetching: \(url)")
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            let decoder = JSONDecoder()
            do {
                let responseObject = try decoder.decode(ResponseType.self, from: data)
                DispatchQueue.main.async {
                    completion(responseObject, nil)
                }
            } catch {
                print("Error fetching data: \(error)")
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        }
        task.resume()
        
        return task
    }
    
    class func taskForDownload(img: String, completion: @escaping (Data?, Error?) -> Void) {
        let url = URL(string: img)
        guard let imageURL = url else {
             DispatchQueue.main.async {
                 completion(nil, nil)
             }
             return
         }
         
         let request = URLRequest(url: imageURL)
         let task = URLSession.shared.dataTask(with: request) { data, response, error in
             DispatchQueue.main.async {
                 completion(data, nil)
             }
         }
         task.resume()
    }
    
    class func getPhotos(params: SearchRequestParams, completion: @escaping ([PhotoResponse], Int, Error?) -> Void) {
        let page = randomizePageNumber(totalPicsAvailable: 0, maxNumPicsdisplayed: params.per_page)
        let _params = SearchRequestParams(lat: params.lat, lon: params.lon, page: page)
        
        let _ = taskForGETRequest(url: Endpoints.searchLocationPhotos(_params).url, responseType: SearchPhotoResponse.self) { response, error in
            if let response = response {
                completion(response.photos.photo, response.photos.pages, nil)
            } else {
                completion([], 0, error)
            }
        }
    }
    
}
