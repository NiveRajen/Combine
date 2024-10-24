//
//  CollectByCount.swift
//  CombineSwiftUI
//
//  Created by Nivedha Rajendran on 24.10.24.
//

//You can pass a number into the collect operator and it will keep collecting items and putting them into an array until it reaches that number and then it will publish the array. It will continue to do this until the pipeline finishes.

import SwiftUI
import Combine

struct Collect_ByCountView: View {
    
    @StateObject private var vm = Collect_ByCountViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            HeaderView(title: "Collect",
                       subtitle: "By Count",
                       desc: "You can collect a number of values you specify and put them into arrays before publishing downstream.")
            
            Text("Team Size: \(Int(vm.teamSize))")
            
            Slider(value: $vm.teamSize, in: 2...4, step: 1,
                   minimumValueLabel: Text("2"),
                   maximumValueLabel: Text("4"), label:{ })
            .padding(.horizontal)
            
            Text("Teams")
            
            //The joined function puts all the items in an array into a single string, separated by the string you specify.
            List(vm.teams, id: \.self) { team in
                Text(team.joined(separator: ", "))
            }
        }
        .font(.title)
        .onAppear {
            vm.fetch()
        }
    }
}

class Collect_ByCountViewModel: ObservableObject {
    
    @Published var teamSize = 2.0
    
    @Published var teams: [[String]] = []
    
    private var players: [String] = []
    
    private var cancellables: Set<AnyCancellable> = []
    
    //A reference to the teamSize pipeline is stored in cancellables. So why isn’t the players  pipeline in the createTeams function stored too?
    //You need to keep the teamSize pipeline alive because it’s actively connected to a slider on the view.
    //But you don’t need to store a reference to the players pipeline because you use it one time and then you are done.
    init() {
        $teamSize
            .sink { [unowned self] in createTeams(with: Int($0)) }
            .store(in: &cancellables)
    }
    
    func fetch() {
        players = ["Mattie", "Chelsea", "Morgan", "Chase", "Kristin", "Beth", "Alex", "Ivan",
                   "Hugo", "Rod", "Lila", "Chris"]
        createTeams(with: Int(teamSize))
    }
    
    //All of the player names will go through this pipeline and be group together (or collected) into arrays using the collect operator.
    func createTeams(with size: Int) {
        teams.removeAll()
        _ = players.publisher
            .collect(size)
            .sink { [unowned self] (team) in
                teams.append(team)
            }
    }
}

struct Collect_ByCountView_Previews: PreviewProvider {
    static var previews: some View {
        Collect_ByCountView()
    }
}
