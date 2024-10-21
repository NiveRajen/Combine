//
//  Append.swift
//  CombineSwiftUI
//
//  Created by Nivedha Rajendran on 20.10.24.
//

import SwiftUI
import Combine

struct AppendView: View {
    @StateObject private var vm = AppendViewModel()
    var body: some View {
        VStack(spacing: 20) {
            HeaderView(title: "Append",
                       subtitle: "Definition",
                       desc: "The append operator will add data after the publisher sends out all of its data.")
            List(vm.dataToView, id: \.self) { datum in
                Text(datum)
            }
        }
        .font(.title)
        .onAppear {
            vm.fetch()
            vm.fetchAppendPipelines()
        }
    }
}

class AppendViewModel: ObservableObject {
    
    @Published var dataToView: [String] = []
    
    var cancellable: AnyCancellable?
    
    var emails: AnyCancellable?
    
    init() {
        //Here values never gets updated. It’s because the pipeline never finished. You can see in the Xcode debug console window that the completion never printed.
        //Just keep this in mind when using this operator. You want to use it on a pipeline that actually finishes.
        cancellable = $dataToView
            .append(["Total: $3,819"])
            .append(["(tap refresh to update 1)"])
            .sink { (completion) in
                print(completion)
            } receiveValue: { (data) in
                print(data)
            }
    }
    
    func fetch() {
        let dataIn = ["Amsterdam", "Oslo", "* Helsinki", "Prague", "Budapest"]
        cancellable = dataIn.publisher
        //This item will be published last after all other items finish.
        //Note: The items are appended
        //        AFTER the publisher finishes.
        //        If the publisher never finishes, the items will never get appended.
        //        A Sequence publisher is being used here which automatically finishes when the last item is published. So the append will always work here.
            .append("(* - May change)")
            .append("(tap refresh to update)")
            .sink { [unowned self] datum in
                self.dataToView.append(datum)
            }
    }
    
    func fetchAppendPipelines() {
        let unread = ["New from Meng", "What Shai Mishali says about Combine"]
            .publisher
            .prepend("UNREAD")
        let read = ["Donny Wals Newsletter", "Dave Verwer Newsletter", "Paul Hudson Newsletter"]
            .publisher
            .prepend("READ")
        //This is where the read pipeline is being appended on the unread pipeline.
        emails = unread
            .append(read)
            .sink { [unowned self] datum in
                self.dataToView.append(datum)
            }
    }
}


struct AppendView_Previews: PreviewProvider {
    static var previews: some View {
        AppendView()
    }
}
