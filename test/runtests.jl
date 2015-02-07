
using UUID

# v1 -------

u1 = UUID.v1()
u1::UUID.Uuid

@assert UUID.get_version(u1) == 1
@assert string(u1) != nothing
@assert int(u1) != nothing
@assert hex(u1) != nothing

@assert UUID.v1() != UUID.v1()  # just checking :)

# v4 -------

u4 = UUID.v4()
u4::UUID.Uuid

@assert UUID.get_version(u4) == 4
@assert string(u4) != nothing
@assert int(u4) != nothing
@assert uint(u4) != nothing
@assert hex(u4) != nothing

@assert UUID.v4() != UUID.v4()
