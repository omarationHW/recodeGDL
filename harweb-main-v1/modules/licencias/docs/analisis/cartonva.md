# Documentación Técnica: Migración Formulario Cartografía Predial (cartonva)

## 1. Descripción General
Este módulo permite consultar la información de una cuenta catastral y visualizar su cartografía predial en un visor web externo. El formulario original en Delphi ha sido migrado a una arquitectura moderna basada en Laravel (backend/API), Vue.js (frontend SPA), y PostgreSQL (base de datos y lógica de negocio).

## 2. Arquitectura
- **Backend:** Laravel 10+ (PHP 8), API RESTful, endpoint único `/api/execute`.
- **Frontend:** Vue.js 3, componente de página independiente, sin tabs.
- **Base de Datos:** PostgreSQL 13+, lógica encapsulada en stored procedures.
- **Patrón de integración:** eRequest/eResponse (entrada/salida JSON).

## 3. API Backend
- **Endpoint:** `POST /api/execute`
- **Entrada:**
  ```json
  {
    "eRequest": {
      "action": "getCartografiaPredial",
      "params": { "cvecuenta": 123456 }
    }
  }
  ```
- **Salida:**
  ```json
  {
    "eResponse": {
      "success": true,
      "cuenta": { ... },
      "visor_url": "http://192.168.4.20:8080/Visor/index.html#user=123&session=se123&clavePredi0=XXXXXX"
    }
  }
  ```
- **Acciones soportadas:**
  - `getCartografiaPredial`: Devuelve datos de la cuenta y URL del visor.
  - `getCuentaByCvecuenta`: Devuelve solo los datos de la cuenta.
  - `getVisorUrl`: Devuelve solo la URL del visor para una clave catastral.

## 4. Stored Procedures
- Toda la lógica SQL se encapsula en funciones PostgreSQL (`sp_get_cartografia_predial`, `sp_get_cuenta_by_cvecuenta`).
- El backend invoca estos SP vía DB::select o DB::statement.

## 5. Frontend (Vue.js)
- Página independiente `/cartografia-predial`.
- Formulario para ingresar la clave de cuenta catastral.
- Al buscar, muestra los datos y un iframe con el visor cartográfico.
- No usa tabs ni componentes tabulares.
- Incluye breadcrumbs y manejo de errores.

## 6. Seguridad
- Validación de parámetros en backend y frontend.
- Manejo de errores y mensajes claros al usuario.
- No expone SQL ni rutas internas.

## 7. Extensibilidad
- El endpoint `/api/execute` puede ser extendido para otras acciones relacionadas.
- El componente Vue puede ser reutilizado en otras vistas.

## 8. Configuración
- La URL base del visor puede configurarse en `config/cartonva.php` en Laravel.

## 9. Pruebas
- Incluye casos de uso y escenarios de prueba para asegurar la funcionalidad.

---
