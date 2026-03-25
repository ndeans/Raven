# Project Challenges

## Wildfly Deployment Conflict (2026-03-16)
The Wildfly server fails to boot due to a `Duplicate resource` error for `Raven-JAXRS.war`.
- **Symptoms**: `WFLYCTL0212: Duplicate resource` and reports of duplicate JAX-RS contexts.
- **Hypothesis**: Conflicting entries between `standalone.xml` and the `deployments/` folder, possibly involving a context root overlap between `Raven-JAXRS` and `Raven-Jakarta-JAXRS`.
- **Status**: Investigating `standalone.xml` and `jboss-web.xml`.


## Operation M2: Removals

This operation will allow an entire upload to be removed based on the upload_id

## Operation R7 : Conversations

This operation will apply to one upload at a time and will reconstruct the conversations within the upload. To do this, we need to use elements in the html field to link an originating (up-link) post to a responding (down-link) post. 

On the OPP website, members reading a post have the option to "reply" or "quote reply"

![](https://onenote.officeapps.live.com/o/GetImage.ashx?&WOPIsrc=https%3A%2F%2Fmy%2Emicrosoftpersonalcontent%2Ecom%2Fpersonal%2F82cc2ddfc7584d90%2F%5Fvti%5Fbin%2Fwopi%2Eashx%2Ffiles%2F82CC2DDFC7584D90%21s9ae64f3fe1594e7dbfb4595e30b99ce4&access_token=eyJhbGciOiJSUzI1NiIsImtpZCI6IjAyNTZDNTI2ODlDMUFFMkNCOTgwNjJGRjc5NzFDMzkzMTNDNjk4Q0QiLCJ0eXAiOiJKV1QiLCJ4NXQiOiJBbGJGSm9uQnJpeTVnR0xfZVhIRGt4UEdtTTAifQ%2EeyJuYW1laWQiOiIwIy5mfG1lbWJlcnNoaXB8bmRlYW5zQGhvdG1haWwuY29tIiwibmlpIjoibWljcm9zb2Z0LnNoYXJlcG9pbnQiLCJpc3VzZXIiOiJ0cnVlIiwiY2FjaGVrZXkiOiIwaC5mfG1lbWJlcnNoaXB8MDAwNjAwMDBhNzljNzk5NEBsaXZlLmNvbSIsInNoYXJpbmdpZCI6IjM0Mjk3MDg3NzgwMTI2MjI1MjQiLCJzaWQiOiJXQUNfMzQyOTcwODc3ODAxMjYyMjUyNCIsInNpZ25pbl9zdGF0ZSI6IltcImttc2lcIl0iLCJpc2xvb3BiYWNrIjoiVHJ1ZSIsImFwcGN0eCI6IjlhZTY0ZjNmZTE1OTRlN2RiZmI0NTk1ZTMwYjk5Y2U0O3NWbW5MTllEVndnbmwrblF1ZEFwRHlXbzJHYz07RGVmYXVsdDs7MUIwM0M0MzEyRUY7VHJ1ZTs7OzE4NTUzMDA7NWY0MTAxYTItMTBlZi1jMDAwLTJmYjktNDg2MjA5ZjI2YjYzIiwiZmlkIjoiMTkzNjg4IiwiaXNzIjoiMDAwMDAwMDMtMDAwMC0wZmYxLWNlMDAtMDAwMDAwMDAwMDAwQDkwMTQwMTIyLTg1MTYtMTFlMS04ZWZmLTQ5MzA0OTI0MDE5YiIsImF1ZCI6IndvcGkvbXkubWljcm9zb2Z0cGVyc29uYWxjb250ZW50LmNvbUA5MTg4MDQwZC02YzY3LTRjNWItYjExMi0zNmEzMDRiNjZkYWQiLCJuYmYiOiIxNzczODUzNTUwIiwiZXhwIjoiMTc3NDI4MTk1MCJ9%2EwYGXR5QkcRPorQ2ewjaLQpOqSxuHLjnk3yND7gmfm1kT921ikGWqz3uhu42npxQ2bHonLNPQTfVeMqJfgz3RUI4fJL9Oyo7IrOk0H9MccUM1RkUH%2DPYdD6zCypscsmKpSbeC4oOrJX6q%2DSs9gw1dghYyQibaunFtOkL0Zw8W7YbS5etIxaMa4AroA26oVhOhLonX%2Dcrx75R%5FhWggpZW5dgYTfPaLk5A2CZNxxmV0nByMwhkDGdRumFbRMI8NmH9iIZH20BQhMHbGaWynjiGayZwv%5FuIHYZvAXT9EF137oFoVsZVunztS7PxYG6RDT5JJBVji76nFOtHrWxcodeKE1Q&access_token_ttl=1774281950743&ObjectDataBlobId=%7B7f944163-e49b-4f29-ae2a-b043773856b3%7D%7B1%7D&usid=e296fc3e-866b-4b52-d4d4-02b0deafda4d&build=16.0.19906.41003&waccluster=US1&wdwacuseragent=MSWACONSync)

If they choose to "reply" the HTML field saved from their resulting post will not contain any divisions describing any other post. But if they chose "Quote Reply" the HTML field saved from their resulting post WILL contain divisions describing another post. 

#### Input : (upload_id)
Operation R7 will be initiated with a single parameter query against the content database (MongoDB) in which an upload_id will be used to extract all the posts containing that upload_id. 
```
db.posts.find(
{upload_id: "337"},
{post_id: 1, author: 1, head: 1, html: 1, link: 1}
)
```
For each returned row representing a post in the upload, the contents will be copied or linked to a new post_object in the operational data structure.  

#### Operational Data Structure:
This structure will be initialized with the results of the query mentioned in the last section, but there will be an additional "width" field added and initialized to zero. 
```
list
	post 
		post_id, author, head, html, link, width	
```
The "post_id", "author", "head", "html" and link fields will be copies or references to those same fields in each post contained in the list.  The "width" will be a numeric field containing the count of responding posts. 

#### Output Data Structure:
This structure will be used to reconstruct the conversations. They will be instantiated each time a conversation is discovered and added to a list. At the end of the operation there will be a list of conversations that will be sent to the UI.
```
List 
	Conversation
		Post #1
		Post #2
```
#### Operational Loops:
The operation starts by using the input query to generate a return set of posts which it will map, row by row, to the operational data structure.

Once the data is loaded, the system will loop through each post record using a recommendeds
a loop through the entire query result (entire upload by default) at the first post, which can be determined by the post_id. 
There will be an outside loop, run once through all the objects in the list. For each object, there will be an inside loop that looks for posts that are in direct response. If none are found, the "width" field remain at zero for the current object in the outside loop. Otherwise, the width will be incremented for every responding post found.

#### Pattern Matching: (Approach #1 - Text Matching)

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















