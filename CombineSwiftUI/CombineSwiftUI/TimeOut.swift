//
//  TimeOut.swift
//  CombineSwiftUI
//
//  Created by Nivedha Rajendran on 22.10.24.
//

//You don’t want to make users wait too long while the app is retrieving or processing data. So you can use the timeout operator to set a time limit. If the pipeline takes too long you can automatically finish it once the time limit is hit. Optionally, you can define an error so you can look for this error when the pipeline finishes.
//This way when the pipeline finishes, you can know if it was specifically because of the timeout and not because of some other condition.

import SwiftUI
import Combine

struct TimeoutError: Error, Identifiable {
    let id = UUID()
    let title = "Timeout"
    let message = "Please try again later."
}

struct TimeOutView: View {
    
    @StateObject private var vm = TimeoutViewModel()
    
    var body: some View {
        
        VStack(spacing: 20) {
            
            HeaderView(title: "Timeout",
                       subtitle: "Introduction",
                       desc: "You can specify a time limit for the timeout operator. If no item comes down the pipeline before that time limit then pipeline is finished.")
            
            Button("Fetch Data") {
                vm.fetch()
            }
            
            if vm.isFetching {
                ProgressView("Fetching...")
            }
            
            Spacer()
            
            DescView(desc: "You can also set a custom error when the time limit is exceeded.")
            
            Spacer()
        }
        .font(.title)
        .alert(item: $vm.timeoutError) { timeoutError in
            Alert(title: Text(timeoutError.title), message: Text(timeoutError.message))
        }
    }
}

class TimeoutViewModel: ObservableObject {
    
    @Published var dataToView: [String] = []
    
    @Published var isFetching = false
    
    @Published var timeoutError: TimeoutError?
    
    private var cancellable: AnyCancellable?
    
    func fetch() {
        isFetching = true
        
        //This URL isn’t real. I wanted something that would delay fetching.
        guard let url = URL(string: "https://bigmountainstudio.com/nothing") else {
            return
        }
        
        cancellable = URLSession.shared.dataTaskPublisher(for: url)
//        I set the timeout to be super short 0.1 seconds) just to trigger it.
            .timeout(.seconds(0.1), scheduler: RunLoop.main, customError: { URLError(.timedOut) })
            .map { $0.data }
            .decode(type: String.self, decoder: JSONDecoder())
            .sink(receiveCompletion: { [unowned self] completion in
                isFetching = false
                if case .failure(URLError.timedOut) = completion {
                    timeoutError = TimeoutError()
                }
            }, receiveValue: { [unowned self] value in
                dataToView.append(value)
            })
    }
}


struct TimeOutView_Previews: PreviewProvider {
    static var previews: some View {
        TimeOutView()
    }
}
