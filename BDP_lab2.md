# Lab2 Result

## Commands:
```
$ hadoop fs -help
$ hadoop-moonshot fs –ls
$ hadoop-moonshot fs -ls /data
$ hadoop-moonshot fs –mkdir input
$ hadoop-moonshot fs -copyFromLocal input/sherlock.txt input
$ hadoop-moonshot fs -copyToLocal <hdfsfile> <localdestination>
$ hadoop-moonshot fs -rm -r out
$ hadoop-moonshot fs -getmerge out count.txt
```

## Compare execution between in local and cluster
If we `diff` the two logs form **local** and **remote**:
```
$ diff -u ../Lab1/logs/local logs/remote_auto
```
More information about the job:
![](result/diff_local_remote.png)

* For command `getmerge`, it just merge serval files into one file.(Compare **result/remote_auto_count** and **result/remote_auto_part-r-00000** + **result/remote_auto_part-r-00001**)

## With Big files(>128MB)
```
$ hadoop-moonshot jar dist/WordCount.jar WordCount /data/gutenberg out
$ diff -u logs/bigfile_auto logs/bigfile_4jobs
```

## Combiner
```
$ diff -u logs/bigfile_auto logs/bigfile_auto_combiner
```

## Filtered out more words
```
$ diff -u logs/bigfile_auto_combiner_only_alphabetic logs/bigfile_auto_combiner_only_alphabetic_and_space_v1
```
The way they used
```
String line = value.toString().replaceAll("[^a-zA-Z\\s]", "");
```
is not correct at all. Because,
1. Should not replace the **space**
2. Should replace by **space** not by nothing.
Should be:
```
String line = value.toString().replaceAll("[^a-zA-Z\\s]", " ");
```
But it doesn't speed up even if it contains less key than.
