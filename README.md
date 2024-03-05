# Lab 2: I/O

In this lab, we implement a tool that lists all files in a directory and all its subdirectories.

You will learn
   * how to iterate through all files in a directory
   * how to retrieve the metadata of a file
   * how to print nicely formatted output
   * that error handling requires a significant effort
   * that string handling is not one of C's strengths
   * and a bunch of other useful programming tricks and C library functions

## Important Dates

| Date | Description |
|:---  |:--- |
| Tuesday, March 19, 18:30 | I/O Lab hand-out |
| Tuesday, March 26, 18:30 | I/O Lab session 1 |
| Tuesday, April 2, 18:30 | I/O Lab session 2 |
| Wednesday, April 3, 23:59 | Submission deadline |


## Logistics

### Hand-out

You can clone this repository directly on your VM instance or local computer and get to work. If you want to keep your own repository, you should **keep the lab's visibility to private**. Otherwise, others would see your work. Read the instructions here carefully.

#### Changing visibility

After cloning the repository, you should change the push remote URL to your own repository.
1. Create an empty repository that you're going to manage **(again, keep it private)**
2. Copy the url of that repository
3. On your terminal in the cloned directory, type `git remote set-url --push origin <repo_url>`
4. Check with `git remote -v` if the push URL has changed to yours while the fetch URL remains the same (this repo)


### Submission

You should upload your archive file(.tar) containing code (dirtree.c) and report (20XX-XXXXX.pdf) via eTL. To make an archive file, follow the example below on your own VM.
```
$ ls
2024-12345.pdf  Makefile  README.md  reference  src  tools
$ tar -cvf 2024-12345.tar src/dirtree.c 2024-12345.pdf
src/dirtree.c
2024-12345.pdf
$ file 2024-12345.tar
2024-12345.tar: POSIX tar archive (GNU)
```
To move the archive file from VM to your local computer, use either (1) shared folder or (2) scp (secure copy) command.
You can download the archive file from the VM to your local machine with the following commands, which is similar with the ssh command.

- With VirtualBox:
```sh
scp -P 8888 sysprog@localhost:<target_path> <download_path>
# example: scp -P 8888 sysprog@localhost:/home/sysporg/2024_SPRING_SYSPROG_LAB2/2024-12345.tar .
```

- With UTM:
```sh
scp sysprog@<hostname>:<target_path> <download_path>
# example: scp sysprog@192.168.4.4:/home/sysprog/2024_SPRING_SYSPROG_LAB2/2024-12345.tar .
```

| parameter | Description |
|:---  |:--- |
| hostname | ip address of VM |
| target_path | absolute path of the file you want to copy (in VM) |
| download_path | (relative) path where a file will be downloaded (in PC) |

You can get your VM's hostname using `hostname -I` command, and the absolute path of a file using `realpath <filename>` command.

#### Report Guideline

Your report should answer following questions.

1. Explain `C library call` that you used in your code.
2. Briefly describe your code including following information
   1. how to iterate through all files in a directory
   2. how to retrieve the metadata of a file
   3. how to print nicely formatted output


## Dirtree Overview

Our tool is called _dirtree_. Dirtree recursively traverses a directory tree and prints out a sorted list of all files.

```
$ dirtree demo
demo
  subdir1
    sparsefile
    thisisanextremelylongfilenameforsuchasimplisticfile
  subdir2
    brokenlink
    symboliclink
  subdir3
    pipe
    socket
  one
  two
```

Dirtree can also show details...
```
$ dirtree -v demo
demo
  subdir1                                                sysprog:sysprog         4096 rwxrwxr-x  d
    sparsefile                                           sysprog:sysprog         8192 rw-rw-r--   
    thisisanextremelylongfilenameforsuchasimplistic...   sysprog:sysprog         1000 rw-rw-r--   
  subdir2                                                sysprog:sysprog         4096 rwxrwxr-x  d
    brokenlink                                           sysprog:sysprog            8 rwxrwxrwx  l
    symboliclink                                         sysprog:sysprog            6 rwxrwxrwx  l
  subdir3                                                sysprog:sysprog         4096 rwxrwxr-x  d
    pipe                                                 sysprog:sysprog            0 rw-rw-r--  f
    socket                                               sysprog:sysprog            0 rwxrwxr-x  s
  one                                                    sysprog:sysprog            1 rw-rw-r--   
  two                                                    sysprog:sysprog            2 rw-rw-r--
```

