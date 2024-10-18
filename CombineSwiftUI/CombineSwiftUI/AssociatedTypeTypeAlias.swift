//
//  AssociatedTypeTypeAlias.swift
//  CombineSwiftUI
//
//  Created by Nivedha Rajendran on 18.10.24.
//

import SwiftUI

protocol GameScore {
    //You use associatedtype to indicate it can be any type.
    associatedtype TeamScore // This can be anything: String, Int, Array, etc.
    associatedtype Team: Collection
    
    
    var team1: Team { get set }
    var team2: Team { get set }
    
    func compareTeamSizes() -> String
    
    func calculateWinner(teamOne: TeamScore, teamTwo: TeamScore) -> String
}


protocol Team {
    associatedtype Team
    
    var team1: Team { get set }
    var team2: Team { get set }
    
    //This will makes sure that associatedType of two protocols are same type
    func assign<T>(team: T) where T: GameScore, Self.Team == T.TeamScore
}

struct FootballGame: GameScore {
    //You use typealias to declare the type when conforming to the protocol.
    //we can comment the typealias and declare the parameters of function with Int type
    typealias TeamScore = Int
    
    
    //Instead of using typealias, we can use the string array to set the type
    var team1 = ["Player One", "Player Two"]
    var team2 = ["Player One", "Player Two", "Player Three"]
    
    //MArk the type of parameter with typealias
    func calculateWinner(teamOne: TeamScore, teamTwo: TeamScore) -> String {
        if teamOne > teamTwo {
            return "Team one wins"
        } else if teamOne == teamTwo {
            return "The teams tied."
        }
        return "Team two wins"
    }
    
    func compareTeamSizes() -> String {
        if team1.count > team2.count {
            return "Team 1 has more players"
        } else if team1.count == team2.count {
            return "Both teams are the same size"
        }
        return "Team 2 has more players"
    }
}

struct AssociatedTypeTypeAlias: View {
    
    var game = FootballGame()
    
    private var team1 = Int.random(in: 1..<50)
    
    private var team2 = Int.random(in: 1..<50)
    
    @State private var winner = ""
    
    @State private var comparison = ""
    
    var body: some View {
        VStack(spacing: 20) {
            HeaderView(title: "AssociatedType",
                       subtitle: "Introduction",
                       desc: "When looking at Apple's documentation you see 'associatedtype' used a lot. It's a placeholder for a type that YOU assign when you adopt the protocol.")
            HStack(spacing: 40) {
                Text("Team One: \(team1)")
                Text("Team Two: \(team2)")
            }
            
            Button("Calculate Winner") {
                winner = game.calculateWinner(teamOne: team1, teamTwo: team2)
            }
            Text(winner)
            
            Button("Evaluate Teams") {
                comparison = game.compareTeamSizes()
            }
            
            Text(comparison)
            
            Spacer()
        }
        .font(.title)
    }
}

struct AssociatedTypeTypeAlias_Previews: PreviewProvider {
    static var previews: some View {
        AssociatedTypeTypeAlias()
    }
}
