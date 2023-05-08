//
//  ViewController.swift
//  DI3
//
//  Created by 方品中 on 2023/5/8.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var label3: UILabel!
    @IBOutlet weak var label4: UILabel!
    @IBOutlet weak var label5: UILabel!
    @IBOutlet weak var label6: UILabel!
    
    var array = [PlayGrounds]()
    var semaphore = DispatchSemaphore(value: 1)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let group = DispatchGroup()
        
        let url1 = "https://data.taipei/api/v1/dataset/c7784a9f-e11e-4145-8b72-95b44fdc7b83?scope=resourceAquire&limit=1&offset=0"
        let url2 = "https://data.taipei/api/v1/dataset/c7784a9f-e11e-4145-8b72-95b44fdc7b83?scope=resourceAquire&limit=1&offset=10"
        let url3 = "https://data.taipei/api/v1/dataset/c7784a9f-e11e-4145-8b72-95b44fdc7b83?scope=resourceAquire&limit=1&offset=20"
        
        // 1. GCD Group
        //        fetchDataByGroup(group: group, url: url1)
        //        fetchDataByGroup(group: group, url: url2)
        //        fetchDataByGroup(group: group, url: url3)
        //
        //        group.notify(queue: DispatchQueue.main) {
        //            print("Fetch Done")
        //
        //            DispatchQueue.main.async {
        //                self.array.enumerated().forEach { [weak self] index, item in
        //                    switch index {
        //                    case 0:
        //                        self?.label1.text = item.result.results.first?.district
        //                        self?.label2.text = item.result.results.first?.location
        //                    case 1:
        //                        self?.label3.text = item.result.results.first?.district
        //                        self?.label4.text = item.result.results.first?.location
        //                    case 2:
        //                        self?.label5.text = item.result.results.first?.district
        //                        self?.label6.text = item.result.results.first?.location
        //                    default:
        //                        return
        //                    }
        //                }
        //            }
        //        }
        //        print("Fetch Start")
        
        // 2. GCD Semaphore
        fetchDataBySemaphore(urlString: url1) { [weak self] item in
            DispatchQueue.main.async {
                print(1)
                self?.label1.text = item.result.results.first?.district
                self?.label2.text = item.result.results.first?.location
            }
            
            self?.semaphore.signal()
        }
        fetchDataBySemaphore(urlString: url2) { [weak self] item in
            DispatchQueue.main.async {
                print(2)
                self?.label3.text = item.result.results.first?.district
                self?.label4.text = item.result.results.first?.location
            }
            self?.semaphore.signal()
        }
        fetchDataBySemaphore(urlString: url3) { [weak self] item in
            DispatchQueue.main.async {
                print(3)
                self?.label5.text = item.result.results.first?.district
                self?.label6.text = item.result.results.first?.location
            }
            self?.semaphore.signal()
        }
    }
    
    func fetchApi(urlString: String, completion: @escaping (PlayGrounds) -> Void) {
        guard let url = URL(string: urlString) else {
            return
        }
        print(urlString)
        for _ in 0...100000{}
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            let decoder = JSONDecoder()
            if let data = data {
                do {
                    let data = try decoder.decode(PlayGrounds.self, from: data)
                    completion(data)
                } catch {
                    print(error)
                }
            }
        }.resume()
    }
    
    func fetchDataByGroup(group: DispatchGroup, url: String) {
        group.enter()
        fetchApi(urlString: url) { [weak self] data in
            self?.array.append(data)
            group.leave()
        }
    }
    
    func fetchDataBySemaphore(urlString: String, completion: @escaping (PlayGrounds) -> Void) {
        semaphore.wait()

        fetchApi(urlString: urlString, completion: completion)
    }
}

struct PlayGrounds: Codable {
    var result: PlayGroundsInfo
}

struct PlayGroundsInfo: Codable {
    var limit: Int
    var offset: Int
    var count: Int
    var sort: String
    var results: [PlayGroundInfo]
}

struct PlayGroundInfo: Codable {
    var id: Int
    var location: String
    var district: String
    var address: String
    var longitude: String
    var latitude: String
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case location
        case district
        case address
        case longitude
        case latitude
    }
}
