//
//  Receive.swift
//  CombineSwiftUI
//
//  Created by Nivedha Rajendran on 09.12.24.
//


import SwiftUI
import Combine

//Publishers and operators upstream, will do its work in the background- here datataskpublisher and map
//Data from the background will be then moved to the foreground (main) thread and send it downstream”


//“Sometimes publishers will be doing work in the background. If you then try to display the data on the view it may or may not be displayed. Xcode will also show you the “purple warning” which is your hint that you need to move data from the background to the foreground (or main thread) so it can be displayed.”

//“The receive operator will move items coming down the pipeline to  another pipeline (thread).”


struct ReceiveView: View {
    
    @StateObject private var vm = ReceiveViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            HeaderView(title: "Receive",
                       subtitle: "Introduction",
                       desc: "The receive operator will move items coming down the pipeline to another pipeline (thread).")
            Button("Get Data From The Internet") {
                vm.fetch()
            }
            vm.imageView
                .resizable()
                .scaledToFit()
            Spacer(minLength: 0)
        }
        .font(.title)
    }
}

class ReceiveViewModel: ObservableObject {
    
    @Published var imageView = Image("blank.image")
    
    @Published var errorForAlert: ErrorForAlert?
    
    var cancellables: Set<AnyCancellable> = []
    
    func fetch() {
        //“In this example, a URL is used to retrieve an image on a background thread, and then it is moved to a foreground (main) thread to be displayed on the UI.”
        
        let url = URL(string: "https://http.cat/401")!
        //“The dataTaskPublisher will automatically do work in the background. If you set a breakpoint, you can see in the Debug navigator that it’s not on the main thread.”
    
        URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .tryMap { data in
                guard let uiImage = UIImage(data: data) else {
                    throw ErrorForAlert(message: "Did not receive a valid image.")
                }
                return Image(uiImage: uiImage)
            }
        //“The RunLoop is a scheduler which is basically a mechanism to specify where and how work is done. I’m specifying I want work done on the main thread. You could also use these other schedulers: DispatchQueue.main, OperationQueue.main”
        //“How do I know if I should use receive(on:)?”
//        “2. Purple warning in Xcode editor”
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { [unowned self] completion in
                if case .failure(let error) = completion {
                    if error is ErrorForAlert {
                        errorForAlert = (error as! ErrorForAlert)
                    } else {
                        errorForAlert = ErrorForAlert(message: "Details: \(error.localizedDescription)")
                    }
                }
            }, receiveValue: { [unowned self] image in
                imageView = image
            })
            .store(in: &cancellables)
    }
}


struct ReceiveView_Previews: PreviewProvider {
    static var previews: some View {
        ReceiveView()
    }
}
