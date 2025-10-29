# Casos de Uso - fechasegfrm

**Categoría:** Form

## Caso de Uso 1: Registrar una nueva fecha y oficio

**Descripción:** El usuario ingresa una fecha y un número de oficio válido y guarda el registro.

**Precondiciones:**
El usuario tiene acceso a la página del formulario y la tabla 'fechasegfrm' existe.

**Pasos a seguir:**
1. Acceder a la página 'Formulario Fecha Seguimiento'.
2. Seleccionar una fecha válida en el campo de fecha.
3. Ingresar un texto válido en el campo 'Oficio'.
4. Hacer clic en el botón 'Aceptar'.

**Resultado esperado:**
El registro se guarda correctamente y aparece en la tabla de registros recientes. Se muestra un mensaje de éxito.

**Datos de prueba:**
{ "fecha": "2024-07-01", "oficio": "OF-1234" }

---

## Caso de Uso 2: Intentar guardar sin ingresar oficio

**Descripción:** El usuario intenta guardar el formulario sin ingresar el campo 'Oficio'.

**Precondiciones:**
El usuario tiene acceso a la página del formulario.

**Pasos a seguir:**
1. Acceder a la página 'Formulario Fecha Seguimiento'.
2. Seleccionar una fecha válida.
3. Dejar el campo 'Oficio' vacío.
4. Hacer clic en el botón 'Aceptar'.

**Resultado esperado:**
El sistema muestra un mensaje de error indicando que el campo 'Oficio' es obligatorio. No se guarda ningún registro.

**Datos de prueba:**
{ "fecha": "2024-07-01", "oficio": "" }

---

## Caso de Uso 3: Visualizar registros recientes

**Descripción:** El usuario accede a la página y visualiza la tabla de los últimos registros guardados.

**Precondiciones:**
Existen registros previos en la tabla 'fechasegfrm'.

**Pasos a seguir:**
1. Acceder a la página 'Formulario Fecha Seguimiento'.
2. Observar la tabla de registros recientes en la parte inferior.

**Resultado esperado:**
Se muestran los últimos 20 registros ordenados por fecha de creación descendente.

**Datos de prueba:**
No se requiere datos de entrada.

---

