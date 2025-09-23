# Casos de Uso - tipobloqueofrm

**Categoría:** Form

## Caso de Uso 1: Bloquear una licencia con motivo válido

**Descripción:** El usuario selecciona un tipo de bloqueo válido y proporciona un motivo para bloquear una licencia existente.

**Precondiciones:**
El usuario está autenticado y la licencia existe en la base de datos.

**Pasos a seguir:**
1. Acceder a la página de bloqueo de licencia.
2. Seleccionar un tipo de bloqueo del catálogo.
3. Ingresar un motivo válido (ejemplo: 'DOCUMENTACIÓN INCOMPLETA').
4. Hacer clic en 'Aceptar'.

**Resultado esperado:**
El sistema registra el bloqueo y muestra el mensaje 'Bloqueo registrado correctamente.'

**Datos de prueba:**
{ "tipo_bloqueo_id": 2, "motivo": "DOCUMENTACIÓN INCOMPLETA", "usuario_id": 1, "licencia_id": 1001 }

---

## Caso de Uso 2: Intentar bloquear una licencia con tipo de bloqueo inválido

**Descripción:** El usuario intenta bloquear una licencia seleccionando un tipo de bloqueo que no está activo o no existe.

**Precondiciones:**
El usuario está autenticado y la licencia existe.

**Pasos a seguir:**
1. Acceder a la página de bloqueo de licencia.
2. Seleccionar un tipo de bloqueo inválido (por ejemplo, ID no existente).
3. Ingresar un motivo.
4. Hacer clic en 'Aceptar'.

**Resultado esperado:**
El sistema muestra el mensaje 'Tipo de bloqueo inválido.' y no registra el bloqueo.

**Datos de prueba:**
{ "tipo_bloqueo_id": 999, "motivo": "PRUEBA", "usuario_id": 1, "licencia_id": 1001 }

---

## Caso de Uso 3: Cancelar el proceso de bloqueo

**Descripción:** El usuario decide no continuar con el bloqueo y cancela el formulario.

**Precondiciones:**
El usuario está en la página de bloqueo de licencia.

**Pasos a seguir:**
1. Acceder a la página de bloqueo de licencia.
2. Hacer clic en 'Cancelar'.

**Resultado esperado:**
El sistema regresa a la página anterior sin realizar ningún cambio.

**Datos de prueba:**
No aplica

---

