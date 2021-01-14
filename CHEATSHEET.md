https://github.com/commitizen/cz-cli
https://repo1.dso.mil/platform-one/big-bang/charter/-/blob/master/DevCIWorkflow.md
https://www.conventionalcommits.org/en/v1.0.0/
https://commitlint.js.org/#/
https://github.com/conventional-changelog/commitlint
https://repo1.dso.mil/platform-one/big-bang/umbrella/-/merge_requests/146

# Squash quick tip
```
git checkout workflow-example
git reset $(git merge-base master $(git rev-parse --abbrev-ref HEAD))
git add -A
git commit -m "feat: example squashed conventional commit"
git push --force
```

# Husky usage
```
npm install --only=dev
```

# Commitizen usage
```
npm install -g commitizen
git cz
```

```
git log --graph --decorate --pretty=oneline --abbrev-commit
git rebase -i
```