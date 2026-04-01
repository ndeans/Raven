
## Wildfly Deployment Conflict (2026-03-16)
The Wildfly server fails to boot due to a `Duplicate resource` error for `Raven-JAXRS.war`.
- **Symptoms**: `WFLYCTL0212: Duplicate resource` and reports of duplicate JAX-RS contexts.
- **Hypothesis**: Conflicting entries between `standalone.xml` and the `deployments/` folder, possibly involving a context root overlap between `Raven-JAXRS` and `Raven-Jakarta-JAXRS`.
- **Status**: Investigating `standalone.xml` and `jboss-web.xml`.


## Operation M2: Removals

This operation will allow an entire upload to be removed based on the upload_id

## Operation R7 : Conversations

### Overview : 
This operation needs to apply to one upload at a time and will reconstruct the conversations within the upload. To do this, we need to use elements in the html field to link an originating (up-link) post to a responding (down-link) post. 

On the OPP website, members reading a post have the option to "reply" or "quote reply"

If they choose to "reply" the HTML field saved from their resulting post will not contain any divisions describing any other post. But if they chose "Quote Reply" the HTML field saved from their resulting post WILL contain divisions describing another post. 

So the challenge is to use these structural patterns to link individual posts into conversational threads.

### Approaches and Ideas :

[[_ideas#Operation R7 - Conversations]]


