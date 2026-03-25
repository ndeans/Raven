

## 01 : To Pierre - On boarding

I am a retired software engineer currently working on a passion project called Raven, which does two things... It serves as a functioning model of the kind of technology I most recently worked with professionally in 2023. And it also serves as a "conversation base" by extracting conversations from an anonymous political discussion site and allowing for various queries against that data to find patterns of interest. 

An an AI agent, you are filling in a role that my project (Raven) refers to as Pierre. Pierre acts like a consultant.

The other AI agent is referred to as Larry and is currently running in Antigravity using Gemini 3 as the LLM.

Please read "../Raven/docs/Raven Project Initiator.md" for context. And let me know if you understand.


## 02: To Pierre - Antigravity Questions

Larry just made some change to the Raven_Processor and the Raven_Jobs projects to implement Operation M1. Then he ran a build and execute. The log shows errors.

Questions:
#1 - Since Operation M1 requires changes to two projects... Larry needs to be able to switch project directories without loosing context. How can I make that happen?
#2 - How can I get Larry to read the logs so he can catch the errors?


### 03: To Larry - On boarding

I am a retired software engineer currently working on a passion project called Raven, which serves as a "conversation-base" by extracting conversations from an anonymous political discussion site and allowing for various queries against that data to find patterns of interest. 
	
You are the Antigravity agent that fills a role in my Raven project that I refer to as Larry. 
Your working directory is ~/Projects. You will be working with three projects under this root.

~/Projects
  |-- Raven
  |     |-- docs
  |-- java_projects
    |-- Raven-Processor
    |-- Raven-Jobs

*Raven/docs* is for documentation relevant to ALL Raven projects
*java_projects/Raven-Processor* and *java_projects/Raven-Jobs* are the java projects you will be working on. All file references should be use paths relative to the ~Projects root.

Please read ../Raven/docs/Raven Project Initiator.md for context and get updates from Raven/docs/_review.md

### 04: To Larry - Operation M1 Shell Script

I want you to write a bash script to run operation M1. I don't want to use Maven for this. I'd rather use the jar and call it from a shell script.

- Copy the Raven-Jobs.jar file to the new "Raven/bin" directory.
- In that same directory, write a bash script that will call the main function in the Raven-Job.jar.
*Note - this will eventually be a parameterized function call,to allow for more maintenance jobs.*
- add a job to the crontab that calls the script at 6:00 every morning.
- append what you did and how it works to the "Operation M1.md" document.



