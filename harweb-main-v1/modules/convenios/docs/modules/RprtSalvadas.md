# Documentación Técnica: Migración de Formulario RprtSalvadas (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo corresponde a la migración del formulario de reporte "RprtSalvadas" desde Delphi a una arquitectura moderna basada en Laravel (backend/API), Vue.js (frontend) y PostgreSQL (base de datos). El reporte permite consultar y visualizar registros de "salvadas" (acciones guardadas) filtrando por usuario y rango de fechas.

## 2. Arquitectura
- **Backend:** Laravel API, endpoint unificado `/api/execute` bajo el patrón eRequest/eResponse.
- **Frontend:** Componente Vue.js como página independiente.
- **Base de Datos:** PostgreSQL, lógica de reporte encapsulada en stored procedure.

## 3. API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Request:**
  ```json
  {
    "eRequest": "RprtSalvadas.generateReport",
    "params": {
      "user_id": 123, // opcional
      "date_from": "2024-06-01", // opcional
      "date_to": "2024-06-30" // opcional
    }
  }
  ```
- **Response:**
  ```json
  {
    "success": true,
    "data": [
      {
        "user_id": 123,
        "user_name": "Juan Perez",
        "saved_at": "2024-06-15",
        "description": "Registro de ejemplo",
        "status": "Activo"
      },
      ...
    ],
    "message": "Reporte generado correctamente."
  }
  ```

## 4. Stored Procedure
- **Nombre:** `rprt_salvadas_report`
- **Parámetros:**
  - `user_id` (integer, opcional)
  - `date_from` (date, opcional)
  - `date_to` (date, opcional)
- **Retorna:** Tabla con columnas: user_id, user_name, saved_at, description, status
- **Lógica:** Filtra por usuario y rango de fechas si se especifican.

## 5. Frontend (Vue.js)
- Página independiente con formulario para filtros y tabla de resultados.
- Llama al endpoint `/api/execute` usando fetch/AJAX.
- Muestra mensajes de error, carga y resultados.

## 6. Consideraciones de Seguridad
- Validar y sanear los parámetros recibidos.
- El endpoint debe estar protegido por autenticación (no incluido en este ejemplo).
- El stored procedure previene inyección SQL al usar parámetros.

## 7. Supuestos
- Existe una tabla `salvadas` con los campos: id, user_id, saved_at, description, status.
- Existe una tabla `users` con los campos: id, name.
- El frontend y backend están correctamente conectados.

## 8. Extensibilidad
- Se pueden agregar más filtros o columnas al reporte fácilmente.
- El patrón eRequest/eResponse permite agregar más operaciones sin crear nuevos endpoints.
