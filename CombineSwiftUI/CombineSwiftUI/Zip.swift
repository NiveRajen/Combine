//
//  Zip.swift
//  CombineSwiftUI
//
//  Created by Nivedha Rajendran on 15.12.24.
//

import SwiftUI

//Using the zip operator you can connect two pipelines and then use a closure to process the data from each publisher in some way. There is also a zip3 and zip4 to connect even more pipelines together. You will still have just one pipeline after connecting all the pipelines that send down the data to your subscriber.
struct ZipView: View {
    
    @StateObject private var vm = ZipViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            HeaderView(title: "Zip",
                       subtitle: "Introduction",
                       desc: "You can combine multiple pipelines and pair up the values from each one and do something with them using the zip operator.")
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100, maximum: 250))]) {
                ForEach(vm.dataToView) { artData in
                    VStack {
                        Image(artData.artist)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                        Text(artData.artist)
                            .font(.body)
                    }
                    .padding(4)
                    .background(artData.color.opacity(0.4))
                    .frame(height: 150)
                }
            }
        }
        .font(.title)
        .onAppear {
            vm.fetch()
        }
    }
}

class ZipViewModel: ObservableObject {
    @Published var dataToView: [ArtData] = []
    
    func fetch() {
        //There are two publishers, one for an artist’s name and another for color.
       // The zip operator combines the values from these two publishers and sends them down the pipeline. They are used together to create the UI.
        let artists = ["Picasso", "Michelangelo", "van Gogh", "da Vinci", "Monet"]
        //Published when there is a value from BOTH publishers. If you were to remove Color.green from the  colors array then “Monet” would not get published. It is because “Monet" would not have a matching value from the colors array anymore.
        let colors = [Color.red, Color.orange, Color.blue, Color.purple, Color.green]
        //The zip operator will match up items from each publisher and pass them as input parameters into its closure. In this example, both input parameters are used to create a new ArtData object and then send that down the pipeline.
        _ = artists.publisher
            .zip(colors.publisher) { (artist, color) in
                return ArtData(artist: artist, color: color)
            }
            .sink { [unowned self] (item) in
                dataToView.append(item)
            }
    }
}

#Preview {
    ZipView()
}
