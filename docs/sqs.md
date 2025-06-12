# Amazon SQS

- Amazon SQS is a fully managed message queuing service.
- It enables you to decouple and scale microservices, distributed systems, and serverless applications.

## Types of Queues

- **Standard Queue (default)**
  - Unlimited throughput.
  - At-least-once delivery (duplicates are possible).
  - Best-effort ordering (no guarantee of message order).

- **FIFO Queue (First-In-First-Out)**
  - Limited throughput:
    - Up to 300 transactions/second without batching.
    - Up to 3,000 transactions/second with batching (up to 10 messages per batch).
  - Exactly-once processing (no duplicates).
  - Message order is preserved within a given message group ID.
  - Requires a Deduplication ID (can be provided or auto-generated).

## Key Features & Concepts

### Queue Parameters

  [aws docs](https://docs.aws.amazon.com/AWSSimpleQueueService/latest/APIReference/API_SetQueueAttributes.html)

- **Visibility Timeout**  
  Time a message remains hidden from other consumers after being retrieved.
  - Default: 30 seconds  
  - Maximum: 12 hours  
  - Can also be set per message

- **Message Retention Period**  
  How long SQS retains a message if it is not deleted.
  - Range: 1 minute to 14 days  
  - Default: 4 days  
  - Cannot be overridden per message (set at the queue level only).

- **DelaySeconds**  
  Delay before a newly sent message becomes visible.
  - Range: 0 to 900 seconds (0–15 minutes).  
  - Can be set per message (overrides queue-level default).

- **ReceiveMessageWaitTimeSeconds**  
  Enables long polling on ReceiveMessage.
  - Range: 0 to 20 seconds.  
  - Default: 0 (seconds) → short polling.  
  - Can be set at queue level or per-request.

- **Maximum Message Size**  
  - 256 KB (including body and attributes).

- **Maximum Batch Size**  
  - Up to 10 messages per batch (for SendMessageBatch, ReceiveMessage, DeleteMessageBatch).
  - It can't be set at queue level

### Dead-Letter Queues (DLQs)

- Redirects messages that couldn’t be processed successfully.
- After a message exceeds the maximum receive count (configured per queue), it is moved to the DLQ.
- Useful for debugging poison messages and preventing a single stuck message from blocking the queue.

### Message Attributes

- You can attach up to 10 metadata attributes per message (strings, numbers, or binary).
- Commonly used for:
  - Message filtering (in combination with SNS).
  - Carrying lightweight metadata without changing the message body.

## Integration with Other AWS Services

- **SNS → SQS**  
  - SNS can publish to one or more SQS queues (fan-out pattern).
  - SQS subscribers receive a copy of each SNS message.

- **Lambda ↔ SQS**  
  - Lambda can be configured as an event source for an SQS queue.
  - Supports both Standard and FIFO queues.
  - Lambda polls the queue and invokes your function with a batch of messages.

- **S3 Event Notifications → SQS**  
  - S3 can publish event notifications (e.g., object creation) directly to an SQS queue.

## Developer Tips

- Always delete messages after successful processing to prevent redelivery.
- Use batch operations (up to 10 messages) for better throughput:
  - `SendMessageBatch`
  - `ReceiveMessage` (with `MaxNumberOfMessages=10`)
  - `DeleteMessageBatch`
- Tune Visibility Timeout and use DLQs to handle processing failures gracefully.
- For FIFO queues, group related messages using the same Message Group ID to ensure strict ordering.
- Consider increasing `ReceiveMessageWaitTimeSeconds` (long polling) to reduce empty responses and lower API costs.
