OK... 
---

# Raven-Analyzer

There are currently four projects related to the Raven System

|||
|---|---|
|OPP-Userscripts|(Raven-Extractor) user script for extracting data from the OPP website|
|Raven-Processor|A library used by the web service AND the web application for handling traffic to/from the dual database backend|
|Raven-Jakarta-JAXRS|The web service that the userscripts send data to.|
|Raven-Jakarta-Web|The web application that display the data in the dual-database backend.|

Now we are going to add two new projects… Raven-Jobs and Raven-Jakarta-Analyzer, which together form the Raven Analyzer system. This system will extend and complement the existing web application by providing maintenance operations and research query results.

Raven-Analyzer will revolve around the idea of using both databases to reconstruct conversations and find common patterns. These queries can't be done with typical query tools because of the differences between the types of database — MariaDB is a SQL database for storing information that is unique to a topic or a specific upload, while MongoDB is a no-SQL database for storing content as a collection of posts.

---

## Project Structure

| Project                | Framework     | Deployed As          | Purpose                     |
| ---------------------- | ------------- | -------------------- | --------------------------- |
| OPP-Userscripts        | TamperMonkey  | userscript           | Extractor userscript        |
| Raven-Processor        | Java Core     | library (jar)        | Shared business/query logic |
| Raven-Jobs             | Plain Java    | standalone (jar)     | Maintenance operations      |
| Raven-Jakarta-JAXRS    | Jakarta JAXRS | Raven-JAXRS (war)    | Inbound data web service    |
| Raven-Jakarta-Web      | Jakarta JSF   | Raven-Web (war)      | Display application         |
| Raven-Jakarta-Analyzer | Jakarta JSF   | Raven-Analyzer (war) | Research query UI           |

### Architectural Notes

- Business and query logic lives in Raven-Processor, keeping UI tiers thin
- Raven-Jobs is a plain Java standalone JAR — no Jakarta dependency needed at the business or data tier
- Raven-Jakarta-Analyzer is a JSF web application running alongside Raven-Jakarta-Web on Wildfly

---

## Database Schema

**MariaDB — `uploads` table**

| Column      | Notes                                          |
| ----------- | ---------------------------------------------- |
| upload_id   | Primary key. Shared key with MongoDB.          |
| upload_time | Timestamp of upload                            |
| topic_id    | Identifies the topic                           |
| topic_title | Human-readable topic title                     |
| report_type | Not currently used                             |
| post_count  | Number of posts in upload                      |
| pruned      | TINYINT(1) NOT NULL DEFAULT 0 — tombstone flag |
| pruned_at   | DATETIME NULL — timestamp of tombstone         |

**MongoDB — `posts` collection**

| Field     | Notes                                                         |
| --------- | ------------------------------------------------------------- |
| _id       | MongoDB-generated ObjectId                                    |
| post_id   | Sequential number assigned by OPP. Natural chronological key. |
| author    | Post author. Exactly matches author references in html field. |
| head      | Post heading                                                  |
| link      | Post link                                                     |
| text      | Post text content                                             |
| html      | Post HTML content. Contains "wrote:" divs for quote-replies.  |
| topic_id  | Identifies the topic                                          |
| upload_id | Foreign key — shared key with MariaDB                         |

---

## Operations

Operations are identified by a prefix and a sequential number:

- **M** — Maintenance operations (Raven-Jobs / Raven-Processor)
- **R** — Research operations (Raven-Jakarta-Analyzer / Raven-Processor)

New operations can be added to either list as they are identified.

---

### Maintenance Operations (Raven-Jobs)

#### M1: Remove Duplicates

On OPP, topics grow over time as people add more posts. So an upload today might only be a subset of an upload of the same topic tomorrow. The fact that we can upload a single topic multiple times means that we can end up with a LOT of redundant data. M1 rectifies that by retaining only the latest upload for each topic and pruning all previous versions.

**Design Notes**

- Pruning is driven from the MariaDB side, using `topic_id` to group uploads and `upload_time` to identify the latest
- `upload_id` is the shared key used to cascade deletes to MongoDB
- A tombstone pattern is used to ensure recoverability across both databases

**Two-Phase Pruning Process**

_Phase 1 — Mark (MariaDB transaction)_

```sql
UPDATE uploads
SET pruned = 1, pruned_at = NOW()
WHERE pruned = 0
AND upload_id NOT IN (
    SELECT upload_id FROM uploads u2
    WHERE u2.topic_id = uploads.topic_id
    ORDER BY upload_time DESC
    LIMIT 1
)
```

_Phase 2 — Sweep_

```
For each upload_id WHERE pruned = 1:
    deleteMany from MongoDB WHERE upload_id = ?
    if MongoDB confirms deletion:
        DELETE from MariaDB WHERE upload_id = ?
    else:
        log failure, leave tombstone in place for next run
```

**Recovery**

Phase 2 is idempotent. Any run will pick up tombstoned records left behind by a previous failed run. The tombstone record serves as both a work queue entry and an audit log entry.

---

### Research Operations — Stage 1 (Single Database)

Stage 1 queries run against each database independently and can be validated using DBGate or equivalent tooling.

#### MariaDB Queries

**R1: Topics by upload count** Identify how many times each topic has been uploaded.

**R2: Topics by post count** Rank topics by size — largest topics by number of posts.

**R3: Upload activity over time** Count uploads per time period to identify activity patterns.

#### MongoDB Queries

**R4: Most prolific authors overall** Rank authors by total post count across all topics.

**R5: Most prolific authors per topic** Rank authors by post count within each topic.

**R6: Authors appearing across the most topics** Identify authors with the broadest participation across topics.

---

### Research Operations — Stage 2 (Compound Queries)

Stage 2 queries combine data from both databases and require the compound query framework built in Raven-Processor. Thread reconstruction relies on parsing the `html` field for `"wrote:"` div patterns, which indicate quote-replies. The `post_id` field provides reliable chronological ordering for resolving reply targets.

**Threading Algorithm**

```
For each post (ordered by post_id ASC):
    if html contains "wrote: [author]":
        parent = MAX(post_id) WHERE author = [author]
                                AND post_id < current_post_id
        add edge: current_post → parent
    else:
        mark as root post

Build directed graph from edges
Identify connected components → conversation threads
Identify isolated posts → no edges in or out
```

**Edge Case Handling**

| Condition                                           | Handling                                |
| --------------------------------------------------- | --------------------------------------- |
| Single "wrote:" reference                           | Full participation in graph             |
| Multiple "wrote:" references in one post            | Flag, include as best-effort or exclude |
| Nesting depth > N (configurable)                    | Flatten or exclude                      |
| Author in "wrote:" not matched to any post in topic | Orphan edge, log and discard            |

#### Compound Query Operations

**R7: Reconstruct full conversation thread for a topic** Build and display the full reply tree for a given topic using the threading algorithm above.

**R8: Dominant conversationalists vs isolated contributors per topic** Classify authors within a topic by their participation in conversation threads vs standalone posting.

**R9: Topics by conversational density** Rank topics by ratio of reply posts to standalone posts.

**R10: Author co-occurrence across topics** Identify authors who frequently appear together across multiple topics.

**R11: Thread depth analysis per topic** Measure the depth of conversation trees per topic — identifying topics with deep back-and-forth exchanges.

---

**Note: Raven** A "Raven" directory exists under ~/Projects for research artifacts, test queries, and experimental work supporting all stages.

-
