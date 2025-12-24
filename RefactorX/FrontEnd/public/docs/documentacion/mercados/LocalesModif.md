# LocalesModif

## AnÃ¡lisis TÃ©cnico

# Documentación Técnica: Migración Formulario LocalesModif (Delphi) a Laravel + Vue.js + PostgreSQL

## Arquitectura General
- **Backend**: Laravel (PHP 8+), API RESTful, endpoint único `/api/execute` (patrón eRequest/eResponse)
- **Frontend**: Vue.js SPA, cada formulario es una página independiente (NO tabs)
- **Base de Datos**: PostgreSQL, lógica de negocio crítica en stored procedures
- **Seguridad**: Autenticación Laravel Sanctum/JWT, validación de parámetros en backend

## Flujo de Trabajo
1. **Carga de Catálogos**: Al cargar la página, el frontend solicita catálogos (zonas, cuotas, sectores, movimientos, bloqueos) vía `/api/execute`.
2. **Búsqueda de Local**: El usuario ingresa criterios y envía el formulario. El frontend llama a `/api/execute` con `action: 'buscar_local'` y los parámetros. El backend ejecuta el SP `sp_localesmodif_buscar_local` y retorna los datos del local.
3. **Modificación**: El usuario edita los campos permitidos y envía el formulario. El frontend llama a `/api/execute` con `action: 'modificar_local'` y los datos. El backend ejecuta el SP `sp_localesmodif_modificar_local`, que:
   - Registra el movimiento en `ta_11_movimientos`
   - Actualiza el registro en `ta_11_locales`
   - Si aplica, inserta/actualiza en `ta_11_bloqueo`
   - Si aplica, recalcula adeudos (puede llamar a otro SP)

## API Unificada (eRequest/eResponse)
- **Endpoint**: `/api/execute`
- **Método**: POST
- **Request**:
  ```json
  {
    "action": "buscar_local|modificar_local|catalogos|movimientos|bloqueos",
    "params": { ... }
  }
  ```
- **Response**:
  ```json
  {
    "success": true|false,
    "message": "...",
    "data": { ... }
  }
  ```

## Validaciones
- Todas las validaciones de negocio y formato se realizan en el backend (Laravel y SPs)
- El frontend realiza validaciones mínimas de requeridos y formato

## Stored Procedures
- Toda la lógica de modificación, movimientos, bloqueos y recalculo de adeudos está en SPs PostgreSQL
- Los SPs devuelven errores mediante excepciones o mensajes en el campo `result`

## Seguridad
- El endpoint requiere autenticación (token)
- El ID de usuario se obtiene del contexto de sesión y se pasa a los SPs

## Extensibilidad
- El patrón eRequest/eResponse permite agregar nuevas acciones sin modificar el endpoint
- Los catálogos pueden ser cacheados en frontend

## Despliegue
- El controlador debe estar registrado en `routes/api.php`:
  ```php
  Route::post('/execute', [LocalesModifController::class, 'execute']);
  ```
- El componente Vue debe estar registrado en el router como página independiente

# Notas de Migración
- El formulario Delphi tenía lógica de habilitación/deshabilitación de campos según el tipo de movimiento; esto se implementa en Vue.js con lógica reactiva.
- Los combos de zona, cuota, sector, movimiento y bloqueo se llenan desde catálogos vía API.
- El SP de modificación debe ser atómico y manejar transacciones.
- Los mensajes de error del SP se devuelven al frontend para mostrar al usuario.

# Consideraciones de Pruebas
- Pruebas de concurrencia: dos usuarios modificando el mismo local
- Pruebas de integridad: no permitir movimientos inválidos según reglas de negocio
- Pruebas de seguridad: sólo usuarios autenticados pueden modificar


## Casos de Uso

# Casos de Uso - LocalesModif

**Categoría:** Form

## Caso de Uso 1: Modificación de Nombre de Local

**Descripción:** El usuario busca un local vigente y modifica el nombre del titular.

**Precondiciones:**
El usuario está autenticado y tiene permisos de modificación. El local existe y está vigente.

**Pasos a seguir:**
1. El usuario ingresa los datos de búsqueda (oficina, mercado, categoria, sección, local, letra, bloque) y presiona 'Buscar'.
2. El sistema muestra los datos actuales del local.
3. El usuario edita el campo 'Nombre' y presiona 'Modificar'.
4. El sistema valida y ejecuta la modificación.

**Resultado esperado:**
El nombre del local se actualiza correctamente. Se registra el movimiento en la bitácora.

**Datos de prueba:**
{ "oficina": 1, "num_mercado": 10, "categoria": 2, "seccion": "SS", "local": 123, "letra_local": null, "bloque": null, "nombre": "JUAN PEREZ" }

---

## Caso de Uso 2: Bloqueo de Local por Incumplimiento

**Descripción:** El usuario bloquea un local seleccionando la clave de bloqueo y fecha de inicio.

**Precondiciones:**
El usuario está autenticado. El local está vigente y no tiene bloqueo activo.

**Pasos a seguir:**
1. El usuario busca el local.
2. Selecciona el movimiento 'Bloquear'.
3. Selecciona la clave de bloqueo y fecha de inicio.
4. Presiona 'Modificar'.

**Resultado esperado:**
El local queda bloqueado, se inserta registro en ta_11_bloqueo.

**Datos de prueba:**
{ "id_local": 123, "tipo_movimiento": 12, "cve_bloqueo": 5, "fecha_inicio_bloqueo": "2024-07-01", "observacion": "Incumplimiento de pago" }

---

## Caso de Uso 3: Desbloqueo de Local

**Descripción:** El usuario desbloquea un local bloqueado, registrando la fecha final y observación.

**Precondiciones:**
El local tiene un bloqueo activo.

**Pasos a seguir:**
1. El usuario busca el local.
2. Selecciona el movimiento 'Desbloquear'.
3. Selecciona la clave de bloqueo y fecha final.
4. Presiona 'Modificar'.

**Resultado esperado:**
El bloqueo se actualiza con fecha final y observación.

**Datos de prueba:**
{ "id_local": 123, "tipo_movimiento": 13, "cve_bloqueo": 5, "fecha_inicio_bloqueo": "2024-07-01", "fecha_final_bloqueo": "2024-07-15", "observacion": "Pago regularizado" }

---



## Casos de Prueba

## Casos de Prueba para LocalesModif

### Caso 1: Modificación exitosa de nombre
- **Entrada**: Local vigente, nuevo nombre válido
- **Acción**: Buscar local, modificar nombre, enviar
- **Esperado**: Respuesta success=true, nombre actualizado, movimiento registrado

### Caso 2: Intento de modificar local inexistente
- **Entrada**: Datos de búsqueda que no existen
- **Acción**: Buscar local
- **Esperado**: Respuesta success=false, mensaje 'Local no encontrado'

### Caso 3: Bloqueo de local sin seleccionar clave de bloqueo
- **Entrada**: Movimiento 'Bloquear', sin clave de bloqueo
- **Acción**: Modificar
- **Esperado**: Respuesta success=false, mensaje de validación

### Caso 4: Desbloqueo de local con fecha final y observación
- **Entrada**: Movimiento 'Desbloquear', clave de bloqueo, fecha final, observación
- **Acción**: Modificar
- **Esperado**: Respuesta success=true, bloqueo actualizado

### Caso 5: Modificación con usuario no autenticado
- **Entrada**: Cualquier acción
- **Acción**: Llamar API sin token
- **Esperado**: Respuesta HTTP 401 Unauthorized



