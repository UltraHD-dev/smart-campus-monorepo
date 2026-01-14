
.PHONY: docker-up docker-down monitor status test-infra db-check open-all open-grafana db-connect-auth db-connect-schedule redis-connect clean help

help:
	@echo "Available commands:"
	@echo "  docker-up       - Start infrastructure and open links"
	@echo "  docker-down     - Stop infrastructure"
	@echo "  monitor         - Show service links"
	@echo "  status          - Show container status"
	@echo "  open-all        - Open all web interfaces"
	@echo "  open-grafana    - Open Grafana"
	@echo "  db-connect-auth - Connect to PostgreSQL Auth"
	@echo "  db-connect-schedule - Connect to PostgreSQL Schedule"
	@echo "  redis-connect   - Connect to Redis"
	@echo "  clean           - Clean all containers and volumes"

docker-up:
	docker-compose up -d
	@echo "Waiting 10 seconds for initialization..."
	sleep 10
	make open-all

docker-down:
	docker-compose down
	docker system prune -f --volumes

monitor:
	@echo "🌐 Open these links:"
	@echo "Grafana: http://localhost:13000 (admin/admin)"
	@echo "Prometheus: http://localhost:19090"
	@echo "pgAdmin: http://localhost:15050 (admin@example.com/admin123)"

status:
	docker-compose ps

open-all:
	xdg-open http://localhost:13000 &
	xdg-open http://localhost:19090 &
	xdg-open http://localhost:15050

open-grafana:
	xdg-open http://localhost:13000

db-connect-auth:
	psql -h localhost -p 15432 -U campus -d auth_db

db-connect-schedule:
	psql -h localhost -p 15433 -U campus -d schedule_db

redis-connect:
	redis-cli -h localhost -p 16379 -a campus123

clean:
	docker-compose down
	docker system prune -f --volumes