...or a summary of a directory:
```
$ dirtree -v -s demo
Name                                                        User:Group           Size     Perms Type
----------------------------------------------------------------------------------------------------
demo
  subdir1                                                sysprog:sysprog         4096 rwxrwxr-x  d
    sparsefile                                           sysprog:sysprog         8192 rw-rw-r--   
    thisisanextremelylongfilenameforsuchasimplistic...   sysprog:sysprog         1000 rw-rw-r--   
  subdir2                                                sysprog:sysprog         4096 rwxrwxr-x  d
    brokenlink                                           sysprog:sysprog            8 rwxrwxrwx  l
    symboliclink                                         sysprog:sysprog            6 rwxrwxrwx  l
  subdir3                                                sysprog:sysprog         4096 rwxrwxr-x  d
    pipe                                                 sysprog:sysprog            0 rw-rw-r--  f
    socket                                               sysprog:sysprog            0 rwxrwxr-x  s
  one                                                    sysprog:sysprog            1 rw-rw-r--   
  two                                                    sysprog:sysprog            2 rw-rw-r--   
----------------------------------------------------------------------------------------------------
4 files, 3 directories, 2 links, 1 pipe, and 1 socket                           21497
```

If you want to print directories only, dirtree will.
```
$ dirtree -d -v -s demo
Name                                                        User:Group           Size     Perms Type
----------------------------------------------------------------------------------------------------
demo
  subdir1                                                sysprog:sysprog         4096 rwxrwxr-x  d
  subdir2                                                sysprog:sysprog         4096 rwxrwxr-x  d
  subdir3                                                sysprog:sysprog         4096 rwxrwxr-x  d
----------------------------------------------------------------------------------------------------
3 directories
```

Last but not least, dirtree can generate aggregate totals over several directories:
```
$ dirtree -v -s demo/subdir1 demo/subdir2
Name                                                        User:Group           Size     Perms Type
----------------------------------------------------------------------------------------------------
demo/subdir1
  sparsefile                                             sysprog:sysprog         8192 rw-rw-r--   
  thisisanextremelylongfilenameforsuchasimplisticfile    sysprog:sysprog         1000 rw-rw-r--   
----------------------------------------------------------------------------------------------------
2 files, 0 directories, 0 links, 0 pipes, and 0 sockets                          9192

Name                                                        User:Group           Size     Perms Type
----------------------------------------------------------------------------------------------------
demo/subdir2
  brokenlink                                             sysprog:sysprog            8 rwxrwxrwx  l
  symboliclink                                           sysprog:sysprog            6 rwxrwxrwx  l
----------------------------------------------------------------------------------------------------
0 files, 0 directories, 2 links, 0 pipes, and 0 sockets                            14

Analyzed 2 directories:
  total # of files:                       2
  total # of directories:                 0
  total # of links:                       2
  total # of pipes:                       0
  total # of sockets:                     0
  total file size:                     9206
```

## Dirtree Specification 

### Command line arguments

Dirtree accepts the following command line arguments
```
dirtree [Options] [Directories]
```

| Option      | Description |
|:----        |:----        |
| -h          | Help screen |
| -d          | Turn on directory only mode |
| -v          | Turn on detailed mode |
| -s          | Turn on summary mode |

`Directories` is a list of directories that are to be traversed. Dirtree accepts up to 64 directories.
If no directory is given, then the current directory is traversed. 

### Operation

1. Dirtree traverses each directory in the list `Directories` recursively. 
2. In each directory, it enumerates all directory entries and prints them in alphabetical order. Directories are listed before files. The special entries '.' and '..' are ignored.
3. A summary is printed after each directory. If several directories are traversed, an aggregate total is printed at the end.

### Output

As dirtree traverses the directory tree, it prints the names of the sorted entities in a directory. The names are indented according to the level of the subdirectory. For each additional level, the names are printed after two spaces to allow for easy visual identification of the directory structure.

<table>
  <tbody>
    <tr>
      <td>
        <pre>dir             <br>  subdir1<br>    subdir2<br>      file1<br>      file2<br>      file3<br>  file4</pre>
      </td>
    </tr>
  </tbody>
</table>

#### Detailed mode
In detailed mode, dirtree prints out the following additional details for each entry:
* User and group  
  Each file in Unix belongs to a user and a group. Detailed mode prints the names of the user and the group separated by a colon (:).
* Size  
  The size of the file in bytes.
* Permissions  
  The read/write/execute permissions for user owner, for group owner, and for others.
* File type  
  Indicates the type of file by a single character

  | Type | Character |
  |:---  |:---------:|
  | File | _(empty)_ |
  | Directory | d |
  | Link | l |
  | Character device | c |
  | Block device | b |
  | Fifo | f |
  | Socket | s |


#### Summary mode
In summary mode, dirtree prints a header and footer around each directory and a one-liner containing statistics about the directory.

