//
//  Filter.swift
//  CombineSwiftUI
//
//  Created by Nivedha Rajendran on 24.10.24.
//

//Use this operator to specify which items get republished based on the criteria you set up. You may have a scenario where you have data cached or in memory. You can use this filter operator to return all the items that match the user’s criteria and republish that data to the UI.

import SwiftUI
import Combine

//The error conforms to Identifiable so the @Published property can be observed by the alert modifier
struct FilterError: Error, Identifiable {
    let id = UUID()
    let description = "There was a problem filtering. Please try again."
}

struct FilterView: View {
    
    @StateObject private var vm = FilterViewModel()
    
    var body: some View {
        
        VStack(spacing: 20) {
            HeaderView(title: "Filter",
                       subtitle: "Introduction",
                       desc: "The filter operator will republished upstream values it receives if it matches some criteria that you specify.")
            
            HStack(spacing: 40.0) {
                Button("Animals") { vm.filterData(criteria: "Animal") }
                Button("People") { vm.filterData(criteria: "Person") }
                Button("All") { vm.filterData(criteria: " ") }
            }
            
            List(vm.filteredData, id: \.self) { datum in
                Text(datum)
            }
        }
        .font(.title)
        .alert(item: $vm.filterError) { error in
            Alert(title: Text("Error"), message: Text(error.description))
         }
    }
}


class FilterViewModel: ObservableObject {
    
    @Published var filteredData: [String] = []
    
    //we pretend we already  have some fetched data we’re working with (dataIn)
    let dataIn = ["Person 1", "Person 2", "Animal 1", "Person 3", "Animal 2", "Animal 3", "*"]
    
    @Published var filterError: FilterError?
    
    private var cancellable: AnyCancellable?
    
    init() {
        //filterData(criteria: " ")
        tryFilterData(criteria: " ")
    }
    
    func filterData(criteria: String) {
        filteredData = []
        cancellable = dataIn.publisher
        //Every item that comes through the pipeline will be checked against your criteria.
        //If true, the filter operator republishes the data and it continues down the pipeline.
            .filter { item -> Bool in
                item.contains(criteria)
            }
        //above operator can be return as follows
        //.filter { $0.contains(criteria) }
            .sink { [unowned self] datum in
                filteredData.append(datum)
            }
    }
    
    
    func tryFilterData(criteria: String) {
        filteredData = []
        
        cancellable = dataIn.publisher
            .tryFilter { item -> Bool in
                //In this scenario, we throw an error. The sink subscriber will catch it and  assign it to a @Published property. Once that happens the view will show an alert with the error message.
                if item == "*" {
                    throw FilterError()
                }
                return item.contains(criteria)
            }
        //Since the tryFilter indicates a failure can occur in the pipeline, you are forced to use the sink(receiveCompletion:receiveValue:) subscriber.
        //Xcode will complain if you just try to use the sink(receiveValue:) subscriber.
            .sink(receiveCompletion: { [unowned self] (completion) in
                if case .failure(let error) = completion {
                    self.filterError = error as? FilterError
                }
            }, receiveValue: { [unowned self] (item) in
                filteredData.append(item)
            })
    }
}


struct FilterView_Previews: PreviewProvider {
    static var previews: some View {
        FilterView()
    }
}
