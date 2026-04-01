# Operation R7: Conversation Linking

**Objective:** [[_challenges#Operation R7 Conversations]]
**Approach Selected:** [[_ideas#Operation R7 - Conversations]] — Approach #2: Recursive Functions / CSS Selectors (Jsoup)

---

## Overview

Operation R7 reconstructs threaded conversations from a single upload's posts. Given an `upload_id`, it queries all posts in that upload from MongoDB, parses each post's HTML to identify quote-reply relationships, builds a parent-child tree, and then traverses that tree recursively to produce a list of conversations — each representing one root-to-leaf path through the reply tree.

---

## Dependency Change

### [MODIFY] Raven-Processor — pom.xml

Add a version property alongside existing properties:
```xml
<jsoup.version>1.18.3</jsoup.version>
```

Add the dependency alongside existing dependencies:
```xml
<!-- https://mvnrepository.com/artifact/org.jsoup/jsoup -->
<dependency>
    <groupId>org.jsoup</groupId>
    <artifactId>jsoup</artifactId>
    <version>${jsoup.version}</version>
</dependency>
```

---

## Proposed Changes

### Raven-Processor

---

#### [NEW] R7Post.java

The operational data object. One instance per post returned from MongoDB.

| Field | Type | Source | Notes |
|-------|------|--------|-------|
| `post_id` | String | MongoDB | Primary identifier |
| `author` | String | MongoDB | Author of this post |
| `head` | String | MongoDB | Post heading/subject |
| `html` | String | MongoDB | Full HTML content of the post |
| `link` | String | MongoDB | URL to original post on OPP |
| `width` | int | Computed | Count of direct responses to this post. Initialised to `0`. |
| `uplink_post_id` | String | Computed | `post_id` of the post this post is replying to. Initialised to `null`. |

---

#### [NEW] R7Conversation.java

The output data object. One instance per discovered conversation (one root-to-leaf path through the reply tree).

| Field | Type | Notes |
|-------|------|-------|
| `posts` | List\<R7Post\> | Ordered list — root post first, leaf post last |

---

#### [MODIFY] MongoDao.java

Add a new query method:

**`getPostsByUploadId(String uploadId)`**

Executes:
```
db.posts.find(
    { upload_id: uploadId },
    { post_id: 1, author: 1, head: 1, html: 1, link: 1 }
)
```
Returns `List<R7Post>` with `width = 0` and `uplink_post_id = null` on every entry.

---

#### [NEW] R7Service.java

The main orchestrator for Operation R7. Exposes one public entry point and implements the four phases as private methods.

**Public entry point:**
```
public List<R7Conversation> execute(String uploadId)
```
Calls all four phases in sequence and returns the completed conversation list.

---

**Phase 1 — Load**

Calls `MongoDao.getPostsByUploadId(uploadId)`.
Stores the result as the working list (`List<R7Post>`) used by all subsequent phases.

---

**Phase 2 — Parse & Link**

Iterates through every post in the working list. For each post:

1. Parse the `html` field with Jsoup: `Jsoup.parse(post.getHtml())`
2. Select the outer div: `doc.selectFirst("div.smalltext")`
3. Select the inner div: `doc.selectFirst("div.quote_colors")`
4. If **neither is present** → this post has no uplink. Leave `uplink_post_id` as `null`. Move to next post.
5. If **both are present**:
   - Extract quoted author: take `outerDiv.ownText()`, strip the trailing `" wrote:"` suffix → `quotedAuthor`
   - Extract quoted text: take `innerDiv.text()` (Jsoup strips tags automatically), extract the first 20 words → `quotedText`
   - Search the working list for a post where `author == quotedAuthor` AND the first 20 words of that post's **own content** equals `quotedText`
   - To extract a candidate post's own content: parse its `html` with Jsoup, **remove the `div.smalltext` element if present**, then call `.text()` and take the first 20 words. This ensures that any quote the candidate post itself carries is excluded from the comparison — only the candidate's original words are matched against. This defends against the edge case where a user manually types quoted content in a plain `[Reply]` rather than using the `[Quote Reply]` button, which would otherwise cause the BB's automatic wrapping not to apply.
   - **Exactly one match found:**
     - Set `currentPost.uplink_post_id = match.post_id`
     - Increment `match.width`
   - **Zero matches found:** log warning (uploadId, post_id, quotedAuthor). Skip this link. Continue.
   - **More than one match found:** log warning (uploadId, post_id, quotedAuthor — ambiguous match). Skip this link. Continue.

After Phase 2, every post that carries a quote-reply either points to its parent via `uplink_post_id`, or has been logged and skipped. The reply graph is complete.

---

**Phase 3 — Find Roots**

Filter the working list to identify conversation starting points:

```
roots = posts where uplink_post_id == null AND width > 0
```

Posts where `uplink_post_id == null AND width == 0` are standalone comments — they participated in no conversation. Exclude them from all further processing.

---

**Phase 4 — Recursive Conversation Builder**

Private recursive method:
```
private void buildConversations(R7Post current, List<R7Post> pathSoFar,
                                List<R7Conversation> results, List<R7Post> allPosts)
```

Logic:
```
children = allPosts where uplink_post_id == current.post_id

// BASE CASE — no one replied to this post; the path is complete
if children is empty:
    results.add(new R7Conversation(pathSoFar))
    return

// RECURSIVE CASE — branch deeper for each child
for each child in children:
    buildConversations(child, pathSoFar + [child], results, allPosts)
```

Kick off from each root:
```
for each root in roots:
    buildConversations(root, List.of(root), results, allPosts)
```

---

### Raven-Jobs — Temporary Test Runner

Until Raven-Jakarta-Analyzer is built, Raven-Jobs will host a console-based test runner for R7 to support development verification.

---

#### [MODIFY] pom.xml

Confirm `Raven-Processor` is listed as a local dependency (already in place from M1 if not already present).

#### [NEW] R7TestRunner.java

A simple console runner that invokes `R7Service` and dumps results to stdout. Not a production feature — exists solely to verify R7 output during development.

1. Accept an `upload_id` as input (hardcoded constant for initial testing, or passed via `args[]`)
2. Instantiate `R7Service` and call `execute(uploadId)`
3. Iterate through the returned `List<R7Conversation>` and print each conversation to console:
```
Conversation 1:
  [post_id: 1] bob — The moon is cheese.
  [post_id: 2] frank — get a job.

Conversation 2:
  [post_id: 1] bob — The moon is cheese.
  [post_id: 3] hilda — That would be impossible.
  ...
```

#### [MODIFY] App.java

Add an `R7` option alongside the existing `M1` option to invoke `R7TestRunner`.

---

> **Future Home — Raven-Jakarta-Analyzer**
> R7 (and all future R-series operations) will ultimately be served through the planned **Raven-Jakarta-Analyzer** project — a new JSF application (6th project in the Raven system) that will provide a UI for entering an `upload_id` and displaying the resulting conversation tree visually. Raven-Jobs retains ownership of all M-series operations. Raven-Jakarta-Web is planned to be rebranded as **Raven-Jakarta-Console**, focused on support and maintenance roles.

---

## Key Rules Summary

| Rule | Behaviour |
|------|-----------|
| A conversation is a root-to-leaf path through the reply tree | Each unique path = one `R7Conversation` |
| An upload may have multiple independent roots | Each root starts its own tree; all are processed |
| Standalone post (no uplink, no responses) | Discarded — not included in any conversation |
| Plain reply-without-quote (no uplink div, but has responses) | Treated as a root if `width > 0` |
| Link-level error (zero or ambiguous match in Phase 2) | Log and skip that link only — operation continues |

---

## Sample Trace

#### Input (from MongoDB):

| post | author | quoted author | quote | content |
|------|--------|---------------|-------|---------|
| 1 | bob | (none) | | The moon is cheese. |
| 2 | frank | bob | The moon is cheese. | get a job. |
| 3 | hilda | bob | The moon is cheese. | That would be impossible. |
| 4 | chuck | hilda | That would be impossible. | Why? |
| 5 | julie | bob | The moon is cheese. | You must be hungry - lol |
| 6 | hilda | chuck | Why? | There's no cows in space. |
| 7 | hank | (plain reply, no quote) | | frank rhymes with hank :) |
| 8 | bob | julie | You must be hungry - lol | very hungry - lol |

#### After Phase 2 (uplink_post_id and width resolved):

| post | uplink_post_id | width |
|------|----------------|-------|
| 1 | null | 3 |
| 2 | 1 | 0 |
| 3 | 1 | 1 |
| 4 | 3 | 1 |
| 5 | 1 | 1 |
| 6 | 4 | 0 |
| 7 | null | 0 ← discarded in Phase 3 |
| 8 | 5 | 0 |

#### After Phase 3 (roots):

Post 1 is the only root. Post 7 discarded.

#### After Phase 4 (conversations):

| Conversation | Post sequence |
|---|---|
| 1 | 1 → 2 |
| 2 | 1 → 3 → 4 → 6 |
| 3 | 1 → 5 → 8 |

---

## Verification Plan

### Automated Tests (JUnit 5 / Mockito — already in project)

- Mock `MongoDao.getPostsByUploadId()` to return the 8-post sample dataset above
- Assert Phase 2 produces correct `uplink_post_id` and `width` values for all 8 posts
- Assert Phase 3 identifies Post 1 as the sole root; Post 7 discarded
- Assert Phase 4 produces exactly 3 conversations: `[1,2]`, `[1,3,4,6]`, `[1,5,8]`
- Edge case: upload with multiple independent root posts — verify all roots are processed
- Edge case: zero-match link — assert warning logged, operation continues, remaining posts unaffected
- Edge case: ambiguous match (duplicate author + first-20-words) — assert warning logged, link skipped
- Edge case: candidate post contains its own quote div (manually typed reply scenario) — assert own-content extraction correctly excludes the nested quote, match resolves to correct uplink

### Manual Verification

1. Run `R7Service.execute()` against a known `upload_id` in MongoDB
2. Verify the returned conversation list matches the threading visible on the OPP source site
3. Confirm standalone posts (plain replies with no quote, no responses) are absent from all results
