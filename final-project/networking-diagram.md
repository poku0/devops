# Networking Diagram — Password Pusher Final Project

## Mermaid Diagram

```mermaid
graph TB
    USER[User Browser]
    CF[Cloudflare Proxy and DNS\npwpush.kulboka.com\ngrafana.kulboka.com]

    subgraph AWS[AWS eu-north-1]
        subgraph VPC[VPC 10.0.0.0/16]
            IGW[Internet Gateway]

            subgraph PUBLIC[Public Subnet 10.0.1.0/24]
                ALB[Application Load Balancer\nHTTPS :443]
                NAT[NAT Gateway]
            end

            subgraph PRIVATE[Private Subnet 10.0.2.0/24]
                EC2[EC2 Ubuntu 24.04\nt3.small\nNo SSH / SSM only]

                subgraph DOCKER[Docker Compose Stack]
                    PWP[pwpush :5100]
                    DB[PostgreSQL :5432]
                    GRAF[Grafana :3000]
                    PROM[Prometheus :9090]
                    CAD[cAdvisor :8080]
                    NODE[Node Exporter :9100]
                end
            end

            S3EP[S3 VPC Gateway Endpoint]
            SSMEP1[SSM Endpoint]
            SSMEP2[SSM Messages Endpoint]
            SSMEP3[EC2 Messages Endpoint]
        end

        S3[S3 Config Bucket\ncompose + monitoring + branding]
        ACM[ACM Certificate]
        SSM[AWS Systems Manager]
    end

    USER -->|HTTPS| CF
    CF -->|HTTPS 443| ALB
    ALB -->|HTTP 5100| PWP
    PWP -->|TCP 5432| DB

    PROM -->|Scrape| PWP
    PROM -->|Scrape| CAD
    PROM -->|Scrape| NODE
    GRAF -->|Query| PROM

    EC2 -->|Outbound via private route| NAT
    NAT --> IGW
    ALB --> IGW

    EC2 -->|Read config files| S3EP
    S3EP --> S3

    EC2 -->|Session Manager| SSMEP1
    EC2 -->|Session Manager| SSMEP2
    EC2 -->|Session Manager| SSMEP3
    SSMEP1 --> SSM
    SSMEP2 --> SSM
    SSMEP3 --> SSM

    ACM -.->|TLS cert for ALB| ALB
```

## Short Explanation

- Users access the application through **Cloudflare**.
- Cloudflare forwards HTTPS traffic to the **AWS Application Load Balancer**.
- The ALB sends application traffic to **Password Pusher** running on a private **EC2** instance.
- The EC2 instance is not publicly reachable and is managed through **AWS Systems Manager**, not SSH.
- The application uses **PostgreSQL** internally and exposes monitoring through **Prometheus** and **Grafana**.
- The private EC2 instance downloads deployment configuration from **S3** through an **S3 VPC endpoint**.
- Outbound internet access for the private subnet goes through the **NAT Gateway**.
