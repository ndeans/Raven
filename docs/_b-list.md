## Formatting of docs in underscore-files.

I noticed that the output from Larry (Antigravity agent) looks much nicer in the Antigravity application than it does in the markdown files included in the project. 

This is not a critical issue but it's kind of an irritant. The following is an example... After onboarding Larry at the start of a session, I requested an analysis of the cost of that onboarding process. Larry complied by offering the stats within Antigravity, that looks like this...

### Original rendered in Antigravity.
---

![alt text](image.png)

---
I responded with this...

*Please Add that cost analysis as you formatted to section ### Larry - Onboarding Cost Analysis 2026-03-17 in the _review.md file.*

### First write to _review.md file
---
The onboarding process was quite efficient. Here is a breakdown of the "cost" in terms of operations and estimated data processed during my initialization as Larry:

Operational Summary
Total Tool Calls: 20
Directory/File Discovery: 6 calls (list_dir, find_by_name)
Documentation & Code Reads: 5 files (Totaling ~515 lines of code/markdown)
Task/Artifact Management: 8 calls (Setting up and updating 
task.md
 and UI state)
Communication: 1 call (notify_user)
Data & Token Estimates
While I don't have access to the exact sub-cent token billing, I can estimate the volume of data retrieved:

Activity	Details	Estimated Volume
Documentation Reads	
Initiator.md
, 
_review.md
~10.5 KB (~3k tokens)
Code Analysis	
Maria_DAO
, 
MongoDao
, 
PruneJob
~10.8 KB (~3k tokens)
Context Overhead	System prompts, tool definitions, directory listings	~15-20k tokens*
Total Input Processed	Includes full conversation history	~25k - 30k tokens
*Context overhead is common for agentic workflows to ensure I understand the tools and project constraints perfectly.

Files Analyzed
Raven Project Initiator.md
 (195 lines)
_review.md
 (35 lines)
Maria_DAO.java
 (127 lines)
MongoDao.java
 (100 lines)
PruneJob.java
 (58 lines)
I am now fully cached and context-aware, ready to jump into implementation!

---
My response... "*hmm... OK, that works but the formatting in your initial analysis is better. I like the icons. :)*"

Larry responded with...

*I've updated _review.md to use the initial, more stylized formatting with bolded headers and specific bullet points. I agree—the extra formatting makes the summary much easier to scan! 
View the reformatted _review.md

But when I did that, this is what I found...

### second write to _review.md
---
#### **Operational Summary**

* **Total Tool Calls**: 20

* **Directory/File Discovery**: 6 calls (`list_dir`, `find_by_name`)

* **Documentation & Code Reads**: 5 files (Totaling ~515 lines of code/markdown)

* **Task/Artifact Management**: 8 calls (Setting up and updating `task.md` and UI state)

* **Communication**: 1 call (`notify_user`)

  

#### **Data & Token Estimates**

| Activity | Details | Estimated Volume |

| :--- | :--- | :--- |

| **Documentation Reads** | `Initiator.md`, `_review.md` | ~10.5 KB (~3k tokens) |

| **Code Analysis** | `Maria_DAO`, `MongoDao`, `PruneJob` | ~10.8 KB (~3k tokens) |

| **Context Overhead** | System prompts, tool definitions, directory listings | ~15-20k tokens* |

| **Total Input Processed** | Includes full conversation history | **~25k - 30k tokens** |

  

*\*Context overhead is common for agentic workflows to ensure I understand the tools and project constraints perfectly.*


#### **Files Analyzed**

1. **[Raven Project Initiator.md](file:///home/ndeans/Projects/Raven/docs/Raven%20Project%20Initiator.md)** (195 lines)

2. **[_review.md](file:///home/ndeans/Projects/Raven/docs/_review.md)** (35 lines)

3. **[Maria_DAO.java](file:///home/ndeans/Projects/java_projects/Raven-Processor/src/main/java/us/deans/raven/processor/Maria_DAO.java)** (127 lines)

4. **[MongoDao.java](file:///home/ndeans/Projects/java_projects/Raven-Processor/src/main/java/us/deans/raven/processor/MongoDao.java)** (100 lines)

5. **[PruneJob.java](file:///home/ndeans/Projects/java_projects/Raven-Jobs/src/main/java/us/deans/raven/jobs/PruneJob.java)** (58 lines)

---
Definitely better but...

Larry explained that for tables he is using GFM (GitHub Flavored Markdown) and that it might not be rendered the same way depending on the theme Obsidian is using. I did notice that Warp renders the content differently too.

I have to realize that I'm on the learning curve for Obsidian as much as I am for Antigravity. Larry mentioned a tip...
### Pro-Tip for Obsidian

If you want your tables to look as premium as they do here, I highly recommend the **"Advanced Tables"** plugin for Obsidian. It adds auto-formatting and better UI for editing them. You can also look at themes like **"Minimal"** with the **"Minimal Theme Settings"** plugin, which allows you to turn on "Zebra Stripes" for tables!

I'm going to call this a side_issue for now...
***




