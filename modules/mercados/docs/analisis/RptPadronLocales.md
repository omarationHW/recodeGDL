# Documentación Técnica: Migración de RptPadronLocales (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Arquitectura General
- **Backend:** Laravel (PHP 8+), API RESTful, endpoint único `/api/execute` usando patrón eRequest/eResponse.
- **Frontend:** Vue.js SPA, cada formulario es una página independiente (no tabs).
- **Base de Datos:** PostgreSQL, toda la lógica SQL encapsulada en stored procedures.
- **Comunicación:** El frontend consume el endpoint `/api/execute` enviando `{ action, params }` y recibe `{ success, data, message }`.

## 2. Flujo de Datos
1. El usuario accede a la página de Padrón de Locales.
2. El componente Vue carga recaudadoras y mercados vía `/api/execute` (`getRecaudadora`, `getMercado`).
3. Al seleccionar y consultar, Vue envía `getPadronLocales` con parámetros.
4. Laravel recibe la petición, despacha al stored procedure correspondiente y retorna los datos.
5. Vue muestra la tabla y totales.

## 3. Backend (Laravel)
- **Controlador:** `RptPadronLocalesController`
  - Método único `execute(Request $request)`.
  - Despacha según `action` a métodos privados que llaman los stored procedures.
  - Maneja errores y retorna respuesta estándar.
- **Seguridad:**
  - Se recomienda proteger el endpoint con autenticación JWT o session según el contexto.
  - Validar parámetros antes de ejecutar SPs.

## 4. Frontend (Vue.js)
- **Componente:** `PadronLocalesPage.vue`
  - Página completa, sin tabs.
  - Formulario para seleccionar recaudadora y mercado.
  - Tabla de resultados con totales calculados en frontend.
  - Manejo de loading y errores.
  - Uso de breadcrumbs para navegación.

## 5. Stored Procedures (PostgreSQL)
- Todos los queries SQL del formulario se encapsulan en SPs.
- Los SPs devuelven tablas con los campos necesarios, incluyendo campos calculados (vigencia, renta, etc).
- Se recomienda usar transacciones sólo donde sea necesario (no para consultas).

## 6. API Unificada
- **Endpoint:** `/api/execute` (POST)
- **Request:**
  ```json
  {
    "action": "getPadronLocales",
    "params": { "oficina": 1, "mercado": 2 }
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

## 7. Validaciones y Seguridad
- Validar que los parámetros requeridos estén presentes antes de llamar SPs.
- Manejar errores de base de datos y retornar mensajes claros.
- Limitar el acceso a usuarios autenticados.

## 8. Extensibilidad
- Para agregar nuevos formularios, crear nuevos SPs y métodos en el controlador.
- El frontend puede agregar nuevas páginas siguiendo el mismo patrón.

## 9. Pruebas
- Se recomienda usar PHPUnit para backend y Cypress/Jest para frontend.
- Los casos de uso y pruebas deben cubrir escenarios de éxito, error y edge cases.

---
