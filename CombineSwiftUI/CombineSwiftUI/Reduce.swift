//
//  Reduce.swift
//  CombineSwiftUI
//
//  Created by Nivedha Rajendran on 24.10.24.
//

//The reduce operator gives you a closure to examine not only the current item coming down the pipeline but also the previous item that was returned from the reduce closure. After the pipeline finishes, the reduce function will publish the last item remaining.
//If you’re familiar with the scan operator you will notice the functions look nearly identical. The main difference is that reduce will only publish one item at the end.
//The tryReduce will only publish one item, just like reduce will, but you also have the option to throw an error. Once an error is thrown, the pipeline will then finish.
//Any try operator marks the downstream pipeline as being able to fail which means that you will have to handle potential errors in some way.

import SwiftUI
import Combine

struct NotAnAnimalError: Error, Identifiable {
    let id = UUID()
    let message = "We found an item that was not an animal."
}

struct ReduceView: View {
    
    @StateObject private var vm = ReduceViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            HeaderView(title: "Reduce",
                       subtitle: "Introduction",
                       desc: "The reduce operator provides a closure for you to examine all items BEFORE publishing one final value when the pipeline finishes.")
            List(vm.animals, id: \.self) { animal in
                Text(animal)
            }
            Text("Longest animal name: ") + Text("\(vm.longestAnimalName)")
                .bold()
        }
        .font(.title)
        .onAppear {
//            vm.fetch()
            vm.tryFetchReduce()
        }
        //This alert monitors a published property  on the view model so once it becomes not nil it will present an alert.
        .alert(item: $vm.error) { error in
            Alert(title: Text("Error"), message: Text(error.message))
        }
    }
}


class ReduceViewModel: ObservableObject {
    @Published var longestAnimalName = ""
    @Published var animals: [String] = []
    @Published var error: NotAnAnimalError?
    
    func fetch() {
        let dataIn = ["elephant", "deer", "mouse", "hippopotamus", "rabbit", "aardvark"]
        
        _ = dataIn.publisher
            .sink { [unowned self] (item) in
                animals.append(item)
            }
        
        //The first parameter is a default value so the first item has something it can be compared to or examined in some way.
        //The closure’s input parameter named longestNameSoFar is actually the previous item that was returned from the reduce operator.
        //The nextName is the current item.
        dataIn.publisher
        //            .reduce("") { (longestNameSoFar, nextName) in
        //                if nextName.count > longestNameSoFar.count {
        //                    return nextName
        //                }
        //                return longestNameSoFar
        //            }
            .reduce("") { $0.count > $1.count ? $0 : $1 }
            .assign(to: &$longestAnimalName)
    }
    
    func tryFetchReduce() {
        let dataIn = ["elephant", "deer", "mouse", "oak tree", "hippopotamus", "rabbit", "aardvark"]
        
        _ = dataIn.publisher
            .sink { [unowned self] (item) in
                animals.append(item)
            }
        
        //When using a try operator the pipeline recognizes that it can now fail. So a sink with just receiveValue will not work. The error should be handled in some way so the sink’s completion will assign it to a published property to be shown on the view.
        _ = dataIn.publisher
            .tryReduce("") { (longestNameSoFar, nextName) in
                if nextName.contains("tree") {
                    throw NotAnAnimalError()
                }
                if nextName.count > longestNameSoFar.count {
                    return nextName
                }
                return longestNameSoFar
            }
            .sink { [unowned self] completion in
                if case .failure(let error) = completion {
                    self.error = error as? NotAnAnimalError
                }
            } receiveValue: { [unowned self] longestName in
                longestAnimalName = longestName
            }
    }
}


struct ReduceView_Previews: PreviewProvider {
    static var previews: some View {
        ReduceView()
    }
}
