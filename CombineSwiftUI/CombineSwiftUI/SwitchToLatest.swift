//
//  SwitchToLatest.swift
//  CombineSwiftUI
//
//  Created by Nivedha Rajendran on 14.12.24.
//

import SwiftUI
import Combine

//You use switchToLatest when you have a pipeline that has publishers being sent downstream. If you looked at the flatMap operator you will understand this concept of a publisher of publishers. Instead of values going through your pipeline, it’s publishers. And those publishers are also publishing values on their own. With the flatMap operator, you can collect ALL of these values these publishers are emitting and send them all downstream.  But maybe you don’t want ALL of the values that ALL of these publishers emit. Instead of having these publishers run at the same time, maybe you want just the latest publisher that came through to run and cancel out all the other ones that are still running that came before it. And that is what the switchToLatest operator is for. It’s kind of similar to combineLatest, where only the last value that came through is used. This is using the last publisher that came through

struct SwitchToLatest: View {
    @StateObject private var vm = SwitchToLatestViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            HeaderView(title: "SwitchToLatest",
                       subtitle: "Introduction",
                       desc: "The switchToLatest operator will use only the latest publisher that comes through the pipeline.When the switchToLatest operator receives a new publisher, it will cancel the current publisher it might have.")
    //uncomment this to check another case
            //            Text(vm.names.joined(separator: ", "))
            //            Button("Find Gender Probability") {
            //                vm.fetchNameResults()
            //            }
            //            List(vm.nameResults, id: \.name) { nameResult in
            //                HStack {
            //                    Text(nameResult.name)
            //                        .frame(maxWidth: .infinity, alignment: .leading)
            //                    Text(nameResult.gender + ": ")
            //                    Text(getPercent(nameResult.probability))
            //                }
            //            }
    //comment this to check another case
            List(vm.names, id: \.self) { name in
                Button(name) {
                    vm.fetchNameDetail.send(name)
                }
            }
            HStack {
                Text(vm.nameResult?.name ?? "Select a name")
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text((vm.nameResult?.gender ?? "") + ": ")
                Text(getPercent(vm.nameResult?.probability ?? 0))
            }
            .padding()
            .border(Color("Gold"), width: 2)
        }
        .font(.title)
    }
    
    func getPercent(_ number: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        return formatter.string(from: NSNumber(value: number)) ?? "N/A"
    }
}

class SwitchToLatestViewModel: ObservableObject {
    
    @Published var names = ["Kelly", "Madison", "Pat", "Alexus", "Taylor", "Tracy"]
    @Published var nameResults: [NameResult] = []
    private var cancellables: Set<AnyCancellable> = []
    @Published var nameResult: NameResult?
    //A PassthroughSubject is the publisher this time.
    //Only one name will be sent through at a time. But many names can come through.
    var fetchNameDetail = PassthroughSubject<String, Never>()
    
    init() {
        //In this example, every time you tap a row an API is called to get  information.  If you tap many rows then that could mean a lot of network traffic. Using switchToLatest will automatically cancel all previous network calls and only run the latest one.
        fetchNameDetail
            .map { name -> (String, URL) in
                (name, URL(string: "https://api.genderize.io/?name=\(name)")!)
            }
            .map { (name, url) in
                URLSession.shared.dataTaskPublisher(for: url)
                    .map { (data: Data, response: URLResponse) in
                        data
                    }
                    .decode(type: NameResult.self, decoder: JSONDecoder())
                    .replaceError(with: NameResult(name: name, gender: "Undetermined"))
                // To my surprise,delay API was actually pretty fast so I delayed it for half a second to give the  dataTaskPublisher a chance to get canceled by the switchToLatest operator.
                    .delay(for: 0.5, scheduler: RunLoop.main)
                    .eraseToAnyPublisher()
            }
        //If the user is tapping many rows, the switchToLatest operator will keep canceling dataTaskPublishers until one finishes and then sends the results downstream.
            .switchToLatest()
            .receive(on: RunLoop.main)
            .sink { [unowned self] nameResult in
                self.nameResult = nameResult
            }
            .store(in: &cancellables)
    }
    
    func fetchNameResults() {
        names.publisher
            .map { name -> (String, URL) in
                (name, URL(string: "https://api.genderize.io/?name=\(name)")!)
            }
            .map { (name, url) in
                //Using the URL created with the name, another publisher is created and sent down the pipeline.
                URLSession.shared.dataTaskPublisher(for: url)
                    .map { (data: Data, response: URLResponse) in
                        data
                    }
                    .decode(type: NameResult.self, decoder: JSONDecoder())
                    .replaceError(with: NameResult(name: name, gender: "Undetermined"))
                    .eraseToAnyPublisher()
            }
        //The switchToLatest operator will only republish the item published by the latest dataTaskPublisher that came through. OK, that’s a mouthful.
            .switchToLatest()
        //The receive operator switches execution back to the main thread. If you don’t do this,Xcode will show you a purple warning and you may or may not see results appear on the UI.
            .receive(on: RunLoop.main)
            .sink { [unowned self] nameResult in
                nameResults.append(nameResult)
            }
            .store(in: &cancellables)
    }
}

#Preview {
    SwitchToLatest()
}
