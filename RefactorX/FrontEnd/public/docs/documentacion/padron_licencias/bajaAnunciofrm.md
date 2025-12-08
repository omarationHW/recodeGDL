# Documentación Técnica: bajaAnunciofrm

## Análisis Técnico

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

## Casos de Prueba

# Casos de Prueba: Baja de Anuncio

## Caso 1: Baja exitosa de anuncio sin adeudos
- Ingresar número de anuncio válido, vigente y sin adeudos
- Ingresar motivo, año y folio
- Presionar 'Dar de baja'
- Verificar que el anuncio queda cancelado y los adeudos se actualizan

## Caso 2: Intento de baja con adeudos
- Ingresar número de anuncio con adeudos activos
- Verificar que el botón de baja está deshabilitado y se muestra advertencia

## Caso 3: Baja por error (usuario especial)
- Ingresar como usuario con permisos especiales
- Buscar anuncio vigente y sin adeudos
- Marcar 'Baja por error' y dar de baja
- Verificar que no se requieren año/folio y la baja se realiza

## Caso 4: Baja de anuncio ya cancelado
- Ingresar número de anuncio ya cancelado
- Verificar que se muestra mensaje de advertencia y no se permite baja

## Caso 5: Validación de campos obligatorios
- Intentar dar de baja sin ingresar año/folio (sin marcar baja por error/tiempo)
- Verificar que se muestra mensaje de error y no se procesa la baja

## Casos de Uso

# Casos de Uso - bajaAnunciofrm

**Categoría:** Form

## Caso de Uso 1: Baja de anuncio vigente sin adeudos

**Descripción:** El usuario da de baja un anuncio que está vigente y no tiene adeudos.

**Precondiciones:**
El usuario tiene permisos para dar de baja anuncios. El anuncio existe, está vigente y no tiene adeudos.

**Pasos a seguir:**
1. El usuario ingresa el número de anuncio y presiona 'Buscar'.
2. El sistema muestra los datos del anuncio y confirma que no tiene adeudos.
3. El usuario ingresa el motivo, año y folio de baja.
4. El usuario presiona 'Dar de baja'.
5. El sistema procesa la baja y muestra mensaje de éxito.

**Resultado esperado:**
El anuncio queda con estado 'C' (cancelado), los adeudos se cancelan y el saldo de la licencia se recalcula.

**Datos de prueba:**
{ anuncio: 12345, motivo: 'Cierre de negocio', axo_baja: 2024, folio_baja: 1001, usuario: 'admin', baja_error: false, baja_tiempo: false }

---

## Caso de Uso 2: Intento de baja de anuncio con adeudos

**Descripción:** El usuario intenta dar de baja un anuncio que tiene adeudos activos.

**Precondiciones:**
El usuario tiene permisos. El anuncio existe, está vigente pero tiene adeudos.

**Pasos a seguir:**
1. El usuario ingresa el número de anuncio y presiona 'Buscar'.
2. El sistema muestra los datos y la lista de adeudos.
3. El botón 'Dar de baja' está deshabilitado.

**Resultado esperado:**
No se permite la baja. El sistema muestra mensaje de advertencia.

**Datos de prueba:**
{ anuncio: 54321 }

---

## Caso de Uso 3: Baja de anuncio por error (usuario con permisos especiales)

**Descripción:** Un usuario con permisos especiales realiza una baja por error sin requerir año/folio.

**Precondiciones:**
El usuario pertenece a la dependencia 30 y tiene nivel > 1. El anuncio está vigente y sin adeudos.

**Pasos a seguir:**
1. El usuario ingresa el número de anuncio y presiona 'Buscar'.
2. El sistema muestra los datos y la opción 'Baja por error'.
3. El usuario marca 'Baja por error' y presiona 'Dar de baja'.
4. El sistema procesa la baja sin requerir año/folio.

**Resultado esperado:**
El anuncio queda cancelado y se registra como baja por error.

**Datos de prueba:**
{ anuncio: 67890, motivo: 'Error administrativo', axo_baja: null, folio_baja: null, usuario: 'supervisor', baja_error: true, baja_tiempo: false }

---
