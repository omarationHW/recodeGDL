# Casos de Uso - firma

**Categoría:** Form

## Caso de Uso 1: Validación exitosa de firma electrónica

**Descripción:** Un usuario ingresa su firma electrónica correcta y es validado exitosamente.

**Precondiciones:**
El usuario existe en la tabla 'usuarios' y su campo 'firma_digital' coincide con la ingresada.

**Pasos a seguir:**
1. El usuario accede a la página de firma electrónica.
2. Ingresa su firma digital en el campo correspondiente.
3. Presiona el botón 'Aceptar'.
4. El sistema envía la firma al endpoint '/api/execute' con operación 'firma_validate'.
5. El backend valida la firma y responde con éxito.

**Resultado esperado:**
El usuario recibe un mensaje de éxito ('Firma válida. Bienvenido.') y puede continuar.

**Datos de prueba:**
{ "firma_digital": "123456" } // Asumiendo que '123456' es la firma válida en la base de datos

---

## Caso de Uso 2: Validación fallida de firma electrónica

**Descripción:** Un usuario ingresa una firma electrónica incorrecta.

**Precondiciones:**
El usuario existe, pero la firma ingresada no coincide con la registrada.

**Pasos a seguir:**
1. El usuario accede a la página de firma electrónica.
2. Ingresa una firma digital incorrecta.
3. Presiona 'Aceptar'.
4. El sistema envía la firma al endpoint '/api/execute'.
5. El backend responde que la firma es inválida.

**Resultado esperado:**
El usuario recibe un mensaje de error ('Firma inválida.') y no puede continuar.

**Datos de prueba:**
{ "firma_digital": "abcdef" } // 'abcdef' no existe en la base de datos

---

## Caso de Uso 3: Actualización de firma electrónica

**Descripción:** Un usuario actualiza su firma electrónica.

**Precondiciones:**
El usuario está autenticado y conoce su usuario_id.

**Pasos a seguir:**
1. El usuario accede a la página de actualización de firma.
2. Ingresa la nueva firma digital.
3. Presiona 'Aceptar'.
4. El sistema envía la nueva firma y usuario_id al endpoint '/api/execute' con operación 'firma_save'.
5. El backend actualiza la firma en la base de datos.

**Resultado esperado:**
El usuario recibe un mensaje de éxito ('Firma guardada correctamente.').

**Datos de prueba:**
{ "usuario_id": 1, "firma_digital": "nuevaFirma2024" }

---

