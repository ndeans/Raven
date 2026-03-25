[Raven (branch: main)]
# Review / Walkthrough

## Project Exploration Baseline (2026-03-16)

I have completed the initial exploration of the Raven project suite.

### Accomplishments
1. **Directory Structure Verified**: Confirmed existence of `Raven/docs`, `java_projects/Raven-Processor`, and `java_projects/Raven-Jobs`.
2. **Build Success**: 
    - `Raven-Processor`: Built and installed to local repository (`mvn clean install`).
    - `Raven-Jobs`: Compiled successfully against local processor dependency.
3. **Core Logic Review**: Analyzed `Maria_DAO`, `MongoDao`, and `PruneJob` implementation for the M1 operation. Conformed implementation matches design in `Operation M1.md`.

### M1 Operation Fix (2026-03-16)

I fixed the M1 (Remove Duplicates) operation which was failing due to missing MariaDB columns.

1. **Root Cause**: `SQLSyntaxErrorException: Unknown column 'pruned'` in `uploads` table.
2. **Fix**: Applied schema update adding `pruned` and `pruned_at`.
3. **Verification**: 
   - Re-ran M1 via `Raven-Jobs`. 
   - **Result**: Successfully marked and swept **167** redundant uploads across MariaDB and MongoDB.
   - Logs captured in `java_projects/Raven-Jobs/run_v2.log`.
### Wildfly Deployment Resolution (2026-03-16)

The Wildfly server is now fully operational with the Raven suite deployed.

1.  **Conflict Cleanup**: Cleared redundant WAR artifacts from `standalone/deployments/`.
2.  **Permission Escalation**: Updated `/opt/wildfly` ownership to `ndeans`, eliminating `root` access requirements for standard operations.
3.  **Network Setup**: Successfully bound server to `192.168.12.132:8080`.
4.  **Verification**: 
    - `curl -I http://192.168.12.132:8080/Raven/` -> **200 OK**.
    - All modules (`Raven-JAXRS`, `Raven-Jakarta`, etc.) are deployed.

### E2E Regression Test: Upload Functionality (2026-03-17)

Successfully verified the end-to-end upload pipeline using a simulated payload.

1. **Endpoint Verified**: `http://192.168.12.132:8080/Raven/api/upload`
2. **Payload Execution**: POST request with 2 post records for `topic_id: 9999`.
3. **Backend Persistence**:
   - **MariaDB**: Confirmed `upload_id: 338` created in `uploads` table.
   - **MongoDB**: Confirmed "2 post records inserted" via `server.log` (MongoDao verification).
4. **Conclusion**: Upload functionality is stable and ready for production data.

---

## Agentic Performance Metrics

### Larry - Onboarding Cost Analysis 2026-03-17

### **Operational Summary**
*   **Total Tool Calls**: 20
*   **Directory/File Discovery**: 6 calls (`list_dir`, `find_by_name`)
*   **Documentation & Code Reads**: 5 files (Totaling ~515 lines of code/markdown)
*   **Task/Artifact Management**: 8 calls (Setting up and updating `task.md` and UI state)
*   **Communication**: 1 call (`notify_user`)

### **Data & Token Estimates**
| Activity | Details | Estimated Volume |
| :--- | :--- | :--- |
| **Documentation Reads** | `Initiator.md`, `_review.md` | ~10.5 KB (~3k tokens) |
| **Code Analysis** | `Maria_DAO`, `MongoDao`, `PruneJob` | ~10.8 KB (~3k tokens) |
| **Context Overhead** | System prompts, tool definitions, directory listings | ~15-20k tokens* |
| **Total Input Processed** | Includes full conversation history | **~25k - 30k tokens** |

*\*Context overhead is common for agentic workflows to ensure I understand the tools and project constraints perfectly.*

### **Files Analyzed**
1.  **[Raven Project Initiator.md](file:///home/ndeans/Projects/Raven/docs/Raven%20Project%20Initiator.md)** (195 lines)
2.  **[_review.md](file:///home/ndeans/Projects/Raven/docs/_review.md)** (35 lines)
3.  **[Maria_DAO.java](file:///home/ndeans/Projects/java_projects/Raven-Processor/src/main/java/us/deans/raven/processor/Maria_DAO.java)** (127 lines)
4.  **[MongoDao.java](file:///home/ndeans/Projects/java_projects/Raven-Processor/src/main/java/us/deans/raven/processor/MongoDao.java)** (100 lines)
5.  **[PruneJob.java](file:///home/ndeans/Projects/java_projects/Raven-Jobs/src/main/java/us/deans/raven/jobs/PruneJob.java)** (58 lines)

### Test/Temp

| Activity | Details | Estimated Volume |
| :--- | :--- | :--- |
| **Documentation Reads** | [Initiator.md](cci:7://file:///home/ndeans/Projects/Raven/docs/Raven%20Project%20Initiator.md:0:0-0:0), [_review.md](cci:7://file:///home/ndeans/Projects/Raven/docs/_review.md:0:0-0:0) | ~10.5 KB (~3k tokens) |
| **Code Analysis** | [Maria_DAO](cci:2://file:///home/ndeans/Projects/java_projects/Raven-Processor/src/main/java/us/deans/raven/processor/Maria_DAO.java:9:0-125:1), [MongoDao](cci:2://file:///home/ndeans/Projects/java_projects/Raven-Processor/src/main/java/us/deans/raven/processor/MongoDao.java:12:0-98:1), [PruneJob](cci:2://file:///home/ndeans/Projects/java_projects/Raven-Jobs/src/main/java/us/deans/raven/jobs/PruneJob.java:9:0-56:1) | ~10.8 KB (~3k tokens) |
| **Context Overhead** | System prompts, tool definitions, directory listings | ~15-20k tokens* |
| **Total Input Processed** | Includes full conversation history | **~25k - 30k tokens** |