//
//  RootView.swift
//  
//
//  Created by Yang Xu on 2020/5/14.
//  Copyright © 2020 Yang Xu. All rights reserved.
//

import Combine
import SwiftUI

let store = (UIApplication.shared.delegate as! AppDelegate).store

struct RootView: View {

  @State var name: String = ""
  @State var age: Int = 0
  @State var student = Student()
  @MyState<String>(wrappedValue:String(store.state.student.value.age),toAction:{
    store.state.student.value.age = Int($0) ?? 0
    print("new:\($0)")
  }) var studentAge
  @ObservedPublisher(publisher: store.state.title, initial: "") var title
  var body: some View {
    Form {
      Section {
        Text("name is \(name)")
        Text("age is \(age)")
        Text("student name is :\(student.name)")
//        Text("student age is: \(student.age)")
        Text("title is:\(title)")
        Button("changetitle"){
//            print("")
            store.state.title.value = "title"
        }
        TextField("studentName:", text: store.state.student.binding(for: \.name))
        Button("changName") {
          store.test()
        }
        TextField("student age:", text: $studentAge)
        SubView(name: store.state.name.binding)
        SubView2()

      }
      .onReceive(
        store.state.name,
        perform: { name in
          self.name = name
        }
      )
      .onReceive(
        store.state.age,
        perform: { age in
          self.age = age
        }
      )
      .onReceive(
        store.state.student,
        perform: { student in
          self.student = student
        })
    }

  }
}

struct SubView: View {
  @Binding var name: String
  var body: some View {
    TextField("name:", text: $name)
  }
}

struct SubView2: View {
  @State var address = ""
  var body: some View {
    Text(address).onReceive(
      store.state.address,
      perform: { address in
        self.address = address
      })
  }
}

struct RootView_Previews: PreviewProvider {
  static var previews: some View {
    RootView()
  }
}

class Store {
  var state = AppState()
  func test() {
    state.name.value = Date().description
  }
}

struct AppState {
  var name = CurrentValueSubject<String, Never>("")
  var age = CurrentValueSubject<Int, Never>(0)
  var student = CurrentValueSubject<Student, Never>(Student())
  var address = CurrentValueSubject<String, Never>("dalian")
  var title = CurrentValueSubject<String,Never>("manager")
}

extension CurrentValueSubject {
  var binding: Binding<Output> {
    Binding<Output>(get: { self.value }, set: { self.value = $0 })
  }

  func binding<Value>(for keyPath: WritableKeyPath<Output, Value>) -> Binding<Value> {
    Binding<Value>(
      get: { self.value[keyPath: keyPath] }, set: { self.value[keyPath: keyPath] = $0 })
  }
}

struct Student {
  var name = "fat"
  var age = 18
}

@propertyWrapper
struct MyState<Value>: DynamicProperty {
  typealias Action = (Value) -> Void

  private var _value: State<Value> {
    didSet {
      _toAction?(_value.wrappedValue)
    }
  }
  private var _toAction: Action?

  init(wrappedValue value: Value) {
    self._value = State<Value>(wrappedValue: value)
  }

  init(wrappedValue value: Value, toAction: @escaping Action) {
    self._value = State<Value>(wrappedValue: value)
    self._toAction = toAction
    self._toAction?(value)
  }

  public var wrappedValue: Value {
    get { self._value.wrappedValue }
    nonmutating set {
      self._value.wrappedValue = newValue
      self._toAction?(newValue)
    }
  }

  public var projectedValue: Binding<Value> {
    Binding<Value>(
      get: { self._value.wrappedValue },
      set: {
        self._value.wrappedValue = $0
        self._toAction?($0)
      }
    )
  }

  public func update() {
    //View刷新前执行的代码
    print("updateing")
  }

}




