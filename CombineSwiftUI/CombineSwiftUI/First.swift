//
//  First.swift
//  CombineSwiftUI
//
//  Created by Nivedha Rajendran on 16.11.24.
//

import SwiftUI
import Combine

struct InvalidDeviceError: Error, Identifiable {
    let id = UUID()
    let message = "Whoah, what is this? We found a non-Guest name!"
}

//The first operator is pretty simple. It will publish the first element that comes through the pipeline and then turn off (finish) the pipeline.
struct FirstView: View {
    
    @StateObject private var vm = FirstViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            HeaderView(title: "First",
                       subtitle: "Introduction",
                       desc: "The first operator will return the very first item and then finish the pipeline.")
            .layoutPriority(1)
            
            TextField("search criteria", text: $vm.criteria)
             .textFieldStyle(RoundedBorderTextFieldStyle())
             .padding()
            
            Text("First Found: ") + Text(vm.firstFound)
                .bold()
            
            Text("First Guest: ") + Text(vm.firstGuest)
                .bold()
            
            Form {
                Section(header: Text("Guest List").font(.title2).padding()) {
                    ForEach(vm.guestList, id: \.self) { guest in
                        Text(guest)
                    }
                }
            }
        }
        .font(.title)
        .onAppear() {
            vm.fetch()
        }
        .alert(item: $vm.error) { error in
            Alert(title: Text("Error"), message: Text(error.message))
        }
    }
}

//The dollar sign ($) is used to access the criteria’s publisher. Every time the criteria changes, its value is sent through the pipeline.
//Note: You could probably improve this pipeline with some additional operators such as debounce and removeDuplicates.

class FirstViewModel: ObservableObject {
    @Published var error: InvalidDeviceError?
    @Published var firstGuest = ""
    @Published var criteria = ""
    @Published var firstFound = ""
    @Published var guestList: [String] = []
    let dataIn = ["Jordan", "Chase", "Kaya", "Shai", "Novall", "Sarun"]
    private var criteriaCancellable: AnyCancellable?
    private var cancellables: Set<AnyCancellable> = []
    
    init() {
        criteriaCancellable = $criteria
            .sink { [unowned self] searchCriteria in
                fetchfirst(criteria: searchCriteria)
                fetchFirstWithErrorType(criteria: searchCriteria)
            }
    }
    
    func fetch() {
        _ = dataIn.publisher
            .sink { [unowned self] (item) in
                guestList.append(item)
            }
        
        //The first operator will just return one item. Since the pipeline will finish right after that, we can use the assign(to:) subscriber and set the published property.
        
        dataIn.publisher
            .first()
            .assign(to: &$firstGuest)
    }
    
    //The first(where:) operator will evaluate items coming through the pipeline and see if they satisfy some condition in which you set. The first item that satisfies your condition will be the one that gets published and then the pipeline will finish.
    
    func fetchfirst(criteria: String) {
        dataIn.publisher
//            .first { device in
//                device.contains(criteria)
//            }\
            .first { $0.contains(criteria) }
            .replaceEmpty(with: "Nothing found")
            .assign(to: &$firstFound)
    }
    
    //In this example, we are going to throw an error and assign it to the error published property so the view can get notified. The error conforms to Identifiable so the alert modifier on the view can use it.
    func fetchFirstWithErrorType(criteria: String) {
        dataIn.publisher
            .tryFirst { name in
                if name.contains("Sarun") {
                    throw InvalidDeviceError()
                }
                return name.contains(criteria)
            }
            .replaceEmpty(with: "Nothing found")
            .sink { [unowned self] completion in
                if case .failure(let error) = completion {
                    self.error = error as? InvalidDeviceError
                }
            } receiveValue: { [unowned self] foundDevice in
                firstFound = foundDevice
            }
            .store(in: &cancellables)
    }
}

struct FirstView_Previews: PreviewProvider {
    static var previews: some View {
        FirstView()
    }
}
