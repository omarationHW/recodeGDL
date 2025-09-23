# Casos de Uso - avisofrm

**Categoría:** Form

## Caso de Uso 1: Aceptar aviso sin mostrar información adicional

**Descripción:** El usuario visualiza el aviso y lo acepta sin marcar la opción de 'Más información'.

**Precondiciones:**
El usuario está autenticado y accede a la página del aviso.

**Pasos a seguir:**
1. El usuario ingresa a la página del aviso.
2. Lee el mensaje principal.
3. No marca la casilla 'Más información'.
4. Da clic en 'Aceptar'.

**Resultado esperado:**
Se registra en la base de datos que el usuario aceptó el aviso sin mostrar información adicional.

**Datos de prueba:**
{ "user_id": 1, "show_more": false, "memo_text": null }

---

## Caso de Uso 2: Aceptar aviso mostrando información adicional

**Descripción:** El usuario visualiza el aviso, marca la opción 'Más información', revisa el texto adicional y acepta.

**Precondiciones:**
El usuario está autenticado y accede a la página del aviso.

**Pasos a seguir:**
1. El usuario ingresa a la página del aviso.
2. Lee el mensaje principal.
3. Marca la casilla 'Más información'.
4. Lee el texto adicional.
5. Da clic en 'Aceptar'.

**Resultado esperado:**
Se registra en la base de datos que el usuario aceptó el aviso y mostró información adicional.

**Datos de prueba:**
{ "user_id": 2, "show_more": true, "memo_text": "Aquí puede ir información adicional sobre el error en la clave catastral." }

---

## Caso de Uso 3: Intento de aceptar aviso sin autenticación

**Descripción:** Un usuario no autenticado intenta aceptar el aviso.

**Precondiciones:**
El usuario no está autenticado.

**Pasos a seguir:**
1. El usuario accede a la página del aviso.
2. Da clic en 'Aceptar'.

**Resultado esperado:**
El sistema rechaza la petición y no registra la aceptación.

**Datos de prueba:**
{ "user_id": null, "show_more": false, "memo_text": null }

---

