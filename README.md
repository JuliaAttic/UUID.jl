# UUID.jl
[![Build Status](https://travis-ci.org/forio/UUID.jl.png?branch=master)](https://travis-ci.org/forio/UUID.jl)

#### UUID functionality has been merged into Julia 0.4
##### Moving forward, please use `Base.Random.uuid1()`, `Base.Random.uuid4()`, and `Base.Random.UUID` instead.

## Brief overview

A universally unique identifier (**UUID**) is an identifier standard, as specified by [RFC 4122](http://www.ietf.org/rfc/rfc4122.txt). UUIDs are 128 bits long, and require no central registration process.

Currently, the library generates version 1 and version 4 UUIDs.

### Usage

```julia
julia> using UUID

julia> u1 = UUID.v1() # generate a version 1 uuid
Uuid('c9308c72-3936-11e3-b3d1-305bfaa14fd3')

julia> UUID.get_version(u1) # get uuid version number
1

julia> string(u1) # the canonical representation
"c9308c72-3936-11e3-b3d1-305bfaa14fd3"

julia> hex(u1) # display as hex
"c9308c72393611e3b3d1305bfaa14fd3"

...

julia> u4 = UUID.v4() # generate a version 4 uuid
Uuid('64885014-0f58-4a40-82df-b241dd1fd000')

julia> UUID.get_version(u4)
4

julia> uint(u4) # display as an integer
133630576133332877531369589789882830848

julia> typeof(ans)
Uint128
```

### Notes
Currently, the node id is implemented using section 4.5 of the RFC.

-------

Originally authored by [Bassem Youssef](https://github.com/bass3m)
