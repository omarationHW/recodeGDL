# Documentación Técnica: BloquearTramitefrm

## Análisis Técnico

# Documentación Técnica: Migración de BloquearTramitefrm (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Arquitectura General

- **Frontend**: Vue.js SPA, cada formulario es una página independiente.
- **Backend**: Laravel API, endpoint único `/api/execute` que recibe un objeto `eRequest` y responde con `eResponse`.
- **Base de Datos**: PostgreSQL, toda la lógica de negocio y acceso a datos encapsulada en stored procedures.

## 2. API Unificada

- **Endpoint**: `/api/execute`
- **Método**: POST
- **Request**: `{ eRequest: { action: string, params: object } }`
- **Response**: `{ eResponse: { success: boolean, data: any, message: string } }`

### Acciones soportadas:
- `getTramite`: Obtiene los datos de un trámite por ID.
- `getBloqueos`: Obtiene el historial de bloqueos/desbloqueos de un trámite.
- `getGiroDescripcion`: Obtiene la descripción del giro asociado al trámite.
- `bloquearTramite`: Bloquea el trámite, cancela el último bloqueo vigente y registra el nuevo bloqueo.
- `desbloquearTramite`: Desbloquea el trámite, cancela el último bloqueo vigente y registra el desbloqueo.

## 3. Stored Procedures

Toda la lógica de acceso y manipulación de datos se realiza mediante funciones almacenadas en PostgreSQL:
- **get_tramite**: Devuelve todos los campos del trámite.
- **get_bloqueos**: Devuelve el historial de bloqueos/desbloqueos, calculando el estado textual.
- **get_giro_descripcion**: Devuelve la descripción del giro.
- **bloquear_tramite**: Realiza el proceso de bloqueo (actualiza campo, cancela vigentes, inserta nuevo registro).
- **desbloquear_tramite**: Realiza el proceso de desbloqueo (igual que bloqueo, pero con valor 0).

## 4. Frontend (Vue.js)

- Página independiente con ruta propia.
- Formulario para ingresar el número de trámite.
- Visualización de datos del trámite y su historial de bloqueos.
- Botones para bloquear/desbloquear según estado actual.
- Prompts para capturar observaciones.
- Mensajes de éxito/error.

## 5. Backend (Laravel)

- Controlador único (`ExecuteController`) que enruta la acción a la función almacenada correspondiente.
- Manejo de errores y respuesta unificada.

## 6. Seguridad

- Validación de parámetros en el frontend y backend.
- Uso de funciones almacenadas para evitar SQL Injection.
- El campo `capturista` debe ser provisto por el frontend (puede integrarse con autenticación en producción).

## 7. Consideraciones de Migración

- Todos los nombres de campos y lógica se mantienen fieles al formulario original.
- El cálculo de propietario nuevo (`propietarionvo`) se realiza en el frontend.
- El historial de bloqueos muestra el estado textual calculado en el SP.

## 8. Extensibilidad

- Se pueden agregar nuevas acciones al endpoint unificado simplemente agregando nuevos casos en el controlador y nuevos SPs.

## 9. Pruebas

- Casos de uso y pruebas detalladas incluidas para asegurar la funcionalidad y robustez del sistema.

## Casos de Prueba

# Casos de Prueba: BloquearTramitefrm

## Caso 1: Consulta de trámite inexistente
- **Entrada:** id_tramite = 999999
- **Acción:** Buscar trámite
- **Resultado esperado:** Mensaje de error 'No se encontró trámite con ese número'.

## Caso 2: Consulta de trámite existente sin bloqueos
- **Entrada:** id_tramite = 2001 (sin registros en bloqueo)
- **Acción:** Buscar trámite
- **Resultado esperado:** Se muestran los datos del trámite y el historial de bloqueos está vacío.

## Caso 3: Bloqueo exitoso de trámite
- **Entrada:** id_tramite = 2002 (bloqueado = 0), observa = 'Prueba bloqueo', capturista = 'tester'
- **Acción:** Buscar trámite, luego bloquear trámite e ingresar motivo.
- **Resultado esperado:** Mensaje de éxito, trámite bloqueado, historial actualizado con nuevo registro.