If there are more than one directories provided on the command line, an aggregate total of all listed directories is shown.
```
$ dirtree -s demo/subdir1 demo/subdir3

Name
----------------------------------------------------------------------------------------------------
demo/subdir1
  subdir2
    file1
    link
----------------------------------------------------------------------------------------------------
1 file, 1 directory, 1 link, 0 pipes, and 0 sockets

Name
----------------------------------------------------------------------------------------------------
demo/subdir3
  file2
----------------------------------------------------------------------------------------------------
1 file, 0 directories, 0 links, 0 pipes, and 0 sockets

Analyzed 2 directories:
  total # of files:                       2
  total # of directories:                 1
  total # of links:                       1
  total # of pipes:                       0
  total # of socksets:                    0
```


#### Directory mode
In directory mode, directory typed entries are printed only.  
```
$ dirtree -d test1
test1
  a
    b
      c
        d
          e
  dir1
  dir2
  dir3
```

If summary mode is also enabled, dirtree only counts the number of directories. Any other statistics including size will not be printed in the summary line.  
```
$ dirtree -d -v -s test1
Name                                                        User:Group           Size     Perms Type
----------------------------------------------------------------------------------------------------
test1
  a                                                      sysprog:sysprog         4096 rwxrwxr-x  d
    b                                                    sysprog:sysprog         4096 rwxrwxr-x  d
      c                                                  sysprog:sysprog         4096 rwxrwxr-x  d
        d                                                sysprog:sysprog         4096 rwxrwxr-x  d
          e                                              sysprog:sysprog         4096 rwxrwxr-x  d
  dir1                                                   sysprog:sysprog         4096 rwxrwxr-x  d
  dir2                                                   sysprog:sysprog         4096 rwxrwxr-x  d
  dir3                                                   sysprog:sysprog         4096 rwxrwxr-x  d
----------------------------------------------------------------------------------------------------
8 directories
```


#### Output formatting
The output prints all elements with the correct indentation. 
In detailed mode, the output is nicely formatted and filenames that are too long are cut and end with three dots (...). 
Unless explicitly specified, you can decide for yourself whether and how you are formatting exceptional cases (error messages, etc.)

```
$ dirtree -v -s demo2
Name                                                        User:Group           Size     Perms Type
----------------------------------------------------------------------------------------------------
demo2
  subdir1                                                sysprog:sysprog         4096 rwxrwxr-x  d
    subdir2                                              sysprog:sysprog         4096 rwxrwxr-x  d
      fifo                                               sysprog:sysprog            0 rw-rw-r--  f
      link                                               sysprog:sysprog           11 rwxrwxrwx  l
      socket                                             sysprog:sysprog            0 rwxrwxr-x  s
      unreasonablyextremelylongfilenamethatdoesntfi...   sysprog:sysprog            0 rw-rw-r--   
  file4                                                  sysprog:sysprog            0 rw-rw-r--   
----------------------------------------------------------------------------------------------------
2 files, 2 directories, 1 link, 1 pipe, and 1 socket                             8203
```

The output in detailed mode consists of the following elements:

| Output element | Width | Alignment | Action on overflow |
|:---            |:-----:|:---------:|:---      |
| Path and name  | 54    | left      | cut and end with three dots |
| User name      |  8    | right     | ignore |
| Group name     |  8    | left      | ignore |
| File size      | 10    | right     | ignore |
| Permission     |  9    | right     | ignore |
| Type           |  1    |           |        |
| Summary line   | 68    | left      | limit to 68 characters |
| Total size     | 14    | right     | ignore |

The following rendering shows the output formatting in detail for each of the different elements. The two rows on top indicate the character position on a line. 
```
         1         2         3         4         5         6         7         8         9        10
1........0.........0.........0.........0.........0.........0.........0.........0.........0.........0

Name                                                        User:Group           Size     Perms Type
----------------------------------------------------------------------------------------------------
<path and name                                       >  <  user>:<group >  <    size> <  perms>  t
<path and name                                       >  <  user>:<group >  <    size> <  perms>  t
...
----------------------------------------------------------------------------------------------------
<summary                                                           >   <  total size>
```

##### Summary line
dirtree takes great care to output grammatically correct English. Zero or >=2 elements are output in plural form, while for exactly one element the singular form is used.
Compare the two summary lines:
```
0 files, 2 directories, 1 link, 1 pipe, and 1 socket

1 file, 1 directory, 2 links, 0 pipes, and 5 sockets
```

### Error handling

