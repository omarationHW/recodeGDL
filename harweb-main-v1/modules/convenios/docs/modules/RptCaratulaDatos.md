# Documentación Técnica: Migración de RptCaratulaDatos (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo corresponde a la migración del formulario **RptCaratulaDatos** de Delphi a una arquitectura moderna basada en Laravel (backend/API), Vue.js (frontend SPA) y PostgreSQL (base de datos). El objetivo es mantener la funcionalidad de consulta y visualización de la carátula de un contrato/convenio, sus pagos y ampliaciones de plazo, con una experiencia de usuario moderna y API RESTful.

## 2. Arquitectura
- **Backend:** Laravel 10+, API RESTful, endpoint único `/api/execute` (patrón eRequest/eResponse).
- **Frontend:** Vue.js 3+, componente de página independiente, navegación tipo breadcrumb, sin tabs.
- **Base de Datos:** PostgreSQL, lógica de negocio encapsulada en stored procedures.

## 3. API Unificada (eRequest/eResponse)
- **Endpoint:** `POST /api/execute`
- **Request:**
  ```json
  {
    "action": "getCaratulaDatos", // o getPagosDetalle, getAmpliacionPlazo
    "params": { "contrato": 123 }
  }
  ```
- **Response:**
  ```json
  {
    "success": true,
    "data": { ... },
    "message": ""
  }
  ```

## 4. Stored Procedures
Toda la lógica SQL y de negocio se implementa en stored procedures PostgreSQL:
- `sp_get_caratula_datos(contrato_id)`
- `sp_get_pagos_detalle(contrato_id)`
- `sp_get_ampliacion_plazo(contrato_id)`

## 5. Controlador Laravel
- Un solo controlador: `RptCaratulaDatosController`
- Métodos privados para cada acción
- Validación de parámetros y manejo de errores
- Uso de DB::select para invocar stored procedures

## 6. Componente Vue.js
- Página independiente `/caratula-datos`
- Formulario de búsqueda por ID de contrato
- Visualización de datos principales, pagos detalle y ampliación de plazo
- Manejo de estados: loading, error, datos
- Uso de Bootstrap para estilos (puede adaptarse a cualquier framework CSS)

## 7. Seguridad
- Validación de parámetros en backend
- Sanitización de entradas
- Uso de roles/autorización en endpoints (a implementar según política de la app)

## 8. Pruebas y Casos de Uso
- Incluye casos de uso para consulta exitosa, contrato inexistente y contrato con ampliación de plazo
- Casos de prueba para validación de parámetros, errores de base de datos y visualización

## 9. Extensibilidad
- El endpoint `/api/execute` puede extenderse para otras acciones relacionadas
- Los stored procedures pueden ser reutilizados por otros módulos

## 10. Migración de lógica Delphi
- Los métodos de cálculo de campos (CalcFields) se migran a SQL o se calculan en frontend según corresponda
- La lógica de presentación (labels, captions) se traslada a la plantilla Vue
- El preview/impresión se reemplaza por visualización web y exportación PDF/Excel (a implementar)

---

# Esquema de Base de Datos
- **ta_17_convenios**: Contratos/convenios principales
- **ta_17_pagos**: Pagos realizados
- **ta_17_amp_plazo**: Ampliaciones de plazo
- **ta_17_hist_conv**: Historia de convenios (original/descuentos)
- **ta_17_colonias, ta_17_servicios, ta_17_tipos, ta_17_calles**: Catálogos

---

# Endpoints y Acciones
| Acción                | Descripción                                 |
|----------------------|---------------------------------------------|
| getCaratulaDatos     | Devuelve todos los datos de la carátula     |
| getPagosDetalle      | Devuelve el detalle de pagos                |
| getAmpliacionPlazo   | Devuelve la última ampliación de plazo      |

---

# Notas de Migración
- Los campos calculados Delphi se implementan como expresiones SQL o en frontend.
- El preview de impresión se reemplaza por visualización web y puede exportarse a PDF/Excel.
- El endpoint es unificado y extensible para futuras acciones.

---
