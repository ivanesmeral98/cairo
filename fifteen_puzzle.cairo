%builtins output
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.registers import get_fp_and_pc
from starkware.cairo.common.dict_access import DictAccess
from starkware.cairo.common.squash_dict import squash_dict

# Cairo program verifying a solution to the 15-puzzle (with the initial state as an input)

# representation of a tile location
struct Location:
    member row: felt
    member col: felt
end

# FUNCTION: verifies that a location is valid
# arugments: loc is the addreess of a Location instance
func verify_valid_location(loc : Location*):
    # checking row is in bounds and within range 0-3 using 
    # math trick where either row or row-1 will be 0 so if correct indices we will get 0; same logic for columns
    tempvar row = loc.row
    assert row * (row - 1) * (row - 2) * (row - 3) = 0

    tempvar col = loc.col
    assert col * (col - 1) * (col - 2) * (col - 3) = 0

    return()
end


# FUNCTION: verifying two conscutive locations are adjacent
func verify_adjacent_locations(loc0 : Location*, loc1 : Location*):
    # need to declare alloc_locals to allocate memory for local variables in function
    alloc_locals
    local row_diff = loc0.row - loc1.row
    local col_diff = loc0.col - loc1.col

    # case where two locations are in the same row; should be 1 * 1 = 1 or -1 * -1 if they are adjacent
    if row_diff == 0: 
        assert col_diff * col_diff = 1
        return()

    # case where two locations are in the same column; should be 1 * 1 = 1 or -1 * -1 if they are adjacent
    else:
        assert row_diff * row_diff = 1
        assert col_diff = 0
        return()
    end
end

func verify_location_list(loc_list : Location*, n_steps):
    # verifying that location is valid, even if n_steps = 0; checks if it is in bounds on our grid
    verify_valid_location(loc=loc_list)

 
    if n_steps == 0:
        # verifying that 3,3 is our last location
        assert loc_list.row = 3
        assert loc_list.col = 3
        return()
    end

    verify_adjacent_locations(loc0=loc_list, loc1=loc_list + Location.SIZE)

    # call verify_location_list recursively on entire list
    verify_location_list(loc_list=loc_list + Location.SIZE, n_steps=n_steps - 1)
    return()
end


# arguments: takes in a pointer to the list of locations, pointer to list of tiles, number of steps in solution, 
#            and pointer called dict
# Function writes new dict entries starting from dict, and returns the "updated" dict pointer -- pointer to 
# next addres to write if you want to add more entries to the lit

func build_dict(
    loc_list : Location*, tile_list : felt*, n_steps,
    dict : DictAccess*) -> (dict : DictAccess*):
    if n_steps == 0:
        # case where there are no steps, return the dict pointer
        return (dict=dict)
    end

    # set the key to the current tile being moved
    assert dict.key = [tile_list]

    # it's previous location should be where the empty tile is going to be
    let next_loc : Location* = loc_list + Location.SIZE
    assert dict.prev_value = 4 * next_loc.row + next_loc.col

    # next location should be where empty tile is now
    assert dict.new_value = 4 * loc_list.row + loc_list.col

    # recursive build dict
    return build_dict(
        loc_list=next_loc,
        tile_list=tile_list+1,
        n_steps=n_steps-1,
        dict=dict+DictAccess.SIZE)
end

# builds final state of board (does backwards for efficiency) 
# for first entry key=1, prev_val=0, new_val=0 ; last entry is: key = 15, prev_val = 14, new_val = 14
func finalize_state(dict : DictAccess*, idx) -> (dict : DictAccess*):
    if idx == 0:
        return (dict=dict)
    end

    assert dict.key = idx
    assert dict.prev_value = idx - 1
    assert dict.new_value = idx - 1

    # recursive call
    return finalize_state(dict=dict + DictAccess.SIZE, idx=idx-1)
end

func main{output_ptr : felt*}():
    alloc_locals

    local loc_tuple : (Location, Location, Location, Location, Location) = (
        Location(row=0, col=2),
        Location(row=1, col=2),
        Location(row=1, col=3),
        Location(row=2, col=3),
        Location(row=3, col=3),
        )

    # Get the value of the frame pointer register (fp) so that
    # we can use the address of loc_tuple.
    let (__fp__, _) = get_fp_and_pc()
    # Since the tuple elements are next to each other we can use the
    # address of loc_tuple as a pointer to the 5 locations.
    verify_location_list(
        loc_list=cast(&loc_tuple, Location*), n_steps=4)
    return ()
end
