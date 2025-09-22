# Casos de Uso - TitulosSin

**Categoría:** Form

## Caso de Uso 1: Impresión exitosa de Título de Propiedad Sin Referencias

**Descripción:** El usuario imprime un título de propiedad sin referencias después de validar los ingresos.

**Precondiciones:**
El usuario tiene acceso al sistema y existe un ingreso válido para los datos proporcionados.

**Pasos a seguir:**
1. El usuario accede a la página TitulosSin.
2. Ingresa la fecha de pago, Ofna, Caja, Operación y Folio.
3. Presiona 'Buscar Ingresos'.
4. El sistema muestra los campos adicionales (Título, Partida, Teléfono).
5. El usuario llena los campos y presiona 'Imprimir Título'.

**Resultado esperado:**
El sistema muestra la vista previa del título y permite su impresión.

**Datos de prueba:**
{ "fecha": "2024-06-01", "ofna": 1, "caja": "A", "operacion": 12345, "folio": 1001, "titulo": 555, "partida": 10, "telefono": "3331234567" }

---

## Caso de Uso 2: Error por ingreso inexistente

**Descripción:** El usuario intenta imprimir un título pero no existe un ingreso para los datos proporcionados.

**Precondiciones:**
El usuario tiene acceso al sistema. No existe ingreso para los datos ingresados.

**Pasos a seguir:**
1. El usuario accede a la página TitulosSin.
2. Ingresa la fecha de pago, Ofna, Caja, Operación y Folio incorrectos.
3. Presiona 'Buscar Ingresos'.

**Resultado esperado:**
El sistema muestra un mensaje de error indicando que no se encontró el ingreso.

**Datos de prueba:**
{ "fecha": "2024-06-01", "ofna": 2, "caja": "B", "operacion": 99999, "folio": 9999 }

---

## Caso de Uso 3: Validación de campos obligatorios

**Descripción:** El usuario intenta imprimir un título sin llenar todos los campos requeridos.

**Precondiciones:**
El usuario tiene acceso al sistema.

**Pasos a seguir:**
1. El usuario accede a la página TitulosSin.
2. Deja vacío el campo 'Folio' y presiona 'Buscar Ingresos'.

**Resultado esperado:**
El sistema muestra un mensaje de error indicando que el folio es requerido.

**Datos de prueba:**
{ "fecha": "2024-06-01", "ofna": 1, "caja": "A", "operacion": 12345, "folio": "" }

---

