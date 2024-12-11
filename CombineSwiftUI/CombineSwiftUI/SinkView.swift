//
//  SinkView.swift
//  CombineSwiftUI
//
//  Created by Nivedha Rajendran on 10.12.24.
//

import SwiftUI
import Combine

//“The sink subscriber will allow you to just receive values and do anything you want with them. There is also an option to run code when the pipeline completes, whether it completed from an error or just naturally.”

struct SinkView: View {
    
    @StateObject private var vm = SinkViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            HeaderView(title: "Sink",
                       subtitle: "Introduction",
                       desc: "The sink subscriber allows you to access every value that comes down the pipeline and do something with it.")
            
            Button("Add Name") {
                vm.fetchRandomName()
                vm.fetch()
            }
            
            HStack {
                Text("A to M")
                    .frame(maxWidth: .infinity)
                
                Text("N to Z")
                    .frame(maxWidth: .infinity)
            }
            
            HStack {
                List(vm.aToM, id: \.self) { name in
                    Text(name)
                }
                List(vm.nToZ, id: \.self) { name in
                    Text(name)
                }
            }
        }
        .font(.title)
        .alert(isPresented: $vm.showErrorAlert) {            Alert(title: Text("Error"), message: Text(vm.errorMessage))
        }
    }
}

class SinkViewModel: ObservableObject {
    let names = ["Joe", "Nick", "Ramona", "Brad", "Mark", "Paul", "Sean", "Alice", "Kaya", "Emily"]
    
    @Published var newName = ""
    @Published var aToM: [String] = []
    @Published var nToZ: [String] = []
    var cancellable: AnyCancellable?
    
    @Published var data = ""
    @Published var showErrorAlert = false
    @Published var errorMessage = "Cannot process numbers greater than 5."
    
    init() {
        //“The first value to come through is the empty string the newName property is assigned. We want to skip this by using the dropFirst operator.”
       //“If the value coming through the pipeline was always assigned to the same @Published property, you could use the assign(to:) subscriber instead.”
        //“Pipeline: The idea here is when a new value is assigned to newName, it is examined and decided which array to add it to.”
        
       //“Note: There are two types of pipelines:
        //•Error-throwing
        //•Non-Error-Throwing
        // You can ONLY use sink(receiveValue:) on non-error-throwing pipelines.  Not sure which kind of pipeline you have?Don’t worry, Xcode won’t let you use this subscriber on an error-throwing pipeline.”
        
        cancellable = $newName
            .dropFirst()
            .sink { [unowned self] (name) in
                let firstLetter = name.prefix(1)
                if firstLetter < "M" {
                    aToM.append(name)
                } else {
                    nToZ.append(name)
                }
            }
    }
    
    func fetchRandomName() {
        newName = names.randomElement()!
    }
    
    //“Pipeline: The idea here is to check values coming through the pipeline and stop if some condition is met.”
    
    //“In this example, we’re examining the completion input parameter to see if there was a failure. If so, then we toggle an indicator and show an alert on the view.”

    func fetch() {
        cancellable = [1,2,3,4,5].publisher
        .tryMap { (value) -> String in
            if value >= 5 {
                throw NumberFiveError()
            }
            return String(value)
        }
        .sink { [unowned self] (completion) in
            switch completion {
                case .failure(_):
                showErrorAlert.toggle()
                case .finished:
                print(completion)
            }
            data = String(data.dropLast(2))
        } receiveValue: { [unowned self] (value) in
            data = data.appending("\(value), ")
        }
    }
}

struct NumberFiveError: Error {}



#Preview {
    SinkView()
}
