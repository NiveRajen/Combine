//
//  URLSessionDataTaskPublisher.swift
//  CombineSwiftUI
//
//  Created by Nivedha Rajendran on 19.10.24.
//



//If you need to get data from an URL then URLSession is the object you want to use. It has a DataTaskPublisher that is actually a publisher which means you can send the results of a URL API call down a pipeline and process it and eventually assign the results to a property.

//The URLSession is an object that you use for:
//• Downloading data from a URL endpoint
//• Uploading data from a URL endpoint
//• Performing background downloads when your app isn’t running
//• Coordinating multiple tasks


//Error Options
//The dataTaskPublisher returns a URLResponse (as you can see in the map operator input parameter). You can also inspect this response and depending on the code, you can notify the user as to why it didn’t work or take some other action. In this case, an exception is not thrown. But you might want to throw an exception because when the data gets to the decode operator, it could throw an error because the decoding will most likely fail.
//Throw Errors
//When it comes to throwing errors from operators, you want to look for operators that start with the word “try”. This is a good indication that the operator will allow you to throw an error and so skip all the other operators between it and your subscriber. For example, if you wanted to throw an error from the map operator, then use the tryMap operator instead.
//Hide Errors
//You may not want to show any error at all to the user and instead hide it and take some other action in response. For example, you could use the replaceError operator to catch the error and then publish some default value instead.

//Source: https://moz.com/learn/seo/http-status-codes
//Code: 1xx, Type: Informational responses, Informational responses: The server is thinking through the error.
//Code: 2xx, Type: Success, Informational responses: The request was successfully completed and the server gave the browser the expected response.
//Code: 3xx, Type: Redirection, Informational responses: You got redirected somewhere else. The request was received, but there’s a redirect of some kind.
//Code: 4xx, Type: Client errors, Informational responses: Page not found. The site or page couldn’t be reached. (The request was made, but the page isn’t valid — this is an error on the website’s side of the conversation and often appears when a page doesn’t exist on the site.)
//Code: 5xx, Type: Server errors, Informational responses: Failure. A valid request was made by the client but the server failed to complete the request.

import SwiftUI
import Combine

struct CatFact: Decodable {
    let _id: String
    let text: String
}

struct ErrorForAlert: Error, Identifiable {
    let id = UUID()
    let title = "Error"
    var message = "Please try again later."
}

struct UrlDataTaskPublisherView: View {
    
    @StateObject private var vm = UrlDataTaskPublisherViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            HeaderView(title: "URLSession DataTaskPublisher",
                       subtitle: "Introduction",
                       desc: "URLSession has a dataTaskPublisher you can use to get data from a URL and run it through a pipeline.")
            vm.imageView
            
            List(vm.dataToView, id: \._id) { catFact in
                Text(catFact.text)
            }
            .font(.title3)
        }
        .font(.title)
        .onAppear {
            vm.fetch()
            vm.fetchImages()
        }
        .alert(item: $vm.errorForAlert) { errorForAlert in
            Alert(title: Text(errorForAlert.title),
                  message: Text(errorForAlert.message))
        }
    }
}

struct UrlDataTaskPublisherView_Previews: PreviewProvider {
    static var previews: some View {
        UrlDataTaskPublisherView()
    }
}


//The URLSession has a shared property that is a singleton. That basically means you don’t have to instantiate the URLSession and there is always only one URLSession. You can use it multiple times to do many tasks (fetch, upload, download, etc.)
//This is great for basic URL requests. But if you need more, you can instantiate the URLSession with more configuration options


//URLSession.shared -> Basic
//• Great for simple tasks like fetching data from a URL to memory
//• You can’t obtain data incrementally as it arrives from the server
//• You can’t customize the connection behavior
//• Your ability to perform authentication is limited
//• You can’t perform background downloads or uploads when your app
//isn’t running
//• You can’t customize caching, cookie storage, or credential storage



//Advanced
//let configuration = URLSessionConfiguration.default
//let session = URLSession(configuration: configuration)

