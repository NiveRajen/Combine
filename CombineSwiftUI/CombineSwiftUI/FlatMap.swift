//
//  FlatMap.swift
//  CombineSwiftUI
//
//  Created by Nivedha Rajendran on 12.12.24.
//

//You are used to seeing a value of some sort sent down a pipeline. But what if you wanted to use that value coming down the pipeline to retrieve more data from another data source. You would essentially need a publisher within a publisher. The flatMap operator allows you to do this.

import Combine
import SwiftUI

struct FlatMapView: View {
    @StateObject private var vm = FlatMapViewModel()
    @State private var count = 1
    var body: some View {
        VStack(spacing: 20) {
            HeaderView(title: "FlatMap",
                       subtitle: "Introduction",
                       desc: "The flatMap operator can be used to create a new publisher for each item that comes through the pipeline.")
            Text(vm.names.joined(separator: ", "))
            Button("Find Gender Probability") {
                vm.fetchNameResults()
            }
            List(vm.nameResults, id: \.name) { nameResult in
                HStack {
                    Text(nameResult.name)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text(nameResult.gender + ": ")
                    Text(getPercent(nameResult.probability))
                }
            }
        }
        .font(.title)
    }
    
    func getPercent(_ number: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        return formatter.string(from: NSNumber(value: number)) ?? "N/A"
    }
}

struct NameResult: Decodable {
    var name = ""
    var gender = ""
    var probability = 0.0
}

class FlatMapViewModel: ObservableObject {
    @Published var names = ["Kelly", "Madison", "Pat", "Alexus", "Taylor", "Tracy"]
    @Published var nameResults: [NameResult] = []
    private var cancellables: Set<AnyCancellable> = []
    
    
    //You can’t guarantee the order in which the results are returned from this flatMap. All of the publishers can run  all at the same time.
   // You CAN control how many publishers can run at the same time though with the maxPublishers parameter.
    //.flatMap(maxPublishers: Subscribers.Demand.max(1)) { (name, url) in
    //Setting maxPublishers tells flatMap how many of the publishers can run at the same time.
    //If set to 1, then one publisher will have to finish before the next one can begin.
    //Now the results are in the same order as the items that came down the pipeline.
    func fetchNameResults() {
        //The main publisher is the list of names. For each  name, a URL is created.
        //That URL (and the original name coming down the pipeline) is passed into the flatMap operator’s closure.
        names.publisher
            .map { name -> (String, URL) in
                (name, URL(string: "https://api.genderize.io/?name=\(name)")!)
            }
        //I explicitly set the failure type of this pipeline to Never. I handle errors within flatMap. The replaceError will convert the pipeline to a non-error-throwing pipeline and set the failure type to Never.
       // I didn’t have to set the return type of flatMap. It will work just fine without it but I wanted it here so you could see it and it would be more clear.
        //You could throw an error from flatMap if you wanted to. You would just have to change the subscriber from sink(receiveValue:) to sink(receiveCompletion:receiveValue:).
            .flatMap { (name, url) -> AnyPublisher<NameResult, Never> in
                URLSession.shared.dataTaskPublisher(for: url)
                //The map here could be replaced with .map { $0.data } or .map(\.data).
                    .map { (data: Data, response: URLResponse) in
                        data
                    }
                //If there is an error from either the dataTaskPublisher or decode then I’m just replacing it with a new NameResult object. This is why name is also passed into flatMap.
                    .decode(type: NameResult.self, decoder: JSONDecoder())
                    .replaceError(with: NameResult(name: name, gender: "Undetermined"))
                    .eraseToAnyPublisher()
            }
            .receive(on: RunLoop.main)
            .sink { [unowned self] nameResult in
                nameResults.append(nameResult)
            }
            .store(in: &cancellables)
    }
}

#Preview { FlatMapView() }
