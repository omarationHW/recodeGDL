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

---

## ESTADO DE COMPLETITUD

### Fecha de Finalización
**2025-11-03**

### Status
✅ **MÓDULO COMPLETADO Y FUNCIONAL**

El módulo Baja de Anuncios ha sido completamente implementado, probado y está operativo sin errores.

### Problemas Resueltos

#### 1. Error "Invalid eRequest"
**Problema**: Al hacer clic en el botón "Buscar", la aplicación devolvía:
```json
{"eResponse":{"success":false,"message":"Invalid eRequest"}}
```

**Causa**: El componente enviaba el objeto `eRequest` directamente en el body en lugar de envolverlo correctamente.

**Solución**: Se corrigió la estructura de la petición en ambos métodos del componente:

**Método `buscarAnuncio` (líneas 302-322)**:
```javascript
// ANTES (INCORRECTO)
const eRequest = {
  Operacion: 'sp_baja_anuncio_buscar',
  Base: 'licencias',
  Parametros: [...]
}
body: JSON.stringify(eRequest)

// DESPUÉS (CORRECTO)
body: JSON.stringify({
  eRequest: {
    Operacion: 'sp_baja_anuncio_buscar',
    Base: 'padron_licencias',
    Parametros: [...],
    Tenant: 'guadalajara'
  }
})
```

**Método `procesarBaja` (líneas 357-397)**:
Se aplicó la misma corrección de estructura.

#### 2. Stored Procedures Inexistentes
**Problema**: Los stored procedures `sp_baja_anuncio_buscar` y `sp_baja_anuncio_procesar` no existían en la base de datos.

**Solución**: Se crearon ambos stored procedures en el schema `public`:

**`sp_baja_anuncio_buscar`**:
- Busca anuncio por número
- Obtiene información de licencia y propietario
- Cuenta adeudos pendientes
- Retorna datos en formato JSONB

**`sp_baja_anuncio_procesar`**:
- Valida que el anuncio exista y esté vigente
- Verifica que no tenga adeudos pendientes
- Actualiza el estado del anuncio a 'C' (Cancelado)
- Cancela los adeudos relacionados
- Registra fecha de baja y motivo

#### 3. Error "Ambiguous column: id_anuncio"
**Problema**: Al ejecutar `sp_baja_anuncio_buscar`, PostgreSQL devolvía:
```
SQLSTATE[42702]: Ambiguous column: 7 ERROR: column reference "id_anuncio" is ambiguous
LINE 4: id_anuncio,
```

**Causa**: El SP usaba `id_anuncio` tanto como nombre de columna de retorno como en cláusulas WHERE, causando ambigüedad en el contexto de la función.

**Solución**: Se reestructuró el SP usando variables locales con prefijo `v_`:
```sql
DECLARE
  v_id_anuncio INTEGER;
  v_id_licencia INTEGER;
  v_texto_anuncio TEXT;
  -- ... más variables
BEGIN
  -- Asignar valores a variables locales primero
  SELECT a.id_anuncio, a.id_licencia, a.texto_anuncio, ...
  INTO v_id_anuncio, v_id_licencia, v_texto_anuncio, ...
  FROM comun.anuncios a
  LEFT JOIN comun.licencias l ON l.id_licencia = a.id_licencia
  WHERE a.anuncio = p_anuncio;

  -- Luego asignar a columnas de retorno
  id_anuncio := v_id_anuncio;
  id_licencia := v_id_licencia;
  -- ...
END;
```

#### 4. Base de Datos Incorrecta
**Problema**: El componente enviaba `Base: 'licencias'` pero el backend esperaba `padron_licencias`.

**Solución**: Se cambió la propiedad Base en ambos métodos (buscar y procesar) a `'padron_licencias'`.

### Configuración Final

**Backend (index.php)**:
```php
'padron_licencias' => [
    'database' => 'padron_licencias',
    'schema' => 'public'
],
```

**Database**:
- Schema: `public` (stored procedures)
- Schema: `comun` (tablas: anuncios, licencias, detsal_lic)
- Host: 192.168.6.146:5432
- Database: padron_licencias

**Frontend**:
- Puerto: 5180
- Base URL API: http://localhost:8000/api/execute

### Funcionalidades Verificadas

✅ **Búsqueda de Anuncio**
- Búsqueda por número de anuncio
- Visualización de información completa
- Datos de licencia y propietario
- Conteo de adeudos pendientes

✅ **Validaciones**
- Anuncio debe existir
- Anuncio debe estar vigente (V)
- No debe tener adeudos pendientes
- Mensajes de error claros y descriptivos

✅ **Procesamiento de Baja**
- Actualización de estado a 'C' (Cancelado)
- Cancelación de adeudos relacionados
- Registro de fecha y motivo de baja
- Confirmación exitosa

✅ **Interfaz de Usuario**
- Formulario de búsqueda responsivo
- Campos deshabilitados hasta búsqueda exitosa
- Botones habilitados según estado del anuncio
- Mensajes de éxito y error claros

### Datos de Prueba

**Anuncios sin adeudos (para probar baja exitosa)**:
- Anuncio #3 (ID: 3, Licencia: 190221, Propietario: ESTEVEZ ALVAREZ CARLOS)
- Anuncio #4 (ID: 4, Licencia: 190221, Propietario: ESTEVEZ ALVAREZ CARLOS)
- Anuncio #25 (ID: 40, Licencia: 116518, Propietario: REFACCIONARIA LA 68, S. A. DE)

**Anuncio con adeudos (para probar validación)**:
- Anuncio #16 (ID: 31, Licencia: 190259, 18 adeudos pendientes)

### Conclusión

El módulo Baja de Anuncios está completamente funcional y cumple con todos los requisitos:
- Comunicación correcta con el backend mediante patrón eRequest/eResponse
- Stored procedures creados y operativos
- Validaciones de negocio implementadas
- Interfaz de usuario intuitiva y responsive
- Manejo adecuado de errores y mensajes

**Marcado en el menú con asterisco (*)** para indicar su estado de completitud.
