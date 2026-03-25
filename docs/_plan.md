[Raven (branch: main)]
# Plan

This document starts at the point where I lost a session with an agent and with it a lot of context. Ultimately, it should be replaced with items in the @Raven project on GitHub

***The project environment has been initialized and verified. 
- [x] Workspace exploration (Raven, Raven-Processor, Raven-Jobs).
- [x] Build verification for `Raven-Processor` and `Raven-Jobs`.
- [x] Initial documentation sync.

***Next priority: Debug Operation M1 in `Raven-Jobs`.
- [x] Run M1 operation and capture logs.
- [x] Investigate failure points in `Maria_DAO`, `MongoDao`, or `PruneJob`.
    - [x] Identified `SQLSyntaxErrorException`: `Unknown column 'pruned' in 'field list'`.
- [x] Implement schema fix: Add `pruned` and `pruned_at` to `uploads` table.

***Next priority: Resolve Wildfly Deployment Conflict.
- [x] Identify and remove conflicting `.war` deployments in Wildfly.
- [x] Verify server startup and endpoint availability.

***Next priority: End-to-End Testing of Upload Functionality.
- [x] Identify Upload REST API endpoint.
- [x] Perform test upload and verify backend persistence.

***Next phase: Maintenance Operations  (R1-R11).
- [x] Deploy M1 as standalone JAR + bash script + cron job (`Raven/bin/run_m1.sh`, 6AM daily).
- [ ] Initiate Research Operations as documented in project architecture.
