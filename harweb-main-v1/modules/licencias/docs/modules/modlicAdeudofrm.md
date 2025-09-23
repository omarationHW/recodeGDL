# Documentación Técnica: Migración de Formulario modlicAdeudofrm (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo permite la gestión de adeudos asociados a licencias y anuncios, permitiendo agregar, modificar, eliminar y listar registros, así como recalcular los saldos globales de la licencia. La migración se realizó de Delphi a una arquitectura moderna basada en Laravel (backend/API), Vue.js (frontend) y PostgreSQL (base de datos).

## 2. Arquitectura
- **Backend:** Laravel 10+, con un único endpoint `/api/execute` que recibe peticiones eRequest/eResponse.
- **Frontend:** Vue.js 3+ (SPA), cada formulario es una página independiente.
- **Base de Datos:** PostgreSQL, con stored procedures para lógica de negocio compleja.

## 3. API Unificada (eRequest/eResponse)
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Formato de petición:**
  ```json
  {
    "eRequest": {
      "action": "list|add|edit|delete|get_saldos",
      "data": { ... }
    }
  }
  ```
- **Formato de respuesta:**
  ```json
  {
    "eResponse": {
      "success": true|false,
      "message": "",
      "data": { ... }
    }
  }
  ```

## 4. Acciones soportadas
- `list`: Listar adeudos de una licencia/anuncio.
- `add`: Agregar un nuevo adeudo.
- `edit`: Modificar un adeudo existente.
- `delete`: Eliminar un adeudo.
- `get_saldos`: Obtener los saldos globales de la licencia.

## 5. Stored Procedure principal
- **calc_sdoslsr:** Recalcula los saldos de la licencia en la tabla `saldos_lic` sumando los valores de `detsal_lic`.

## 6. Validaciones
- Todos los campos requeridos son validados tanto en frontend como en backend.
- No se permite agregar/modificar registros con año vacío o inválido.
- Al eliminar un adeudo, se solicita confirmación al usuario.

## 7. Seguridad
- El endpoint debe estar protegido por autenticación (middleware Laravel, no incluido aquí).
- Validación de parámetros y tipos de datos en backend.

## 8. Consideraciones de Migración
- El formulario Delphi usaba componentes visuales y lógica de eventos; en Vue.js se replicó la experiencia de usuario.
- El recalculo de saldos se realiza siempre que se agrega, edita o elimina un adeudo.
- Los campos ocultos (id_licencia, id_anuncio) se pasan como props o parámetros de ruta en Vue.js.

## 9. Integración
- El componente Vue debe ser montado con los props `idLicencia` y `idAnuncio`.
- El endpoint `/api/execute` debe estar registrado en Laravel routes/api.php.

## 10. Tablas involucradas
- **detsal_lic:** Detalle de adeudos por licencia/anuncio.
- **saldos_lic:** Saldos globales por licencia.

## 11. Extensibilidad
- El patrón eRequest/eResponse permite agregar nuevas acciones fácilmente.
- El stored procedure puede ser extendido para sumar nuevos campos si la lógica de negocio lo requiere.
