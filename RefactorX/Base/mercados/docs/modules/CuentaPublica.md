# Documentación Técnica: Migración Formulario Cuenta Pública (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Arquitectura General
- **Backend:** Laravel 10+ (PHP 8+), API RESTful, endpoint único `/api/execute` (patrón eRequest/eResponse)
- **Frontend:** Vue.js 3 SPA, cada formulario es una página independiente (no tabs)
- **Base de Datos:** PostgreSQL 13+, lógica SQL migrada a stored procedures
- **Autenticación:** Laravel Sanctum/JWT (según política del proyecto)

## 2. API Backend
- **Endpoint:** `POST /api/execute`
- **Request:**
  ```json
  {
    "action": "getEstadAdeudo", // o getTotalAdeudo, getCuentaPublicaReport, etc
    "params": { "oficina": 1, "axo": 2024, "periodo": 6 }
  }
  ```
- **Response:**
  ```json
  {
    "success": true,
    "data": [ ... ],
    "message": ""
  }
  ```
- **Acciones soportadas:**
  - `getRecaudadoras`: Lista de recaudadoras
  - `getEstadAdeudo`: Llama SP para resumen por mercado y mes
  - `getTotalAdeudo`: Llama SP para resumen por recaudadora y mes
  - `getCuentaPublicaReport`: Llama SP para reporte imprimible/exportable

## 3. Stored Procedures PostgreSQL
- Toda la lógica de agregación y consulta de adeudos se implementa en SPs.
- Los SPs reciben parámetros y devuelven tablas (RETURNS TABLE)
- Se recomienda crear índices en `ta_11_locales.vigencia`, `ta_11_locales.oficina`, `ta_11_adeudo_local.axo`, etc.

## 4. Frontend Vue.js
- Página independiente `/cuenta-publica` (ruta propia)
- Formulario con selección de recaudadora, año y mes
- Botón de consulta y botón de impresión/exportación
- Dos tablas: resumen por mercado/mes y resumen por recaudadora/mes
- Totales calculados en frontend
- Navegación breadcrumb
- Uso de Axios para llamadas al endpoint `/api/execute`
- Manejo de loading y errores

## 5. Seguridad
- Validación de parámetros en backend
- Solo usuarios autenticados pueden consultar
- Los SPs no permiten SQL injection (parámetros tipados)

## 6. Extensibilidad
- El endpoint `/api/execute` puede ser extendido para otras acciones
- Los SPs pueden ser reutilizados por otros reportes

## 7. Pruebas y Auditoría
- Todas las acciones quedan registradas en logs de Laravel
- Los SPs pueden ser auditados vía logs de PostgreSQL

## 8. Migración de Datos
- Se recomienda migrar los datos de las tablas originales a PostgreSQL usando ETL (no incluido en este código)

## 9. Consideraciones de UI/UX
- No usar tabs ni componentes tabulares para formularios
- Cada formulario es una página completa
- Breadcrumb para navegación
- Tablas responsivas y exportables

## 10. Dependencias
- Laravel 10+
- Vue.js 3+
- Axios
- Bootstrap 4/5 (opcional para estilos)

---
