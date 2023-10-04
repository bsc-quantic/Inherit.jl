module Inherit

export @inherit

function count_unionall_components(@nospecialize(t))
    i = 0
    while isa(t, UnionAll)
        t = t.body
        i += 1
    end
    return i
end

macro inherit(expr)
    parentname = if expr isa Symbol
        expr
    elseif expr.head == :curly
        expr.args[1]
    else
        throw(ArgumentError("unknown expression"))
    end

    parent = getproperty(__module__, parentname)
    isstructtype(parent) || throw(ArgumentError("parent type must be a struct"))

    if parent isa UnionAll
        expr isa Expr || throw(ArgumentError("parent type is a parametric type but no type parameters are defined"))
        typevars = expr.args[2:end]
        count_unionall_components(parent) == length(typevars) ||
            throw(ArgumentError("not enough type parameters"))
        parent = parent{map(TypeVar, typevars)...}
    end

    # instrospect parent type
    fields = map(fieldnames(parent), fieldtypes(parent)) do name, type
        type isa TypeVar && (type = Symbol(type))
        :($name::$type)
    end

    quote
        $(esc.(fields)...)
    end
end

end
