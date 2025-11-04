# Documentación Técnica: Baja de Licencia

## Descripción General
Este módulo permite realizar la baja administrativa de una licencia y sus anuncios ligados, asegurando que no existan bloqueos ni adeudos pendientes, y actualizando el estatus en la base de datos. Incluye:
- API unificada (eRequest/eResponse) en `/api/execute`
- Controlador Laravel para orquestar la lógica
- Componente Vue.js como página independiente
- Stored Procedures en PostgreSQL para la lógica de negocio

## Flujo de Proceso
1. **Búsqueda de Licencia**: El usuario ingresa el número de licencia y el sistema muestra los datos principales, adeudos y anuncios ligados.
2. **Validación de Adeudos y Bloqueos**: El sistema verifica que la licencia esté vigente, no esté bloqueada y que los anuncios ligados tampoco estén bloqueados.
3. **Confirmación de Baja**: El usuario ingresa el motivo, año y folio de baja (o marca baja por error si aplica).
4. **Ejecución de Baja**: Se ejecuta el stored procedure `sp_baja_licencia`, que:
   - Cancela adeudos de la licencia y anuncios
   - Cambia el estatus de la licencia y anuncios a cancelado
   - Registra la bitácora de baja
   - Recalcula el saldo de la licencia

## API Unificada
- **Endpoint**: `/api/execute`
- **Método**: POST
- **Formato**:
  ```json
  {
    "action": "bajaLicencia",
    "params": {
      "id_licencia": 12345,
      "motivo": "Cierre de negocio",
      "anio": 2024,
      "folio": 123,
      "baja_error": false
    }
  }
  ```
- **Respuesta**:
  ```json
  {
    "success": true,
    "message": "Licencia dada de baja correctamente."
  }
  ```

## Validaciones
- La licencia debe existir y estar vigente
- No debe estar bloqueada (bloqueado < 5)
- Ningún anuncio ligado debe estar bloqueado
- Si hay adeudos, sólo usuarios autorizados pueden continuar (según reglas de negocio)

## Seguridad
- El usuario debe estar autenticado (JWT o sesión)
- El usuario y su nivel se obtienen del token/session y se pasan al SP para bitácora

## Stored Procedures
- Toda la lógica de baja está en el SP `sp_baja_licencia`
- El recálculo de saldos se delega a `calc_sdosl`

## Frontend
- El componente Vue.js es una página completa, sin tabs, con navegación y validaciones en tiempo real
- El formulario de baja sólo se habilita si la licencia cumple las condiciones

## Notas
- El endpoint `/api/execute` puede ser usado por otros formularios siguiendo el patrón eRequest/eResponse
- El SP puede ser extendido para bitácora, logs, o reglas adicionales

---

## ESTADO DE COMPLETITUD

### Fecha de Finalización
**2025-11-04**

### Status
✅ **MÓDULO COMPLETADO Y FUNCIONAL**

El módulo Baja de Licencias ha sido completamente implementado, probado y está operativo sin errores.

### Problemas Resueltos

#### 1. Error "Invalid eRequest"
**Problema**: Al hacer clic en el botón "Buscar", la aplicación devolvía:
```json
{"eResponse":{"success":false,"message":"Invalid eRequest"}}
```

**Causa**: El componente enviaba el objeto `eRequest` directamente en el body en lugar de envolverlo correctamente.

**Solución**: Se corrigió la estructura de la petición en los 4 métodos del componente:

**Métodos corregidos:**
- `buscarLicencia` (líneas 281-296)
- `cargarAdeudos` (líneas 316-331)
- `cargarAnuncios` (líneas 344-359)
- `confirmarBaja` (líneas 376-395)

```javascript
// ANTES (INCORRECTO)
const eRequest = {
  Operacion: 'sp_licencia_buscar',
  Base: 'licencias',
  Parametros: [...]
}
body: JSON.stringify(eRequest)

// DESPUÉS (CORRECTO)
body: JSON.stringify({
  eRequest: {
    Operacion: 'sp_licencia_buscar',
    Base: 'padron_licencias',
    Parametros: [...],
    Tenant: 'guadalajara'
  }
})
```

#### 2. Stored Procedures Inexistentes
**Problema**: Los stored procedures necesarios no existían en la base de datos.

**Solución**: Se crearon 4 stored procedures en el schema `public`:

**`sp_licencia_buscar(p_numero_licencia)`**:
- Busca licencia por número
- Retorna información completa con propietario, actividad, estado
- **Correcciones aplicadas**: Columna `giro` NO existe, se usa `actividad` (character(130)); `bloqueado` es SMALLINT

**`sp_licencia_adeudos(p_id_licencia)`**:
- Lista adeudos pendientes de la licencia
- **Correcciones aplicadas**: Tabla NO tiene columna `concepto`, se usa UNION ALL para crear conceptos virtuales:
  - 'Derechos' (d.derechos)
  - 'Recargos' (d.recargos)
  - 'Formas' (d.forma)
  - 'Actualización' (d.actualizacion)

