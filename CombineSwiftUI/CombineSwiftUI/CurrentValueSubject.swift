//
//  CurrentValueSubject.swift
//  CombineSwiftUI
//
//  Created by Nivedha Rajendran on 18.10.24.
//

import SwiftUI
import Combine


struct CurrentValueSubjectView: View {
    
    @StateObject private var vm = CurrentValueSubjectViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            HeaderView(title: "CurrentValueSubject",
                       subtitle: "Definition",
                       desc: "The CurrentValueSubject publisher will publish its existing value and also new values when it gets them.")
            
            //Using the send function or setting value directly are both valid.
            //“Calling send(_:) on a CurrentValueSubject also updates the current value, making it equivalent to updating the value directly"
            
            Button("Select Lorenzo") {
                vm.selection.send("Lorenzo") //Preferred
            }
            Button("Select Ellen") {
                vm.selection.value = "Ellen"
            }
            //
            
            Text(vm.selection.value)
                .foregroundColor(vm.selectionSame.value ? .red : .green)
        }
        .font(.title)
    }
}

class CurrentValueSubjectViewModel: ObservableObject {
    
    //@Published properties work like the CurrentValueSubject publisher
    //It’s a publisher that holds on to a value (current value) and when the value changes, it is published and sent down a pipeline when there are subscribers attached to the pipeline.
    var selection = CurrentValueSubject<String, Never>("No Name Selected")
    
    @Published var selectionPublisher = "No Name Selected"
    
    var selectionSame = CurrentValueSubject<Bool, Never>(false)
    
    var cancellables: [AnyCancellable] = []
    
    init() {
        $selectionPublisher
            .map{ [unowned self] newValue -> Bool in
                //Unlike @Published properties, this pipeline runs AFTER the current value has been set.
                newValue == selection.value ? true : false
            }
            .sink { [unowned self] value in
                selectionSame.value = value
                objectWillChange.send() //Without this, the view will not know to update.
            }
            .store(in: &cancellables)
    }
}

struct CurrentValueSubjectView_Previews: PreviewProvider {
    static var previews: some View {
        CurrentValueSubjectView()
    }
}
