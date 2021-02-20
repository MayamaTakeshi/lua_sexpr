local lu = require('luaunit')

local ls = require('../lua_sexpr')

function test_empty()
    local res = ls.parse('()')
    lu.assertEquals(res, {})
end

function test_simple_list()
    local res = ls.parse('(aa bb cc)')
    lu.assertEquals(res, {'aa', 'bb', 'cc'})
end

function test_embedded_list()
    local res = ls.parse('(aa bb (cc (dd ee)))')
    lu.assertEquals(res, {'aa', 'bb', {'cc', {'dd', 'ee'}}})
end

function test_quoted_strings()
    local res = ls.parse('(aaa "bbb" ("this is ccc" ("ddd" "eee")))')
    lu.assertEquals(res, {'aaa', 'bbb', {'this is ccc', {'ddd', 'eee'}}})
end

function test_no_spaces()
    local res = ls.parse([[(aaa"bbb"("this is ccc"("ddd""eee")(fff)()))]])
    lu.assertEquals(res, {'aaa', 'bbb', {'this is ccc', {'ddd', 'eee'}, {'fff'}, {}}})
end

function test_multiple_spaces()
    local res = ls.parse([[(aaa   "bbb"   (  "ccc" (   "ddd"  "eee"  )))]])
    lu.assertEquals(res, {'aaa', 'bbb', {'ccc', {'ddd', 'eee'}}})
end

function test_tabs()
    local res = ls.parse('(aaa\t"bbb"\t\t(\t\t\t"ccc"(\t\t\t\t"ddd"\t\t\t\t\t"eee"\t\t\t\t\t)))')
    lu.assertEquals(res, {'aaa', 'bbb', {'ccc', {'ddd', 'eee'}}})
end

function test_tab_cr_lf()
    local res = ls.parse('(aaa "bbb" \t ("this is \r\nccc" (\r \n"ddd" \n"eee"\n\r) ( fff) ()))')
    lu.assertEquals(res, {'aaa', 'bbb', {'this is \r\nccc', {'ddd', 'eee'}, {'fff'}, {}}})
end

function test_stack_underflow()
    local res, details = ls.parse('(a b c))')
    lu.assertEquals({res, details}, {false, "Stack underflow: no matching '(' for  ')' at column 8"})
end

function test_not_empty_after_processing()
    local res, details = ls.parse('((a b c)')
    lu.assertEquals({res, details}, {false, "Unbalanced: stack not empty after processing"})
end

function test_missing_high_level_enclosing()
    local res, details = ls.parse('(a b c) (d)')
    lu.assertEquals({res, details}, {false, "Invalid syntax: high level enclosing (...) missing"})
end

function test_missing_high_level_enclosing2()
    local res, details = ls.parse('(a b c) d')
    lu.assertEquals({res, details}, {false, "Invalid syntax: high level enclosing (...) missing"})
end


os.exit( lu.LuaUnit.run() )