Errors that occur when processing a directory are reported in place of the entries of that directory:
```
$ dirtree -v /etc/cups
/etc/cups
  ...
  interfaces                                                root:lp              4096 rwxr-xr-x  d
  ppd                                                       root:lp              4096 rwxr-xr-x  d
    .keep_net-print_cups-0                                  root:root               0 rw-r--r--   
  ssl                                                       root:lp              4096 rwx------  d
    ERROR: Permission denied
  client.conf                                               root:root              31 rw-r--r--   
  ...
```
This kind of error has the message format `ERROR: <error_str>` and it should be printed after the indentation as before.


If an error occurs when retrieving the meta data of a file, the error message is printed inplace of the file's meta data:
```
$ dirtree -v -s demo3
Name                                                        User:Group           Size     Perms Type 
----------------------------------------------------------------------------------------------------
demo3
  dir1                                                   sysprog:sysprog         4096 --x------  d
    ERROR: Permission denied
  dir2                                                   sysprog:sysprog         4096 r--------  d
    file1                                               Permission denied
    file2                                               Permission denied
    file3                                               Permission denied
  dir3                                                   sysprog:sysprog         4096 rwx------  d
    file4                                                sysprog:sysprog            0 -----x---   
    file5                                                sysprog:sysprog            0 ----w----   
    file6                                                sysprog:sysprog            0 ---r-----   
----------------------------------------------------------------------------------------------------
6 files, 3 directories, 0 links, 0 pipes, and 0 sockets                         12288
```
In this case, the message starts two spaces after the `path and name` element with left alignment.

For any other errors, you can choose what to do. The reference implementation aborts on most errors:
```
$ dirtree -v /proc/self/fd
/proc/self/fd
  0                                                      sysprog:sysprog           64 rwx------  l
  1                                                      sysprog:sysprog           64 rwx------  l
  2                                                      sysprog:sysprog           64 rwx------  l
  3                                                     No such file or directory
```
```
$ dirtree -s -v demo
Name                                                        User:Group           Size     Perms Type
----------------------------------------------------------------------------------------------------
demo
  subdir1                                                arcuser:users           4096 rwxrwxr-x  d
    sparsefile                                           arcuser:users           8192 rw-rw-r--   
Out of memory.
```

## Handout Overview

The handout contains the following files and directories

| File/Directory | Description |
|:---  |:--- |
| README.md | this file | 
| Makefile | Makefile driver program |
| src/dirtree.c | Skeleton for dirtree.c. Implement your solution by editing this file. |
| reference/ | Reference implementation |
| tools/ | Tools to generate directory trees for testing |

### Reference implementation

The directory `reference` contains our reference implementation. You can use it to compare your output to ours.

### Tools

The `tools` directory contains tools to generate test directory trees to test your solution.

| File/Directory | Description |
|:---  |:--- |
| gentree.sh | Driver script to generate a test directory tree. |
| mksock     | Helper script to generate a Unix socket. |
| *.tree     | Script files describing the directory tree layout. |

Invoke `gentree.sh` with a script file to generate one of the provided test directory trees. 

**Note:** due to limitations of VirtualBox's shared folder implementation and your host OS, not all file types are supported in the shared folder. We recommand to create the test directories natively inside the VM, for example, in the `work/` directory.

Assuming you are located in the root directory of your I/O lab repository, use the follwing command to generate the `demo` directory tree
```bash
$ ls
dirtree.c  Makefile  README.md  reference  tools
$ tools/gentree.sh tools/demo.tree 
Generating tree from 'tools/demo.tree'...
Done. Generated 4 files, 2 links, 1 fifos, and 1 sockets. 0 errors reported.
```

You can list the contents of the tree with the reference implementation:
```bash
$ reference/dirtree -v -s demo/
Name                                                        User:Group           Size     Perms Type
----------------------------------------------------------------------------------------------------
demo/
  subdir1                                                sysprog:sysprog         4096 rwxrwxr-x  d
    sparsefile                                           sysprog:sysprog         8192 rw-rw-r--   
    thisisanextremelylongfilenameforsuchasimplistic...   sysprog:sysprog         1000 rw-rw-r--   
  subdir2                                                sysprog:sysprog         4096 rwxrwxr-x  d
    brokenlink                                           sysprog:sysprog            8 rwxrwxrwx  l
    symboliclink                                         sysprog:sysprog            6 rwxrwxrwx  l
  subdir3                                                sysprog:sysprog         4096 rwxrwxr-x  d
    pipe                                                 sysprog:sysprog            0 rw-rw-r--  f
    socket                                               sysprog:sysprog            0 rwxrwxr-x  s
  one                                                    sysprog:sysprog            1 rw-rw-r--   
  two                                                    sysprog:sysprog            2 rw-rw-r--   
----------------------------------------------------------------------------------------------------
4 files, 3 directories, 2 links, 1 pipe, and 1 socket                           21497
```


