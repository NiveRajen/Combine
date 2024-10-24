//
//  RemoveDuplicates.swift
//  CombineSwiftUI
//
//  Created by Nivedha Rajendran on 24.10.24.
//
//
//Your app may subscribe to a feed of data that could give you repeated values. Imagine a weather app for example that periodically checks the temperature. If your
//app keeps getting the same temperature then there may be no need to send it through the pipeline and update the UI.
//The removeDuplicates could be a solution so your app only responds to data that has changed rather than getting duplicate data. If the data being sent through
//the pipeline conforms to the Equatable protocol then this operator will do all the work of removing duplicates for you.

//The removeDuplicates(by:) operator works like the removeDuplicates operator but for objects that do not conform to the Equatable protocol. (Objects that conform to the Equatable protocol can be compared in code to see if they are equal or not.)
//Since removeDuplicates won’t be able to tell if the previous item is the same as the current item, you can specify what makes the two items equal inside this closure.

//You will find the tryRemoveDuplicates is just like the removeDuplicates(by:) operator except it also allows you to throw an error within the closure. In the
//closure where you set your condition on what is a duplicate or not, you can throw an error if needed and the subscriber (or other operators) will then handle the error.

import SwiftUI
import Combine


//The error conforms to Identifiable so the @Published property can be observed by the alert modifier
struct UserId: Identifiable {
    let id = UUID()
    var email = ""
    var name = ""
}

struct RemoveDuplicateError: Error, Identifiable {
    let id = UUID()
    let description = "There was a problem removing duplicate items."
}

struct RemoveDuplicatesView: View {
    
    @StateObject private var vm = RemoveDuplicatesViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            HeaderView(title: "Remove Duplicates",
                       subtitle: "Introduction",
                       desc: "If any repeated data is found, it will be removed.")
            ScrollView {
//                ForEach(vm.data, id: \.self) { name in
//                    Text(name)
//                        .padding(-1)
//                    Divider()
//                }
                
                ForEach(vm.dataToView) { item in
                    Text(item.email)
                        .padding(-1)
                    Divider()
                }
            }
            DescView(desc: "Notice that only duplicates that are one-after-another are removed.")
        }
        .font(.title)
        .alert(item: $vm.removeDuplicateError) { error in
            Alert(title: Text("Error"), message: Text(error.description))
         }
        .onAppear {
//            vm.fetch()
//            vm.fetchNonEquitables()
            vm.fetchTryNonEquitables()
        }
    }
}


class RemoveDuplicatesViewModel: ObservableObject {
    
    @Published var data: [String] = []
    
    var cancellable: AnyCancellable?
    
    @Published var dataToView: [UserId] = []
    
    @Published var removeDuplicateError: RemoveDuplicateError?
    
    func fetch() {
        //If an item coming through the  pipeline was the same as the previous element, the removeDuplicates operator will not republish it.
        let dataIn = ["Lem", "Lem", "Scott", "Scott", "Chris", "Mark", "Adam", "Jared", "Mark"]
        cancellable = dataIn.publisher
            .removeDuplicates()
            .sink{ [unowned self] datum in
                self.data.append(datum)
            }
    }
    
    //MARK:-  These email addresses are part of a struct that does not conform to Equatable. So the pipeline uses removeDuplicates(by:) so it can determine which objects are equal or not.
    
    func fetchNonEquitables() {
        let dataIn = [UserId(email: "joe.m@gmail.com", name: "Joe M."),
                      UserId(email: "joe.m@gmail.com", name: "Joseph M."),
                      UserId(email: "christina@icloud.com", name: "Christina B."),
                      UserId(email: "enzo@enel.it", name: "Lorenzo D."),
                      UserId(email: "enzo@enel.it", name: "Enzo D.")]
        
        _ = dataIn.publisher
            .removeDuplicates(by: { (previousUserId, currentUserId) -> Bool in
                //If the email addresses are the same, we are going to consider that it is the same user and that is what makes UserId structs equal.
                previousUserId.email == currentUserId.email
            })
        //Can also be written as follows
        //.removeDuplicates { $0.email == $1.email }
            .sink { [unowned self] (item) in
                dataToView.append(item)
            }
    }
    
    func fetchTryNonEquitables() {
        let dataIn = [UserId(email: "joe.m@gmail.com", name: "Joe M."),
                      UserId(email: "joe.m@gmail.com", name: "Joseph M."),
                      UserId(email: "christina@icloud.com", name: "Christina B."),
                      UserId(email: "N/A", name: "N/A"),
                      UserId(email: "N/A", name: "N/A")]
        _ = dataIn.publisher
            .tryRemoveDuplicates(by: { (previousUserId, currentUserId) -> Bool in
                if (previousUserId.email == "N/A" && currentUserId.email == "N/A") {
                    //In this scenario, we throw an error. The sink subscriber will catch it and assign it to a  @Published property. Once that happens the view will show an alert with the error message.
                    throw RemoveDuplicateError()
                }
                return previousUserId.email == currentUserId.email
            })
        //Since the tryRemoveDuplicates indicates a failure can occur in the pipeline, you are forced to use the sink(receiveCompletion:receiveValue:) subscriber. Xcode will complain if you just try to use the sink(receiveValue:) subscriber.
            .sink { [unowned self] (completion) in
                if case .failure(let error) = completion {
                    self.removeDuplicateError = error as? RemoveDuplicateError
                }
            } receiveValue: { [unowned self] (item) in
                dataToView.append(item)
            }
    }
}


struct RemoveDuplicatesView_Previews: PreviewProvider {
    static var previews: some View {
        RemoveDuplicatesView()
    }
}
