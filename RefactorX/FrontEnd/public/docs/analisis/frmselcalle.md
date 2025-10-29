# Documentación Técnica: Migración de Formulario frmselcalle (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo corresponde a la migración del formulario de selección de calles (`frmselcalle`) desde Delphi a una arquitectura moderna basada en Laravel (backend/API), Vue.js (frontend) y PostgreSQL (base de datos). El formulario permite buscar calles por nombre y seleccionar una o varias para su posterior uso.

## 2. Arquitectura
- **Backend:** Laravel, expone un endpoint único `/api/execute` que recibe peticiones con el patrón `eRequest`/`eParams` y responde con `eResponse`.
- **Frontend:** Vue.js, componente de página completa, sin tabs, con tabla de selección múltiple y filtro en tiempo real.
- **Base de Datos:** PostgreSQL, lógica SQL encapsulada en stored procedures.

## 3. API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Payload:**
  ```json
  {
    "eRequest": "get_calles",
    "eParams": { "filter": "AVENIDA" }
  }
  ```
- **Respuesta:**
  ```json
  {
    "eResponse": {
      "success": true,
      "data": [ { "cvecalle": 1, "calle": "AVENIDA CENTRAL" }, ... ],
      "message": ""
    }
  }
  ```

## 4. Stored Procedures
- **sp_get_calles(filter TEXT):** Devuelve todas las calles o filtra por prefijo.
- **sp_get_calle_by_ids(ids_csv TEXT):** Devuelve las calles cuyos IDs estén en la lista.

## 5. Frontend (Vue.js)
- Página independiente `/frmselcalle`.
- Input para filtrar calles (convierte a mayúsculas automáticamente).
- Tabla con selección múltiple (checkboxes).
- Botón "Aceptar" muestra los IDs seleccionados.
- Breadcrumb de navegación.

## 6. Backend (Laravel)
- Controlador `ExecuteController` maneja todas las operaciones vía `/api/execute`.
- Llama a los stored procedures según el valor de `eRequest`.
- Manejo de errores y logging.

## 7. Seguridad
- Validación básica de parámetros.
- Uso de prepared statements en Laravel para evitar SQL Injection.

## 8. Consideraciones
- El filtro es por prefijo (como `matches` en Delphi), usando `ILIKE` en PostgreSQL.
- La selección múltiple se maneja en frontend y puede ser enviada al backend para obtener detalles si es necesario.

## 9. Extensibilidad
- Se pueden agregar más operaciones en el mismo endpoint agregando nuevos valores de `eRequest` y sus procedimientos asociados.
