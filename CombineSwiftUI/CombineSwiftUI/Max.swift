//
//  Max.swift
//  CombineSwiftUI
//
//  Created by Nivedha Rajendran on 20.10.24.
//

import SwiftUI

struct Profile: Identifiable {
    let id = UUID()
    var name = ""
    var city = ""
}

struct UserProfile: Identifiable {
    let id = UUID()
    var name = ""
    var city = ""
    var country = ""
}

struct InvalidCountryError: Error, Identifiable {
    var id = UUID()
    var country = ""
}

struct MaxView: View {
    
    @StateObject private var vm = MaxViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            HeaderView(title: "Max",
                       subtitle: "Introduction",
                       desc: "The max operator will publish the maximum value once the upstream publisher is finished.")
            .layoutPriority(1)
            List {
                //This view shows a collection of data and the minimum values for strings and ints using the max operator
                Section(footer: Text("Max: \(vm.maxValue) , \(vm.maxValue1)").bold()) {
                    ForEach(vm.data, id: \.self) { datum in
                        Text(datum)
                    }
                }
            }
            List {
                Section(footer: Text("Max: \(vm.maxNumber)").bold()) {
                    ForEach(vm.numbers, id: \.self) { number in
                        Text("\(number)")
                    }
                }
            }
        }
        .font(.title)
        .alert(item: $vm.invalidCountryError) { alertData in
            Alert(title: Text("Invalid Country:"), message: Text(alertData.country))
        }
        .onAppear {
            vm.fetch()
            vm.fetchMaxby()
        }
    }
}


class MaxViewModel: ObservableObject {
    
    @Published var data: [String] = []
    
    @Published var maxValue = ""
    
    @Published var maxValue1 = ""
    
    @Published var numbers: [Int] = []
    
    @Published var maxNumber = 0
    
    @Published var profiles: [Profile] = []
    
    @Published var profiles1: [UserProfile] = []
    
    @Published var invalidCountryError: InvalidCountryError?
    
    func fetch() {
        let dataIn = ["Aardvark", "Zebra", "Elephant"]
        
        data = dataIn
        dataIn.publisher
        //The max operator will republish just the maximum value that it received from the upstream publisher. If the max operator receives 10 items, it’ll find the maximum item and publish just that one item. If you were to sort your items in descending order then max would take the item at the top.
        //Finding the max value depends on types conforming to the Comparable protocol.
        //The Comparable protocol allows the Swift compiler to know how to order objects and which is greater or lesser than others.
        //But what if a type does not conform to the Comparable protocol? How can you find the max value?
        //Then you can use the max(by:) operator.
            .max()
            .assign(to: &$maxValue)
        
        let dataInNumbers = [900, 245, 783]
        numbers = dataInNumbers
        dataInNumbers.publisher
            .max()
            .assign(to: &$maxNumber)
    }
    
    func fetchMaxby() {
        let dataIn = [Profile(name: "Igor", city: "Moscow"),
                      Profile(name: "Rebecca", city: "Atlanta"),
                      Profile(name: "Christina", city: "Stuttgart"),
                      Profile(name: "Lorenzo", city: "Rome"),
                      Profile(name: "Oliver", city: "London")]
        profiles = dataIn
        _ = dataIn.publisher
        //The max(by:) operator receives the current and next item in the pipeline.
        //You can then define your criteria to get the max value.
        //I should rephrase that. You’re not exactly specifying the criteria to get the max value, instead, you’re specifying the ORDER so that whichever item is last is the maximum
        //            .max(by: { (currentItem, nextItem) -> Bool in
        //                return currentItem.city < nextItem.city
        //            })
        //Above operator can be written as
            .max { $0.city < $1.city }
            .sink { [unowned self] profile in
                maxValue1 = profile.city
            }
    }
    
    func fetchTryMaxby() {
        let dataIn = [UserProfile(name: "Igor", city: "Moscow", country: "Russia"),
                      UserProfile(name: "Rebecca", city: "Atlanta", country: "United States"),
                      UserProfile(name: "Christina", city: "Stuttgart", country: "Germany"),
                      UserProfile(name: "Lorenzo", city: "Rome", country: "Italy")]
        profiles1 = dataIn
        _ = dataIn.publisher
            .tryMax(by: { (current, next) -> Bool in
                if current.country == "United States" {
                    throw InvalidCountryError(country: "United States")
                }
                return current.country < next.country
            })
            .sink { [unowned self] (completion) in
                if case .failure(let error) = completion {
                    self.invalidCountryError = error as? InvalidCountryError
                }
            } receiveValue: { [unowned self] (userProfile) in
                self.maxValue = userProfile.country
            }
    }
}

struct MaxView_Previews: PreviewProvider {
    static var previews: some View {
        MaxView()
    }
}



