
import Foundation
import Nocilla
import Nimble
import XCTest
import Result
@testable import KataTODOAPIClient

class TaskByIdResponseTests: NocillaTestCase {
    fileprivate let apiClient = TODOAPIClient()
    fileprivate let expectedTask = TaskDTO(userId: "1", id: "1", title: "delectus aut autem", completed: false)

    func testParsesTaskProperlyGettingTheTasks() {
        _ = stubRequest("GET", "http://jsonplaceholder.typicode.com/todos/1").andReturn(200)?.withJsonBody(fromJsonFile("getTaskByIdResponse"))
        
        var result: Result<TaskDTO, TODOAPIClientError>?
        apiClient.getTaskById("1") { response in
            result = response
        }
        
        expect(result).toNotEventually(beNil())
        assertTaskContainsExpectedValues(task: result!.value!)
    }
    
    private func assertTaskContainsExpectedValues(task: TaskDTO) {
        expect(task.id).to(equal(expectedTask.id))
        expect(task.userId).to(equal(expectedTask.userId))
        expect(task.title).to(equal(expectedTask.title))
        expect(task.completed).to(equal(expectedTask.completed))
    }
}
