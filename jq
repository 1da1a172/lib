def strip_defaults:
  walk(
    if type == "object" then (
      to_entries
      | del(.[] | select(.value._flags?.default == true))
      | from_entries
    ) else . end
  )
;

def strip_inherited:
  walk(
    if type == "object" then (
      to_entries
      | del(.[] | select(.value._flags?.inherited == true))
      | from_entries
    ) else . end
  )
;

def remove_not_present:
  walk(
    if type == "object" then (
      if ._present == false then
        ._action = "delete"
        | del(._present)
      else . end
    ) else . end
  )
;

def sort_profiles:
  walk(
    if (type == "array") and (length > 1) then (
      if  .[0] | has("profile-name") then (
        sort_by(."profile-name")
      ) elif .[0] | has("name") then (
        sort_by(.name)
      ) elif .[0] | has("accname") then (
        sort_by(.accname)
      ) elif .[0] | has("rad_server_name") then (
        sort_by(.rad_server_name)
      ) elif .[0] | has("sg_name") then (
        sort_by(.sg_name)
      ) else . end
    ) elif type == "object" then (
      if has("netdst__entry") then (
        .netdst__entry |= sort_by(.address, .host_name)
      ) elif has("netdst6__entry") then (
        .netdst6__entry |= sort_by(.address, .host_name)
      ) else . end
    ) else . end
  )
;
