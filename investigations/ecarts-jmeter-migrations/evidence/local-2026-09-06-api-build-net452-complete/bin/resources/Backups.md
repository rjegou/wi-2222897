# Test Backup Archive

This folder is intended to contain the archives of your test backups.
This repository is configured for git-lfs. Git Large File Storage (LFS) replaces large files with text pointers within Git, while storing the file content on a remote server such as GitHub.com or GitHub Enterprise.

## Prerequisite

### Install and configure git-lfs

If you already have git installed, [Download and install Git LFS](https://git-lfs.github.com/).
Otherwise [Download and install Git](https://git-scm.com) and select `GIT LFS` during the component selection.

### Initialize git-lfs for your repo

Git LFS must be installed, and the HTTP headers must be set to 1.1 instead of 2.
Configure git-lfs to download the large file pointers instead of the files themselves.

```cmd
git config http.version HTTP/1.1
git lfs install --skip-smudge
```

Already done - Select the types of files you want Git LFS to handle: here *.bak for SQL Server database backups.

```cmd
git lfs track "Tests\backups\*.bak"
git commit -m "init git-lfs for test backup files"
```

### Archive backups

Add the necessary backup(s) for tests to the `.\Tests\Backups`folder. 
Archive the changes :

```cmd
git commit -m "add backup files"
```

### Push your changes to the server

To push the backups, you need to switch to HTTP/1.1, then push your changes, and finally switch back to HTTP/2.

```cmd
git config --global http.version HTTP/1.1
git push 
git config --global http.version HTTP/2
```

Once pushed, the server will store the .bak outside of the git repository, and create a file with the same name that is just a pointer. Now, when you clone your repository, you only retrieve the file pointers.
Example:

```txt
version https://git-lfs.github.com/spec/v1
oid sha256:81cd2e6cd215d7682c5ed9b36b9a1403f8045a52ee334301b9aa408528bf66d4
size 1828909056
```

## Retrieve a backup file locally

List the LFS files in the repository:

```cmd
git lfs ls-files
```

If you want all the LFS files:

```cmd
git lfs pull
```

To target a specific LFS file:

```cmd
git lfs pull --include "Tests/Backups/AUTO_V25_00.bak"
```
