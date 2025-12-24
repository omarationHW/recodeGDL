# Documentación Técnica: Migración de Formulario PagosEspe (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo permite la autorización y cancelación de pagos especiales para cuentas catastrales. Incluye la migración de la lógica de negocio, validaciones y flujos de trabajo del formulario Delphi original a una arquitectura moderna basada en Laravel (backend/API), Vue.js (frontend) y PostgreSQL (base de datos).

## 2. Arquitectura
- **Backend:** Laravel Controller con endpoint único `/api/execute` (patrón eRequest/eResponse).
- **Frontend:** Componente Vue.js como página independiente (no tabs).
- **Base de Datos:** PostgreSQL con stored procedures para lógica de negocio y validaciones.

## 3. Flujo de Trabajo
- El usuario ingresa los datos de autorización de pago especial.
- El sistema valida:
  - Que la cuenta esté activa y no exenta/cancelada.
  - Que los bimestres y años sean válidos.
  - Que no exista ya un pago especial vigente.
- Si todo es correcto, se autoriza el pago especial y se registra en la tabla `autpagoesp`.
- El usuario puede ver la lista de pagos especiales autorizados para la cuenta.
- Si el pago especial está vigente (no pagado ni cancelado), puede cancelarlo.

## 4. API Backend
- **Endpoint:** `/api/execute`
- **Métodos soportados:**
  - `list`: Lista pagos especiales por cuenta.
  - `authorize`: Autoriza un nuevo pago especial.
  - `cancel`: Cancela un pago especial vigente.
- **Patrón:** eRequest/eResponse (el campo `action` determina la operación).

## 5. Frontend (Vue.js)
- Página independiente con formulario de autorización y tabla de pagos especiales.
- Validaciones en frontend y backend.
- Mensajes de éxito/error claros.
- Acciones disponibles según el estado del pago especial.

## 6. Stored Procedures PostgreSQL
- Toda la lógica de negocio y validaciones críticas se implementan en stored procedures:
  - `sp_autpagoesp_list`: Listar pagos especiales por cuenta.
  - `sp_autpagoesp_authorize`: Autorizar pago especial (con validaciones).
  - `sp_autpagoesp_cancel`: Cancelar pago especial (con validaciones).

## 7. Seguridad
- Todas las acciones requieren autenticación (Laravel middleware).
- El usuario que realiza la acción queda registrado en los campos de auditoría.

## 8. Manejo de Errores
- Los errores de validación y de negocio se devuelven en el campo `message` del eResponse.
- El frontend muestra los mensajes de error al usuario.

## 9. Pruebas y Casos de Uso
- Se incluyen casos de uso y escenarios de prueba para validar la funcionalidad y robustez del sistema.

## 10. Consideraciones de Migración
- Los nombres de campos y lógica de validación se respetan según el código Delphi original.
- Las operaciones de base de datos se migran a PostgreSQL, adaptando tipos de datos y sintaxis.
- El frontend Vue.js es una página completa, sin tabs ni componentes tabulares.

---