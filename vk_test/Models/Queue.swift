import Foundation

public struct Queue<T> {
    var array = [T]()
    
    mutating func push(_ element: T) {
        array.append(element)
    }
    
    mutating func pop() -> T? {
        let first = array.first
        if array.count > 0 {
            array.removeFirst()
        }
        return first
    }
    
    mutating func clear() {
        array.removeAll()
    }
    
    func size() -> Int {
        return array.count
    }
}
