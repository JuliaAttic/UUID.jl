module Uuid

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

type TimestampUuid
    ts_low::Uint32
    ts_mid::Uint16
    ts_hi_and_ver::Uint16
end

type ClockSeqUuid
    clock_seq_hi_and_rsvd::Uint8
    clock_seq_low::Uint8
end

immutable UUID
    ts::TimestampUuid
    cseq::ClockSeqUuid
    node::Vector{Uint8}

    UUID(ts, cseq, node) =
         length(node) != 6 ? error("Node vector size should be 6") :
                             new(TimestampUuid(ts.ts_low,ts.ts_mid,ts.ts_hi_and_ver),
                                 ClockSeqUuid(cseq.clock_seq_hi_and_rsvd,
                                              cseq.clock_seq_low),
                                 node)
end

function build_timestamp()
    timestamp = get_timestamp()
    ts_low::Uint32 = timestamp & typemax(Uint32)
    ts_mid ::Uint16 = (timestamp >> 32) & typemax(Uint16)
    # timestamp is 60 bits so cutoff upper nibble
    ts_hi_and_ver::Uint16 = ((timestamp >> 48) & 0x0FFF)
    TimestampUuid(ts_low,ts_mid,ts_hi_and_ver)
end

function build_version(ts,ver)
    ts.ts_hi_and_ver |= (ver << 12)
    ts
end

function build_clock_sequence(clock_seq)
    if clock_seq == 0
        # generate a random clock sequence
        clock_seq = rand(1:((1<<14) - 1))
    end
    clock_seq_low::Uint8 = clock_seq & 0xFF
    clock_seq_hi_and_rsvd::Uint8 = ((clock_seq & 0x3F00) >> 8) | 0x80
    ClockSeqUuid(clock_seq_hi_and_rsvd,clock_seq_low)
end

# as specified in the RFC 4.5 we can generate a random node id
# and set unicast/multicast bit to 1 (the least significant first octet
# bit)
function build_node()
    node = get_rand_narray(6)
    # set unicast/multicast bit
    node[2] |= 0x01
    node
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

function v1(; clock_seq = 0)
    ts = build_timestamp()
    ts = build_version(ts,1)
    clock_seq = build_clock_sequence(clock_seq)
    node = build_node()
    UUID(ts, clock_seq, node)
end

# version 4 is a random uuid
function v4()
    ts = TimestampUuid(rand(Uint32),
                       rand(Uint16),
                       rand(Uint16) & 0x0FFF) # clear version
    build_version(ts,4)
    UUID(ts,
         ClockSeqUuid(rand(Uint8), rand(Uint8)),
         get_rand_narray(6))
end

function asString(uuid , joiner::String="")
    join([@sprintf("%08x",uuid.ts.ts_low),
                    @sprintf("%04x",uuid.ts.ts_mid),
                    @sprintf("%04x",uuid.ts.ts_hi_and_ver),
                    mapreduce(s->@sprintf("%02x",s),*,
                              [uuid.cseq.clock_seq_hi_and_rsvd,
                               uuid.cseq.clock_seq_low]),
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
    convert(Int128,parseint(Uint128,toHex(uuid),16))
end

function get_version(uuid)
    uuid.ts.ts_hi_and_ver & 0xF000 >> 12 |> int
end

# override default show for UUID type
import Base.show
show(io::IO, uuid::UUID) = print(io,string("UUID(\'",toStr(uuid),"\'"))

end
