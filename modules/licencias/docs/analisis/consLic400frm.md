# Documentación Técnica: Migración Formulario consLic400frm (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este proyecto migra el formulario consLic400frm de Delphi a una arquitectura moderna basada en Laravel (backend/API), Vue.js (frontend SPA) y PostgreSQL (base de datos). El formulario permite consultar datos de licencias (lic_400) y sus pagos (pago_lic_400) mediante una interfaz web y un API unificado.

## 2. Arquitectura
- **Backend:** Laravel 10+, API RESTful, endpoint único `/api/execute`.
- **Frontend:** Vue.js 2/3 SPA, rutas independientes para cada formulario.
- **Base de Datos:** PostgreSQL, lógica encapsulada en stored procedures.

## 3. API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Formato de entrada:**
  ```json
  {
    "eRequest": "getLic400", // o "getPagoLic400"
    "params": { ... }
  }
  ```
- **Formato de salida:**
  ```json
  {
    "eResponse": {
      "success": true|false,
      "message": "...",
      "data": [ ... ]
    }
  }
  ```

## 4. Stored Procedures
- **get_lic_400(p_licencia INTEGER):** Devuelve los datos de la licencia.
- **get_pago_lic_400(p_numlic INTEGER):** Devuelve los pagos asociados a la licencia.

## 5. Frontend (Vue.js)
- **Página 1:** Consulta de datos de la licencia (`/lic400/datos`)
- **Página 2:** Consulta de pagos de la licencia (`/lic400/pagos`)
- Navegación entre páginas mediante router-link.
- Cada página es independiente y funcional por sí sola.

## 6. Backend (Laravel)
- **Controlador:** `Api\ExecuteController`
- **Métodos:**
  - `getLic400`: Llama a SP `get_lic_400`.
  - `getPagoLic400`: Llama a SP `get_pago_lic_400`.
- **Validación:** Parámetros requeridos, manejo de errores.

## 7. Seguridad
- Validación de parámetros en backend.
- No se exponen queries directas, sólo SP parametrizados.

## 8. Pruebas
- Casos de uso y escenarios de prueba detallados (ver más abajo).

## 9. Consideraciones
- El frontend asume uso de Axios y Vue Router.
- El backend asume conexión PostgreSQL configurada en `.env`.
- Los nombres de campos y tablas deben coincidir con la estructura original.

## 10. Extensibilidad
- El endpoint `/api/execute` puede ampliarse para otros formularios y operaciones siguiendo el patrón eRequest/eResponse.
