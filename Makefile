
dependencies := localstack

# Docker commands utilities

start-deps: # Start dependencies
	@echo "Starting dependencies..."
	@docker-compose up -d $(dependencies)

start: # Start server and poller in Docker
	@echo "Starting server and poller ..."
	@docker-compose up server poller --build

down: # Stop all containers 
	@echo "Stopping..."
	@docker-compose down -v

# For starting the server and poller locally

start-server: ## Start the server in your machine
	@echo "Starting server..."
	go run cmd/server/main.go

start-poller: ## Start the poller in your machine
	@echo "Starting poller..."
	go run cmd/poller/main.go

# aws utilities

aws-upload-file: ## Upload a file to S3 to receive the notification in the SQS to trigger the new request handler
	./aws-utils-scripts/s3-upload-file.sh

aws-purge: ## Purge the S3 bucket and SQS queues
	./aws-utils-scripts/clean-s3-and-queues.sh


# send requests to the server
# to create a file or multiple files
text ?= Some text

create-file:
	curl -X POST http://localhost:8090/create-file \
	  -H "Content-Type: application/json" \
	  -d '{"text": "$(text)"}'

n ?= 10

create-files:
	curl -X POST http://localhost:8090/create-files \
	  -H "Content-Type: application/json" \
	  -d '{"number_of_files": $(n)}'