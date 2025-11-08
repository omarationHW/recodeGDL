# Documentación Técnica: Catálogo de Recaudadoras (Migración Delphi → Laravel + Vue.js + PostgreSQL)

## 1. Descripción General
Este módulo implementa el catálogo de recaudadoras, migrando la funcionalidad de Delphi a una arquitectura moderna basada en Laravel (backend/API), Vue.js (frontend SPA) y PostgreSQL (base de datos). El reporte permite visualizar la lista de recaudadoras con diferentes criterios de ordenamiento.

## 2. Arquitectura
- **Backend**: Laravel API, endpoint único `/api/execute` que recibe un objeto `eRequest` y parámetros.
- **Frontend**: Componente Vue.js como página independiente, consulta el API y muestra los datos en tabla.
- **Base de Datos**: PostgreSQL, lógica de consulta encapsulada en stored procedure.

## 3. API Unificada
- **Endpoint**: `/api/execute`
- **Método**: POST
- **Request Body**:
  ```json
  {
    "eRequest": "getRecaudadorasReport",
    "params": { "opcion": 1 }
  }
  ```
- **Response**:
  ```json
  {
    "eResponse": "getRecaudadorasReport",
    "data": [ ... ]
  }
  ```

## 4. Stored Procedure
- **Nombre**: `sp_recaudadoras_report`
- **Parámetro**: `opcion` (integer)
  - 1: Ordenar por id_rec
  - 2: Ordenar por recaudadora
  - 3: Ordenar por domicilio
  - 4: Ordenar por sector, id_rec
- **Retorno**: Tabla con columnas `id_rec`, `recaudadora`, `domicilio`, `sector`

## 5. Frontend (Vue.js)
- Página independiente, muestra encabezados, selección de criterio de ordenamiento y tabla de resultados.
- Actualiza automáticamente al cambiar el criterio.
- Incluye breadcrumb y fecha/hora de impresión.

## 6. Backend (Laravel)
- Controlador `ExecuteController` maneja todas las solicitudes `/api/execute`.
- Llama al stored procedure según el valor de `eRequest`.
- Devuelve los datos en formato JSON.

## 7. Seguridad
- El endpoint puede protegerse con middleware de autenticación según necesidades del proyecto.

## 8. Extensibilidad
- El patrón eRequest/eResponse permite agregar nuevas operaciones sin crear nuevos endpoints.

## 9. Pruebas
- Casos de uso y pruebas detallados en las secciones siguientes.
