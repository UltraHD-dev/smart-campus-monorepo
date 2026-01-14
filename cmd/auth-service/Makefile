.PHONY: generate proto clean

generate:
	@echo "Generating Go code from protobuf..."
	mkdir -p internal/gen
	protoc --proto_path=proto \
		--go_out=internal/gen --go_opt=paths=source_relative \
		--go-grpc_out=internal/gen --go-grpc_opt=paths=source_relative \
		proto/*.proto
	@echo "Code generated!"

proto: generate

clean:
	rm -rf internal/gen

run-auth:
	cd cmd/auth-service && go run main.go

run-org:
	cd cmd/organization-service && go run main.go

run-all: docker-up
	@echo "Starting all services..."
	@make run-auth &
	@sleep 2
	@make run-auth &
	@echo "Services started"
	@echo "Auth: localhost:50051"
	@echo "Organization: localhost:50052"
