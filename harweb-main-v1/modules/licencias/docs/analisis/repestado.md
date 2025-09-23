# Documentación Técnica: Migración de Formulario repestado (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
El formulario **repestado** permite consultar y generar un reporte del estado de un trámite, mostrando información detallada del trámite y sus revisiones. La migración implica transformar la lógica Delphi a una arquitectura moderna basada en Laravel (backend/API), Vue.js (frontend SPA), y PostgreSQL (base de datos), usando un endpoint API unificado y stored procedures para la lógica SQL.

## 2. Arquitectura
- **Backend:** Laravel 10+ (PHP 8), API RESTful, endpoint único `/api/execute`.
- **Frontend:** Vue.js 3 (Composition API o Options API), componente de página independiente.
- **Base de Datos:** PostgreSQL 13+, lógica SQL encapsulada en stored procedures.
- **Patrón de integración:** eRequest/eResponse (entrada y salida JSON estructurado).

## 3. API Backend
- **Ruta:** `POST /api/execute`
- **Entrada:**
  ```json
  {
    "eRequest": {
      "action": "get_estado_tramite", // o "print_reporte"
      "params": { "id_tramite": 12345 }
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
- **Controlador:** `RepEstadoController@execute` maneja todas las acciones relacionadas con el formulario.
- **Seguridad:** Validación de parámetros, manejo de errores, autenticación JWT (si aplica).

## 4. Stored Procedures
- Toda la lógica de consulta se encapsula en SPs. Ejemplo: `sp_repestado_get_estado_tramite` recibe el id_tramite y retorna todos los campos requeridos.
- Los SPs pueden ser extendidos para incluir revisiones, dependencias, etc., si se requiere.

## 5. Frontend Vue.js
- **Componente:** Página independiente (`RepEstadoPage.vue`)
- **Funcionalidad:**
  - Formulario para capturar el número de trámite.
  - Consulta vía API y despliegue de datos.
  - Botón para imprimir/generar reporte (abre PDF o similar).
  - Manejo de estados de carga y error.
  - No usa tabs ni subcomponentes tabulares.
  - Navegación breadcrumb incluida.

## 6. Integración y Flujo
1. Usuario ingresa el número de trámite y presiona buscar.
2. Vue.js llama a `/api/execute` con acción `get_estado_tramite`.
3. Laravel ejecuta el SP y retorna los datos.
4. Vue.js muestra los datos en la página.
5. Si el usuario presiona "Imprimir Reporte", Vue.js llama a la acción `print_reporte` y abre el PDF generado.

## 7. Consideraciones Técnicas
- **Validación:** El backend valida que el parámetro `id_tramite` sea numérico y exista.
- **Errores:** Todos los errores se devuelven en el campo `message` de `eResponse`.
- **Extensibilidad:** El endpoint y el SP pueden ser extendidos para incluir más detalles (revisiones, dependencias, etc.).
- **Seguridad:** Se recomienda proteger el endpoint con autenticación y autorización.

## 8. Migración de SQL
- Todas las consultas SQL del Delphi se migran a stored procedures en PostgreSQL.
- Se usa `COALESCE` para concatenar campos nulos.
- Los campos de tipo memo/texto se mapean a `TEXT` en PostgreSQL.

## 9. Pruebas y QA
- Se proveen casos de uso y escenarios de prueba para validar la funcionalidad.

---
