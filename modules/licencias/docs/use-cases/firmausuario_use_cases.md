# Casos de Uso - firmausuario

**Categoría:** Form

## Caso de Uso 1: Validación exitosa de firma electrónica

**Descripción:** Un usuario autorizado ingresa correctamente su usuario y firma electrónica, y el sistema valida exitosamente.

**Precondiciones:**
El usuario 'jdoe' existe en la tabla 'usuarios' con firma_digital 'abc123'.

**Pasos a seguir:**
1. Acceder a la página de firma electrónica.
2. Ingresar 'jdoe' en el campo Usuario.
3. Ingresar 'abc123' en el campo Firma.
4. Presionar 'Aceptar'.

**Resultado esperado:**
El sistema muestra el mensaje 'Firma validada correctamente.' y success=true.

**Datos de prueba:**
{ "usuario": "jdoe", "firma": "abc123" }

---

## Caso de Uso 2: Firma incorrecta para usuario existente

**Descripción:** Un usuario existente ingresa una firma incorrecta.

**Precondiciones:**
El usuario 'jdoe' existe en la tabla 'usuarios' con firma_digital 'abc123'.

**Pasos a seguir:**
1. Acceder a la página de firma electrónica.
2. Ingresar 'jdoe' en el campo Usuario.
3. Ingresar 'wrongpass' en el campo Firma.
4. Presionar 'Aceptar'.

**Resultado esperado:**
El sistema muestra el mensaje 'Usuario o firma incorrectos.' y success=false.

**Datos de prueba:**
{ "usuario": "jdoe", "firma": "wrongpass" }

---

## Caso de Uso 3: Usuario inexistente

**Descripción:** Un usuario que no existe intenta validar su firma.

**Precondiciones:**
El usuario 'ghost' no existe en la tabla 'usuarios'.

**Pasos a seguir:**
1. Acceder a la página de firma electrónica.
2. Ingresar 'ghost' en el campo Usuario.
3. Ingresar cualquier valor en el campo Firma.
4. Presionar 'Aceptar'.

**Resultado esperado:**
El sistema muestra el mensaje 'Usuario o firma incorrectos.' y success=false.

**Datos de prueba:**
{ "usuario": "ghost", "firma": "cualquier" }

---

