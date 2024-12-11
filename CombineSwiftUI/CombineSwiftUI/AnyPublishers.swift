//
//  AnyPublishers.swift
//  CombineSwiftUI
//
//  Created by Nivedha Rajendran on 11.12.24.
//

import SwiftUI
import Combine

//“The AnyPublisher object can represent, well, any publisher or operator. (Operators are a form of publishers.) When you create pipelines and want to store them in properties or return them from functions, their resulting types can bet pretty big because you will find they are nested. You can use AnyPublisher to turn these seemingly complex types into a simpler type.”

struct AnyPublishersView: View {
   @StateObject private var vm = AnyPublishersViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            HeaderView(title: "AnyPublisher",                       subtitle: "Introduction",                       desc: "The AnyPublisher is a publisher that all publishers (and                               operators) can become. You can use a special operator called                               eraseToAnyPublisher to create this common object.")
                .layoutPriority(1)
            
            Toggle("Home Team", isOn: $vm.homeTeam)
            .padding()
            
            Text("Team")
            .bold()
            
            List(vm.team, id: \.self) { name in
                Text(name)
            }
        }
        .font(.title)
    }
}

class AnyPublishersViewModel: ObservableObject {
    @Published var homeTeam = true
    @Published var team: [String] = []
    private var cancellables: Set<AnyCancellable> = []
    
    init() {
        $homeTeam
            .sink { [unowned self] value in
                fetch(homeTeam: value)
            }            .store(in: &cancellables)
    }
    
    //“AppPublishers.teamPublisher returns a publisher that either gets the home team or the away team. These are two different pipelines that can be returned from the same function but use the same subscriber.”
    func fetch(homeTeam: Bool) {
        team.removeAll()
        AppPublishers.teamPublisher(homeTeam: homeTeam)
            .sink { [unowned self] item in
                team.append(item)
            }
            .store(in: &cancellables)
    }
    
    //“There may be a scenario in your app where you need the same publisher on multiple views. Instead of duplicating the publisher, you can extract it to a common class like this.”
    //“Both of these publishers are returning strings and never fail (meaning they don’t throw errors).This is a fake URL to get a team based on an id. If you have read about dataTaskPublisher then you know errors can be thrown. So to make both pipelines return the same type of AnyPublisher that never returns errors I use the replaceError operator to intercept errors, return a String and cancel the publisher”
    
    class AppPublishers {
        static func teamPublisher(homeTeam: Bool) -> AnyPublisher<String, Never> {
            if homeTeam {
                //“There may be a scenario in your app where you need the same publisher on multiple views. Instead of duplicating the publisher, you can extract it to a common class like this.”
                return ["Stockton", "Malone", "Williams"].publisher
                    .prepend("HOME TEAM")
                    .eraseToAnyPublisher()
            } else {
                let url = URL(string: "https://www.nba.com/api/getteam?id=21")!
                return URLSession.shared.dataTaskPublisher(for: url)
                    .map { (data: Data, response: URLResponse) in
                        data
                    }
                    .decode(type: String.self, decoder: JSONDecoder())
                    .receive(on: RunLoop.main)
                    .prepend("AWAY TEAM")
                    .replaceError(with: "No players found")
                    .eraseToAnyPublisher()
            }
        }
    }
}

#Preview {
    AnyPublishersView()
}
