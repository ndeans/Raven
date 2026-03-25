# Operation M1: Remove Duplicates

This operation implements the two-phase pruning process to remove redundant topic uploads from the Raven system. It retains only the latest upload for each topic and removes all previous versions from both MariaDB and MongoDB.

## User Review Required

IMPORTANT

This change introduces data deletion operations. Ensure that the database credentials and connection strings in `Raven-Processor` are correct for your environment before running.

## Proposed Changes

### Raven-Processor

The shared library needs to provide the data access layer for the pruning process.

---

#### [MODIFY] 

RvnJob.java

Add `pruned` (Boolean) and `pruned_at` (String/Long) fields to match the database schema.

#### [MODIFY] 

Maria_DAO.java

- Add `markForPruning()` method to execute Phase 1 (SQL UPDATE on `uploads`).
- Add `getPrunedUploadIds()` method to retrieve `upload_id`s marked for deletion.
- Add `deleteUpload(long uploadId)` method to remove the metadata record after Phase 2 confirms MongoDB deletion.

#### [MODIFY] 

MongoDao.java

- Add `deletePosts(long uploadId)` method to delete all posts associated with an upload.

---

### Raven-Jobs

This project will serve as the execution host for the M1 operation.

---

#### [MODIFY] 

pom.xml

Add `Raven-Processor` as a local dependency.

#### [NEW] 

PruneJob.java

Orchestrates the M1 process:

1. Calls `Maria_DAO.markForPruning()`.
2. Iterates through `Maria_DAO.getPrunedUploadIds()`.
3. For each ID: Calls `MongoDao.deletePosts()`.
4. If successful: Calls `Maria_DAO.deleteUpload()`.

#### [MODIFY] 

App.java

Update to allow running the `PruneJob`.

---

## Verification Plan

### Automated Tests

- Build and install `Raven-Processor` locally: `mvn install` in Raven-Processor.
- Run `mvn test` in `Raven-Jobs` (will require adding integration tests or mocking the DAOs).

### Manual Verification

1. Run `Raven-Jobs` with the `M1` option.
2. Verify logs show "Marking" and "Sweeping" phases.
3. Check MariaDB `uploads` table for expected deletions.

### Before Operation M1:

MongoDB
db.posts.find({},{topic_id: 1, upload_id: 1, author: 1, text: 1 }) = 51,480 rows

MariaDB
select * from uploads order by topic_id, upload_id; = 272 rows


---

# Walkthrough: Operation M1 - Remove Duplicates

I have implemented the **Remove Duplicates (M1)** operation across the Raven system. This handles the two-phase pruning process to keep only the latest topic uploads.

## Changes Made

### 1. Raven-Processor (Shared Library)
The data tier was updated to support pruning operations:
- **`RvnJob`**: Added `pruned` and `pruned_at` fields to support the tombstone pattern.
- **`Maria_DAO`**:
    - `markForPruning()`: Executes the SQL to mark old uploads.
    - `getPrunedUploadIds()`: Retrieves the work queue for Phase 2.
    - `deleteUpload()`: Finalizes deletion after Phase 2 is complete.
- **`MongoDao`**:
    - `deletePosts()`: Handles bulk deletion of posts in MongoDB by `upload_id`.

### 2. Raven-Jobs (Operation Host)
- **Dependency**: Configured `pom.xml` to depend on the local `Raven-Processor` build.
- **`PruneJob.java`**: A new orchestrator class that coordinates the two-phase process.
- **`App.java`**: Updated to run the `PruneJob` upon execution.

## Verification Results

### Build Status
The project builds successfully targeting Java 17:
```text
[INFO] --- maven-compiler-plugin:3.12.1:compile (default-compile) @ raven-jobs ---
[INFO] Compiling 2 source files with javac [debug release 17] to target/classes
[INFO] ------------------------------------------------------------------------
[INFO] BUILD SUCCESS
```

### After Operation M1:

MongoDB
db.posts.find({},{topic_id: 1, upload_id: 1, author: 1, text: 1 }) = 20,828 rows

MariaDB
select * from uploads order by topic_id, upload_id; = 105 rows



## How to Trigger
To run the M1 operation from the command line:

```bash
cd /home/ndeans/Projects/java_projects/Raven-Jobs
mvn exec:java -Dexec.mainClass="us.deans.raven.App"
```

> [!CAUTION]
> Running this will perform permanent deletions in your MariaDB and MongoDB instances based on the pruning logic. Ensure you have backups if testing on production data.

---

# Deployment: Standalone JAR & Cron Schedule (2026-03-23)

Operation M1 is now deployed as a standalone runner — no Maven required at runtime.

## How It Works

### 1. Fat JAR Build (`raven-jobs-1.0-SNAPSHOT.jar`)

The `maven-shade-plugin` was added to `Raven-Jobs/pom.xml`. Running `mvn clean package` now produces a self-contained fat JAR (~8MB) in `target/` with all dependencies bundled and `us.deans.raven.App` set as the `Main-Class`.

To rebuild after code changes:
```bash
cd /home/ndeans/Projects/java_projects/Raven-Jobs
mvn clean package
cp target/raven-jobs-1.0-SNAPSHOT.jar /home/ndeans/Projects/Raven/bin/
```

### 2. Deployment Layout

```
Raven/bin/
  ├── raven-jobs-1.0-SNAPSHOT.jar   # Fat JAR (all deps bundled)
  ├── run_m1.sh                     # Wrapper script
  └── logs/                         # Dated log files written here
        └── m1_YYYYMMDD_HHMMSS.log
```

### 3. Wrapper Script (`run_m1.sh`)

The script resolves its own absolute path (safe for cron), invokes the JAR, and writes stdout/stderr to a dated log file in `Raven/bin/logs/`.

```bash
/home/ndeans/Projects/Raven/bin/run_m1.sh
```

To run manually (e.g. for testing):
```bash
/home/ndeans/Projects/Raven/bin/run_m1.sh
tail -f /home/ndeans/Projects/Raven/bin/logs/m1_*.log
```

### 4. Cron Schedule

M1 runs automatically every day at **6:00 AM**:

```
0 6 * * * /home/ndeans/Projects/Raven/bin/run_m1.sh
```

View or edit the schedule:
```bash
crontab -l       # view
crontab -e       # edit
```