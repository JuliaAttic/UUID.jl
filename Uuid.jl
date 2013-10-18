# uuid layout and byteorder from RFC 4122
# 0                   1                   2                   3
# 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
# |                          time_low                             |
# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
# |       time_mid                |         time_hi_and_version   |
# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
# |clk_seq_hi_res |  clk_seq_low  |         node (0-1)            |
# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
# |                         node (2-5)                            |
# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+

module Uuid

type Uuid
    ts_low::Uint32
    ts_mid::Uint16
    ts_hi_and_ver::Uint16
    clock_seq_hi_and_rsvd::Uint8
    clock_seq_low::Uint8
    node::Vector{Uint8}

    Uuid(ts_low,ts_mid,ts_hi_and_ver,
         clock_seq_hi_and_rsvd,clock_seq_low,
         node) = length(node) != 6 ? error("Node vector size should be 6") :
                                     new(ts_low,ts_mid,ts_hi_and_ver,
                                         clock_seq_hi_and_rsvd,
                                         clock_seq_low,node)
    Uuid() = Uuid(0,0,0,0,0,[0, 0, 0, 0, 0, 0])
end

function get_rand_narray(n)
    rand(Uint8,n)
end

# Per RFC 4122:
# Get the current time as a 60-bit count of 100-nanosecond intervals
# since 00:00:00.00, 15 October 1582
# 0x01b21dd213814000 is the number of 100-ns intervals between the
# UUID epoch 1582-10-15 00:00:00 and the Unix epoch 1970-01-01 00:00:00
const number_100ns_intervals = 0x01b21dd213814000

function get_timestamp()
    # 1e9 /100 for 100ns intervals
    iround(time() * 1e7) + number_100ns_intervals
end

function build_timestamp(uuid)
    timestamp = get_timestamp()
    uuid.ts_low = timestamp & typemax(Uint32)
    uuid.ts_mid = (timestamp >> 32) & typemax(Uint16)
    # timestamp is 60 bits so cutoff upper nibble, also add version
    uuid.ts_hi_and_ver = ((timestamp >> 48) & 0x0FFF)
    #uuid.ts_hi_and_ver = ((timestamp >> 48) & 0x0FFF) | (1 << 12)
    uuid
end

function build_version(uuid,ver)
    uuid.ts_hi_and_ver |= (ver << 12)
    uuid
end

function build_clock_sequence(uuid,clock_seq)
    if clock_seq == 0
        # generate a random clock sequence
        clock_seq = rand(1:((1<<14) - 1))
    end
    uuid.clock_seq_low = clock_seq & 0xFF
    uuid.clock_seq_hi_and_rsvd = ((clock_seq & 0x3F00) >> 8) | 0x80
    uuid
end

# as specified in the RFC 4.5 we can generate a random node id
# and set unicast/multicast bit to 1 (the least significant first octet
# bit)
function build_node(uuid)
    uuid.node = get_rand_narray(6)
    # set unicast/multicast bit
    uuid.node[2] |= 0x01
    uuid
end

function v1(; clock_seq = 0)
    uuid = Uuid()
    build_timestamp(uuid)
    build_version(uuid,1)
    build_clock_sequence(uuid,clock_seq)
    build_node(uuid)
    uuid
end

# version 4 is a random uuid
function v4()
    uuid = Uuid(rand(Uint32),
                rand(Uint16),
                rand(Uint16),
                rand(Uint8),
                rand(Uint8),
                get_rand_narray(6))
    build_version(uuid,4)
    uuid
end

function asString(uuid , joiner::String="")
    join([@sprintf("%08x",uuid.ts_low),
                    @sprintf("%04x",uuid.ts_mid),
                    @sprintf("%04x",uuid.ts_hi_and_ver),
                    mapreduce(s->@sprintf("%02x",s),*,
                              [uuid.clock_seq_hi_and_rsvd,
                               uuid.clock_seq_low]),
                    mapreduce(s->@sprintf("%02x",s),*,uuid.node)],joiner)
end

function toHex(uuid)
    asString(uuid)
end

function toStr(uuid)
    asString(uuid,"-")
end

function toInt(uuid)
    # TODO makes this less hacky right now
    convert(Int128,parseint(Uint128,tohex(uuid),16))
end

function bytes()
end

function parse()
end

function unparse()
end

end
