//
//  CompactMap.swift
//  CombineSwiftUI
//
//  Created by Nivedha Rajendran on 22.10.24.
//

//The compactMap operator gives you a convenient way to drop all nils that come through the pipeline. You are even given a closure to evaluate items coming through the pipeline and if you want, you can return a nil. That way, the item will also get dropped.

import SwiftUI

//The error conforms to Identifiable so the @Published property can be observed by the alert modifier
struct InvalidValueError: Error, Identifiable {
    let id = UUID()
    let description = "One of the values you entered is invalid and will have to be updated."
}

struct CompactMapView: View {
    
    @StateObject private var vm = CompactMapViewModel()
    
    var body: some View {
        VStack(spacing: 10) {
            
            HeaderView(title: "CompactMap",
                       subtitle: "Introduction",
                       desc: "The compactMap operator will remove nil values as they come through the pipeline.")
            .layoutPriority(1)
            
            Text("Before using compactMap:")
            
            List(vm.dataWithNils, id: \.self) { item in
                Text(item)
                    .font(.title3)
                    .foregroundColor(.gray)
            }
            
            Text("After using compactMap:")
            
            List(vm.dataWithoutNils, id: \.self) { item in
                Text(item)
                    .font(.title3)
                    .foregroundColor(.gray)
            }
            .frame(maxHeight: 150)
        }
        .font(.title)
        //This is an error type in the view model that also conforms to Identifiable so it can be used here as the item parameter.
        .alert(item: $vm.invalidValueError) { error in
            Alert(title: Text("Error"), message: Text(error.description))
         }
        .onAppear {
            vm.fetch()
            vm.fetchTruCompactMap()
        }
    }
}

//Looking at the screenshot of before and after compactMap, you can see that the nils were dropped. But you also see that “Invalid” was dropped too.

class CompactMapViewModel: ObservableObject {
    
    @Published var dataWithNils: [String] = []
    
    @Published var dataWithoutNils: [String] = []
    
    @Published var dataToView: [String] = []
    
    @Published var invalidValueError: InvalidValueError?
    
    func fetch() {
        let dataIn = ["Value 1", nil, "Value 3", nil, "Value 5", "Invalid"]
        
        _ = dataIn.publisher
            .sink { [unowned self] (item) in
                dataWithNils.append(item ?? "nil")
            }
        
        _ = dataIn.publisher
        //“Invalid” was dropped because inside our compactMap we look for this value in particular and return a nil.
        //Returning a nil inside a compactMap closure means it will get dropped.
        //Actually, yes. Nils will come in and can be returned from  the closure but they do not continue down the pipeline. - Completion is called
            .compactMap{ item in
                if item == "Invalid" {
                    return nil // Will not get republished
                }
                return item
            }
        //can also be written as
        //.compactMap { $0 }
            .sink { [unowned self] (item) in
                dataWithoutNils.append(item)
            }
    }
    
    func fetchTruCompactMap() {
        let dataIn = ["Value 1", nil, "Value 3", nil, "Value 5", "Invalid"]
        
        //Like all other operators that begin with “try”, tryCompactMap lets the pipeline know that a possible failure is possible.
        _ = dataIn.publisher
            .tryCompactMap{ item in
                if item == "Invalid" {
                    //In this scenario, we throw an error instead of dropping the item by returning a nil.
                    throw InvalidValueError()
                }
                return item
            }
        //Since the tryCompactMap indicates a failure can occur in the pipeline, you are forced to use the sink(receiveCompletion:receiveValue:) subscriber.
        //Xcode will complain if you just try to use the sink(receiveValue:) subscriber.
            .sink { [unowned self] (completion) in
                if case .failure(let error) = completion {
                    self.invalidValueError = error as? InvalidValueError
                }
            } receiveValue: { [unowned self] (item) in
                dataToView.append(item)
            }
    }
}

struct CompactViewView_Previews: PreviewProvider {
    static var previews: some View {
        CompactMapView()
    }
}
