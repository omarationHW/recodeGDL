# Documentación: ConsUem400

## Análisis Técnico

# Documentación Técnica: Migración Formulario ConsUem400 (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo corresponde a la migración del formulario ConsUem400, que permite consultar datos históricos y comprobantes del sistema UEM-400 (AS400), desde Delphi a una arquitectura moderna basada en Laravel (backend/API), Vue.js (frontend SPA) y PostgreSQL (base de datos).

## 2. Arquitectura
- **Backend:** Laravel 10+ (PHP 8), expone un endpoint único `/api/execute` que recibe eRequest con acción y parámetros.
- **Frontend:** Vue.js 3 SPA, cada formulario es una página independiente, sin tabs.
- **Base de Datos:** PostgreSQL, toda la lógica SQL relevante se implementa como stored procedures/functions.

## 3. API Unificada (eRequest/eResponse)
- **Endpoint:** `POST /api/execute`
- **Entrada (eRequest):**
  ```json
  {
    "action": "search_by_cuenta", // o "search_by_comprobante"
    "params": { ... }
  }
  ```
- **Salida (eResponse):**
  ```json
  {
    "status": "success|error",
    "data": { ... },
    "message": "..."
  }
  ```

## 4. Métodos Disponibles
- `search_by_comprobante`: Consulta por año y comprobante (campos anio, comprob)
- `search_by_cuenta`: Consulta por recaudadora, ur y cuenta (campos recaud, ur, cuenta)

## 5. Stored Procedures
- `sp_cons_uem400_by_comprobante(anio, comprob)`
- `sp_cons_uem400_by_cuenta(recaud, ur, cuenta)`
Ambos devuelven dos tablas (historico y comp_400) en formato JSON.

## 6. Frontend (Vue.js)
- Página independiente `/cons-uem400`
- Dos formularios: búsqueda por cuenta y por comprobante
- Resultados en tablas separadas
- Sin tabs ni pestañas
- Navegación breadcrumb opcional

## 7. Validaciones
- Todos los campos requeridos en frontend y backend
- Manejo de errores y mensajes claros

## 8. Seguridad
- El endpoint `/api/execute` debe estar protegido por autenticación JWT o session según la política del sistema.
- Validar y sanear todos los parámetros recibidos.

## 9. Pruebas y Casos de Uso
- Ver sección de casos de uso y pruebas.

## 10. Extensibilidad
- El patrón eRequest/eResponse permite agregar nuevas acciones sin modificar el endpoint.
- Los stored procedures pueden ser extendidos para lógica adicional.

## 11. Migración de Datos
- Se asume que las tablas `historico` y `comp_400` ya existen y están pobladas en PostgreSQL.

## 12. Notas
- El frontend puede ser adaptado a cualquier framework SPA moderno.
- El backend puede ser adaptado a otros frameworks que soporten el patrón eRequest/eResponse.

## Casos de Uso

> ⚠️ Pendiente de documentar

## Casos de Prueba

> ⚠️ Pendiente de documentar

## Arquitectura

> ⚠️ Pendiente de documentar

## Integración con Backend

> ⚠️ Pendiente de documentar

## Consideraciones de Migración

> ⚠️ Pendiente de documentar

