# Raven System — Run Book

Operational reference for the Raven system. Intended for dev-ops and maintenance personnel.

**Host**: `192.168.12.132`
**Owner**: `ndeans`
**Java**: OpenJDK 17 (Temurin 17.0.12)

---

## 1. Wildfly Application Server

Wildfly is **not** managed by systemd. It is started and stopped manually.

**Installation**: `/opt/wildfly/`
**Bind address**: `192.168.12.132:8080`

> [!NOTE]
> The public interface defaults to `127.0.0.1` in `standalone.xml`. Use `-b` to bind to the network interface at start time.

### Start
```bash
/opt/wildfly/bin/standalone.sh -b 192.168.12.132 &
```
To confirm it's up:
```bash
curl -I http://192.168.12.132:8080/Raven/
# Expected: HTTP/1.1 200 OK
```

### Stop
```bash
/opt/wildfly/bin/jboss-cli.sh --connect --controller=192.168.12.132:9990 command=:shutdown
```

### Check deployed modules
```bash
ls /opt/wildfly/standalone/deployments/
```
Expected modules: `Raven-JAXRS.war`, `Raven-Web.war`, `Raven-Analyzer.war`

---

## 2. MariaDB

Managed by **systemd**. Version: MariaDB 10.5

### Start / Stop / Status
```bash
sudo systemctl start  mariadb
sudo systemctl stop   mariadb
sudo systemctl status mariadb
```

### Raven Database
- **Key table**: `uploads` — contains `upload_id`, `topic_id`, `upload_time`, `pruned`, `pruned_at`

### Useful queries
```sql
-- Check total uploads
SELECT COUNT(*) FROM uploads;

-- Check for pending tombstones (M1 incomplete runs)
SELECT * FROM uploads WHERE pruned = 1;

-- View uploads by topic
SELECT topic_id, COUNT(*) AS uploads FROM uploads GROUP BY topic_id ORDER BY topic_id;
```

---

## 3. MongoDB

Managed by **systemd**. Version: 7.0.12

### Start / Stop / Status
```bash
sudo systemctl start  mongod
sudo systemctl stop   mongod
sudo systemctl status mongod
```

### Raven Collection
- **Key collection**: `posts` — contains `upload_id`, `post_id`, `author`, `topic_id`, `html`

### Useful queries
```javascript
// Total post count
db.posts.countDocuments()

// Posts by upload_id
db.posts.find({ upload_id: 338 }).count()
```

---

## 4. Scheduled Maintenance (Cron)

### M1 — Remove Duplicates

Runs automatically every day at **6:00 AM**.

```
0 6 * * * /home/ndeans/Projects/Raven/bin/run_m1.sh
```

Manage the schedule:
```bash
crontab -l    # view
crontab -e    # edit
```

To trigger manually:
```bash
/home/ndeans/Projects/Raven/bin/run_m1.sh
```

Logs are written to:
```
/home/ndeans/Projects/Raven/bin/logs/m1_YYYYMMDD_HHMMSS.log
```

---

## 5. Filesystem Reference

| Path | Description |
|---|---|
| `/opt/wildfly/` | Wildfly installation root |
| `/opt/wildfly/bin/standalone.sh` | Wildfly start script |
| `/opt/wildfly/bin/jboss-cli.sh` | Wildfly CLI (stop/admin) |
| `/opt/wildfly/standalone/deployments/` | Deployed WAR files |
| `/opt/wildfly/standalone/log/server.log` | Wildfly server log |
| `/home/ndeans/Projects/Raven/docs/` | Project documentation |
| `/home/ndeans/Projects/Raven/bin/` | Standalone operation runner |
| `/home/ndeans/Projects/Raven/bin/raven-jobs-1.0-SNAPSHOT.jar` | M1 fat JAR (all deps bundled) |
| `/home/ndeans/Projects/Raven/bin/run_m1.sh` | M1 wrapper script |
| `/home/ndeans/Projects/Raven/bin/logs/` | M1 run logs |
| `/home/ndeans/Projects/java_projects/Raven-Processor/` | Shared library source |
| `/home/ndeans/Projects/java_projects/Raven-Jobs/` | M1 job source |

---

## 6. Rebuild & Redeploy (after code changes)

### Raven-Processor (shared library — rebuild first)
```bash
cd /home/ndeans/Projects/java_projects/Raven-Processor
mvn clean install
```

### Raven-Jobs (M1 operation)
```bash
cd /home/ndeans/Projects/java_projects/Raven-Jobs
mvn clean package
cp target/raven-jobs-1.0-SNAPSHOT.jar /home/ndeans/Projects/Raven/bin/
```

### WAR deployments (web modules)
Redeploy by copying the new `.war` to `/opt/wildfly/standalone/deployments/`. Wildfly hot-deploys automatically when it detects a changed artifact.
