# Documentación Técnica: Migración de Formulario RprtSalvadas

## Descripción General
Este módulo corresponde a la migración del formulario Delphi `RprtSalvadas` a una arquitectura moderna basada en Laravel (backend/API), Vue.js (frontend) y PostgreSQL (base de datos). El objetivo es permitir la generación y visualización de reportes de "salvadas" (registros) entre dos fechas.

## Arquitectura
- **Frontend:** Vue.js SPA, página independiente para el reporte.
- **Backend:** Laravel API, endpoint unificado `/api/execute` usando patrón eRequest/eResponse.
- **Base de Datos:** PostgreSQL, lógica de reporte encapsulada en stored procedure.

## Flujo de Datos
1. El usuario ingresa un rango de fechas y solicita el reporte.
2. El frontend envía una petición POST a `/api/execute` con un objeto `eRequest` que especifica la operación y los parámetros.
3. El backend interpreta la operación, ejecuta el stored procedure correspondiente y retorna los resultados en un objeto `eResponse`.
4. El frontend muestra los resultados en una tabla.

## Detalles Técnicos
### Endpoint API
- **URL:** `/api/execute`
- **Método:** POST
- **Request:**
  ```json
  {
    "eRequest": {
      "operation": "getSalvadasReport",
      "params": {
        "start_date": "2024-06-01",
        "end_date": "2024-06-30"
      }
    }
  }
  ```
- **Response:**
  ```json
  {
    "eResponse": {
      "success": true,
      "data": [
        {"fecha": "2024-06-01", "descripcion": "Ejemplo", "valor": 100.0},
        ...
      ],
      "message": ""
    }
  }
  ```

### Stored Procedure
- **Nombre:** report_salvadas
- **Parámetros:** start_date (DATE), end_date (DATE)
- **Retorna:** Tabla con columnas fecha, descripcion, valor

### Frontend
- Página Vue.js independiente
- Formulario para seleccionar fechas
- Tabla de resultados
- Mensajes de error y estado

## Seguridad
- Validación de fechas en frontend y backend
- Manejo de errores y mensajes claros
- El endpoint puede protegerse con autenticación según necesidades del proyecto

## Consideraciones
- El stored procedure debe adaptarse a la estructura real de la tabla `salvadas`.
- El frontend puede ampliarse para exportar a PDF/Excel si se requiere.