//• You can change the default request and response timeouts
//• You can make the session wait for connectivity to be established
//• You can prevent your app from using a cellular network
//• Add additional HTTP headers to all requests
//• Set cookie, security, and caching policies
//• Support background transfers, etc

//The DataTaskPublisher will take a URL and then attempt to fetch data from it and publish the results.
//URLSession ----> DataTaskPublisher ----> Data, Result, Error

class UrlDataTaskPublisherViewModel: ObservableObject {
    
    @Published var dataToView: [CatFact] = []
    
    @Published var errorForAlert: ErrorForAlert?
    
    @Published var imageView: Image?
    
    var cancellables: Set<AnyCancellable> = []
    
    func fetch() {
        guard let url = URL(string: "https://cat-fact.herokuapp.com/facts") else {
            return
        }
        
        //To check Alert
        //        guard let url = URL(string: "https://cat-fact.herokuapp.com/nothing") else {
        //            return
        //        }
        
        //The dataTaskPublisher will run asynchronously
        URLSession.shared.dataTaskPublisher(for: url)
        
        // The Data and Response can be inspected inside a map operator. Since dataTaskPublisher returns these two things, the map operator will automatically expose those two things as input parameters.
        
        //            .map { (data: Data, response: URLResponse) in
        //                data
        //            }
        
        //To make above code shorter you can use what’s called “shorthand argument  names” or “anonymous closure arguments”. It’s a way to reference arguments coming into a closure with a dollar sign and numbers
        //        $0 = (data: Data, response: URLResponse)
        //        The $0 represents the tuple.
        
            .map { $0.data }
        //Since you know you are getting back JSON (Javascript Object Notation) from the URL endpoint, you can use the JSONDecoder.
            .decode(type: [CatFact].self, decoder: JSONDecoder())
        //Thread Switching - To move data that is coming down your background pipeline to a new foreground pipeline, you can use the receive(on:) operator.
        //You need to specify a “Scheduler”. A scheduler specifies how and where work will take place. I’m specifying I want work done on the main thread. (Run loops manage events and work. It allows multiple things to happen simultaneously.)
            .receive(on: RunLoop.main)
        //There are two sink subscribers:
        //        1. sink(receiveValue:)
        //        2. sink(receiveCompletion:receiveValue:)
        //        When it comes to this pipeline, we are forced to use the second one because this pipeline can fail. Meaning the publisher and other operators can throw an error. In this pipeline, the dataTaskPublisher can throw an error and the decode operator can throw an error.
            .sink(receiveCompletion: {  [unowned self] completion in
                //                If dataTaskPublisher throws an error then it’ll go straight to the sink’s completion handler.
                print(completion)
                
                //Returns Result Type
                if case .failure(let error) = completion {
                    errorForAlert = ErrorForAlert(message: "Details: \(error.localizedDescription)")
                }
            }, receiveValue: { [unowned self] catFact in
                dataToView = catFact
            })
            .store(in: &cancellables)
    }
    
    
    
    func fetchImages() {
        guard let url = URL(string:"https://d31ezp3r8jwmks.cloudfront.net/C3JrpZx1ggNrDXVtxNNcTz3t") else { return }
        
        URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .tryMap { data in
                guard let uiImage = UIImage(data: data) else {
                    throw ErrorForAlert(message: "Did not receive a valid image.")
                }
                return Image(uiImage: uiImage)
            }
        //If an error comes down the pipeline the replaceError operator will receive it and republish the blank image instead.
            .replaceError(with: Image("blank.image"))
            .receive(on: RunLoop.main)
        
        //use this to show alert
        
        //            .sink(receiveCompletion: { [unowned self] completion in
        //                if case .failure(let error) = completion {
        //                    if error is ErrorForAlert {
        //                        errorForAlert = (error as! ErrorForAlert)
        //                    } else {
        //                        errorForAlert = ErrorForAlert(message: "Details: \(error.localizedDescription)")
        //                    }
        //                }
        //            }, receiveValue: { [unowned self] image in
        //                imageView = image
        //            })
            .sink { [unowned self] image in
                imageView = image
            }
            .store(in: &cancellables)
    }
}
