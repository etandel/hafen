check-all: test dialyzer credo format-check

test: start-db
	mix test

credo:
	mix credo

dialyzer:
	mix dialyzer

format-check:
	mix format --check-formatted

iex:
	iex -S mix

format:
	mix format

start-db:
	docker-compose up -d

create-db:
	mix ecto.create

migrate-db:
	mix ecto.migrate

run: start-db create-db migrate-db
	mix phx.server

deploy: check-all
	git push gigalixir HEAD:main