## Your Task

Your task is to implement dirtree according to the specification above.

### Design

In a first step, write down the logical steps of your program on a sheet of paper. We will do that together during the first lab session.

**Recommendation**: do not look at the provided code in `dirtree.c` yet! Think about the logical steps yourself. 
The design is the most difficult and important phase in any project - and also the phase that requires the most practice and sets apart hobby programmers from experts.

### Implementation

Once you have designed the outline of your implementation, you can start implementing it. We provide a skeleton file to help you get started.

The skeleton provides data structures to manage the statistics of a directory, a function to read the next entry from a directory while ignoring the '.' and '..' entries, a comparator function to sort the entries of a directory using quicksort, and full argument parsing and syntax helpers. 

You have to implement the following two parts:
1. in `main()`  
   Iterate through the list of directories stored in `directories`. For each directory, call `processDir()` with the appropriate parameters. Also, depending on the output mode, print header, footer, and statistics.
2. in `processDir()`  
   Open, enumerate, sort, and close the directory. Print elements one by one. Update statistics. If the element is a directory, call `processDir()` recursively.

### Hints

#### Skeleton code
The skeleton code is meant to help you get started. You can modify it in any way you see fit - or implement this lab completely from scratch.

#### C library calls

Knowing which library functions exist and how to use them is difficult at the beginning in every programming language. To help you get started, we provide a list of C library calls / system calls grouped by topic that you may find helpful to solve this lab. Read the man pages carefully to learn how exactly the functions operate.

<table>
  <thead>
    <tr>
      <th align="left">Topic</th>
      <th align="left">C library call</th>
      <th align="left">Description</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td rowspan="4">
        String operations
      </td>
      <td>
        <code>strcmp()</code>
      </td>
      <td>
        compare two strings
      </td>
    </tr>
    <tr>
      <td>
        <code>strncpy()</code>
      </td>
      <td>
        copy up to n characters of one string into another
      </td>
    </tr>
    <tr>
      <td>
        <code>strdup()</code>
      </td>
      <td>
        create a copy of a string. Use <code>free()</code> to free it after use
      </td>
    </tr>
    <tr>
      <td>
        <code>asprintf()</code>
      </td>
      <td>
        asprintf() is extremely helpful to print into a string and allocate memory for it at the same time.
        We will show some examples during the lab session.
      </td>
    </tr>
    <tr>
      <td rowspan="3">
        Directory management
      </td>
      <td>
        <code>opendir()</code>
      </td>
      <td>
        open a directory to enumerate its entries
      </td>
    </tr>
    <tr>
      <td>
        <code>closedir()</code>
      </td>
      <td>
        close an open directory
      </td>
    </tr>
    <tr>
      <td>
        <code>readdir()</code>
      </td>
      <td>
        read next entry from directory
      </td>
    </tr>
    <tr>
      <td rowspan="2">
        File meta data
      </td>
      <td>
        <code>stat()</code>
      </td>
      <td>
        retrieve meta data of a file, follow links
      </td>
    </tr>
    <tr>
      <td>
        <code>lstat()</code>
      </td>
      <td>
        retrieve meta data of a file, do not follow links
      </td>
    </tr>
    <tr>
      <td rowspan="2">
        User/group information
      </td>
      <td>
        <code>getpwuid()</code>
      </td>
      <td>
        retrieve user information (including their name) for a given user ID
      </td>
    </tr>
    <tr>
      <td>
        <code>getgrgid()</code>
      </td>
      <td>
        retrieve group information (including its name) for a given group ID
      </td>
    </tr>
    <tr>
      <td>
        Sorting
      </td>
      <td>
        <code>qsort()</code>
      </td>
      <td>
        quick-sort an array
      </td>
    </tr>
    <tr>
      <td>
        Error Handling
      </td>
      <td>
        <code>strerror()</code>
      </td>
      <td>
        Get string pointer for given error code. <br>
        Refer <a href="https://man7.org/linux/man-pages/man3/errno.3.html"><code>errno</code> man page</a> for detailed error code description.
      </td>
    </tr>
  </tbody>
</table>

#### Final words

This may well be your first project interacting with the C standard library and system calls. At the beginning, you may feel overwhelmed and have no idea how to approach this task. 

Do not despair - we will give detailed instructions during the lab sessions and provide individual help so that each of you can finish this lab. After completing this lab, you can call yourself a system programmer. Inexperienced still, but anyway a system programmer.

<div align="center" style="font-size: 1.75em;">

**Happy coding!**
</div>
