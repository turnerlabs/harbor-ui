# MSS Harbor

A portal for creating and viewing Shipments. This UI creates a simple wrapper around the 
Harbor infrastructure. All harbor APIs are used in collaboration together to provide a
cohesive environment for altering and maintaining application state.


## Contributing

This project uses [git flow][flow] to manage development cycle. Please branch off of `develop`, do PR's back into `develop`. 

When making a release, use the provided `version-bump` script on a release branch.

```bash
# Example workflow
$ git checkout develop
$ git checkout -b new-feature
# Hack away
$ git commit -a -m "comment about feature"
$ git checkout develop
$ git merge --no-ff new-feature

# Create release, x.y.z will be your new version conforming to SemVer
$ git checkout develop
$ git checkout -b release-x.y.z
$ ./version-bump
# This will allow you to put in the new version and commit it
# now finish up release

$ git checkout master
$ git merge --no-ff release-x.y.z
$ git tag x.y.z
$ git checkout develop
$ git merge --no-ff releaes-x.y.z
$ git branch -d releaes-x.y.z
```



[flow]: http://nvie.com/posts/a-successful-git-branching-model/
