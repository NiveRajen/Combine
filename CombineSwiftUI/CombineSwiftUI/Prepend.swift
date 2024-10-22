//
//  Prepend.swift
//  CombineSwiftUI
//
//  Created by Nivedha Rajendran on 22.10.24.
//

//The prepend operator will publish data first before the publisher send out its first item.

import SwiftUI
import Combine

struct PrependView: View {
    
    @StateObject private var vm = PrependViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            HeaderView(title: "Prepend",
                       subtitle: "Introduction",
                       desc: "The prepend operator will add data before the publisher sends outits data.")
            List(vm.dataToView, id: \.self) { datum in
                Text(datum)
            }
        }
        .font(.title)
        .onAppear {
            vm.fetch()
        }
    }
}

class PrependViewModel: ObservableObject {
    
    @Published var dataToView: [String] = []
    
    var cancellable: AnyCancellable?
    
    func fetch() {
        let dataIn = ["Karin", "Donny", "Shai", "Daniel", "Mark"]
        
        let dataInSecond = ["Nive", "Adam"].publisher
        
        cancellable = dataIn.publisher
        //No matter how many items come through the pipeline, the prepend operator will just run one time to send its item through the pipeline first.
        // prepend operators at the bottom actually publish first.
            .prepend("COMBINE AUTHORS")
            .prepend("2022")
        //Not only can you prepend values, you can also prepend pipelines so you get the values from another pipeline first.
        //Be warned though, it’s possible that the second pipeline can block the first pipeline if it doesn’t finish.
            .prepend(dataInSecond)
            .sink { [unowned self] datum in
                self.dataToView.append(datum)
            }
    }
}


struct PrependView_Previews: PreviewProvider {
    static var previews: some View {
        PrependView()
    }
}
