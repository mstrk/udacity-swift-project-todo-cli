import XCTest
@testable import TodoApp

final class AppTests: XCTestCase {
  func testTodoDescription() {
    let todo = Todo(title: "Test Todo")
    XCTAssertEqual(todo.description, "\u{274C} Test Todo")
  }

  func testInMemoryCache() {
    let cache = InMemoryCache()
    let todo = Todo(title: "Test Todo")

    cache.save(todos: [todo])
    XCTAssertEqual(cache.load()?.count, 1)

    let todo2 = Todo(title: "Test Todo 2")
    cache.save(todos: [todo, todo2])
    XCTAssertEqual(cache.load()?.count, 2)
  }

  func testJSONFileManagerCache() {
    let cache = JSONFileManagerCache(fileName: "test-cache")
    let todo = Todo(title: "Test Todo")

    cache.save(todos: [todo])
    XCTAssertEqual(cache.load()?.count, 1)

    let todo2 = Todo(title: "Test Todo 2")
    cache.save(todos: [todo, todo2])
    XCTAssertEqual(cache.load()?.count, 2)
  }

  func testTodosManager() {
    let cache = InMemoryCache()
    let todoManager = TodoManager(cache: cache)

    todoManager.addTodo(with: "Test Todo")
    XCTAssertEqual(cache.load()?.first?.isCompleted, false)

    todoManager.toggleCompletion(forTodoAtIndex: 0)
    XCTAssertEqual(cache.load()?.first?.isCompleted, true)

    todoManager.deleteTodo(atIndex: 0)
    XCTAssertEqual(cache.load()?.count, 0)
  }
}