# Go LocalStack Example

This is a simple project that demonstrates how to use LocalStack with Golang
It shows a fan-out messaging pattern using S3, SNS, and SQS.

- When LocalStack starts (`make start-deps`), the script `./aws-init/init.sh` is executed. It does the following:
  - Creates an S3 bucket called `awesome-bucket`
  - Creates an SNS topic called `awesome-sns-topic`
  - Configures the SNS topic to allow S3 to publish messages to it
  - Adds a notification configuration so that any file uploaded to the S3 bucket with the prefix `new-files/` and suffix `.txt` triggers a message to the SNS topic
  - Creates three SQS queues, with `VisibilityTimeout` set to 30 and `ReceiveMessageWaitTimeSeconds` set to 20 (for long polling)
  - Subscribes the three queues to the SNS topic (the famous fan-out pattern)

- Once the infrastructure is set up, you can run the server, This is a simple app with two endpoints to send files to S3:
  - Run the app:  

  ```bash
    make start-server
  ```

  - Send one file:  
  
    ```bash
    make create-file
    ```
  
    Can send custom text too:  
  
    ```bash
    make create-file text="Hello World"
  
    ```

  - Send multiple files: (It creates 10 files by default)  

    ```bash
    make create-files
    ```

    Or can specify a number of files:

    ```bash
    make create-files n=20
    ```

- Start the poller:

  ```bash
  make start-poller
  ```

- The poller executes `ReceiveMessage` on every queue configured and prints the file key. (Each queue has a different configuration so you can see how they behave. Nothing fancy)

To sum up:

Each uploaded file triggers an S3 event → SNS → SQS → Poller prints the S3 file key.

Note:
The commands `make start-server` and `make start-poller` run the services directly on your machine. To run everything inside Docker, use:

 ```bash
  make start
  ```  

## Prerequisites

- [Docker](https://www.docker.com/)
- [Go](https://golang.org/) - If running the app directly on your machine (outside Docker)

## Some docs

- [sqs](./docs/sqs.md)
- [sns](./docs/sns.md)

## To-Do

- A couple of tests wouldn’t hurt, lol.
