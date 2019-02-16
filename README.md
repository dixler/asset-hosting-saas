# asset-hosting-saas
Serverless system to save the current state of a google doc to AWS and record telemetry on visitors.
Currently working on the frontend. 

The terraform prefix 'dev' disallows users to join through OAuth users must be added manually to the table.

the format for users is as follows:
```json
{
  "userId": "example@gmail.com",
  "file_count": 0,
  "file_limit": 10
}

```
