
import Nocilla
import Nimble
import XCTest
import Result
@testable import KataTODOAPIClient

class TaskResponseTests: NocillaTestCase {

    private let apiClient = TODOAPIClient()

    func testSendsContentTypeHeader() {
        _ = stubRequest("GET", "http://jsonplaceholder.typicode.com/todos")
            .withHeaders(["Content-Type": "application/json", "Accept": "application/json"])?
            .andReturn(200)

        expect(self.getAllTasks()).toNot(beNil())
    }

    func testParsesTasksProperlyGettingAllTheTasks() {
        _ = stubRequest("GET", "http://jsonplaceholder.typicode.com/todos")
            .andReturn(200)?
            .withJsonBody(fromJsonFile("getTasksResponse"))

        let result = self.getAllTasks()
        expect(result?.value?.count).to(equal(200))
        assertTaskContainsExpectedValues(task: (result?.value?[0])!)
    }

    func testReturnsNetworkErrorIfThereIsNoConnectionGettingAllTasks() {
        stubRequest("GET", "http://jsonplaceholder.typicode.com/todos")
            .andFailWithError(NSError.networkError())

        expect(self.getAllTasks()?.error).to(equal(TODOAPIClientError.networkError))
    }
    
    func testReturnsItemNotFoundIfCallReturns404() {
        _ = stubRequest("GET", "http://jsonplaceholder.typicode.com/todos")
            .andReturn(404)

        expect(self.getAllTasks()?.error).to(equal(TODOAPIClientError.itemNotFound))
    }
    
    func testReturnsUnknownErrorWithErrorCodeIfCallReturnsAnError() {
        _ = stubRequest("GET", "http://jsonplaceholder.typicode.com/todos")
            .andReturn(450)
        
        expect(self.getAllTasks()?.error).to(equal(TODOAPIClientError.unknownError(code: 450)))
    }
    
    private func getAllTasks() -> Result<[TaskDTO], TODOAPIClientError>? {
        let done = expectation(description: "call done")
        var result: Result<[TaskDTO], TODOAPIClientError>?
        apiClient.getAllTasks() { response in
            result = response
            done.fulfill()
        }
        wait(for: [done], timeout: 1)
        return result
    }
    
    private func assertTaskContainsExpectedValues(task: TaskDTO) {
        expect(task.id).to(equal("1"))
        expect(task.userId).to(equal("1"))
        expect(task.title).to(equal("delectus aut autem"))
        expect(task.completed).to(beFalse())
    }
}
