# Documentación Técnica: Migración Formulario Exenta (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo permite registrar y eliminar exenciones de pago predial para cuentas catastrales. Incluye la consulta de datos del predio, propietario, y la gestión de los movimientos de exención, replicando la lógica del formulario Delphi original.

## 2. Arquitectura
- **Backend:** Laravel Controller (API RESTful, endpoint único `/api/execute`)
- **Frontend:** Vue.js (componente de página independiente, sin tabs)
- **Base de Datos:** PostgreSQL (stored procedures para lógica de negocio)
- **Comunicación:** Patrón eRequest/eResponse (JSON)

## 3. API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Entrada:**
  ```json
  {
    "eRequest": {
      "action": "nombreAccion",
      "data": { ... }
    }
  }
  ```
- **Salida:**
  ```json
  {
    "eResponse": {
      "status": "success|error",
      "message": "...",
      "data": { ... }
    }
  }
  ```

### Acciones soportadas
- `getPredioData`: Obtiene datos del predio y propietario.
- `getExencionStatus`: Consulta si la cuenta tiene exención activa.
- `registrarExencion`: Registra una exención para la cuenta.
- `eliminarExencion`: Elimina la exención de la cuenta.

## 4. Stored Procedures
- **sp_registrar_exencion:** Registra la exención, actualiza catastro, regprop y llama a sp_exento_en_saldos.
- **sp_eliminar_exencion:** Elimina la exención, actualiza catastro, regprop y llama a sp_exento_en_saldos.
- **sp_exento_en_saldos:** Actualiza los saldos de la cuenta para reflejar la exención o su eliminación.

## 5. Validaciones
- No se permite registrar/eliminar exención si la cuenta tiene abstención (cvemov=12).
- El año de efectos debe ser >= 1970.
- El bimestre debe estar entre 1 y 6.
- Solo se permite registrar exención si actualmente no está exenta, y eliminar si está exenta.

## 6. Frontend (Vue.js)
- Página independiente, sin tabs.
- Consulta datos del predio y propietario al cargar.
- Permite registrar o eliminar exención según el estado actual.
- Muestra mensajes de éxito/error.
- Navegación breadcrumb.

## 7. Seguridad
- Todas las operaciones requieren autenticación (middleware Laravel).
- Validaciones de entrada en backend y frontend.

## 8. Pruebas
- Casos de uso y pruebas detalladas en secciones siguientes.

## 9. Consideraciones de Migración
- Los triggers y lógica de Delphi se migran a stored procedures.
- El endpoint es único y flexible para futuras extensiones.
- El frontend es desacoplado y puede integrarse en cualquier SPA.

