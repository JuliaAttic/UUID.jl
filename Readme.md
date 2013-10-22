# Uuid.jl


## Brief overview

A universally unique identifier (**UUID**) is an identifier standard, as specified by [RFC 4122](http://www.ietf.org/rfc/rfc4122.txt). UUIDs are 128 bits long, and require no central registration process.

Currently, the library generates version 1 and version 4 UUIDs.

### Usage


	julia> using Uuid
	
	julia> u1 = Uuid.v1() # generate a version 1 uuid
	UUID('c9308c72-3936-11e3-b3d1-305bfaa14fd3')
	julia> Uuid.get_version(u1) # get uuid version number
	1
	julia> Uuid.toStr(u1) # the canonical representation
	"c9308c72-3936-11e3-b3d1-305bfaa14fd3"
  	julia> Uuid.toHex(u1) # display as hex
	"c9308c72393611e3b3d1305bfaa14fd3"
	
	
	julia> u4 = Uuid.v4() # generate a version 4 uuid
	UUID('64885014-0f58-4a40-82df-b241dd1fd000')
	julia> Uuid.get_version(u4)
	4
	julia> Uuid.toInt(u4) # display as an integer
	133630576133332877531369589789882830848
	julia> typeof(ans)
	Int128
	


### Notes
Currently, the node id is implemented using section 4.5 of the RFC.

### Todo
- version 3 (using MD5 hash) and version 5 (using SHA-1 hash).

##### Questions
Feel free to submit any pull requests or issues. Originally authored by Bassem Youssef, byoussef@forio.com.