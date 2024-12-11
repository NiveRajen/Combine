//
//  CombineLatest.swift
//  CombineSwiftUI
//
//  Created by Nivedha Rajendran on 11.12.24.
//
//“Using the combineLastest operator you can connect two or more pipelines and then use a closure to process the latest data received from each publisher in some way. There is also a combineLatest to connect 3 or even 4 pipelines together. You will still have just one pipeline after connecting all of the publishers.”

import Combine
import SwiftUI

struct CombineLatestView: View {
    @StateObject private var vm = CombineLatestViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            HeaderView(title: "CombineLatest",
                       subtitle: "Introduction",
                       desc: "You can combine multiple pipelines and pair up the last values from each one and do something with them using the combineLatest operator.")
            VStack {
                Image(vm.artData.artist)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                Text(vm.artData.artist)
                    .font(.body)
                
                Text(vm.artData.artist)                    .font(.body)
            }
            .padding()
            .background(vm.artData.color.opacity(0.3))
            .padding()
        }
        .font(.title)
        .onAppear {
            vm.fetch()
        }
    }
}

class CombineLatestViewModel: ObservableObject {
    @Published var artData = ArtData(artist: "Van Gogh", color: Color.red)
    
    func fetch() {
        //“The three publishers used all have varying amounts of data. But remember, the combineLatest is only interested in the latest value the publisher sends down the pipeline”
        let artists = ["Picasso", "Michelangelo", "van Gogh", "da Vinci", "Monet"]
        let colors = [Color.red, Color.orange, Color.blue, Color.purple, Color.green]
        let numbers = [1,2,3,4,5]
        
        _ = artists.publisher
            .combineLatest(colors.publisher, numbers.publisher) { (artist, color, number) in
            
            return ArtData(artist: artist, color: color, number: number)
        }
        .sink { [unowned self] (artData) in                self.artData = artData
        }
    }
}


#Preview {
    CombineLatestView()
}


struct ArtData: Identifiable {
    let id = UUID()
    var artist = ""
    var color = Color.clear
    var number = 0
}

