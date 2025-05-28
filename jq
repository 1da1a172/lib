def s_to_ms:
  . * 100000 | round | . / 100
;

def ipv4_sorter:
    (. / ".")[] | tonumber
;

def ipv6_sorter:
    (. / ":")[] | length, .
;

# just sanity checks, please only pass valid network addresses
def is_ipv4: test("[0-9]{1,3}(\\.[0-9]{1,3}){3}"; "s") ;
def is_ipv6: test(":.*:") ;

def ip_sorter:
    if is_ipv4 then (
        4,
        ipv4_sorter
    ) elif is_ipv6 then (
        6,
        ipv6_sorter
    ) else (
        0,
        .
    ) end
;

# helpers for .ntp_server_info
def typed_ip_sortable:
    has("ip_type") and (has("ip") or has("ip6"))
;

def typed_ip_sorter:
    .ip_type,
    if has("ip") then ( .ip | ipv4_sorter ) else null end,
    if has("ip6") then ( .ip6 | ipv6_sorter ) else null end,
    .
;

# common actions
def strip_defaults:
    walk(
        if type == "object" then (
            to_entries
            | del(.[] | select(.value._flags?.default == true))
            | from_entries
        ) end
    )
;

def strip_inherited:
    walk(
        if type == "object" then (
            to_entries
            | del(.[] | select(.value._flags?.inherited == true))
            | from_entries
        ) end
    )
;

def strip_flags:
    walk(
        if type == "object" then (
            del(._flags)
        ) end
    )
;

def remove_not_present:
    walk(
        if type == "object" then (
            if ._present == false then (
                ._action = "delete"
                | del(._present)
            ) end
        ) end
    )
;

def prof(p):
    select(."profile-name" == p)
;

def has_prof(p):
    if . == null then (
        false
    ) else (
      map(."profile-name" == p) | any
    ) end
;

def del_prof:
    {
        "profile-name",
        "_action": "delete"
    }
;

# unsafe keys:
# - name: .server_group_prof[].auth_server
# - action: .acl_sess[].acl_sess__v{4,6}policy
# - dany
# - dst
# - permit
# - sany
# - service-any
# - service_app
# - src
# - svc
def sort_profiles:
    walk(
        if (type == "array") and (length > 1) then (
            # safe to sort in EVERY array
            if all(has("profile-name")) then (
                # common
                sort_by(."profile-name")
            ) elif all(has("rfc3576_server")) then (
                # .aaa_prof[].rfc3576_client
                sort_by(.rfc3576_server | ip_sorter)
            ) elif all(has("accname")) then (
                # .acl_sess
                sort_by(.accname)
            ) elif all(has("ip")) then (
                # .cluster_prof[].cluster_controller (and sometimes .ntp_server_info)
                sort_by(.ip | ipv4_sorter)
            ) elif all(has("ipv6")) then (
                # .cluster_prof[].cluster_controller_v6
                sort_by(.ipv6 | ipv6_sorter)
            ) elif all(has("cert_type") and has("name")) then (
                # .crypto_local_pki_cert
                sort_by(.cert_type, .name)
            ) elif all(has("username")) then (
                # .mgmt_user_cfg_int
                sort_by(.username)
            ) elif all(has("dstname")) then (
                # .netdst, .netdst6
                sort_by(.dstname)
            ) elif all(typed_ip_sortable) then (
                # .ntp_server_info
                sort_by(typed_ip_sorter)
            ) elif all(has("rad_server_name")) then (
                # .rad_server
                sort_by(.rad_server_name)
            ) elif all(has("server_ip")) then (
                # .rfc3576_client_prof[]
                sort_by(.server_ip | ip_sorter)
            ) elif all(has("rname")) then (
                # .role
                sort_by(.rname)
            ) elif all(has("sg_name")) then (
                # .server_group_prof
                sort_by(.sg_name)
            ) elif all(has("ipAddress")) then (
                # .snmp_ser_host_snmpv3
                sort_by(.ipAddress | ip_sorter)
            ) elif all(has("_objname")) then (
                # .netdst[].netdst__entry; netdst6[].netdst6__entry
                sort_by(
                    ._objname,
                    if ._objname == "netdst__host" then (
                        .address | ipv4_sorter
                    ) elif ._objname == "netdst6__host" then (
                        .address | ipv6_sorter
                    ) elif ._objname == "netdst__name" or .objname == "netdst6__name" then (
                        .host_name
                    ) elif ._objname == "netdst__network" then (
                        (.address | ipv4_sorter),
                        (.netmask | ipv4_sorter)
                    ) elif ._objname == "netdst6__network" then (
                        .sip6net | ipv6_sorter
                    ) end
                )
            ) end
        ) elif type == "object" then (
            # keys that are used elsewhere in an order senitive array
            ## objects that may have more than thing that needs sorted (e.g., top object)
            if has("cp_bwc") then (
                # top
                .cp_bwc |= sort_by(.name)
            ) end
            | if has("crypto_local_pki_rcp") then (
                # top
                .crypto_local_pki_rcp |= sort_by(.name)
            ) end
            | if has("netsvc") then (
                # top
                .netsvc |= sort_by(.name)
            ) end
            | if has("radius_attr") then (
                # top
                .radius_attr |= sort_by(.name)
            ) end
            | if has("snmp_ser_trap_enable") then (
                # top
                .snmp_ser_trap_enable |= sort_by(.name)
            ) end
            | if has("snmp_ser_user") then (
                # top
                .snmp_ser_user |= sort_by(.name)
            ) end
            | if has("time_range_per") then (
                # top
                .time_range_per |= sort_by(.name)
            ) end
            | if has("vlan_name") then (
                # top
                .vlan_name |= sort_by(.name)
            ) end
            | if has("vlan_name_id") then (
                # top
                .vlan_name_id |= sort_by(.name)
            ) end
            ## mutually exclusive arrays
            #| if has("foo") then (
            #    # .bat[]
            #    .foo |= sort_by(.name)
            #) elif has("bar") then (
            #    # .baz[]
            #    .bar |= sort_by(.name)
            #) end
        ) end
    )
;
# TODO:
# - .time_range_per[].time_range_per__day[].
# - .time_range_per[].time_range_per__week[].
# Consider looping for stuff sorted by .name
