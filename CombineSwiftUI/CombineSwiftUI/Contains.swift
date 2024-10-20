//
//  Contains.swift
//  CombineSwiftUI
//
//  Created by Nivedha Rajendran on 20.10.24.
//
import SwiftUI
import Combine

//The contains operator has just one purpose - to let you know if an item coming through your pipeline matches the criteria you specify. It will publish a true when a match is found and then finishes the pipeline, meaning it stops the flow of any remaining data.

struct ContainView: View {
    
    @StateObject private var vm = ContainsViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            HeaderView(title: "Contains",
                       subtitle: "Introduction",
                       desc: "The contains operator will publish a true and finish the pipeline when an item coming through matches its criteria.\n\nThe contains(where:) operator will publish a true and finish the pipeline when an item coming through matches the criteria you specify within the closure it provides.")
            Text("House Details")
                .fontWeight(.bold)
            Group {
                Text(vm.description)
                Toggle("Basement", isOn: $vm.basement)
                Toggle("Air Conditioning", isOn: $vm.airconditioning)
                Toggle("Heating", isOn: $vm.heating)
            }
            .padding(.horizontal)
        }
        .font(.title)
        .onAppear {
            vm.fetch()
        }
    }
}

struct ContainsView_Previews: PreviewProvider {
    static var previews: some View {
        ContainView()
    }
}



class ContainsViewModel: ObservableObject {
    
    @Published var description = ""
    
    @Published var airconditioning = false
    
    @Published var heating = false
    
    @Published var basement = false
    
    private var cancellables: [AnyCancellable] = []
    
    var fruitName = ""
    
    @Published var vitaminA = false
    
    @Published var place = "Nevada"
    
    @Published var invalidSelectionError: InvalidSelectionError?
    
    @Published var result = ""
    
    func fetch() {
        let incomingData = ["3 bedrooms", "2 bathrooms", "Air conditioning", "Basement"]
        incomingData.publisher
        //The prefix operator just returns the first 2 items in this pipeline.
            .prefix(2)
            .sink { [unowned self] (item) in
                description += item + "\n"
            }
            .store(in: &cancellables)
        
        //These single-purpose publishers will just look for one match and publish a true or false to the @Published properties.
        incomingData.publisher
            .contains("Air conditioning")
            .assign(to: &$airconditioning)
        incomingData.publisher
            .contains("Heating")
            .assign(to: &$heating)
        incomingData.publisher
            .contains("Basement")
            .assign(to: &$basement)
        
        let incomingData1 = [Fruit(name: "Apples", nutritionalInformation: "Vitamin A, Vitamin C")]
        
        //Notice in this case I’m not storing the cancellable in a property because I don’t need to. After the pipeline finishes, I don’t have to hold on to a reference of it.
        _ = incomingData1.publisher.sink {[unowned self] (fruit) in
            fruitName = fruit.name
        }
        
        //These single-purpose publishers will just look for one match and publish a true or false to the @Published properties.
        //Remember, when the first match is found, the publisher will finish, even if there are more items in the pipeline.
        incomingData1.publisher
            .contains(where: { (fruit) -> Bool in
                fruit.nutritionalInformation.contains("Vitamin A")
            })
            .assign(to: &$vitaminA)
        
        
        //Can also be written like below. Notice how this contains(where: ) is written differently without the parentheses. This is another way to write the operator that the compiler will still understand.
        //This contains(where:) operator gives you a closure to specify your criteria to find a match. This could be useful where the items coming through the pipeline are not simple primitive types like a String or Int. Items that do not match the criteria are dropped (not published) and when the first item is a match, the boolean true is published.
        //When the first match is found, the pipeline is finished/stopped.
        //If no matches are found at the end of all the items, a boolean false is published and the pipeline is finished/stopped.
        incomingData1.publisher
            .contains{(fruit) -> Bool in
                fruit.nutritionalInformation.contains("Vitamin A")
            }
            .assign(to: &$vitaminA)
    }
    
    func search() {
        let incomingData = ["Places with Salt Water", "Utah", "California"]
        _ = incomingData.publisher
            .dropFirst()
            .tryContains(where: { [unowned self] (item) -> Bool in
                //If Mars is selected, then an error is thrown.
                //The condition for when the error is thrown can be anything you want.
                //But if an item from your data source contains the place selected, then a true will be published and the pipeline will finish.
                if place == "Mars" {
                    throw InvalidSelectionError()
                }
                return item == place
            })
            .sink { [unowned self] (completion) in
                switch completion {
                case .failure(let error):
                    self.invalidSelectionError = error as? InvalidSelectionError
                default:
                    break
                }
            } receiveValue: { [unowned self] (result) in
                self.result = result ? "Found" : "Not Found"
            }
    }
}

struct Fruit: Identifiable {
    let id = UUID()
    var name = ""
    var nutritionalInformation = ""
}

struct InvalidSelectionError: Error, Identifiable {
    var id = UUID()
}
