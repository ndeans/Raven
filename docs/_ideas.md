---
aliases:
---
---

# Operation R7 - Conversations: 
In Answer To: [[_challenges#Operation R7 Conversations]]

## Input : (upload_id)
Operation R7 will be initiated with a single parameter query against the content database (MongoDB) in which an upload_id will be used to extract all the posts containing that upload_id. 
```
db.posts.find(
{upload_id: "337"},
{post_id: 1, author: 1, head: 1, html: 1, link: 1}
)
```
For each returned row representing a post in the upload, the contents will be copied or linked to a new post_object in the operational data structure.  

## Operational Data Structure:
This structure will be initialized with the results of the query mentioned in the last section, but there will be an additional "width" field added and initialized to zero. 
```
list
	post 
		post_id, author, head, html, link, width	
```
The "post_id", "author", "head", "html" and link fields will be copies or references to those same fields in each post contained in the list.  The "width" will be a numeric field containing the count of responding posts. 

## Output : Data Structure:
This structure will be used to reconstruct the conversations. They will be instantiated each time a conversation is discovered and added to a list. At the end of the operation there will be a list of conversations that will be sent to the UI.
```
List 
	Conversation
		Post #1
		Post #2
```

## Linking (Approach #1) - Nested Loops / Text Matching

#### Overview
Inside the "html" field, there are two divisions, one nested inside another. For example...
```
<div style="margin-top:1%; margin-left:1%; margin-right:1%; color:#333333;" class="smalltext">Turtle keeper wrote:
	<div class="quote_colors" style="border-width:1px; border-style:dotted;          padding-left:1%; padding-right:1%; line-height:1.5em;">Oops. A Republic and      a Democracy are 2 DIFFERENT types of government.  Look it up and read it.        How many times does the word Democracy show up in the Constitution?  Go          ahead and guess…..</div>
</div>
```
The rest of the HTML field will be content from the author of the post being inspected.

The key here is in the content of the outside division (class="smalltext"), before the start of the inside division (class="quote_colors"). So in this case, "Turtle keeper wrote:" If we remote:" at the end we are left with "Turtle keeper" which is the author of the post that the current post is responding to.

But Turtle keeper may have written several previous posts so we can't rely on that alone to find the specific post being responded to. For that we have to go further...

The inside division contains the contents of the uplink post. Here we need to use pattern matching to find the specific post by Turtle keeper that we are looking for. Since many of the posters are grammatically incompetent, we can't depend on grammatical symbols like periods. It's probably safer to go with a word count.   

So if we pull out the first 20 words, we get...

*"Oops. A Republic and a Democracy are 2 DIFFERENT types of government.  Look it up and read it. How many"

Now were are reducing potential up-links to those authored by Turtle keeper and starting with those 20 words. 

On the very unlikely chance that there are more than one post within the upload by the same author with the same first 20 words within the upload, I am willing to allow the system to error out... Abandon the attempt, log the issue and move on. Otherwise, once a match is found. The "width" field for the current object in the outside loop should be incremented. 

#### Operational Loops:
The operation starts by using the input query to generate a return set of posts which it will map, row by row, to the operational data structure.

Once the data is loaded, the system will loop through each post record using a recommended
a loop through the entire query result (entire upload by default) at the first post, which can be determined by the post_id. 
There will be an outside loop, run once through all the objects in the list. For each object, there will be an inside loop that looks for posts that are in direct response. If none are found, the "width" field remain at zero for the current object in the outside loop. Otherwise, the width will be incremented for every responding post found.
#### Standalone Comments:
Any post object in which the html field is missing the nested divisions to describe an up-link post and for which the width is zero at the completion of the outside loop, should be removed from the list.

#### Sample Process:

###### from MongoDB:

| post   | author | quoted author    | quote                     | blabber                   |
| ------ | ------ | ---------------- | ------------------------- | ------------------------- |
| post 1 | bob    | (original post)  |                           | The moon is cheese.       |
| post 2 | frank  | reply to bob     | The moon is cheese.       | get a job.                |
| post 3 | hilda  | reply to bob     | The moon is cheese.       | That would be impossible. |
| post 4 | chuck  | reply to hilda   | That would be impossible. | Why?                      |
| post 5 | julie  | reply to bob     | The moon is cheese.       | You must be hungry - lol  |
| post 6 | hilda  | reply to chuck   | Why?                      | There's no cows in space. |
| post 7 | hank   | (reply no quote) |                           | frank rhymes with hank :) |
| post 8 | bob    | reply to julie   | You must be hungry - lol  | very hungry - lol         |

###### Nested Loops:  

| post | quote | width |       |       |       |                                 |
| ---- | ----- | ----- | ----- | ----- | ----- | ------------------------------- |
| 1    | 0     | 3     |       |       |       | inner loops for 2,3,5           |
|      | post  | quote | width |       |       |                                 |
|      | 2     | 1     | 0     |       |       | two-post conversation, depth=2  |
|      | 3     | 1     | 1     |       |       | inner loop for 4                |
|      |       | post  | quote | width |       |                                 |
|      |       | 4     | 3     | 1     |       | inner loop for 6                |
|      |       |       | post  | quote | width |                                 |
|      |       |       | 6     | 4     | 0     | sustained conversation, depth=4 |
|      | 5     | 1     | 1     | 1     | 0     | inner loop for 8                |
|      |       | 8     | 5     | 0     | 0     | sustained conversation, depth=3 |
| 7    | 0     | 0     |       |       |       | removed                         |

###### Conversations:

| conversation | post sequence |
| ------------ | ------------- |
| 1            | 1,2           |
| 2            | 1,3,4,6       |
| 3            | 1,5,8         |


## Linking (Approach #2) - Recursive Functions / CSS Selectors

#### The Library: Jsoup

In Java, the standard tool for this job is **Jsoup** — a widely-used HTML parsing library. It lets you point at an HTML string and say _"find me the element matching this CSS selector"_ — exactly like a browser's developer tools. Clean, battle-tested, one dependency.
#### The Two CSS Selectors You Need

Given this HTML structure from a quote-reply post:
```html
<div class="smalltext">Turtle keeper wrote:
    <div class="quote_colors">Oops. A Republic and a Democracy...</div>
</div>
```
html

| What you want                                | CSS Selector       | Returns                                 |
| -------------------------------------------- | ------------------ | --------------------------------------- |
| The outer wrapper (contains author name)     | `div.smalltext`    | `"Turtle keeper wrote:"`                |
| The inner quote block (contains quoted text) | `div.quote_colors` | `"Oops. A Republic and a Democracy..."` |

If **neither selector finds anything** → the post has no quote → it's a potential root post.

This replaces all the fragile string-searching in Approach #1 with two clean, targeted lookups.


#### The Four Phases
---
##### Phase 1 — Load

Query MongoDB with the `upload_id`. Map each result into your operational data structure, adding one new field:
```
post_id, author, head, html, link, width, uplink_post_id
```
`uplink_post_id` starts as **null** for every post.

---
##### Phase 2 — Parse & Link

Loop through every post. For each one, use Jsoup to check the HTML:
```
For each post in the list:

    outerDiv = jsoup.select("div.smalltext")
    innerDiv = jsoup.select("div.quote_colors")

    If innerDiv is found:
        quotedAuthor  = outerDiv.ownText()         // "Turtle keeper wrote:"
                        .removeSuffix(" wrote:")   // → "Turtle keeper"

        quotedText    = innerDiv.text()            // plain text, tags stripped
                        .first20Words()            // → first 20 words

        match = find post in list where:
                    author == quotedAuthor
                    AND html.first20Words == quotedText

        If match found:
            post.uplink_post_id = match.post_id
            match.width += 1

        If no match found:
            log the issue, skip this link
```
After this phase, every post either points to its parent or doesn't. The graph is built.

---
##### Phase 3 — Find the Roots
```
roots = all posts where uplink_post_id == null
                    AND width > 0
```
_(Posts where both are null/zero are the standalone comments — discard them.)_

---
##### Phase 4 — Recursive Conversation Builder

This is the heart of the new approach. One function, calling itself:

```
function buildConversations(currentPost, pathSoFar):

    children = all posts where uplink_post_id == currentPost.post_id

    // BASE CASE — no one replied to this post
    If children is empty:
        save pathSoFar as a completed Conversation
        return

    // RECURSIVE CASE — go deeper for each child
    For each child in children:
        buildConversations(child, pathSoFar + [child])


// Kick it off from each root
For each root in roots:
    buildConversations(root, [root])
```

That's it. The function doesn't know or care how deep the tree goes. It just keeps diving until it hits a leaf, then saves the path.

##### Traced Against Your Sample Data

After Phase 2, the links look like this:

```
Post 1 → (root)
Post 2 → uplink: Post 1
Post 3 → uplink: Post 1
Post 4 → uplink: Post 3
Post 5 → uplink: Post 1
Post 6 → uplink: Post 4
Post 7 → (root, but width=0) ← discarded in Phase 3
Post 8 → uplink: Post 5
```
Phase 4 traces:

```
Start at Post 1
├── Child: Post 2 → no children → save [1, 2]          ✓ Conv 1
├── Child: Post 3 → has child Post 4
│   └── Child: Post 4 → has child Post 6
│       └── Child: Post 6 → no children → save [1,3,4,6] ✓ Conv 2
└── Child: Post 5 → has child Post 8
    └── Child: Post 8 → no children → save [1,5,8]     ✓ Conv 3
```
Matches your expected output exactly.

##### What This Approach Buys You

| Approach #1 (original)                 | CSS Selector + Recursion                            |
| -------------------------------------- | --------------------------------------------------- |
| Manual string searching in raw HTML    | Jsoup handles HTML parsing cleanly                  |
| Fragile to whitespace / tag variations | CSS selectors are robust to style attribute changes |
| Two-level loop (depth limited)         | Recursive — handles any depth                       |
| No explicit parent link stored         | `uplink_post_id` makes the tree queryable           |
| Conversation rule implied              | Root-to-leaf rule is explicit in the code           |

---






