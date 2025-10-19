# 🚗 Vehicle Stack

This repository orchestrates the entire Vehicle Streaming Platform, integrating real-time data generation, processing, and visualization.
All services are managed with Docker Compose for a reproducible local setup.

## 🧩 Architecture Overview
```
vehicle-stack/
├── vehicle-simulator/        # Synthetic vehicle telemetry generator (Python + OSRM)
├── vehicle-stream-processor/ # Flink jobs for real-time processing
├── vehicle-warehouse/        # ClickHouse schema and views
├── vehicle-realtime-api/     # WebSocket gateway (Kafka → WS)
├── vehicle-dashboard/        # React + MapLibre web dashboard
├── osrm-data/                # Local OSRM map data (ignored by Git)
└── docker-compose.yml        # Orchestrates all services
```
## ⚙️ Requirements

- Docker ≥ 24
- Docker Compose v2
- ~10 GB free disk space (for map data and containers)

## 🚀 First-Time Setup
### 1. Prepare OSRM map data

Download and preprocess OpenStreetMap data for Spain (or your region):
```
mkdir osrm-data
cd osrm-data
wget https://download.geofabrik.de/europe/spain-latest.osm.pbf
cd ..

docker run -t -v $(pwd)/osrm-data:/data osrm/osrm-backend osrm-extract -p /opt/car.lua /data/spain-latest.osm.pbf
docker run -t -v $(pwd)/osrm-data:/data osrm/osrm-backend osrm-partition /data/spain-latest.osrm
docker run -t -v $(pwd)/osrm-data:/data osrm/osrm-backend osrm-customize /data/spain-latest.osrm
```

The osrm-data folder is git-ignored.
Each user must generate these files locally before running the stack.

###  2. Start the stack
``` 
docker compose up -d
```

Services started:

- Kafka (KRaft) — message broker

- OSRM — routing engine for vehicle paths
- Vehicle Simulator — sends synthetic telemetry to Kafka
- ClickHouse — analytical storage
- Grafana — visualization
- Kafka UI (KafbatUI) — monitor topics and messages

### 3. Verify the setup
Check running containers
docker compose ps

Open Kafka UI
```
👉 http://localhost:8085
```

Topic: vehicle-data
You should see live JSON messages such as:
```
{
  "vehicle_id": "car-001",
  "lat": 40.4167,
  "lon": -3.7037,
  "speed_kmh": 83.4,
  "rpm": 3280,
  "oil_temp": 91.2,
  "fuel": 49.8,
  "timestamp": 1727859200
}
````
Test OSRM API
```
👉 http://localhost:5000/route/v1/driving/-3.70379,40.41678;-0.37629,39.46975?overview=false
```
Simulator logs
```
docker compose logs -f vehicle-simulator
```
### 4. Stop everything
```
docker compose down
```
## 🧠 Next Steps

Add Flink jobs in vehicle-stream-processor to consume and enrich data.

Persist processed telemetry in ClickHouse.

Connect the Dashboard and Realtime API for live visualization.