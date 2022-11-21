def strip_defaults:
  walk(
    if type == "object" then (
      to_entries
      | del(.[] | select(.value._flags?.default == true))
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
