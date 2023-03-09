
# Filters an item from an array
# Usage:
#  > fish_completion_filter_from_array bar foo bar baz
#  > foo baz
function fish_completion_sync_filter
  set -l item $argv[1]
  set -e argv[1]
  set -l array $argv
  for array_item in $array
    if [ $array_item != $item ]
      echo $array_item
    end
  end
end

function fish_completion_sync_add_comp
  set -l array $argv
  for array_item in $array
    echo "$array_item/fish/vendor_completions.d"
  end
end

set -g FISH_COMPLETION_ADDITIONS

function fish_completion_sync --on-variable XDG_DATA_DIRS
  set -l FISH_COMPLETION_DATA_DIRS (fish_completion_sync_add_comp (fish_completion_sync_filter "" (string split ":" $XDG_DATA_DIRS)))
  # If there are paths in $FISH_COMPLETION_ADDITIONS,
  # but not in $XDG_DATA_DIRS
  #   remove them from $fish_complete_path
  #   remove them from $FISH_COMPLETION_ADDITIONS
  for addition in $FISH_COMPLETION_ADDITIONS
    # test if addition is in xdg_data_dirs
    if not contains $addition $FISH_COMPLETION_DATA_DIRS
      set fish_complete_path (fish_completion_sync_filter $addition $fish_complete_path)
      set FISH_COMPLETION_ADDITIONS (fish_completion_sync_filter $addition $FISH_COMPLETION_ADDITIONS)
    end
  end

  # if there are paths in $XDG_DATA_DIRS
  # but not in $FISH_COMPLETION_ADDITIONS
  #   add them to $fish_complete_path
  #   add them to $FISH_COMPLETION_ADDITIONS
  for data_dir in $FISH_COMPLETION_DATA_DIRS
    if not contains $data_dir $FISH_COMPLETION_ADDITIONS
      set -a fish_complete_path $data_dir
      set -a FISH_COMPLETION_ADDITIONS $data_dir
    end
  end
end