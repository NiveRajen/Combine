//
//  Mapping.swift
//  CombineSwiftUI
//
//  Created by Nivedha Rajendran on 24.10.24.
//

//These operators all have to do with performing some function on each item coming through the pipeline. The function or process you want to do with each element
//can be anything from validating the item to changing it into something else.

//With the map operator, you provide the code to perform on each item coming through the pipeline. With the map function, you can inspect items coming through and validate them, update them to something else, even change the type of the item.
//Maybe your map operator receives a tuple (a type that holds two values) but you only want one value out of it to continue down the pipeline. Maybe it receives Ints but you want to convert them to Strings. This is an operator in which you can do anything you want within it. This makes it a very popular operator to know.

//The tryMap operator is just like the map operator except it can throw errors. Use this if you believe items coming through could possibly cause an error. Errors thrown will finish the pipeline early.

import SwiftUI


struct Creator: Identifiable {
    let id = UUID()
    var fullname = ""
}

//This will be the error type thrown in the tryMap.
//Identifiable
//The error conforms to Identifiable so the view’s alert modifier can observe it and display an Alert.
//CustomStringConvertible
//This allows us to set a description for our error object that we can then use on the UI. You could just as easily add your own String property to hold an error message.

struct ServerError: Error, Identifiable, CustomStringConvertible {
    let id = UUID()
    let description = "There was a server error while retrieving values."
}

struct MapView: View {
    
    @StateObject private var vm = MapViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            HeaderView(title: "Map",
                       subtitle: "Introduction",
                       desc: "Use the map operator to run some code with each item that is  passed through the pipeline.")
            List(vm.dataToView, id: \.self) { item in
                //Every item that goes through the pipeline will get an icon added to it and be turned to uppercase.
                Text(item)
            }
        }
        .font(.title)
        .onAppear {
            //            vm.fetch()
            //            vm.fetchKeyPath()
            vm.fetchTryMap()
        }
        .alert(item: $vm.error) { error in
            Alert(title: Text("Error"), message: Text(error.description))
        }
    }
}


class MapViewModel: ObservableObject {
    
    @Published var dataToView: [String] = []
    
    @Published var error: ServerError?
    
    func fetch() {
        let dataIn = ["mark", "karin", "chris", "ellen", "paul", "scott"]
        
        _ = dataIn.publisher
        //Map operators receive an item, do something to it, and then republish an item. Something always needs to be returned to continue down the pipeline.
            .map({ (item) in
                return "* " + item.uppercased()
            })
        
        //above operator can be written as
        //            .map { "* " + $0.uppercased() }
            .sink { [unowned self] (item) in
                dataToView.append(item)
            }
    }
    
    func fetchKeyPath() {
        let dataIn = [
            Creator(fullname: "Mark Moeykens"),
            Creator(fullname: "Karin Prater"),
            Creator(fullname: "Chris Ching"),
            Creator(fullname: "Donny Wals"),
            Creator(fullname: "Paul Hudson"),
            Creator(fullname: "Joe Heck")]
        
        //You simply provide a key path to the property that you want to send downstream.
        //        Note: You can also used a shorthand argument name too: .map { $0.fullname }
        _ = dataIn.publisher
            .map(\.fullname)
            .sink { [unowned self] (name) in
                dataToView.append(name)
            }
    }
    
    func fetchTryMap() {
        let dataIn = ["Value 1", "Value 2", "Server Error 500", "Value 3"]
        _ = dataIn.publisher
            .tryMap { item -> String in
                if item.lowercased().contains("error") {
                    throw ServerError()
                }
                return item
            }
            .sink { [unowned self] completion in
                if case .failure(let error) = completion {
                    self.error = error as? ServerError
                }
            } receiveValue: { [unowned self] item in
                dataToView.append(item)
            }
    }
}


struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
    }
}
