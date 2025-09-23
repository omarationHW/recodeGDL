# Documentación Técnica: Condonación de Adeudos (AdeudosCN_Cond)

## Descripción General
Este módulo permite condonar (marcar como condonado) un adeudo de exedencia vigente para un contrato, periodo y tipo de operación. La migración se realizó desde Delphi a Laravel + Vue.js + PostgreSQL, usando un endpoint API unificado y stored procedures para la lógica de negocio.

## Arquitectura
- **Frontend**: Vue.js SPA, cada formulario es una página independiente.
- **Backend**: Laravel, controlador único para /api/execute, patrón eRequest/eResponse.
- **Base de Datos**: PostgreSQL, lógica crítica en stored procedures.

## Flujo de Proceso
1. El usuario ingresa los datos del contrato, tipo de aseo, año, mes, tipo de movimiento y oficio.
2. El frontend consulta los catálogos necesarios (tipos de aseo y operación).
3. El frontend valida la existencia del contrato y la exedencia vigente para el periodo y operación.
4. Si existe, ejecuta la stored procedure para condonar el adeudo.
5. El backend responde con éxito o error y el frontend muestra el mensaje correspondiente.

## API
- **Endpoint**: POST /api/execute
- **Patrón**: { action: string, params: object }
- **Acciones soportadas**:
    - getCatalogs
    - getContratoInfo
    - checkExedenciaVigente
    - condonarAdeudo

## Stored Procedure
- **sp16_condona_adeudo**: Encapsula la lógica de condonación, validando existencia y estado del adeudo antes de actualizarlo.

## Validaciones
- Todos los campos son obligatorios.
- El contrato debe existir.
- Debe existir un adeudo vigente para el periodo y tipo de operación.
- El usuario debe estar autenticado (para registrar el usuario que realiza la condonación).

## Seguridad
- El endpoint requiere autenticación (Laravel middleware auth:api recomendado).
- El usuario que ejecuta la condonación queda registrado en la tabla de pagos.

## Manejo de Errores
- Todos los errores se devuelven en formato { success: false, message: '...' }.
- Errores de validación y de base de datos se manejan y reportan al usuario.

## Consideraciones
- El frontend no permite tabs ni componentes tabulares, cada formulario es una página.
- El endpoint es único y multipropósito, siguiendo el patrón eRequest/eResponse.
- Toda la lógica de negocio crítica reside en stored procedures para facilitar auditoría y portabilidad.

## Extensibilidad
- El patrón eRequest/eResponse permite agregar nuevas acciones sin modificar el endpoint.
- Los catálogos pueden ser cacheados en frontend para mejorar rendimiento.

