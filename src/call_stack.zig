const MAX = 12;
var STACK: [MAX]u16 = undefined;

var next: usize = 0;

pub const CallStackError = error{ EmptyStack, FullStack };

pub fn push(address: u16) error{FullStack}!void {
    if (next == MAX) {
        return error.FullStack;
    }
    STACK[next] = address;
    next += 1;
}

pub fn pop() error{EmptyStack}!u16 {
    if (next == 0) {
        return error.EmptyStack;
    }
    const result = STACK[next - 1];
    next -= 1;
    return result;
}
