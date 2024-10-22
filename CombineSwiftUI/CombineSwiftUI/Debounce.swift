//
//  Debounce.swift
//  CombineSwiftUI
//
//  Created by Nivedha Rajendran on 22.10.24.
//

//Think of “debounce” like a pause. The word “bounce” is used in electrical engineering. It is when push-button switches make and break contact several times when the button is pushed. When a user is typing and backspacing and typing more it could seem like the letters are bouncing back and forth into the pipeline.The prefix “de-” means “to remove or lessen”. And so, “debounce” means to “lessen bouncing”. It is used to pause input before being sent down the pipeline.

import SwiftUI

class DebounceViewModel: ObservableObject {
    
    @Published var name = ""
    @Published var nameEntered = ""
    
    //The idea here is that we want to “slow down” the input so we publish whatever came into the pipeline every 0.5 seconds.
    //You will notice when you play the video that the letters entered only get published every 0.5 seconds.
    //The scheduler is basically a mechanism to specify where and how work is done. I’m specifying I want work done on the main thread. You could also use DispatchQueue.main.
    init() {
        $name
            .debounce(for: 0.5, scheduler: RunLoop.main)
            .assign(to: &$nameEntered)
    }
}

struct DebounceView: View {
    
    @StateObject private var vm = DebounceViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            HeaderView(title: "Debounce",
                       subtitle: "Definition",
                       desc: "The debounce operator can pause items going through your pipeline  for a specified amount of time.")
            TextField("name", text: $vm.name)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            Text(vm.nameEntered)
            Spacer()
        }
        .font(.title)
    }
}


struct DebounceView_Previews: PreviewProvider {
    static var previews: some View {
        DebounceView()
    }
}
