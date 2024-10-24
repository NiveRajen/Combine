//
//  ReplaceEmptyView.swift
//  CombineSwiftUI
//
//  Created by Nivedha Rajendran on 24.10.24.
//

//Use the replaceEmpty operator when you want to show or set some value in the case that nothing came down your pipeline. This could be useful in situations where you want to set some default data or notify the user that there was no data.

import SwiftUI
import Combine

struct ReplaceEmptyView: View {
    
    @StateObject private var vm = ReplaceEmptyViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            HeaderView(title: "ReplaceEmpty",
                       subtitle: "Introduction",
                       desc: "You can use replaceEmpty in cases where you have a publisher that finishes and nothing came down the pipeline.")
            HStack {
                TextField("criteria", text: $vm.criteria)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button("Search") {
                    vm.search()
                }
            }
            .padding()
            List(vm.dataToView, id: \.self) { item in
                Text(item)
                //If no data was returned, then a check is done and the color of the text is changed here.
                    .foregroundColor(item == vm.noResults ? .gray : .primary)
            }
        }
        .font(.title)
    }
}


class ReplaceEmptyViewModel: ObservableObject {
    
    @Published var dataToView: [String] = []
    
    @Published var criteria = ""
    
    var noResults = "No results found"
    
    func search() {
        dataToView.removeAll()
        
        let dataIn = ["Result 1", "Result 2", "Result 3", "Result 4"]
        
        _ = dataIn.publisher
            .filter { $0.contains(criteria) }
        //If the pipeline finishes and nothing came through it (no matches found), then he value defined in the replaceEmpty operator will be published.
//        Note: This will only work on a pipeline that actually finishes. In this scenario, a Sequence publisher is being used and it will finish by itself when all items have run through the pipeline.
            .replaceEmpty(with: noResults)
            .sink { [unowned self] (item) in
                dataToView.append(item)
            }
    }
}


struct ReplaceEmptyView_Previews: PreviewProvider {
    static var previews: some View {
        ReplaceEmptyView()
    }
}
