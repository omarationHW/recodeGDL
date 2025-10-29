# Casos de Uso - sfrmprediocarto

**Categoría:** Form

## Caso de Uso 1: Visualización de la ubicación de un predio existente

**Descripción:** Un usuario ingresa una clave catastral válida y visualiza la ubicación cartográfica del predio.

**Precondiciones:**
El usuario tiene acceso a la aplicación y conoce la clave catastral.

**Pasos a seguir:**
1. El usuario accede a la página 'Ubicación del Predio'.
2. Ingresa la clave catastral '1234567890'.
3. Presiona el botón 'Mostrar Ubicación'.
4. El sistema muestra el visor cartográfico con la ubicación correspondiente.

**Resultado esperado:**
El visor se carga correctamente mostrando la ubicación del predio con la clave catastral ingresada.

**Datos de prueba:**
cvecatastro: '1234567890'

---

## Caso de Uso 2: Intento de visualización sin ingresar clave catastral

**Descripción:** El usuario intenta visualizar la ubicación sin proporcionar la clave catastral.

**Precondiciones:**
El usuario accede a la página pero no ingresa ningún dato.

**Pasos a seguir:**
1. El usuario accede a la página 'Ubicación del Predio'.
2. Deja el campo de clave catastral vacío.
3. Presiona el botón 'Mostrar Ubicación'.

**Resultado esperado:**
El sistema muestra un mensaje de error indicando que la clave catastral es obligatoria.

**Datos de prueba:**
cvecatastro: ''

---

## Caso de Uso 3: Visualización con clave catastral inválida (caracteres especiales)

**Descripción:** El usuario ingresa una clave catastral con caracteres no permitidos.

**Precondiciones:**
El usuario accede a la página y tiene una clave catastral inválida.

**Pasos a seguir:**
1. El usuario accede a la página 'Ubicación del Predio'.
2. Ingresa la clave catastral 'ABC@#123!'.
3. Presiona el botón 'Mostrar Ubicación'.

**Resultado esperado:**
El sistema genera la URL, pero el visor externo puede no mostrar resultados. El sistema no debe fallar internamente.

**Datos de prueba:**
cvecatastro: 'ABC@#123!'

---

