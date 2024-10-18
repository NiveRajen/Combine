# Combine

Publisher:

A type that can push out data. It can push out the data all at once or over time. 
In English, “publish” means to “produce and send out to make known”.

protocol Publisher {
    func receive(subscriber:)
}
func PublishData<Output, Failure>(...)

protocol Publisher {
    associatedtype Output
    associatedtype Failure: Error
    
    func receive<S>(subscriber: S) where S : Subscriber, Self.Failure == S.Failure, Self.Output == S.Input
}

Subscriber:

Something that can receive data from a publisher. In English, “subscribe” means to “arrange to receive something”.
"I would like to sign up for some data."

func SubscriberToData<Input, Failure>(...)

protocol Subscriber {
    func receive(subscription:)
    func receive(input:)
    func receive(completion:)
}

protocol Subscriber {
    associatedtype Input
    associatedtype Failure: Error
}

Operators:
Operators are functions you can put right on the pipeline between the Publisher and the Subscriber.
They take in data, do something, and then re-publish the new data. So operators ARE publishers.
They modify the Publisher much like you’d use modifiers on a SwiftUI view.

func FilterData<Output, Failure>(...)

Upstream
“Upstream” means “in the direction of the PREVIOUS part”.
In Combine, the previous part is usually a Publisher or Operator

Downstream
“Downstream” means “in the direction of the NEXT part”.
In Combine, the next part could be another Publisher, Operator or even the Subscriber at the end.


General: Publisher and Subscriber should have same data type. You WILL NOT have to conform to these protocols yourself. The Combine team did all of this for you!
