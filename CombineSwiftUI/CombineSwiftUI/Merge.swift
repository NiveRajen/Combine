//
//  Merge.swift
//  CombineSwiftUI
//
//  Created by Nivedha Rajendran on 12.12.24.
//

//Pipelines that send out the same type can be merged together so items that come from them will all come together and be sent down the same pipeline to the subscriber. Using the merge operator you can connect up to eight publishers total.

import SwiftUI

struct MergeView: View {
    @StateObject private var vm = MergeViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            HeaderView(title: "Merge",
                       subtitle: "Introduction",
                       desc: "The merge operator can collect items of the same type from many different publishers and send them all down the same pipeline.")
            List(vm.data, id: \.self) { item in
                Text(item)
            }
        }
        .font(.title)
        .onAppear {
            vm.fetch()
        }
    }
}

//You can merge up to seven additional publishers of the same type to your main publisher.
class MergeViewModel: ObservableObject {
    @Published var data: [String] = []
    
    func fetch() {
        let artists = ["Picasso", "Michelangelo"]
        let colors = ["red", "purple", "blue", "orange"]
        let numbers = ["1", "2", "3"]
        
        _ = artists.publisher
            .merge(with: colors.publisher, numbers.publisher)
            .sink { [unowned self] item in
                data.append(item)
            }
    }
}

#Preview {
    MergeView()
}
