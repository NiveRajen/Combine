//
//  PropertiesFunctions.swift
//  CombineSwiftUI
//
//  Created by Nivedha Rajendran on 11.12.24.
//

//“You don’t always have to assemble your whole pipeline in your observable object. You can store your publishers (with or without operators) in properties or return publishers from functions to be used at a later time. Maybe you notice you have a common beginning to many of your pipelines. This is a good opportunity to extract them out into a common property or function. Or maybe you are creating an API and you want to expose publishers to consumers.”

import SwiftUI
import Combine

struct PropertiesFunctionView: View {
    
    @StateObject private var vm = PropertiesFunctionViewModel()
    
    var body: some View {        VStack(spacing: 20) {
        HeaderView(title: "Using Properties",
                   subtitle: "Introduction",
                   desc: "You can store publishers in properties to be used later. The publisher can also have operators connected to them too.")
        Text("\(vm.lastName), \(vm.firstName)")
        Text("Team")
            .bold()
        List(vm.team, id: \.self) { name in
            Text(name)
        }
    }
    .font(.title)
    .onAppear {
        vm.fetch()
    }
    }
}

struct PPropertiesFunctionView_Previews: PreviewProvider {
    static var previews: some View {
        PropertiesFunctionView()
    }
}

//“All of the data on the UI comes from publishers stored in properties or functions with subscribers attached to them later.”

class PropertiesFunctionViewModel: ObservableObject {
    @Published var firstName = ""
    @Published var lastName = ""
    @Published var team: [String] = []
    
//    “Here’s an example of just storing a publisher in a property”
    var firstNamePublisher = Just("Nivedha")
    
//    “If you’re adding operators, you might find it easier to use a closure. If there’s only one item in a closure then you don’t need to use the get or the return keywords”
    var lastNameUppercased: Just<String> {
        Just("Rajendran")
            .map { $0.uppercased()
            }
    }
    
    //“You can also have functions that return whole pipelines. The sink subscribers return AnyCancellable. The assign(to:) does not.”
    
    func teamPipeline(uppercased: Bool) -> AnyCancellable {
        ["Saravana", "Pavithra", "Fred"].publisher
            .map {
                uppercased ? $0.uppercased() : $0
            }
            
            .sink { [unowned self] name in
                team.append(name)
            }
    }
    
    func fetch() {
        //“From here, you can just attach operators and subscribers to your publisher properties”
      
        firstNamePublisher
            .map { $0.uppercased() }
            .assign(to: &$firstName)
        
        lastNameUppercased
            .assign(to: &$lastName)
        
        //“If you’re returning a whole pipeline, then just call the function and handle the returned cancellable in some way.”
        _ = teamPipeline(uppercased: false)
    }
}


