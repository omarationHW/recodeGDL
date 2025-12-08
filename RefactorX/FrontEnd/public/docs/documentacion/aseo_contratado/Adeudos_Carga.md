# DocumentaciÃ³n TÃ©cnica: Adeudos_Carga

## AnÃ¡lisis TÃ©cnico

# Documentación Técnica: Carga de Adeudos (Adeudos_Carga)

## Descripción General
El proceso "Carga de Adeudos" permite generar automáticamente los registros de adeudos (pagos) para todos los contratos vigentes y no vigentes de un ejercicio fiscal determinado. Se utiliza para inicializar o regenerar los adeudos de un año completo, insertando un registro mensual por contrato en la tabla `ta_16_pagos`.

## Arquitectura
- **Backend:** Laravel Controller (API RESTful, endpoint único `/api/execute`)
- **Frontend:** Vue.js (SPA, página independiente)
- **Base de Datos:** PostgreSQL (Stored Procedure)
- **Patrón API:** eRequest/eResponse

## Flujo de Proceso
1. El usuario accede a la página de "Carga de Adeudos".
2. Ingresa el ejercicio fiscal y su ID de usuario.
3. Al enviar el formulario, el frontend realiza una petición POST a `/api/execute` con el payload eRequest.
4. El backend valida los datos y ejecuta el stored procedure `sp_carga_adeudos_contratos_vigentes` en PostgreSQL.
5. El stored procedure recorre todos los contratos vigentes/no vigentes y genera los pagos mensuales para el ejercicio.
6. El backend retorna el resultado en eResponse.

## Endpoint API
- **URL:** `/api/execute`
- **Método:** POST
- **Entrada:**
  ```json
  {
    "eRequest": {
      "action": "carga_adeudos",
      "ejercicio": 2024,
      "usuario_id": 23
    }
  }
  ```
- **Salida:**
  ```json
  {
    "eResponse": {
      "success": true,
      "message": "Carga de adeudos ejecutada correctamente",
      "result": []
    }
  }
  ```

## Validaciones
- El ejercicio debe ser un año válido (>= 2000).
- El usuario debe estar autenticado y tener permisos para ejecutar el proceso.
- El stored procedure ignora pagos ya existentes para evitar duplicados.

## Seguridad
- El endpoint debe estar protegido por autenticación (middleware Laravel).
- El usuario_id debe corresponder al usuario autenticado.

## Manejo de Errores
- Si falta algún parámetro, retorna 422 con detalles.
- Si ocurre un error en la base de datos, retorna 500 con el mensaje de error.
- Si la acción no es reconocida, retorna 400.

## Detalles del Stored Procedure
- Recorre todos los contratos con status 'V' (vigente) o 'N' (no vigente).
- Para cada contrato, obtiene la unidad de recolección y el costo correspondiente al ejercicio.
- Inserta 12 registros (uno por mes) en `ta_16_pagos` para cada contrato.
- Si ya existe un pago para ese periodo y contrato, lo ignora (manejo de unique_violation).

## Consideraciones
- El proceso puede ser pesado si hay muchos contratos; se recomienda ejecutarlo fuera de horario laboral o en modo batch.
- Se recomienda auditar los resultados y revisar los logs de errores.

## Extensibilidad
- El endpoint y el stored procedure pueden ser reutilizados para otros procesos de carga masiva.
- El frontend puede ser adaptado para otros procesos similares cambiando el action.


## Casos de Prueba

# Casos de Prueba: Carga de Adeudos

## Caso 1: Carga exitosa de adeudos
- **Entrada:** ejercicio=2024, usuario_id=23
- **Acción:** POST /api/execute con eRequest.action='carga_adeudos'
- **Esperado:**
  - Código HTTP 200
  - eResponse.success = true
  - Se insertan 12 pagos por contrato

## Caso 2: Ejercicio inválido
- **Entrada:** ejercicio=1999, usuario_id=23
- **Acción:** POST /api/execute con eRequest.action='carga_adeudos'
- **Esperado:**
  - Código HTTP 422
  - eResponse.success = false
  - Mensaje de error sobre el ejercicio

## Caso 3: Usuario no autenticado
- **Entrada:** ejercicio=2024, usuario_id=null
- **Acción:** POST /api/execute con eRequest.action='carga_adeudos'
- **Esperado:**
  - Código HTTP 422
  - eResponse.success = false
  - Mensaje de error sobre usuario_id

## Caso 4: Pagos ya existen para algunos contratos
- **Entrada:** ejercicio=2024, usuario_id=23
- **Acción:** POST /api/execute con eRequest.action='carga_adeudos'
- **Precondición:** Algunos pagos ya existen en ta_16_pagos
- **Esperado:**
  - Código HTTP 200
  - eResponse.success = true
  - Solo se insertan los pagos faltantes

## Caso 5: Acción no soportada
- **Entrada:** action='otro_proceso', ejercicio=2024, usuario_id=23
- **Acción:** POST /api/execute
- **Esperado:**
  - Código HTTP 400
  - eResponse.success = false
  - Mensaje de acción no soportada


## Casos de Uso

# Casos de Uso - Adeudos_Carga

**Categoría:** Form

## Caso de Uso 1: Carga masiva de adeudos para el ejercicio actual

**Descripción:** El usuario administrador ejecuta la carga de adeudos para todos los contratos vigentes del año fiscal actual.

**Precondiciones:**
El usuario tiene permisos de administrador. El ejercicio actual no tiene adeudos generados previamente.

**Pasos a seguir:**
1. El usuario accede a la página de Carga de Adeudos.
2. Ingresa el ejercicio actual (por ejemplo, 2024) y su ID de usuario.
3. Presiona el botón 'Ejecutar Carga de Adeudos'.
4. El sistema valida los datos y ejecuta el proceso.
5. El sistema muestra un mensaje de éxito.

**Resultado esperado:**
Se generan 12 adeudos (uno por mes) para cada contrato vigente y no vigente del ejercicio seleccionado. No hay duplicados.

**Datos de prueba:**
ejercicio: 2024, usuario_id: 23

---

## Caso de Uso 2: Intento de carga de adeudos con ejercicio inválido

**Descripción:** El usuario intenta ejecutar la carga de adeudos con un año inválido (por ejemplo, 1999).

**Precondiciones:**
El usuario tiene acceso al sistema.

**Pasos a seguir:**
1. El usuario accede a la página de Carga de Adeudos.
2. Ingresa el ejercicio 1999 y su ID de usuario.
3. Presiona el botón 'Ejecutar Carga de Adeudos'.

**Resultado esperado:**
El sistema rechaza la petición y muestra un mensaje de error indicando que el ejercicio es inválido.

**Datos de prueba:**
ejercicio: 1999, usuario_id: 23

---

## Caso de Uso 3: Carga de adeudos cuando ya existen pagos para el periodo

**Descripción:** El usuario ejecuta la carga de adeudos para un ejercicio donde ya existen algunos pagos generados.

**Precondiciones:**
Existen registros previos en ta_16_pagos para algunos contratos y meses del ejercicio.

**Pasos a seguir:**
1. El usuario accede a la página de Carga de Adeudos.
2. Ingresa el ejercicio correspondiente y su ID de usuario.
3. Presiona el botón 'Ejecutar Carga de Adeudos'.

**Resultado esperado:**
El sistema inserta solo los pagos que no existen, ignorando los duplicados. No se generan errores.

**Datos de prueba:**
ejercicio: 2024, usuario_id: 23 (con pagos previos en ta_16_pagos)

---



---
**Componente:** `Adeudos_Carga.vue`
**MÃ³dulo:** `aseo_contratado`

