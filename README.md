# asset-hosting-saas
Serverless system to save the current state of a Google Doc to AWS and record telemetry on visitors.

# Configuration
## Special prefixes
### dev
The terraform prefix 'dev' disallows users to join through OAuth users must be added manually to the table. You might not want random users creating files on your AWS account.

the format for users is as follows:
```json
{
  "userId": "example@gmail.com",
  "file_count": 0,
  "file_limit": 10
}

```
## OAuth 2.0
This has currently been hardcoded for use with Google's OAuth 2.0. To configure it, you must add the generated AWS API Gateway endpoint to the Authorized redirect URIs session(make sure to click save). You also want to add the valid JavaScript origins(i.e. http://localhost:8080)

# Notes/TODO list:
## Frontend
* Currently working on a frontend(don't know frontend very well so I'm holding off on posting what I'm currently using out of embarassment(not to say that this is any better))
* Learn enough JavaScript to use D3.js or Chart.js
## DevOps
* Need to learn automated unit testing(probably TravisCI)
* Build full auto-deploying script
## Analytics
* Need a better timeseries database
  * Wait for AWS Timestream to launch
  * Proposal: Mangle DynamoDB into a timeseries database
* Write Analytics APIs
## Security
* Need to make createAsset() transactional to avoid race conditions.
  * Could use GCP BigQuery, but hybrid cloud terraform provisioning seems like a pain due to creds and could be a learning experience.
  * Would add extra complexity for a mere transactional
