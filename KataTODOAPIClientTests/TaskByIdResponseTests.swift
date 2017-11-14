
import Nocilla
import Nimble
import XCTest
import Result
@testable import KataTODOAPIClient

class TaskByIdResponseTests: NocillaTestCase {
    private let apiClient = TODOAPIClient()
    private let expectedTask = TaskDTO(userId: "1", id: "1", title: "delectus aut autem", completed: false)

    func testParsesTaskProperlyGettingTheTasks() {
        _ = stubRequest("GET", "http://jsonplaceholder.typicode.com/todos/1").andReturn(200)?.withJsonBody(fromJsonFile("getTaskByIdResponse"))
        
        assertTaskContainsExpectedValues(task: getTaskById("1")?.value)
    }
    
    func testReturnsItemNotFoundIfCallReturns404() {
        _ = stubRequest("GET", "http://jsonplaceholder.typicode.com/todos/1")
            .andReturn(404)
        
        expect(self.getTaskById("1")?.error).toEventually(equal(TODOAPIClientError.itemNotFound))
    }
    
    func testReturnsUnknownErrorWithErrorCodeIfCallReturnsAnError() {
        _ = stubRequest("GET", "http://jsonplaceholder.typicode.com/todos/1")
            .andReturn(450)
        
        expect(self.getTaskById("1")?.error).toEventually(equal(TODOAPIClientError.unknownError(code: 450)))
    }
    
    func testEmptyTaskIfServerReturnsEmptyJSON() {
        _ = stubRequest("GET", "http://jsonplaceholder.typicode.com/todos/1").andReturn(200)?.withJsonBody(fromJsonFile("emptyResponse"))
        
        assertTaskContainsEmptyTask(task: getTaskById("1")?.value)
    }
    
    private func getTaskById(_ id: String) -> Result<TaskDTO, TODOAPIClientError>? {
        let done = expectation(description: "call done")
        var result: Result<TaskDTO, TODOAPIClientError>?
        apiClient.getTaskById("1") { response in
            result = response
            done.fulfill()
        }
        wait(for: [done], timeout: 1)
        return result
    }
    
    private func assertTaskContainsExpectedValues(task: TaskDTO?) {
        expect(task?.id).to(equal(expectedTask.id))
        expect(task?.userId).to(equal(expectedTask.userId))
        expect(task?.title).to(equal(expectedTask.title))
        expect(task?.completed).to(equal(expectedTask.completed))
    }
    
    private func assertTaskContainsEmptyTask(task: TaskDTO?) {
        expect(task?.id).to(equal(""))
        expect(task?.userId).to(equal(""))
        expect(task?.title).to(equal(""))
        expect(task?.completed).to(beFalse())
    }
}
