%builtins output
from starkware.cairo.common.serialize import serialize_word
from starkware.cairo.common.alloc import alloc

# FUNCTION: array_sum: sum elements of array
# - Description: Here we define a function named array_sum that takes in two arguments: arr and size
# - Arguments: arr points to an array of size elements; arr is of type: felt* which is a pointer
# - Return value: single value named sum
func array_sum(arr : felt*, size) -> (sum):
    # case where size is 0
    if size == 0:
        return (sum=0)
    end

    # case where size is not 0
    # recursive call to next element and decrementing amount of calls left; idea that arr points to first memory cell of the array
    let (sum_of_rest) = array_sum(arr=arr+1, size=size-1) 

    # returning sum of first element (using dereference operator) and add it to sum of rest!
    return (sum=[arr] + sum_of_rest)
end

# FUNCTION: even_products: computes the product of all even entires of an array
func even_products(arr : felt*, size) -> (product):
    if size == 0:
        return (product=1)
    end

    # same functionality as array_sum but increment the pointer by 2
    let (sum_of_evens) = even_products(arr=arr+2, size=size-2)

    return (product=[arr] * sum_of_evens)
end


# starting point for any cairo program
func main{output_ptr : felt*}():
    # SERIALIZE WORD gets one argument and the implicit argument (output_ptr in this case) and writes value to memory cell
    # so arugment is value set to [output_ptr] and returns next memory cell
    
    const ARRAY_SIZE_ONE = 3
    const ARRAY_SIZE_TWO = 4

    # ALLOCATE array space
    let (ptr) = alloc()
    let (even_ptr) = alloc()

    # populate values
    assert [ptr] = 1
    assert [ptr+1] = 2
    assert [ptr+2] = 3

        # populate values
    assert [even_ptr] = 3
    assert [even_ptr+1] = 6
    assert [even_ptr+2] = 9
    assert [even_ptr+3] = 12

    # let (sum) = array_sum(arr=ptr, size=ARRAY_SIZE_ONE)

    let (evens) = even_products(arr=even_ptr, size=ARRAY_SIZE_TWO)
    
    serialize_word(evens)
    
    return()
end
