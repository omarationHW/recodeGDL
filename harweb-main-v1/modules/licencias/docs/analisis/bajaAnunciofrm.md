# Documentación Técnica: Migración de Formulario Baja de Anuncio (Delphi) a Laravel + Vue.js + PostgreSQL

## Arquitectura General
- **Backend**: Laravel API con endpoint único `/api/execute` que recibe un objeto `eRequest` con acción, parámetros y usuario.
- **Frontend**: Componente Vue.js como página independiente, sin tabs, con navegación y validaciones.
- **Base de Datos**: PostgreSQL, toda la lógica SQL encapsulada en stored procedures.
- **Comunicación**: El frontend llama a `/api/execute` enviando la acción y parámetros, y recibe la respuesta en `eResponse`.

## Flujo de Trabajo
1. **Búsqueda de Anuncio**: El usuario ingresa el número de anuncio y presiona buscar. El frontend llama a `/api/execute` con acción `buscar_anuncio`.
2. **Visualización**: Se muestran los datos del anuncio, licencia relacionada, propietario y adeudos (si existen).
3. **Verificación de Permisos**: El backend puede verificar los permisos del usuario para mostrar u ocultar opciones de baja por error o baja en tiempo.
4. **Baja de Anuncio**: Si el anuncio está vigente y no tiene adeudos, el usuario puede dar de baja el anuncio, indicando motivo, año y folio (a menos que sea baja por error o en tiempo). El frontend llama a `/api/execute` con acción `baja_anuncio`.
5. **Procesamiento**: El stored procedure realiza la baja, cancela los adeudos y recalcula el saldo de la licencia.
6. **Respuesta**: El backend responde con el resultado de la operación.

## API Unificada (eRequest/eResponse)
- **Endpoint**: `/api/execute`
- **Entrada**: `{ eRequest: { action: 'buscar_anuncio'|'baja_anuncio'|'verificar_permisos', params: {...}, user: ... } }`
- **Salida**: `{ eResponse: { status: 'ok'|'error', data: ..., errors: [...] } }`

## Seguridad
- El backend valida permisos y estado del anuncio antes de permitir la baja.
- El frontend muestra u oculta campos según los permisos del usuario.

## Validaciones
- No se permite baja si el anuncio no está vigente o tiene adeudos.
- Si es baja por error o en tiempo, no se requieren año/folio.
- El motivo es opcional pero recomendable.

## Navegación
- El componente Vue es una página completa, sin tabs.
- Puede integrarse en un router como `/baja-anuncio`.

## Stored Procedures
- Toda la lógica de negocio y validación reside en los SPs de PostgreSQL.
- El recalculo de saldos se realiza vía SP `calc_sdosl`.

## Extensibilidad
- El patrón eRequest/eResponse permite agregar nuevas acciones sin modificar el endpoint.
- Los SPs pueden evolucionar sin afectar el frontend.

## Errores y Mensajes
- Todos los errores se devuelven en el campo `errors` de la respuesta.
- El frontend muestra los mensajes de error o éxito según corresponda.
