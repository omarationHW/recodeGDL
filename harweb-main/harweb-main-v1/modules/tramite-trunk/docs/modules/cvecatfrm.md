# Documentación Técnica: Migración de Formulario Clave Catastral (cvecatfrm)

## Arquitectura General
- **Backend**: Laravel (PHP) + PostgreSQL
- **Frontend**: Vue.js SPA (Single Page Application)
- **API**: Único endpoint `/api/execute` que recibe eRequest (action, data) y responde eResponse (status, data, errors)
- **Stored Procedures**: Toda la lógica de negocio y validación SQL se implementa en funciones/procedimientos almacenados de PostgreSQL

## Flujo de la Página
1. **Carga de datos**: Al entrar a la página, se consulta la información de la cuenta catastral, propietario y ubicación usando `getCveCatInfo`.
2. **Visualización**: Se muestran los datos actuales y un formulario para capturar la nueva clave catastral y subpredio.
3. **Validación**: Al enviar el formulario, se valida la clave catastral con reglas de negocio (longitud, zona, subzona, unicidad) usando `validateCveCat`.
4. **Bloqueo de manzana**: Se verifica si la manzana está bloqueada antes de permitir el cambio.
5. **Actualización**: Si todo es válido, se actualiza la clave catastral y subpredio, y se registra el movimiento en la tabla de catastro.

## API Unificada
- **Endpoint**: `/api/execute`
- **Método**: POST
- **Entrada**: `{ action: string, data: object }`
- **Salida**: `{ status: 'ok'|'error', data: object|null, errors: array }`

### Acciones soportadas
- `getCveCatInfo`: Obtiene información de la cuenta
- `validateCveCat`: Valida la nueva clave catastral
- `updateCveCat`: Actualiza la clave catastral y subpredio
- `checkBlockedManzana`: Verifica si la manzana está bloqueada

## Stored Procedures
- Toda la lógica de validación y actualización se implementa en funciones PL/pgSQL.
- El controlador Laravel invoca estos procedimientos usando DB::select/DB::update según corresponda.

## Frontend (Vue.js)
- Cada formulario es una página independiente (no tabs)
- El componente obtiene la cuenta por parámetro de ruta
- Validaciones y mensajes de error se muestran en tiempo real
- Navegación y breadcrumbs pueden agregarse según el router principal

## Seguridad
- El endpoint requiere autenticación (no incluida aquí, pero debe usarse middleware de Laravel)
- Los cambios quedan auditados por usuario y asiento

## Consideraciones
- El frontend asume que el usuario está autenticado y su nombre de usuario está disponible
- El backend debe validar permisos antes de permitir cambios
- El endpoint es genérico y puede extenderse para otras acciones
