//
//  CombineSwiftUI
//
//  Created by Nivedha Rajendran on 18.10.24.
//

import SwiftUI

//View
struct SimpleMVVM: View {
    @StateObject var vm = BookViewModel()
    var body: some View {
        List(vm.books) { book in
            HStack {
                Image(systemName: "book")
                Text(book.name)
            }
        }
        .onAppear {
            vm.fetch()
        }
    }
}

//Model
struct BookModel: Identifiable {
    var id = UUID()
    var name = ""
}

//View Model
class BookViewModel: ObservableObject {
    @Published var books = [BookModel]()
    func fetch() {
        books =
        [BookModel(name: "SwiftUI"),
         BookModel(name: "Animations"),
         BookModel(name: "SwiftData"),
         BookModel(name: "Combine")]
    }
}

#Preview {
    SimpleMVVM()
}