## Caso 4: Desbloqueo exitoso de trámite
- **Entrada:** id_tramite = 2003 (bloqueado = 1), observa = 'Prueba desbloqueo', capturista = 'tester'
- **Acción:** Buscar trámite, luego desbloquear trámite e ingresar motivo.
- **Resultado esperado:** Mensaje de éxito, trámite desbloqueado, historial actualizado con nuevo registro.

## Caso 5: Intento de bloquear trámite ya bloqueado
- **Entrada:** id_tramite = 2003 (bloqueado = 1)
- **Acción:** Buscar trámite, intentar bloquear trámite
- **Resultado esperado:** Botón de bloqueo deshabilitado, no se permite la acción.

## Caso 6: Intento de desbloquear trámite no bloqueado
- **Entrada:** id_tramite = 2002 (bloqueado = 0)
- **Acción:** Buscar trámite, intentar desbloquear trámite
- **Resultado esperado:** Botón de desbloqueo deshabilitado, no se permite la acción.

## Caso 7: Cancelación de prompt de motivo
- **Entrada:** id_tramite = 2002, acción de bloquear/desbloquear, usuario cancela el prompt
- **Acción:** Cancelar el prompt de motivo
- **Resultado esperado:** No se realiza ninguna acción, estado sin cambios.

## Casos de Uso

# Casos de Uso - BloquearTramitefrm

**Categoría:** Form

## Caso de Uso 1: Consulta de trámite existente y visualización de historial de bloqueos

**Descripción:** El usuario ingresa el número de un trámite existente y visualiza todos los datos relevantes, así como el historial de bloqueos y desbloqueos.

**Precondiciones:**
El trámite con el ID proporcionado existe en la base de datos.

**Pasos a seguir:**
1. El usuario accede a la página de Bloqueo de Trámites.
2. Ingresa el número de trámite en el campo correspondiente.
3. Presiona Enter o hace clic en 'Buscar'.
4. El sistema muestra los datos del trámite y el historial de bloqueos.

**Resultado esperado:**
Se muestran correctamente los datos del trámite y el historial de bloqueos/desbloqueos.

**Datos de prueba:**
id_tramite: 1001 (existente)

---

## Caso de Uso 2: Bloqueo de un trámite no bloqueado

**Descripción:** El usuario bloquea un trámite que actualmente no está bloqueado, registrando el motivo.

**Precondiciones:**
El trámite existe y su campo 'bloqueado' es 0.

**Pasos a seguir:**
1. El usuario busca el trámite.
2. El botón 'Bloquear trámite' está habilitado.
3. El usuario hace clic en 'Bloquear trámite'.
4. Ingresa el motivo en el prompt.
5. El sistema actualiza el estado y registra el bloqueo.

**Resultado esperado:**
El trámite queda bloqueado, el botón de desbloqueo se habilita y el historial se actualiza.

**Datos de prueba:**
id_tramite: 1002 (bloqueado = 0), observa: 'Falta documentación', capturista: 'admin'

---

## Caso de Uso 3: Desbloqueo de un trámite bloqueado

**Descripción:** El usuario desbloquea un trámite que está actualmente bloqueado, registrando el motivo.

**Precondiciones:**
El trámite existe y su campo 'bloqueado' es 1.

**Pasos a seguir:**
1. El usuario busca el trámite.
2. El botón 'Desbloquear trámite' está habilitado.
3. El usuario hace clic en 'Desbloquear trámite'.
4. Ingresa el motivo en el prompt.
5. El sistema actualiza el estado y registra el desbloqueo.

**Resultado esperado:**
El trámite queda desbloqueado, el botón de bloqueo se habilita y el historial se actualiza.

**Datos de prueba:**
id_tramite: 1003 (bloqueado = 1), observa: 'Documentación recibida', capturista: 'admin'

---
