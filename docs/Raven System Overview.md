
The Raven System provides me with the tools to extract the content of online discussions and store them in dual-database backend from which conversations can be reconstructed.  


## Project Structure

| Project                | Framework     | Deployed As          | Purpose                     |
| ---------------------- | ------------- | -------------------- | --------------------------- |
| OPP-Userscripts        | TamperMonkey  | userscript           | Extractor userscript        |
| Raven-Processor        | Java Core     | library (jar)        | Shared business/query logic |
| Raven-Jobs             | Plain Java    | standalone (jar)     | Maintenance operations      |
| Raven-Jakarta-JAXRS    | Jakarta JAXRS | Raven-JAXRS (war)    | Inbound data web service    |
| Raven-Jakarta-Web      | Jakarta JSF   | Raven-Web (war)      | Display application         |
| Raven-Jakarta-Analyzer | Jakarta JSF   | Raven-Analyzer (war) | Research query UI           |
