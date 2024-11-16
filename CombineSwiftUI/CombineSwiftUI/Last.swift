//
//  Last.swift
//  CombineSwiftUI
//
//  Created by Nivedha Rajendran on 16.11.24.
//

import SwiftUI
import Combine

//The last operator is pretty simple. It will publish the last element that comes through the pipeline and then turn off (finish) the pipeline.
struct LastView: View {
    
    @StateObject private var vm = lastViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            HeaderView(title: "last",
                       subtitle: "Introduction",
                       desc: "The last operator will return the very last item and then finish the pipeline.")
            .layoutPriority(1)
            
            TextField("search criteria", text: $vm.criteria)
             .textFieldStyle(RoundedBorderTextFieldStyle())
             .padding()
            
            Text("last Found: ") + Text(vm.lastFound)
                .bold()
            
            Text("last Guest: ") + Text(vm.lastGuest)
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

class lastViewModel: ObservableObject {
    @Published var error: InvalidDeviceError?
    @Published var lastGuest = ""
    @Published var criteria = ""
    @Published var lastFound = ""
    @Published var guestList: [String] = []
    
    let dataIn = ["Jordan", "Chase", "Kaya", "Shai", "Novall", "Sarun"]
    private var criteriaCancellable: AnyCancellable?
    private var cancellables: Set<AnyCancellable> = []
    
    init() {
        criteriaCancellable = $criteria
            .sink { [unowned self] searchCriteria in
                fetchlast(criteria: searchCriteria)
                fetchlastWithErrorType(criteria: searchCriteria)
            }
    }
    
    func fetch() {
        _ = dataIn.publisher
            .sink { [unowned self] (item) in
                guestList.append(item)
            }
        
        //The last operator will just return one item. Since the pipeline will finish right after that, we can use the assign(to:) subscriber and set the published property.
        
        dataIn.publisher
            .last()
            .assign(to: &$lastGuest)
    }
    
    //The last(where:) operator will evaluate items coming through the pipeline and see if they satisfy some condition in which you set. The last item that satisfies your condition will be the one that gets published and then the pipeline will finish.
    
    func fetchlast(criteria: String) {
        dataIn.publisher
//            .last { name in
//                name.contains(criteria)
//            }
            .last(where: { name in
                name == "Kaya"
             })
//            .last { $0.contains(criteria) }
            .replaceEmpty(with: "Nothing found")
            .assign(to: &$lastFound)
    }
    
    //In this example, we are going to throw an error and assign it to the error published property so the view can get notified. The error conforms to Identifiable so the alert modifier on the view can use it.
    func fetchlastWithErrorType(criteria: String) {
        dataIn.publisher
            .tryLast { name in
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
                lastFound = foundDevice
            }
            .store(in: &cancellables)
    }
}

struct lastView_Previews: PreviewProvider {
    static var previews: some View {
        LastView()
    }
}
