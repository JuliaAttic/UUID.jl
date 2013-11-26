# UUID.jl
[![Build Status](https://travis-ci.org/forio/UUID.jl.png?branch=v0.0.2)](https://travis-ci.org/forio/UUID.jl)

## Brief overview

A universally unique identifier (**UUID**) is an identifier standard, as specified by [RFC 4122](http://www.ietf.org/rfc/rfc4122.txt). UUIDs are 128 bits long, and require no central registration process.

Currently, the library generates version 1 and version 4 UUIDs.

### Usage


    julia> using UUID

    julia> u1 = UUID.v1() # generate a version 1 uuid
    Uuid('c9308c72-3936-11e3-b3d1-305bfaa14fd3')
    julia> UUID.get_version(u1) # get uuid version number
    1
    julia> string(u1) # the canonical representation
    "c9308c72-3936-11e3-b3d1-305bfaa14fd3"
    julia> hex(u1) # display as hex
    "c9308c72393611e3b3d1305bfaa14fd3"


    julia> u4 = UUID.v4() # generate a version 4 uuid
    Uuid('64885014-0f58-4a40-82df-b241dd1fd000')
    julia> UUID.get_version(u4)
    4
    julia> int(u4) # display as an integer
    133630576133332877531369589789882830848
    julia> typeof(ans)
    Int128



### Notes
Currently, the node id is implemented using section 4.5 of the RFC.

### Todo
- version 3 (using MD5 hash) and version 5 (using SHA-1 hash).

##### Questions
Feel free to submit any pull requests or issues. Originally authored by Bassem Youssef, byoussef@forio.com.
