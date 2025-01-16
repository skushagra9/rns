# Node-PS-App with Terraform and Cloud SQL

This project demonstrates deploying a **Node.js To-Do application** to **Google Cloud Run**, backed by a **Cloud SQL PostgreSQL database**, using **Terraform** for infrastructure management.

---

## Features

- A RESTful To-Do API built with **Node.js** and **Express**.
- Cloud-native deployment on **Google Cloud Run**.
- PostgreSQL database hosted on **Cloud SQL**.
- Fully automated infrastructure setup with **Terraform**.

---


### API Endpoints

1. Create a To-Do

This endpoint allows you to add a new to-do item.

Curl Command:
```
curl -X POST http://34.54.16.31/todos/create \
  -H "Content-Type: application/json" \
  -d '{"task": "Buy groceries"}'
```

Expected Response:
```

{
  "message": "To-do created successfully",
  "todo": {
    "id": 1,
    "task": "Buy groceries"
  }
}
```

2. Get All To-Dos

This endpoint retrieves all the to-do items stored in the database.

Curl Command:```curl http://34.54.16.31/todos```

Expected Response:
```
{
  "todos": [
    {
      "id": 1,
      "task": "Buy groceries"
    },
    {
      "id": 2,
      "task": "Go for a walk"
    }
  ]
}
```
## Key Components

### 1. Docker Image

The application is containerized for portability and consistency. The image is hosted on Docker Hub and ready for deployment.

- **Docker Hub Repository**: `testnetfilament/node-ps-app:latest2`
- **Optimizations**:
  - Built on a lightweight Alpine-based image.
  - Dependencies are only installed when the `package.json` file changes, reducing build time and ensuring faster redeployments.

### 2. Google Cloud SQL

- **Purpose**: Hosts a PostgreSQL database for storing to-do tasks.
- **Configuration**:
  - Managed via Terraform, which sets up:
    - A PostgreSQL database instance.
    - A `todos_db` database within the instance.
    - A secure user with restricted access.

### 3. Google Cloud Run

- **Purpose**: Deploys and runs the Node.js application in a fully managed, serverless environment.
- **Benefits**:
  - Auto-scaling based on traffic.
  - No server maintenance required.

### 4. HTTP Load Balancer

- **Purpose**: Routes traffic from the internet to the Cloud Run service.
- **Configuration**:
  - Managed using Terraform.
  - Exposes the application via a global IP.

**Access URL**: [http://34.54.16.31](http://34.54.16.31)

---

## How to Use This Project

### 1. Clone the Repository

```bash
git clone https://github.com/skushagra9/rns
```

### 2. Build and Push the Docker Image:
```
cd node-js-backend
sudo docker build . -t <your_dockerhub_username>/node-ps-app:latest\
sudo docker push <your_dockerhub_username>/node-ps-app:latest
```

### 3. Deploy Infrastructure with Terraform:
```
Add the docker image in variables.tf file
terraform init
terraform apply
```
