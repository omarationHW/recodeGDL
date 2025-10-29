# Casos de Uso - Titulos

**Categoría:** Form

## Caso de Uso 1: Búsqueda y Visualización de Título Existente

**Descripción:** El usuario busca un título existente por fecha, folio y operación, y visualiza los datos del beneficiario.

**Precondiciones:**
El título debe existir en la base de datos.

**Pasos a seguir:**
1. El usuario ingresa la fecha de pago, folio y número de operación en el formulario.
2. Presiona el botón 'Buscar'.
3. El sistema consulta el backend y muestra los datos del título y beneficiario.

**Resultado esperado:**
Se muestran todos los datos del título y beneficiario en el formulario.

**Datos de prueba:**
{ "fecha": "2024-06-01", "folio": 12345, "operacion": 6789 }

---

## Caso de Uso 2: Actualización de Beneficiario de Título

**Descripción:** El usuario actualiza los datos del beneficiario de un título existente.

**Precondiciones:**
El título debe existir y el usuario debe tener permisos de edición.

**Pasos a seguir:**
1. El usuario busca el título (ver caso anterior).
2. Modifica los campos de nombre, domicilio, colonia y teléfono del beneficiario.
3. Presiona el botón 'Actualizar Beneficiario'.
4. El sistema envía los datos al backend y actualiza el registro.

**Resultado esperado:**
El beneficiario se actualiza correctamente y se muestra un mensaje de éxito.

**Datos de prueba:**
{ "control_rcm": 12345, "titulo": 1, "fecha": "2024-06-01", "libro": 10, "axo": 2024, "folio": 100, "nombre": "JUAN PEREZ", "domicilio": "AV. PRINCIPAL 123", "colonia": "CENTRO", "telefono": "3312345678", "partida": "PART-001" }

---

## Caso de Uso 3: Impresión de Título

**Descripción:** El usuario imprime el título de propiedad con los datos actualizados.

**Precondiciones:**
El título debe existir y tener datos completos de beneficiario.

**Pasos a seguir:**
1. El usuario busca el título y verifica los datos.
2. Presiona el botón 'Imprimir Título'.
3. El sistema obtiene los datos de impresión y muestra la vista previa.

**Resultado esperado:**
Se muestra la vista previa de los datos de impresión del título.

**Datos de prueba:**
{ "fecha": "2024-06-01", "folio": 12345, "operacion": 6789 }

---

