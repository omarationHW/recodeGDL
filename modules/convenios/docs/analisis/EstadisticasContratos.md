# Documentación Técnica: Migración de Estadísticas Contratos (Delphi → Laravel + Vue.js + PostgreSQL)

## 1. Arquitectura General
- **Backend:** Laravel 10+ (PHP 8), API RESTful, endpoint único `/api/execute` (patrón eRequest/eResponse)
- **Frontend:** Vue.js 3 SPA, cada formulario es una página independiente (NO tabs)
- **Base de Datos:** PostgreSQL 13+, lógica de negocio en stored procedures
- **Comunicación:** JSON, autenticación recomendada vía JWT o Laravel Sanctum

## 2. API Unificada (eRequest/eResponse)
- **Endpoint:** `POST /api/execute`
- **Entrada:**
  ```json
  {
    "eRequest": {
      "action": "getEstadisticasContratos", // o getAdeudosVencidos, getRecaudacion, getEstadisticasPeriodos
      "params": { ... }
    }
  }
  ```
- **Salida:**
  ```json
  {
    "eResponse": {
      "success": true,
      "data": [ ... ],
      "message": ""
    }
  }
  ```

## 3. Stored Procedures
- Toda la lógica de reportes y consultas reside en stored procedures PostgreSQL.
- Los procedimientos reciben parámetros y devuelven tablas (RETURNS TABLE).
- Ejemplo de llamada desde Laravel:
  ```php
  DB::select('CALL spd_17_adeudo_venc(?, ?)', [$anioObra, $fondo]);
  ```

## 4. Controlador Laravel
- Un solo controlador maneja todas las acciones relacionadas con Estadísticas Contratos.
- Métodos privados para cada acción (estadísticas, adeudos, recaudación, periodos).
- Manejo de errores y logging.

## 5. Componente Vue.js
- Página independiente, sin tabs.
- Permite seleccionar el tipo de listado, fondo, año de obra, fechas, etc.
- Muestra resultados en tabla dinámica.
- Exportación simple a CSV (puede mejorarse a Excel con librerías externas).

## 6. Seguridad
- Se recomienda proteger el endpoint con autenticación (JWT/Sanctum).
- Validar y sanitizar todos los parámetros recibidos.

## 7. Extensibilidad
- Para agregar nuevos reportes, basta con crear un nuevo stored procedure y agregar el case correspondiente en el controlador.

## 8. Pruebas
- Se recomienda usar Postman para pruebas de API y Cypress/Jest para frontend.

## 9. Despliegue
- Backend: Docker o servidor PHP con PostgreSQL.
- Frontend: SPA compilada, servir desde Nginx/Apache o como static assets.

## 10. Notas
- El frontend es desacoplado: puede integrarse en cualquier SPA Vue.js.
- El backend puede ampliarse para otros formularios siguiendo el mismo patrón.
