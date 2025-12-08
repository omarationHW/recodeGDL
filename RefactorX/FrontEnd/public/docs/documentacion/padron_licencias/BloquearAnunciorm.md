# Documentación Técnica: BloquearAnunciorm

## Análisis Técnico

# Documentación Técnica: Migración de Formulario BloquearAnunciorm (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo permite consultar, bloquear y desbloquear anuncios publicitarios registrados en la base de datos. Cada acción queda registrada en la tabla de movimientos de bloqueo, permitiendo auditoría y trazabilidad.

## 2. Arquitectura
- **Frontend:** Vue.js (Single Page Component)
- **Backend:** Laravel (API RESTful, endpoint único `/api/execute`)
- **Base de Datos:** PostgreSQL (Stored Procedures para toda la lógica de negocio)

## 3. API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Formato de entrada:**
  ```json
  {
    "eRequest": {
      "operation": "nombre_operacion",
      "params": { ... }
    }
  }
  ```
- **Formato de salida:**
  ```json
  {
    "eResponse": {
      "success": true|false,
      "data": [ ... ],
      "message": "..."
    }
  }
  ```

## 4. Operaciones soportadas
- `buscar_anuncio`: Busca un anuncio por su número.
- `consultar_bloqueos`: Lista los movimientos de bloqueo/desbloqueo de un anuncio.
- `bloquear_anuncio`: Bloquea un anuncio (requiere motivo y usuario).
- `desbloquear_anuncio`: Desbloquea un anuncio (requiere motivo y usuario).

## 5. Stored Procedures
Toda la lógica de negocio y validación reside en funciones de PostgreSQL:
- **buscar_anuncio(numero_anuncio TEXT):** Devuelve los datos del anuncio.
- **consultar_bloqueos(id_anuncio INTEGER):** Devuelve el historial de bloqueos/desbloqueos.
- **bloquear_anuncio(id_anuncio INTEGER, observa TEXT, usuario TEXT):** Realiza el bloqueo, valida estado y registra movimiento.
- **desbloquear_anuncio(id_anuncio INTEGER, observa TEXT, usuario TEXT):** Realiza el desbloqueo, valida estado y registra movimiento.

## 6. Seguridad
- El usuario que realiza la acción debe ser enviado en el parámetro `usuario`.
- El endpoint debe estar protegido por autenticación (middleware Laravel, no incluido aquí).

## 7. Frontend
- Página independiente, sin tabs.
- Permite buscar por número de anuncio, muestra detalles y estado.
- Permite bloquear/desbloquear con motivo (modal de confirmación).
- Muestra historial de movimientos.

## 8. Validaciones
- No se puede bloquear un anuncio ya bloqueado.
- No se puede desbloquear un anuncio no bloqueado.
- El motivo es obligatorio para bloquear/desbloquear.
- El número de anuncio debe existir.

## 9. Consideraciones
- El campo `bloqueado` en la tabla `anuncios` es el indicador principal del estado.
- Cada movimiento de bloqueo/desbloqueo se registra en la tabla `bloqueo` con campo `vigente` ('V' para vigente, 'C' para cancelado).
- El frontend asume que el usuario autenticado está disponible en `window.user.username` (ajustar según integración real).

## 10. Tablas involucradas
- `anuncios`: Datos del anuncio, incluye campo `bloqueado`.
- `bloqueo`: Historial de bloqueos/desbloqueos.

## 11. Flujo de trabajo
1. Usuario ingresa número de anuncio y consulta.
2. El sistema muestra detalles y estado.
3. Si está bloqueado, solo permite desbloquear; si no, solo permite bloquear.
4. Al bloquear/desbloquear, se solicita motivo y se registra el movimiento.
5. El historial se actualiza automáticamente.

## 12. Errores comunes
- Intentar bloquear un anuncio ya bloqueado.
- Intentar desbloquear un anuncio no bloqueado.
- Número de anuncio inexistente.

## 13. Extensibilidad
- Se pueden agregar más operaciones siguiendo el patrón eRequest/eResponse y creando nuevos stored procedures.

## Casos de Prueba

# Casos de Prueba para BloquearAnunciorm

