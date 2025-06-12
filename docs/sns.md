# Amazon SNS

[aws docs](https://docs.aws.amazon.com/sns/latest/dg/sns-fifo-topics.html)

- Amazon Simple Notification Service (SNS) is a fully managed pub/sub messaging service.
- It enables you to send messages to a large number of subscribers

## Types of Topics

- **Standard Topic (default)**
  - High throughput:  
    - Up to 30,000 messages per second (MPS) per account in US East (N. Virginia) Region.  
    - Up to 9,000 MPS per account in US West (Oregon) and Europe (Ireland) Regions.  
    - In other Regions, standard topics support at least 300 MPS per account by default (can be increased via Service Quotas).
  - “At-least-once” delivery (duplicates are possible).
  - Best-effort ordering (no guaranteed ordering).
  - The maximum message size is 256 KB

- **FIFO Topic (First-In-First-Out)**
  - Exactly-once message delivery (no duplicates).
  - Strict ordering within each Message Group ID.
  - Throughput limits (per topic & per message group): ([fifo-max-throughput-and-quotas](https://repost.aws/questions/QU96dBCBROTiSQmR92B-LOjQ/clarification-about-sns-fifo-max-throughput-and-quotas))
    - By default, 300 MPS per Message Group ID.
    - By default, 3,000 MPS per topic (when `FifoThroughputScope=Topic`).
  - Requires a `ContentBasedDeduplication` flag or an explicit `MessageDeduplicationId` on each publish.
    - If `ContentBasedDeduplication` is enabled, SNS computes a SHA-256 hash of the message body to generate a deduplication ID automatically.
    - If the `MessageDeduplicationId` is provided, SNS uses this ID to detect and prevent duplicate messages within a 5-minute deduplication interval.
  - The maximum message size is 256 KB
  
## Key Features & Concepts

### Topics and Subscriptions

- **Topic**

  A logical access point for publishers to send messages.

- **Subscription**  

  Endpoints that receive topic messages. Supported protocols include:
  - HTTP/HTTPS
  - AWS Lambda
  - SQS (Standard or FIFO)
  - Email/Email-JSON
  - SMS
  - Mobile Push (Amazon Device Messaging, Firebase Cloud Messaging, Apple Push Notification Service, etc.)

### Message Attributes & Filtering

- You can attach up to 10 custom attributes (string, string array, or binary) per message.

- **Subscription Filter Policy**  
  - Allows each subscriber to receive only a subset of messages based on attribute-matching rules.  
  - Improves fan-out efficiency by delivering only relevant messages to each endpoint.

### Delivery Retries & Dead-Letter Queues

- SNS automatically retries failed deliveries (for HTTP/S, Lambda, SQS, etc.) using exponential backoff.
- You can configure a **Dead-Letter Queue (DLQ)** for each subscription:
  - Unreachable or invalid endpoints (after maximum retry attempts) can be redirected to an SQS queue (DLQ).  
  - Helps isolate and debug undeliverable messages and prevents them from being lost silently.

## Integration with Other AWS Services

- **SNS → SQS**  
  - You can subscribe one or more SQS queues (standard or FIFO) to an SNS topic (fan-out pattern).  
  - For FIFO topics, ordering is preserved end-to-end if the SQS queue is also FIFO.

- **SNS → Lambda**  
  - SNS can invoke Lambda functions directly upon message publication.  
  - Works for both standard and FIFO topics.  

- **SNS → HTTP/HTTPS Endpoints**  
  - You can deliver messages to any reachable HTTP/HTTPS listener.  
  - Best for webhooks, web services, or internal APIs.

- **SNS → Email / SMS / Mobile Push**  
  - Turn SNS into a notification hub, sending alerts via email, SMS, or mobile push to applications.