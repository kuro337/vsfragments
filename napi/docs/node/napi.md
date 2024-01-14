# napi

```c
// This is the core C addon
#include <node_api.h>

// This is the c++ addon (wrapper to node_api.h)
#include "napi.h"
```

- To have syntax highlighting find the system Node location which should have headers for `v8` and `napi`

```bash
# Finding Node headers on system

# path of node
brew --prefix node

# node headers
ls $(brew --prefix node)/include/node
ls /opt/homebrew/opt/node/include/node/node_api.h
```

- Create a `.clangd` file at root pointing to the headers

```yaml
CompileFlags:
  Add:
    - "--include-directory=/opt/homebrew/opt/node/include/node"
    - "--include-directory=src/native/c"
```

- Make sure the Extension has the `--enable-config` enabled for Arguments