| Caso | Descripción | Entrada | Resultado Esperado |
|------|-------------|---------|--------------------|
| TC01 | Buscar anuncio existente | numero_anuncio = '12345' | Devuelve datos del anuncio y su estado |
| TC02 | Buscar anuncio inexistente | numero_anuncio = '99999' | Mensaje: 'No se encontró licencia con ese número' |
| TC03 | Bloquear anuncio no bloqueado | numero_anuncio = '12345', motivo = 'Incumplimiento', usuario = 'admin' | Estado cambia a BLOQUEADO, historial actualizado |
| TC04 | Bloquear anuncio ya bloqueado | numero_anuncio = '54321', usuario = 'admin' | Mensaje de error: 'El anuncio ya está bloqueado, no se puede bloquear' |
| TC05 | Desbloquear anuncio bloqueado | numero_anuncio = '67890', motivo = 'Revisión aprobada', usuario = 'admin' | Estado cambia a NO BLOQUEADO, historial actualizado |
| TC06 | Desbloquear anuncio no bloqueado | numero_anuncio = '12345', usuario = 'admin' | Mensaje de error: 'El anuncio no está bloqueado, no se puede desbloquear' |
| TC07 | Consultar historial de bloqueos | numero_anuncio = '12345' | Tabla de movimientos muestra todos los bloqueos/desbloqueos |
| TC08 | Bloquear anuncio sin motivo | numero_anuncio = '12345', motivo = '', usuario = 'admin' | Mensaje de error: 'El motivo es obligatorio' (validación frontend) |

## Casos de Uso

# Casos de Uso - BloquearAnunciorm

**Categoría:** Form

## Caso de Uso 1: Bloquear un anuncio no bloqueado

**Descripción:** El usuario busca un anuncio existente que no está bloqueado y procede a bloquearlo, registrando el motivo.

**Precondiciones:**
El anuncio existe y su campo 'bloqueado' es 0.

**Pasos a seguir:**
1. El usuario ingresa el número de anuncio en el formulario y presiona 'Buscar'.
2. El sistema muestra los datos del anuncio y el estado 'NO BLOQUEADO'.
3. El usuario hace clic en 'Bloquear anuncio'.
4. El sistema solicita el motivo del bloqueo.
5. El usuario ingresa el motivo y confirma.
6. El sistema ejecuta el procedimiento de bloqueo y actualiza el estado y el historial.

**Resultado esperado:**
El anuncio queda bloqueado, el estado cambia a 'BLOQUEADO' y se registra el movimiento en el historial.

**Datos de prueba:**
numero_anuncio: '12345', motivo: 'Incumplimiento de normas', usuario: 'admin'

---

## Caso de Uso 2: Intentar bloquear un anuncio ya bloqueado

**Descripción:** El usuario intenta bloquear un anuncio que ya está bloqueado.

**Precondiciones:**
El anuncio existe y su campo 'bloqueado' es 1.

**Pasos a seguir:**
1. El usuario ingresa el número de anuncio y presiona 'Buscar'.
2. El sistema muestra el estado 'BLOQUEADO'.
3. El usuario intenta hacer clic en 'Bloquear anuncio'.

**Resultado esperado:**
El botón está deshabilitado o el sistema muestra un mensaje de error indicando que ya está bloqueado.

**Datos de prueba:**
numero_anuncio: '54321', usuario: 'admin'

---

## Caso de Uso 3: Desbloquear un anuncio bloqueado

**Descripción:** El usuario desbloquea un anuncio que está actualmente bloqueado.

**Precondiciones:**
El anuncio existe y su campo 'bloqueado' es 1.

**Pasos a seguir:**
1. El usuario ingresa el número de anuncio y presiona 'Buscar'.
2. El sistema muestra el estado 'BLOQUEADO'.
3. El usuario hace clic en 'Desbloquear anuncio'.
4. El sistema solicita el motivo del desbloqueo.
5. El usuario ingresa el motivo y confirma.
6. El sistema ejecuta el procedimiento de desbloqueo y actualiza el estado y el historial.

**Resultado esperado:**
El anuncio queda desbloqueado, el estado cambia a 'NO BLOQUEADO' y se registra el movimiento en el historial.

**Datos de prueba:**
numero_anuncio: '67890', motivo: 'Revisión aprobada', usuario: 'admin'

---
