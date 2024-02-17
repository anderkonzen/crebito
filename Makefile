null:
	@:

.PHONY: build
build: 
	docker build -t anderkonzen/crebito .

.PHONY: build-linux
build-linux: 
	docker buildx build --platform linux/amd64 -t anderkonzen/crebito .

.PHONY: push
push: 
	docker push anderkonzen/crebito:latest

.PHONY: up
up:
	docker compose up

.PHONY: down
down:
	docker compose down

.PHONY: kill
kill:
	docker compose kill

