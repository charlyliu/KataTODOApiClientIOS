
import Nocilla
import Nimble
import XCTest
import Result
@testable import KataTODOAPIClient

class AddTaskRequestTests: NocillaTestCase {
    
    private let apiClient = TODOAPIClient()
    private let expectedTask = TaskDTO(userId: "1", id: "1", title: "delectus aut autem", completed: false)
    
    func testShouldSendTheCorrectBody() {
        _ = stubRequest("POST", "http://jsonplaceholder.typicode.com/todos").withJsonBody(fromJsonFile("addTaskToUserRequest"))?.andReturn(200)
        
        expect(self.addTaskToUser()).toNot(beNil())
    }
    
    func testReturnsATaskWhenSentCorrectly() {
        _ = stubRequest("POST", "http://jsonplaceholder.typicode.com/todos").andReturn(200)?.withJsonBody(fromJsonFile("addTaskToUserResponse"))
        
        assertTaskContainsExpectedValues(task: addTaskToUser()?.value)
    }
    
    func testReturnsUnknownErrorWithErrorCodeIfCallReturnsAnError() {
        _ = stubRequest("POST", "http://jsonplaceholder.typicode.com/todos")
            .andReturn(450)
        
        expect(self.addTaskToUser()?.error).toEventually(equal(TODOAPIClientError.unknownError(code: 450)))
    }
    
    private func addTaskToUser() -> Result<TaskDTO, TODOAPIClientError>? {
        let done = expectation(description: "call done")
        var result: Result<TaskDTO, TODOAPIClientError>?
        apiClient.addTaskToUser("1", title: "Finish this kata", completed: false) { response in
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
}
