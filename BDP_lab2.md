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

## Bonus: Word Length Count
```
$ sort -n -k2 result/sherlock_unique_word_length
> 18	1
21	1
17	2
16	8
15	29
1	38
14	84
2	130
13	214
12	430
3	450
11	794
10	1357
4	1375
5	1998
9	2004
8	2574
6	2725
7	2910
```
Compare to:
```
$ sort -n -k2 ../Lab1/result/local_length_part-r-00000
> 18	1
17	2
21	11
16	21
15	91
14	315
13	876
12	1943
11	3835
10	8583
9	15265
8	20169
1	31169
7	34120
6	43497
5	58079
2	101725
4	104132
3	125791
```
