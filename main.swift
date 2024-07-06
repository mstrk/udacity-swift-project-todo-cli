import Foundation

// * Create the `Todo` struct.
// * Ensure it has properties: id (UUID), title (String), and isCompleted (Bool).
struct Todo: CustomStringConvertible {
  let id: UUID
  let title: String
  var isCompleted: Bool

  init(title: String, isCompleted: Bool = false) {
    self.id = UUID()
    self.title = title
    self.isCompleted = isCompleted
  }

  var description: String {
    return "\(title) - \(isCompleted ? "Completed" : "Not Completed")"
  }
}

// Create the `Cache` protocol that defines the following method signatures:
//  `func save(todos: [Todo])`: Persists the given todos.
//  `func load() -> [Todo]?`: Retrieves and returns the saved todos, or nil if none exist.
protocol Cache {
  func save(todos: [Todo])
  func load() -> [Todo]?
}

// `FileSystemCache`: This implementation should utilize the file system 
// to persist and retrieve the list of todos. 
// Utilize Swift's `FileManager` to handle file operations.
// final class JSONFileManagerCache: Cache {
//   // TODO: Implement the JSONFileManagerCache
// }

// `InMemoryCache`: : Keeps todos in an array or similar structure during the session. 
// This won't retain todos across different app launches, 
// but serves as a quick in-session cache.
final class InMemoryCache: Cache {
  var todos: [Todo] = []

  func save(todos: [Todo]) {
    self.todos = todos
  }

  func load() -> [Todo]? {
    return todos
  }
}

// The `TodosManager` class should have:
// * A function `func listTodos()` to display all todos.
// * A function named `func addTodo(with title: String)` to insert a new todo.
// * A function named `func toggleCompletion(forTodoAtIndex index: Int)` 
//   to alter the completion status of a specific todo using its index.
// * A function named `func deleteTodo(atIndex index: Int)` to remove a todo using its index.
final class TodoManager {
  var cache: Cache

  init(cache: Cache) {
    self.cache = cache
  }

  private func loadTodos() -> [Todo]? {
    guard let todos = cache.load() else {
      print("\nSomething went wrong, we're unable to load todos.")
      return nil
    }

    return todos
  }

  func listTodos() -> Bool {
    guard let todos = loadTodos() else {
      return false
    }

    print("\nYour todos:")

    if todos.isEmpty {
      print("  No todos yet, add some!")
      return false
    }

    for (index, todo) in todos.enumerated() {
      print("  \(index + 1). \(todo)")
    }

    return true
  }

  func addTodo(with title: String) {
    guard var todos = loadTodos() else {
      return
    }

    let todo = Todo(title: title)
    todos.append(todo)
    cache.save(todos: todos)

    print("\nTodo added!")
  }

  func toggleCompletion(forTodoAtIndex number: Int) {
    guard var todos = loadTodos() else {
      return
    }

    let index = number - 1

    guard index >= 0 && index < todos.count else {
      print("\nInvalid todo number, please try again.")
      return
    }

    todos[index].isCompleted.toggle()
    cache.save(todos: todos)

    print("\nTodo completion status toggled!")
  }
  
  func deleteTodo(atIndex index: Int) {
    guard var todos = loadTodos() else {
      return
    }

    guard index >= 0 && index < todos.count else {
      print("\nInvalid todo number, please try again.")
      return
    }

    todos.remove(at: index)
    cache.save(todos: todos)

    print("\nTodo deleted!")
  }
}


// * The `App` class should have a `func run()` method, this method should perpetually 
//   await user input and execute commands.
//  * Implement a `Command` enum to specify user commands. Include cases 
//    such as `add`, `list`, `toggle`, `delete`, and `exit`.
//  * The enum should be nested inside the definition of the `App` class
final class App {
  enum Command: String {
    case add
    case list
    case toggle
    case delete
    case exit
  }

  let todoManager: TodoManager

  init(todoManager: TodoManager) {
    self.todoManager = todoManager
  }

  func promptForTodoNumber() -> Int? {
    print("\nEnter the number of the todo:", terminator: " ")

    guard let number = Int(readLine() ?? "") else {
      print("\nInvalid todo number, please try again.")
      return nil
    }

    return number
  }

  func run() {
    print("Welcome to the Todo CLI!")

    while true {
      print("\nWhat would you like to do? (add, list, toggle, exit):", terminator: " ")

      guard let command = Command(rawValue: readLine() ?? "") else {
        continue
      }

      switch command {
        case .add:
          print("\nEnter todo title:", terminator: " ")

          let invalidPrompt = "\nInvalid title, please try again."

          guard let title = readLine() else {
            print(invalidPrompt)
            continue
          }

          if title.isEmpty {
            print(invalidPrompt)
            continue
          }

          todoManager.addTodo(with: title)
        case .list:
          _ = todoManager.listTodos()
        case .toggle:
          let success = todoManager.listTodos()

          if !success {
            continue
          }
          
          guard let number = promptForTodoNumber() else {
            continue
          }

          todoManager.toggleCompletion(forTodoAtIndex: number)
        case .delete:
          let success = todoManager.listTodos()

          if !success {
            continue
          }
          
          guard let number = promptForTodoNumber() else {
            continue
          }

          todoManager.deleteTodo(atIndex: number - 1)
        case .exit:
          print("\nGoodbye!")
        return
      }
    }
  }
}

// Start the app
let cache = InMemoryCache()
let todoManager = TodoManager(cache: cache)
let app = App(todoManager: todoManager)
app.run()

