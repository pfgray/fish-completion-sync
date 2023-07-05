# fish-completion-sync

A fish plugin to help dynamically load fish completions from `$XDG_DATA_DIRS`.

## Installation

### home-manager

```nix
{
  programs.fish = {
    # ...
    plugins = [
      #...
      {
        name = "fish-completion-sync";
        src = pkgs.fetchFromGitHub {
          owner = "pfgray";
          repo = "fish-completion-sync";
          rev = "483145eb997c47dd8b16f193dd0b927d76ec122c";
          sha256 = "sha256-MnrDegGc3kmnfL021JZWRLR8iaYYwwoy0FpUSP7AeVA=";
        };
      }
    ];
  };
}
```

### fisher
```
fisher install pfgray/fish-completion-sync
```

## Why

Fish only considers `$XDG_DATA_DIRS` on shell startup, and thus will not dynamically load completions if `$XDG_DATA_DIRS` changes sometime after the shell starts. This leads to problems when using tools like [direnv](https://github.com/direnv/direnv), which try to add completions on a per-folder basis.

This plugin tries to alleviate this issue.

tl;dr; it's the bit of glue between:
https://github.com/fish-shell/fish-shell/issues/8261
and:
https://github.com/direnv/direnv/issues/443

## How it works

Fish _will_ search `$fish_complete_path` dynamically, so the idea is to implement a function which listens for changes to `$XDG_DATA_DIRS`, and attempts to keep that in sync with `$fish_complete_path`.

```
function fish_completion_sync --on-variable XDG_DATA_DIRS
   
  # If there are paths in $FISH_COMPLETION_ADDITIONS,
  # but not in $XDG_DATA_DIRS
  #   remove them from $fish_complete_path
  #   remove them from $FISH_COMPLETION_ADDITIONS

  # if there are paths in $XDG_DATA_DIRS
  # but not in $FISH_COMPLETION_ADDITIONS
  #   add them to $fish_complete_path
  #   add them to $FISH_COMPLETION_ADDITIONS

  echo "got new data dirs: $XDG_DATA_DIRS"
end
```

### Caveats

This has been working well for me, but it's stopped working a few times, and I haven't been able to pinpoint why. If you experience this, you can set the environment variable `FISH_COMPLETION_DEBUG` to help debug:

```fish
set -x FISH_COMPLETION_DEBUG 1
```

Submit an issue if the problem persists.