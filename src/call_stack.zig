const MAX = 12;
var STACK: [MAX]usize = undefined;

var next: usize = 0;

pub const CallStackError = error{ EmptyStack, FullStack };

pub fn push(address: usize) error{FullStack}!void {
    if (next == MAX) {
        return error.FullStack;
    }
    STACK[next] = address;
    next += 1;
}

pub fn pop() error{EmptyStack}!usize {
    if (next == 0) {
        return error.EmptyStack;
    }
    const result = STACK[next - 1];
    next -= 1;
    return result;
}
