# sentinel-go-ebpf-plugin

This is an exploratory project. The purpose is to use the function of ebpf to implement some features such as sentinel traffic limit. The project is still being explored.

# Requirements
Linux >= 4.9.

# Example

use `go generate` to compile the code.

```go
$ make -C ../
```

Then 

```go
$ go run -exec sudo ./ebpf
```

Output as below:

```go
2022/10/31 16:27:45 Comm             Src addr        Port   -> Dest addr       Port  
2022/10/31 16:27:54 google_guest_ag 10.182.0.2      55146  -> 74.125.137.95   443   
2022/10/31 16:28:11 google_osconfig 10.182.0.2      35330  -> 74.125.137.95   443   
2022/10/31 16:31:54 google_guest_ag 10.182.0.2      38566  -> 142.251.2.95    443   
2022/10/31 16:32:11 google_osconfig 10.182.0.2      59934  -> 142.251.2.95    443   
2022/10/31 16:35:54 google_guest_ag 10.182.0.2      54706  -> 142.251.2.95    443   
2022/10/31 16:36:11 google_osconfig 10.182.0.2      39752  -> 142.251.2.95    443   
2022/10/31 16:39:54 google_guest_ag 10.182.0.2      42938  -> 142.250.141.95  443   
2022/10/31 16:40:11 google_osconfig 10.182.0.2      52648  -> 142.250.141.95  443
```


# Waht we can get

```go
/* user accessible mirror of in-kernel sk_buff.
 * new fields can only be added to the end of this structure
 */
struct __sk_buff {
	__u32 len;
	__u32 pkt_type;
	__u32 mark;
	__u32 queue_mapping;
	__u32 protocol;
	__u32 vlan_present;
	__u32 vlan_tci;
	__u32 vlan_proto;
	__u32 priority;
	__u32 ingress_ifindex;
	__u32 ifindex;
	__u32 tc_index;
	__u32 cb[5];
	__u32 hash;
	__u32 tc_classid;
	__u32 data;
	__u32 data_end;
	__u32 napi_id;

	/* Accessed by BPF_PROG_TYPE_sk_skb types from here to ... */
	__u32 family;
	__u32 remote_ip4;	/* Stored in network byte order */
	__u32 local_ip4;	/* Stored in network byte order */
	__u32 remote_ip6[4];	/* Stored in network byte order */
	__u32 local_ip6[4];	/* Stored in network byte order */
	__u32 remote_port;	/* Stored in network byte order */
	__u32 local_port;	/* stored in host byte order */
	/* ... here. */

	__u32 data_meta;
	__bpf_md_ptr(struct bpf_flow_keys *, flow_keys);
	__u64 tstamp;
	__u32 wire_len;
	__u32 gso_segs;
	__bpf_md_ptr(struct bpf_sock *, sk);
	__u32 gso_size;
};
```

Some tcp header information: 

```go
	__u32 remote_ip4;	/* Stored in network byte order */
	__u32 local_ip4;	/* Stored in network byte order */
	__u32 remote_ip6[4];	/* Stored in network byte order */
	__u32 local_ip6[4];	/* Stored in network byte order */
	__u32 remote_port;	/* Stored in network byte order */
	__u32 local_port;	/* stored in host byte order */
```

data\_meta store the meta data. 
data is the pointer to the begin of data.
data_end is the pointer to the end of data.

Using the data pointer, the starting point of each tcp data can be found. But if you want to get the entire http package, you need to get multiple tcp packages, which is more difficult. 

# To continue research
- use kprobe bpf to hook system call of application process
- use uprobe bpf to hook entire http package


# License
MIT

