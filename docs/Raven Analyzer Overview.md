Raven-Analyzer 

There are currently four projects related to the Raven System 

|   |   |
|---|---|
|OPP-Userscripts|(Raven-Extractor) user script for extracting data from the OPP website|
|Raven-Processor|A library used by the web service AND the web application for handling traffic to/from the dual database backend|
|Raven-Jakarta-JAXRS|The web service that the userscripts send data to.|
|Raven-Jakarta-Web|The web application that display the data in the dual-database backend.|

Now we are going to add a fifth project…  Raven-Analyzer that will extend or compliment the web-application and provide query results. 

Raven-Analyzer will revolve around the idea of using both databases to reconstruct conversations and find common patterns. This will further exploit the Jakarta Java framework as the fourth Java project. 

These queries can't be done with typical query tools because of the differences between the types of database they are… MariaDB is a SQL database for storing information that is unique to a topic or a specific upload.  MongoDB is a no-SQL database for storing content as a collection of posts. 

|         |                                                                                                                    |
| ------- | ------------------------------------------------------------------------------------------------------------------ |
| Stage 1 | Collection of Queries that can be run directly against each database separately                                    |
| Stage 2 | Build a basic framework for building compound queries in which two or more database-specific queries are combinded |
| Stage 3 | Finalization of queries and UI adjustments to display results.                                                     |


Note: Raven+ 

Since these stages encompass research as well as development, I've created a "Raven+" directory under ~/Projects. Under that is space for things like files for test queries. 



Stage 1 

MongoDB  
Set up a research directory and files 

Operation 1: Remove duplicates 

Operation 1: Remove duplicates 

On OPP, topics grow over time as people add more posts. So an upload today might only be a subset of an upload of the same topic tomorrow. The fact that we can upload a single topic multiple times means that we can windup with a LOT of redundant data. This first operation will rectify that by searching for uploads of the same topic and deleting all the previous versions up to the latest.