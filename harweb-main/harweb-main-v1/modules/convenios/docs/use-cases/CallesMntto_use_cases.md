# Casos de Uso - CallesMntto

**Categoría:** Form

## Caso de Uso 1: Alta de una nueva Calle

**Descripción:** El usuario desea registrar una nueva calle en el catálogo para una colonia específica.

**Precondiciones:**
El usuario está autenticado y tiene permisos de alta. Existen colonias, tipos, servicios y cuentas en catálogo.

**Pasos a seguir:**
1. El usuario accede a la página de Mantenimiento de Calles.
2. Selecciona la colonia, ingresa el número de calle, selecciona tipo y servicio.
3. Escribe la descripción de la calle y el año de obra.
4. Selecciona la cuenta de ingreso y la cuenta de rezago.
5. Selecciona la vigencia, plazo y tipo de plazo.
6. Da clic en 'Agregar'.
7. El sistema envía la petición 'insertCalle' al backend.
8. El backend valida y ejecuta el stored procedure de inserción.
9. El sistema muestra mensaje de éxito y actualiza la lista.

**Resultado esperado:**
La nueva calle aparece en la lista y el usuario ve el mensaje 'Calle insertada correctamente'.

**Datos de prueba:**
{ colonia: 1, calle: 101, tipo: 2, servicio: 3, desc_calle: 'AV. PRINCIPAL', axo_obra: 2024, cuenta_ingreso: 12345, cuenta_rezago: 54321, vigencia_obra: 'A', plazo: 12, clave_plazo: 'M' }

---

## Caso de Uso 2: Edición de una Calle Existente

**Descripción:** El usuario necesita modificar la descripción y el plazo de una calle ya registrada.

**Precondiciones:**
Existe una calle registrada con colonia=1 y calle=101.

**Pasos a seguir:**
1. El usuario busca la calle en la lista.
2. Da clic en 'Editar'.
3. Modifica la descripción y el plazo.
4. Da clic en 'Actualizar'.
5. El sistema envía la petición 'updateCalle' al backend.
6. El backend valida y ejecuta el stored procedure de actualización.
7. El sistema muestra mensaje de éxito y actualiza la lista.

**Resultado esperado:**
La calle muestra la nueva descripción y plazo. El usuario ve el mensaje 'Calle actualizada correctamente'.

**Datos de prueba:**
{ colonia: 1, calle: 101, tipo: 2, servicio: 3, desc_calle: 'AV. PRINCIPAL MODIFICADA', axo_obra: 2024, cuenta_ingreso: 12345, cuenta_rezago: 54321, vigencia_obra: 'A', plazo: 24, clave_plazo: 'M' }

---

## Caso de Uso 3: Validación de Campos Requeridos

**Descripción:** El usuario intenta guardar una calle sin llenar todos los campos obligatorios.

**Precondiciones:**
El usuario está en el formulario y deja campos vacíos.

**Pasos a seguir:**
1. El usuario deja vacío el campo 'desc_calle' y da clic en 'Agregar'.
2. El sistema valida y detecta el campo faltante.
3. El sistema muestra un mensaje de error.

**Resultado esperado:**
El sistema no permite guardar y muestra el mensaje 'The desc_calle field is required.'

**Datos de prueba:**
{ colonia: 1, calle: 102, tipo: 2, servicio: 3, desc_calle: '', axo_obra: 2024, cuenta_ingreso: 12345, cuenta_rezago: 54321, vigencia_obra: 'A', plazo: 12, clave_plazo: 'M' }

---

