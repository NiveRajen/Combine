//
//  Min.swift
//  CombineSwiftUI
//
//  Created by Nivedha Rajendran on 20.10.24.
//

import SwiftUI


struct MinView: View {
    
    @StateObject private var vm = MinViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            HeaderView(title: "Min",
                       subtitle: "Introduction",
                       desc: "The min operator will publish the minimum value once the upstream publisher is finished.")
            .layoutPriority(1)
            List {
                //This view shows a collection of data and the minimum values for strings and ints using the min operator
                Section(footer: Text("Min: \(vm.minValue) , \(vm.minValue1)").bold()) {
                    ForEach(vm.data, id: \.self) { datum in
                        Text(datum)
                    }
                }
            }
            List {
                Section(footer: Text("Min: \(vm.minNumber)").bold()) {
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
            vm.fetchMinby()
        }
    }
}


class MinViewModel: ObservableObject {
    
    @Published var data: [String] = []
    
    @Published var minValue = ""
    
    @Published var minValue1 = ""
    
    @Published var numbers: [Int] = []
    
    @Published var minNumber = 0
    
    @Published var profiles: [Profile] = []
    
    @Published var profiles1: [UserProfile] = []
    
    @Published var invalidCountryError: InvalidCountryError?
    
    func fetch() {
        let dataIn = ["Aardvark", "Zebra", "Elephant"]
        
        data = dataIn
        dataIn.publisher
        //The min operator will republish just the minimum value that it received from the upstream publisher. If the min operator receives 10 items, it’ll find the minimum item and publish just that one item. If you were to sort your items in descending order then min would take the item at the top.
        //Finding the min value depends on types conforming to the Comparable protocol.
        //The Comparable protocol allows the Swift compiler to know how to order objects and which is greater or lesser than others.
        //But what if a type does not conform to the Comparable protocol? How can you find the min value?
        //Then you can use the min(by:) operator.
            .min()
            .assign(to: &$minValue)
        
        let dataInNumbers = [900, 245, 783]
        numbers = dataInNumbers
        dataInNumbers.publisher
            .min()
            .assign(to: &$minNumber)
    }
    
    func fetchMinby() {
        let dataIn = [Profile(name: "Igor", city: "Moscow"),
                      Profile(name: "Rebecca", city: "Atlanta"),
                      Profile(name: "Christina", city: "Stuttgart"),
                      Profile(name: "Lorenzo", city: "Rome"),
                      Profile(name: "Oliver", city: "London")]
        profiles = dataIn
        _ = dataIn.publisher
        //The min(by:) operator receives the current and next item in the pipeline.
        //You can then define your criteria to get the min value.
        //I should rephrase that. You’re not exactly specifying the criteria to get the min value, instead, you’re specifying the ORDER so that whichever item is last is the minimum
        //            .min(by: { (currentItem, nextItem) -> Bool in
        //                return currentItem.city < nextItem.city
        //            })
        //Above operator can be written as
            .min { $0.city < $1.city }
            .sink { [unowned self] profile in
                minValue1 = profile.city
            }
    }
    
    func fetchTryMinby() {
        let dataIn = [UserProfile(name: "Igor", city: "Moscow", country: "Russia"),
                      UserProfile(name: "Rebecca", city: "Atlanta", country: "United States"),
                      UserProfile(name: "Christina", city: "Stuttgart", country: "Germany"),
                      UserProfile(name: "Lorenzo", city: "Rome", country: "Italy")]
        profiles1 = dataIn
        _ = dataIn.publisher
            .tryMin(by: { (current, next) -> Bool in
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
                self.minValue = userProfile.country
            }
    }
}

struct MinView_Previews: PreviewProvider {
    static var previews: some View {
        MinView()
    }
}
