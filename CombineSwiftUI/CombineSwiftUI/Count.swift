//
//  Count.swift
//  CombineSwiftUI
//
//  Created by Nivedha Rajendran on 20.10.24.
//

import SwiftUI

struct CountView: View {
    
    @StateObject private var vm = CountViewModel()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                HeaderView(title: "", subtitle: "Introduction",
                           desc: "The count operator simply publishes the total number of items it receives from the upstream publisher.")
                Form {
                    NavigationLink(
                        destination: CountDetailView(data: vm.data),
                        label: {
                            Text(vm.title)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text("\(vm.count)")
                        })
                }
            }
            .font(.title)
            .navigationTitle("Count")
            .onAppear { vm.fetch() }
        }
    }
}

class CountViewModel: ObservableObject {
    
    @Published var title = ""
    
    @Published var data: [String] = []
    
    @Published var count = 0
    
    func fetch() {
        title = "Major Rivers"
        let dataIn = ["Mississippi", "Nile", "Yangtze", "Danube", "Ganges", "Amazon", "Volga",
                      "Rhine"]
        data = dataIn
        dataIn.publisher
        //The count operator simply publishes the count of items it receives. It’s important to note that the count will not be published until the upstream publisher has finished publishing all items.
            .count() //This is a very simplistic example of a very simple operator.
            .assign(to: &$count)
    }
}

struct CountDetailView: View {
    
    var data: [String]
    
    var body: some View {
        List(data, id: \.self) { datum in
            Text(datum)
        }
        .font(.title)
    }
}

struct CountView_Previews: PreviewProvider {
    static var previews: some View {
        CountView()
    }
}
