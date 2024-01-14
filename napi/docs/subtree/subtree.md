# Subtrees

- Nesting a repo within a repo

- Creating a new folder which is a repo in an existing repo

```bash
cd vsfragments
# --prefix <folder> from root adds the folder as a subtree repo

# Create repo in github and add as remote
git remote add vsfragments_node https://github.com/kuro337/vsfragments_node.git

# Add the subtree
git subtree add --prefix napi vsfragments_node main

# To pull updates from the subtree repository
git subtree pull --prefix napi vsfragments_node main

# To push updates to the subtree repository
git subtree push --prefix napi vsfragments_node main


```
