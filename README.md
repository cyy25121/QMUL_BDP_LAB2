# Lab2, Hadoop & HDFS
October 14th 2016

The objectives of this session are:
* Run jobs in a Hadoop Cluster
* Understand how to access the HDFS to handle input and output of Hadoop cluster jobs
* Use a Combiner to reduce the amount of network traffic originated by a Map/Reduce job

## INTRODUCTION
The instructions contained in this sheet as well as the attached configuration files assume that you are working in the ITL in Linux mode. If you wish to go through this lab sheet in another setup you will have to download and setup Hadoop in your machine, and update all the relevant paths to match the configuration of your computer.
### HDFS
This first part of the lab session will show you how you can interact with the HDFS that is deployed in the QMUL Hadoop cluster.
HDFS interaction must be done through command line, by invoking commands in the shape of ***hadoop-moonshot fs -<command>*** options
You will be introduced to the essential HDFS commands that you need to interact with the filesystem, but you can check the complete list of commands by invoking ***hadoop fs -help***

First, let’s have a look at what is currently available in the QMUL HDFS:

You can browse the contents of a remote folder through the ***hadoop-moonshot fs –ls*** command, which is similar to the Unix listing command.

You should only worry about two folders of the filesystem.
The /data folder is the destination for large datasets to be processed.  You can have a look at it by invoking the following command: (There should be some files, including a 35 GB Wikipedia dump
```
hadoop-moonshot fs -ls /data
```
Also, there is a folder created for personal use of each student. You can look at your personal folder (should be empty) by changing the path to:
```
hadoop-moonshot fs -ls
```
Your folder is stored in the ***/user/<userid>*** folder of the HDFS, where your userid will be similar to ec09999, or abc123
The ITL Hadoop cluster will be shared by all students of Big Data Processing, so it is very important that you use it responsibly.

**YOU CANNOT WRITE IN ANY FOLDER THAT IS NOT YOUR PERSONAL FOLDER**
**IF YOU WANT TO COPY FILES INTO THE HDFS, COPY THEM INTO A SUBFOLDER OF YOUR USER FOLDER**

## WORDCOUNT EXECUTION IN THE HADOOP CLUSTER

We will now perform the required steps to run the WordCount program we created last week in our Hadoop cluster. However, we will first use the small input dataset that we used last week.
First, we need to create a folder in our HDFS personal space to store the input data. That operation can be solved with the –mkdir option:
```
hadoop-moonshot fs –mkdir input
```
If you browse now the contents of your folder you should see the newly created folder.
```
hadoop-moonshot fs -ls
```
Now, let’s copy the text file to the HDFS. File transfer from a local filesystem to Hadoop is perform using the –copyFromLocal command:
```
hadoop-moonshot fs -copyFromLocal input/sherlock.txt input
```
If you now check the contents of the input folder in HDFS you should see the file
```
hadoop-moonshot fs –ls input
```
Once your data is copied into HDFS, you can run your previously defined MapReduce job there now. If you remove the -–config option from the previous command, you will use default Hadoop configuration, which in the ITL equals to using the full cluster.  Also, keep in mind that input and output paths will be resolved into the HDFS instead of the local file system on the computer you are using.
```
hadoop-moonshot jar dist/WordCount.jar WordCount input out
```
You should see the usual Hadoop log if the paths you have provided for the input and jar file are correct. Finally, once the process is complete copy the results file back to your local filesystem by using the fs –copyToLocal option. Remember that Reducer#1 output is provided in a file called part-00000
```
hadoop-moonshot fs –copyToLocal <hdfsfile> <localdestination>
```
After retrieving the output you can remove the output folder through the –rmr fs command. If the designated output folder was out, you can remove it by doing:
```
hadoop-moonshot fs –rm -r out
```
How many Mappers and Reducers have been involved in the work?
You can change the number of Reducers that get involved in the job by manually configuring it as part of the job configuration (WordCount.java). Try to add this line to the runJob method of WordCount
```
job.setNumReduceTasks(3);
```
Repackage the Hadoop program using Ant, and run it again on the cluster. There should be now more part-0000x files in the output folder (one per reducer). Have a look at those files (you can either copy them to your local folder, or quickly dump their contents using the `hadoop fs –cat` command.  
Can you see a clear pattern on how Hadoop partitions the keys among multiple reducers? Does it make easier or harder now the problem of manually retrieving information about a specific key? E.g. How many times the word Sherlock appears in the text?
Actually Hadoop has a very useful HDFS command that retrieves all files from a remote folder and merges them into a single file in the local file system on the computer you are using.. In order to locally aggregate all three files invoke the following command:
```
hadoop-moonshot fs -getmerge out count.txt
```
We are going to use now a larger dataset in order to take advantage of the cluster. We will use the folder **/data/gutenberg** where a larger dataset is already loaded. This folder contains a prepacked file with multiple books downloaded from project Gutenberg, written in different languages.
Invoke again the MapReduce job, this time setting the input path to
```
/data/gutenberg
```
 This is going to take a bit more to execute, as you are processing a file of size 400MB.
You can obtain realtime information about the progress of your job by going to the web ui of the hadoop cluster
```
http://studoop:8088
```
You will see a list of running and complete jobs. Find your running job (the console will have displayed your job ID after the job started running) and click in the link of your specific job to access the details page with its current execution status. You can also access that link through the link that is shown in the console output when the job is accepted in the cluster.
Once the job finishes have a look at the output results provided by Hadoop (either through the job information web page, or through the output emitted by Hadoop in the console). There is a total of 24 base metrics providing details on how the parallel process went.
* How many Map tasks does your MapReduce job have? Can you explain the difference with the Sherlock job? How many are actually local mappers (i.e. they are initially collocated with the data they have to process)? How many Reduce tasks?

## ADDING A COMBINER
In this case it should be possible to significantly improve the overall MapReduce performance by adding a Combiner to the process. Add a Combiner to the Hadoop job by adding to the JobConf the following line:
```
job.setCombinerClass(NameOfTheCombiner.class);
```
 So we now have
 ```
job.setMapperClass(TokenizerMapper.class);
job.setCombinerClass(IntSumReducer.class);
job.setReducerClass(IntSumReducer.class);
```

in the **WordCount.java** file.
Repackage the Hadoop program again (`ant clean dist`) and repeat the Hadoop execution over the same data.
Have you seen a noticeable improvement in performance? You can go to the web UI and retrieve the total execution time of both jobs in order to compare it.
In order to understand why it has improved, have a look at the Map output records, Combine input records, Combine output records and Reduce input records. Can you see the impact that defining a Combiner has with large jobs?
Finally, have a look at the results of your process. Can you improve the quality of your word counting program by detecting in your StringTokenizer filter some of the characters that appear at the start of the file? There are quite a few symbols which haven't been filtered out with the base filter. However, this approach needs to specify every single special character. Instead, you can run a regexp before splitting the file, in order to eliminate all non-alphabetic characters: `String line = value.toString().replaceAll("[^a-zA-Z\\s]", "");`

## Word Length Count in Hadoop

Let’s do now a different MapReduce exercise over the same dataset to further practice how to structure MapReduce jobs, and process data using this paradigm.

Let’s find out now, for each word length, how many **unique** words appear in our text corpora for each word size. This way, our desired output is a set of keys in the form:
```
1: 20
2: 300
3: 50000
…

99:1
```
With the first line implying that there are in total 20 **different** words of length one over all the input data, and so on. That is, the 5600 instances of the word ‘the’ will only count once for “3” words.
In order to do that, you will need to run two MapReduce jobs consecutively over the initial dataset.  There is no way to solve this problem by running only one mapreduce job.
We provide you here a potential solution where we start from the output of the WordCount job, and define a second job which processes that output as the intermediate but feel free to devise other potential solutions to implement this task. The one suggested here will work because in the output of the wordcount job we know each work appears exactly once.
Create a NEW folder for your project (you can copy the wordcount project structure). If you prefer you can also add these elements to the existing structure in word count.
 You will need to create the three following classes (the code from the wordcount project will be very useful to completing this exercise):
* Mapper (TokenToLengthMapper). Receives Object, Text emits IntWritable, IntWritable intermediate records, with the emitted key being the length of the received key, and the value being one. As it is using the default input format, the initial value will have a text containing a full line of text. You can extract either the key or the value generated by the previous job through Text.toString().split("\t")
* Reducer/ Combiner (IntIntSumReducer): Receives the intermediate keys  IntWritable, IntWritable, and outputs final keys IntWritable, IntWritable, with the key being the same key that was received, and the value the sum of values.
* Main class(WordLengthCount): Sets up Mapper and Reducer, configures the job.

You should use a Combiner in this job in order to greatly improve the performance.
Package your new project using Ant. You can edit the build.xml file to change the project name as well as the name of the generated jar to avoid further confusion.
Run the job. Keep in mind that you will specify the output folder of the previous job as the input folder for this one, and a new output folder as the final output results. The hadoop jar command needs to specify the name of the jar file as well as the name of the main class (now WordLengthCount).
What is the most common word length? Keep in mind that unless you have taken care to filter out some additional symbols, your data will be not so useful. Also, having input from different languages greatly complicates coming with definite conclusions.
