# Documentación Técnica: Migración de Formulario sfrm_abc_propietario

## 1. Descripción General
Este módulo permite el registro de personas físicas o morales (propietarios) en la base de datos PostgreSQL, migrando la lógica desde Delphi a una arquitectura moderna con Laravel (API) y Vue.js (frontend). Toda la lógica de negocio y validación se centraliza en stored procedures y un endpoint API unificado.

## 2. Arquitectura
- **Frontend**: Vue.js SPA, cada formulario es una página independiente.
- **Backend**: Laravel, controlador único para /api/execute usando patrón eRequest/eResponse.
- **Base de Datos**: PostgreSQL, lógica de negocio en stored procedures.

## 3. API Unificada
- **Endpoint**: `/api/execute`
- **Método**: POST
- **Request**: `{ eRequest: { operation: string, data: object } }`
- **Response**: `{ eResponse: { success: bool, message: string, data: object|null } }`

### Operaciones soportadas
- `check_rfc_exists`: Verifica si un RFC ya existe.
- `insert_persona`: Inserta un nuevo propietario si el RFC no existe.

## 4. Stored Procedures
- **check_rfc_exists(p_rfc)**: Devuelve si el RFC existe (boolean).
- **insert_persona(...)**: Inserta registro, valida duplicidad, retorna id y mensaje.

## 5. Validaciones
- RFC mínimo 9 caracteres, máximo 13.
- Nombre/Razón Social obligatorio.
- Sociedad: 'F' (Física) o 'M' (Moral).
- No se permite duplicidad de RFC.

## 6. Seguridad
- El campo `usu_inicial` debe ser obtenido del usuario autenticado (en este ejemplo es simulado).
- Todas las entradas se validan tanto en frontend como backend.

## 7. Flujo de Registro
1. Usuario ingresa RFC y el sistema verifica duplicidad.
2. Si el RFC no existe, se habilita el registro.
3. Al guardar, se llama a `insert_persona`.
4. El resultado se muestra al usuario.

## 8. Errores y Mensajes
- Mensajes claros para duplicidad, errores de validación y éxito.
- Cancelar limpia el formulario y muestra mensaje de cancelación.

## 9. Consideraciones
- El formulario es una página independiente, sin tabs.
- El campo dirección es opcional.
- El campo IFE es opcional.

## 10. Extensibilidad
- Se pueden agregar más operaciones al endpoint unificado siguiendo el patrón eRequest/eResponse.