**`sp_licencia_anuncios(p_id_licencia)`**:
- Lista anuncios de la licencia con conteo de adeudos
- **Correcciones aplicadas**: `texto_anuncio` es character(50), se convierte a VARCHAR; `bloqueado` es SMALLINT

**`sp_licencia_baja(...)`**:
- Procesa la baja completa (licencia + anuncios + adeudos)
- Valida estado vigente, bloqueos
- Actualiza registros y cancela adeudos
- Retorna respuesta en formato JSONB

#### 3. Errores de Tipo de Datos (Datatype Mismatch)
**Problema**: PostgreSQL rechazaba los SPs por incompatibilidad de tipos de datos.

**Errores identificados y corregidos:**

**sp_licencia_buscar:**
- ❌ `bloqueado INTEGER` → ✅ `bloqueado SMALLINT`
- ❌ Columna `giro` → ✅ Columna `actividad`

**sp_licencia_adeudos:**
- ❌ Columna `concepto` (NO existe) → ✅ UNION ALL para conceptos virtuales
- ❌ `ejercicio INTEGER` → ✅ `ejercicio SMALLINT` (columna `axo`)

**sp_licencia_anuncios:**
- ❌ `texto_anuncio TEXT` → ✅ `texto_anuncio VARCHAR` (con conversión ::VARCHAR)
- ❌ `bloqueado INTEGER` → ✅ `bloqueado SMALLINT`

#### 4. Base de Datos Incorrecta
**Problema**: El componente enviaba `Base: 'licencias'` pero el backend esperaba `padron_licencias`.

**Solución**: Se cambió la propiedad Base en los 4 métodos a `'padron_licencias'`.

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
- Schema: `comun` (tablas: licencias, anuncios, detsal_lic)
- Host: 192.168.6.146:5432
- Database: padron_licencias

**Frontend**:
- Puerto: 5180
- Base URL API: http://localhost:8000/api/execute

### Funcionalidades Verificadas

✅ **Búsqueda de Licencia**
- Búsqueda por número de licencia
- Visualización de información completa
- Datos del propietario y actividad
- Estado de bloqueo

✅ **Carga de Adeudos**
- Lista de adeudos desglosados por concepto (Derechos, Recargos, Formas, Actualización)
- Filtrado de adeudos pendientes (cvepago = 0)
- Ordenamiento por ejercicio

✅ **Carga de Anuncios**
- Lista de anuncios vinculados a la licencia
- Conteo de adeudos por anuncio
- Estado de vigencia y bloqueo

✅ **Validaciones**
- Licencia debe existir y estar vigente (V)
- No debe estar bloqueada
- Anuncios no deben estar bloqueados
- Mensajes de error claros y descriptivos

✅ **Procesamiento de Baja**
- Actualización de estado a 'C' (Cancelado)
- Cancelación de adeudos de licencia y anuncios
- Actualización de anuncios vinculados
- Registro de fecha, año, folio y motivo de baja

✅ **Interfaz de Usuario**
- Formulario de búsqueda responsivo
- Campos deshabilitados hasta búsqueda exitosa
- Botones habilitados según estado de la licencia
- Mensajes de éxito y error claros

### Datos de Prueba

**Licencias vigentes para prueba:**
- Licencia "0" (ID: 260002 - BANCA CREMI S.N.C.) - 6 anuncios vigentes, sin anuncios bloqueados
- Licencia "0" (ID: 260005 - BANCO B.C.H.S.N.C.) - Sin anuncios vigentes
- Licencia "0" (ID: 260050 - NUEVA WAL MART) - Licencia bloqueada (validar restricción)

**Nota**: La mayoría de licencias vigentes tienen al menos 1 adeudo pendiente, lo cual es correcto para probar las validaciones del sistema.

### Estructura de Tablas Identificadas

**comun.licencias:**
- `licencia` (INTEGER) - Número de licencia
- `actividad` (CHARACTER(130)) - Descripción de actividad
- `bloqueado` (SMALLINT) - Estado de bloqueo
- `vigente` (CHARACTER(1)) - Estado vigente (V/C)

**comun.detsal_lic:**
- `axo` (SMALLINT) - Ejercicio/año
- `derechos`, `recargos`, `forma`, `actualizacion` (NUMERIC) - Montos
- `cvepago` (INTEGER) - Clave de pago (0 = pendiente, 999999 = cancelado)

**comun.anuncios:**
- `anuncio` (INTEGER) - Número de anuncio
- `texto_anuncio` (CHARACTER(50)) - Texto del anuncio
- `vigente` (CHARACTER(1)) - Estado vigente (V/C)
- `bloqueado` (SMALLINT) - Estado de bloqueo

### Conclusión

El módulo Baja de Licencias está completamente funcional y cumple con todos los requisitos:
- Comunicación correcta con el backend mediante patrón eRequest/eResponse
- 4 stored procedures creados con tipos de datos correctos
- Validaciones de negocio implementadas
- Interfaz de usuario intuitiva y responsive
- Manejo adecuado de errores y mensajes
- Estructura de datos real documentada

**Marcado en el menú con asterisco (*)** para indicar su estado de completitud.
