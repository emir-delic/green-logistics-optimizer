# Sovereign Green Logistics Optimizer (EuroRoute-IO)

The **Sovereign Green Logistics Optimizer** is an API-first orchestration platform designed to calculate freight routes across. It optimizes for cost, weather risk, and carbon footprint while ensuring that sensitive business data and cryptographic keys remain within **EU-owned infrastructure**, shielded from the US CLOUD Act.

This project demonstrates a "Sovereign-by-Design" architecture, using **AWS** for stateless high-performance compute and **OVHcloud** as the secure Data Fortress.

---

### 1. Architecture: The Hybrid Sovereign Stack

The stack is split between **Processing** (Stateless) and **Persistence** (Sovereign). This ensures that while we use the scale of AWS, no sensitive data is stored on US-owned infrastructure.

| Component | Service | Role | Provider / Jurisdiction |
| :--- | :--- | :--- | :--- |
| **Secrets/KMS** | **OVHcloud KMS** | Hardware-backed Key Management | **OVHcloud (France)** |
| **Orchestrator** | **PolyAPI** | Unified SDK & API Governance | **OVH Managed Kubernetes** |
| **Compute** | **AWS Lambda** | Stateless business logic | **AWS (Germany)** |
| **Gateway** | **AWS API Gateway** | Stateless entry point | **AWS (Germany)** |
| **Database** | **OVH Managed PostgreSQL** | Persistent shipment & route data | **OVHcloud (France)** |
| **Cache** | **OVH Managed Redis** | Real-time tracking & session cache | **OVHcloud (France)** |
| **Storage/Logs** | **OVH Object Storage** | Secure documentation and logs | **OVHcloud (France)** |

---

### 2. Workflow: The Sovereign Orchestration Flow

1.  **Request:** A client sends a request to the `green-logistics-optimizer-gateway-edelic`.
2.  **Secret Retrieval:** The **AWS Lambda** authenticates with **OVHcloud KMS** to retrieve encrypted credentials for external APIs.
3.  **Orchestration:** Lambda executes the **PolyAPI Unified SDK**. The orchestration logic runs on your **OVH Managed Kubernetes** cluster, which concurrent-calls:
    * **Logistics:** DHL for real-time rates.
    * **Environment:** Climatiq for $CO_2$ footprint.
    * **Context:** OpenWeather & Mapbox for risks and ETAs.
4.  **Sovereign Persistence:** The final payload is stored in **OVH Managed PostgreSQL** and cached in **OVH Managed Redis**.
5.  **Response:** A finalized, eco-optimized JSON response is returned to the user.

---

### 3. Data Sovereignty Guardrails

* **Jurisdictional Isolation:** AWS is used strictly for stateless processing in the `eu-central-1` region. All persistent data (State) is managed by **OVHcloud**, a European-headquartered company immune to the US CLOUD Act.
* **The "Sovereign Brain":** By hosting the **PolyAPI Orchestration Layer** on **OVH Managed Kubernetes**, the application's core logic and API mapping stay on EU-owned metal.
* **Infrastructure-as-Code (IaC):** The entire stack is deployed via Terraform, ensuring the sovereign boundaries are enforced programmatically.

---

### 4. Setup & Deployment

#### Prerequisites
* **AWS S3 Bucket:** Ensure `green-logistics-optimizer-state-storage-edelic` is created in `eu-central-1` to store remote state.

---

### 5. Scaling & Future Proofing
* **Provider Agility:** The PolyAPI layer allows for swapping AWS Lambda for **OVHcloud Serverless Functions** with zero changes to the integration logic.
* **API Expansion:** New logistics providers can be "cataloged" into the PolyAPI layer without modifying the core Lambda deployment.