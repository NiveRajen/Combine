//
//  ReplaceNil.swift
//  CombineSwiftUI
//
//  Created by Nivedha Rajendran on 24.10.24.
//

//It’s possible you might get nils in data that you fetch. You can have Combine replace nils with a value you specify.

import SwiftUI
import Combine

class ReplaceNilViewModel: ObservableObject {
    
    @Published var data: [String] = []
    
    private var cancellable: AnyCancellable?
    
    init() {
        let dataIn = ["Customer 1", nil, nil, "Customer 2", nil, "Customer 3"]
        
        cancellable = dataIn.publisher
            .replaceNil(with: "N/A")
            .sink { [unowned self] datum in
                self.data.append(datum)
            }
    }
}

struct ReplaceNilView: View {
    
    @StateObject private var vm = ReplaceNilViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            HeaderView(title: "Replace Nil",
                       subtitle: "Introduction",
                       desc: "If you know you will get nils in your stream, you have the option to use the replaceNil operator to replace those nils with another value.")
            List(vm.data, id: \.self) { datum in
                Text(datum)
            }
            
            DescView(desc: "In this example, I'm replacing nils with 'N/A'.")
        }
        .font(.title)
    }
}


struct ReplaceNilView_Previews: PreviewProvider {
    static var previews: some View {
        ReplaceNilView()
    }
}
