# 📊 Proyecto: Sistema Automatizado de Conciliación de Transacciones

## 🎯 Caso de Negocio e Impacto
- **Problema:** Procesos manuales de conciliación entre múltiples sistemas (ERP, CRM, Pasarelas de Pago) en Excel, propensos a errores y lentos en resolución.
- **Solución:** Pipeline automatizado de datos con detección de causa raíz, priorización de errores y panel de control operativo.
- **Resultado:** Reducción del tiempo de detección/resolución y visibilidad completa del estado transaccional.

## 🏗️ Arquitectura y Flujo (Antes vs. Después)
[ Diagrama de Arquitectura / Flujo Visual ]

## 🛠️ Stack Tecnológico y Roles
- **Python:** Motor ETL (Limpieza, estandarización y cálculo de diferencias).
- **SQL (DuckDB / Postgres):** Motor analítico de conciliación y consultas de negocio.
- **n8n / Make:** Orquestación de flujos de trabajo para excepciones automatizables.
- **Retool:** Interfaz operativa para monitoreo y resolución humana.

## 📐 Modelo de Datos y Reglas de Negocio
- **Grano de la Información:** 1 fila = 1 transacción única (`transaction_id`).
- **Estados de Conciliación:** `MATCHED`, `MISMATCH`, `PENDING`, `FAILED`, `REVIEW`.
- **Causas Raíz:** Diferencia de monto, error de API, duplicados, discrepancia de fechas/moneda.

* **Matriz de Priorización:**
  * 🔴 **HIGH:** Monto > umbral o fallo total de API → Alerta inmediata.
  * 🟡 **MEDIUM:** Transacción duplicada → Cola de revisión.
  * 🟢 **LOW:** Discrepancia menor de fecha → Resuelto por regla.

---

## 💬 Pitch para Entrevistas (Narrativa Profesional)
> "Diseñé un flujo de reconciliación en el que los datos de transacciones se obtienen mediante APIs, Python se encarga de validar y transformar la información en bruto, SQL ejecuta el análisis de reconciliación, n8n gestiona los flujos de excepciones, y Retool ofrece un dashboard operativo para el analista."