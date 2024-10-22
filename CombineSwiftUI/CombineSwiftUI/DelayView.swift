//
//  DelayView.swift
//  CombineSwiftUI
//
//  Created by Nivedha Rajendran on 22.10.24.
//

//You can add a delay on a pipeline to pause items from flowing through. The delay only works once though. What I mean is that if you have five items coming through the pipeline, the delay will only pause all five and then allow them through. It will not delay every single item that comes through.

import SwiftUI
import Combine

struct DelayView: View {
    
    @StateObject private var vm = DelayViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            HeaderView(title: "Delay(for: )",
                       subtitle: "Introduction",
                       desc: "The delay(for: ) operator will prevent the first items from flowing through the pipeline.")
            
            Text("Delay for:")
            
            Picker(selection: $vm.delaySeconds, label: Text("Delay Time")) {
                Text("0").tag(0)
                Text("1").tag(1)
                Text("2").tag(2)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
            
            Button("Fetch Data") {
                vm.fetch()
            }
            
            if vm.isFetching {
                ProgressView()
            } else {
                Text(vm.data)
            }
            Spacer()
        }
        .font(.title)
    }
}


class DelayViewModel: ObservableObject {
    
    @Published var data = ""
    
    var delaySeconds = 1
    
    @Published var isFetching = false
    
    var cancellable: AnyCancellable?
    
    func fetch() {
        isFetching = true
        
        let dataIn = ["Value 1", "Value 2", "Value 3"]
        
        cancellable = dataIn.publisher
        //Adding Delay- This will add delay the mentioned seconds before subscribing
            .delay(for: .seconds(delaySeconds), scheduler: RunLoop.main)
            .first()
            .sink { [unowned self] completion in
                isFetching = false
            } receiveValue: { [unowned self] firstValue in
                data = firstValue
            }
    }
}


struct DelayViewView_Previews: PreviewProvider {
    static var previews: some View {
        DelayView()
    }
}
