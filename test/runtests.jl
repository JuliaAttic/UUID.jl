
using UUID

# v1 -------

u1 = Uuid.v1()
@assert u1::Uuid

@assert UUID.get_version(u1) == 1
@assert string(u1) != nothing
@assert int(u1) != nothing
@assert hex(u1) != nothing

@assert UUID.v1() != UUID.v1()  # just checking :)

# v4 -------

u4 = Uuid.v4()
@assert u4::Uuid

@assert UUID.get_version(u4) == 4
@assert string(u4) != nothing
@assert int(u4) != nothing
@assert hex(u4) != nothing

@assert UUID.v4() != UUID.v4()
