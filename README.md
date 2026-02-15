
# Multicloud Streaming Architecture  
## Confluent Cloud (Azure) → Oracle Cloud Infrastructure (OCI)

---

## Context

This repository documents a real-world architectural validation of a multicloud streaming pipeline using Confluent Cloud as the event backbone and Oracle Cloud Infrastructure (OCI) as the persistence layer.

The objective was not to “connect two services”, but to validate architectural decisions under enterprise constraints:

- How to process business logic before persistence
- How to reduce cross-cloud traffic intentionally
- How to integrate clouds without sharing credentials
- How to troubleshoot serialization and TLS issues in managed environments
- How to operate everything using fully managed services

No VMs.  
No Kubernetes cluster.  
No custom microservices.  
Only managed streaming and storage services.

---

## Architectural Principles

This implementation was guided by five core principles:

1. **Streaming as the system of record**
2. **Business logic executed in motion**
3. **Cross-cloud traffic minimized**
4. **Security without credential leakage**
5. **Vendor-neutral integration design**

---

## High-Level Architecture

Datagen Source  
→ Kafka Topic (`orders_source`)  
→ Flink SQL Processing  
→ Kafka Topic (`oci_vip_orders`)  
→ HTTP Sink Connector  
→ OCI Object Storage  

---

## Operational Evidence

### Confluent Cluster Running

Demonstrates active throughput and CKU allocation.

![Cluster Overview](images/cluster_overview.png)

This confirms that the streaming backbone was operating under real load.

---

### Topic-Level Volume Validation

The raw topic and filtered topic present a clear delta in retained bytes.

![Topics Overview](images/topics_overview.png)

- `orders_source`: raw ingestion
- `oci_vip_orders`: filtered events

This validates that business logic was applied before persistence, reducing storage footprint and cross-cloud bandwidth.

---

### Connector Health & Throughput

HTTP Sink running with stable message processing and zero DLQ messages.

![HTTP Sink Running](images/http_sink_running.png)

This validates operational stability and absence of downstream serialization failures.

---

### Object Successfully Persisted in OCI

![OCI Bucket Object](images/oci_bucket_object.png)

File `pedido_lab.json` confirms end-to-end delivery across cloud providers.

---

## Design Decisions & Trade-Offs

### Why HTTP Sink Instead of S3 Sink?

The decision to use HTTP instead of an S3-specific connector avoids dependency on AWS endpoint semantics and ensures vendor-neutral interoperability.

This makes the integration portable and cloud-agnostic.

---

### Why Filter in Stream Instead of Downstream?

Applying:

```sql
WHERE orderunits > 5
```

inside Flink SQL:

- Reduces unnecessary object writes
- Minimizes network traffic between clouds
- Decreases storage growth
- Improves downstream query efficiency

This is a cost-aware architecture decision.

---

### Why TLS 1.2 Explicitly?

Initial SSL handshake failures exposed a JVM-level protocol negotiation mismatch.

Resolution:

```
ssl.protocol = TLSv1.2
```

This highlights awareness of transport-layer behavior in managed Kafka Connect environments.

---

### Why Convert AVRO to JSON at the Edge?

Internal topic format: Avro (Schema Registry governed).  
External storage requirement: Readable JSON.

```
request.body.format = json
```

Conversion at the connector boundary preserves internal efficiency while ensuring external usability.

---

## Enterprise Considerations

### Scalability

- 6 partitions configured for parallelism
- Stateless filtering logic ensures horizontal scalability
- Connector can scale via tasks.max if needed

---

### Failure Handling

- Dedicated DLQ topics provisioned
- No DLQ messages observed during test
- Batch size set to 1 to reduce replay complexity

---

### Security Model

- Kafka authentication via API keys
- No static OCI credentials shared
- Access granted via Pre-Authenticated Request (time-bound)
- HTTPS-only communication

This follows least-privilege principles.

---

## Metrics Observed

| Metric | Value |
|--------|-------|
| Messages processed | 14,000+ |
| DLQ messages | 0 |
| End-to-end latency | < 2 seconds |
| Cross-cloud protocol | HTTPS PUT |
| Storage layer | OCI Object Storage |
| Infrastructure provisioned | None |

---

## What This Demonstrates

This project demonstrates practical experience with:

- Kafka topic modeling
- Flink SQL stream processing
- Cross-cloud architectural integration
- TLS troubleshooting
- Schema-aware serialization
- Cost-conscious data design
- Managed service orchestration

The focus was architectural validation, not feature exploration.

---

## Potential Next Iterations

- Parquet persistence for analytics optimization
- Integration with Autonomous Data Warehouse
- Lag monitoring dashboards
- Backpressure simulation
- Throughput stress testing

---

## Author

Paulo Magalhães  
Cloud Solutions Engineer  
Enterprise Streaming & Multicloud Architect
