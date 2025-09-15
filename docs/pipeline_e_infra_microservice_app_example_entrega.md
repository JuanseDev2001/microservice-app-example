# Pipeline e Infra para `microservice-app-example`

**Repositorio base:** https://github.com/bortizf/microservice-app-example

**Fecha presentación:** 22 de septiembre

**Duración demo (por grupo):** 8 minutos

---

## 0. Resumen ejecutivo (qué entregamos)

Este documento describe la propuesta completa para que el proyecto `microservice-app-example` sea trabajado por un equipo ágil con pipelines de desarrollo e infraestructura (CI/CD + IaC), estrategias de branching separadas para desarrolladores y para operaciones, patrones de nube aplicados, la arquitectura y los scripts/pipelines necesarios. También incluye un plan de demostración y la documentación necesaria para correr y verificar la solución.

---

## 1. Metodología ágil propuesta

**Scrum ligero (sprints de 1 semana)**

Motivos: entrega incremental rápida (presentación en 22 sept), priorizar historias pequeñas (CI, IaC, tests), facilita coordinación pareja (2 personas), roles simples (PO, equipo). Propuesta rápida de ceremonias:
- Sprint planning: 30 min
- Daily standup: 10 min
- Sprint review + demo: 30 min
- Retrospectiva: 20 min

Definición de listo (DoR) y definición de terminado (DoD) incluidas en la documentación de entrega.

---

## 2. Estrategia de branching

### 2.1 Branching para desarrolladores (2.5%)

**Modelo: GitFlow simplificado**

- `main` — rama protegida; siempre desplegable a producción.
- `develop` — rama de integración; contiene features ya revisadas.
- `feature/<ticket-id>-short-desc` — ramas cortas por historia/tarea (duración: máximo 3 días). Crear PR hacia `develop`.
- `release/<version>` — cuando `develop` está estable para preparar release; pruebas de integración finales.
- `hotfix/<ticket>` — ramas para correcciones críticas desde `main`.

Protecciones y reglas:
- `main` y `develop` requieren PR y pasar checks (lint, unit tests, build). No push directo.
- PR template con checklist (tests, docs, changelog, owner review).

Rationale: permite desarrollo paralelo, revisiones y control de calidad antes de llegar a `main`.

### 2.2 Branching para operaciones (2.5%)

**Modelo: GitOps/Trunk + env branches**

- Infra y config en repositorio `infrastructure/` (o monorepo subfolder).
- Ramas por entorno: `env/staging` y `env/production` (opcional: `env/qa`).
- Cambios infra: PR hacia `env/staging` -> pipeline de infra aplica a staging tras revisión. Cuando todo OK, PR a `env/production` -> pipeline aplica a producción.
- Alternativa (recomendada): usar GitHub protected branches + Terraform Cloud/ArgoCD para aplicar automáticamente cuando PR mergea en `env/*`.

Rationale: separar ciclo de vida de infra del de dev, permitir revisiones y controlar despliegues infra.

---

## 3. Patrones de diseño de nube (mínimo dos) — (15%)

Proponemos utilizar **Cache-Aside** y **Circuit Breaker**. También se describe **Autoscaling** como patrón de soporte.

### 3.1 Cache-Aside

- Uso: cachear resultados de endpoints costosos o consultas a BD.
- Implementación: Redis (managed) delante de servicios de lectura; la app primero consulta Redis, si miss consulta la base y luego guarda en Redis con TTL.
- Beneficio: reduce latencia y carga en DB.

### 3.2 Circuit Breaker

- Uso: para proteger a consumidores de microservicios de llamadas fallidas a servicios dependientes.
- Implementación: librería como Resilience4j (Java) o Polly (if .NET) o un gateway (Envoy) que implemente circuit breaking. Configuración con límites de errores y ventana de recuperación.
- Beneficio: evita cascadas de fallos y permite degradación controlada.

### 3.3 Autoscaling (soporte)

- Uso: escalar réplicas según CPU/RPS o métricas personalizadas.
- Implementación: Horizontal Pod Autoscaler (K8s) o AWS ECS Service AutoScaling / Fargate autoscaling con Application Auto Scaling.

---