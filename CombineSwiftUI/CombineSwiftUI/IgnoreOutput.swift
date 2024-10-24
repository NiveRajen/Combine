//
//  IgnoreOutput.swift
//  CombineSwiftUI
//
//  Created by Nivedha Rajendran on 24.10.24.
//

//This operator is pretty straightforward in its purpose. Anything that comes down the pipeline will be ignored and will never reach a subscriber. A sink subscriber will still detect when it is finished or if it has failed though.

import SwiftUI
import Combine

struct IgnoreOutputView: View {
    @StateObject private var vm = IgnoreOutputViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            HeaderView(title: "IgnoreOutput",
                       subtitle: "Introduction",
                       desc: "As the name suggests, the ignoreOutput operator ignores all items coming down the pipeline but you can still tell if the pipeline finishes or fails.")
            .layoutPriority(1)
            
            List(vm.dataToView, id: \.self) { item in
                Text(item)
            }
            
            Text("Ignore Output:")
                .bold()
            
            List(vm.dataToView2, id: \.self) { item in
                Text(item)
            }
        }
        .font(.title)
        .onAppear {
            vm.fetch()
        }
    }
}


class IgnoreOutputViewModel: ObservableObject {
    @Published var dataToView: [String] = []
    
    @Published var dataToView2: [String] = []
    
    func fetch() {
        let dataIn = ["Value 1", "Value 2", "Value 3"]
        
        _ = dataIn.publisher
            .sink { [unowned self] (item) in
                dataToView.append(item)
            }
        
        //As you can see, all the values never made it through the pipeline because they were ignored.
        _ = dataIn.publisher
            .ignoreOutput()
        //You also can see the receiveValue closure was never run either but the receiveCompletion was.
            .sink(receiveCompletion: { [unowned self] completion in
                dataToView2.append("Pipeline Finished")
            }, receiveValue: { [unowned self] _ in
                dataToView2.append("You should not see this.")
            })
    }
}


struct IgnoreOutputView_Previews: PreviewProvider {
    static var previews: some View {
        IgnoreOutputView()
    }
}
