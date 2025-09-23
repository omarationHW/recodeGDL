# Casos de Uso - impno

**Categoría:** Form

## Caso de Uso 1: Consulta e impresión de notificación de predio urbano

**Descripción:** El usuario ingresa los datos de un predio urbano y obtiene la notificación correspondiente, luego la imprime.

**Precondiciones:**
El predio existe en la base de datos y el usuario tiene acceso al sistema.

**Pasos a seguir:**
1. Ingresar el valor de 'Recaud.' correspondiente (ej: '001').
2. Seleccionar 'U' en 'Tipo de predio'.
3. Ingresar el número de 'Cuenta' (ej: '12345').
4. Presionar el botón 'Buscar'.
5. Visualizar los datos de la notificación.
6. Presionar 'Imprimir Notificación'.

**Resultado esperado:**
Se muestran los datos completos de la notificación y se simula la impresión correctamente.

**Datos de prueba:**
{ "recaud": "001", "urbrus": "U", "cuenta": "12345" }

---

## Caso de Uso 2: Error por datos incompletos

**Descripción:** El usuario intenta buscar una notificación sin llenar todos los campos requeridos.

**Precondiciones:**
El usuario está en la página de notificaciones.

**Pasos a seguir:**
1. Dejar vacío el campo 'Recaud.' o 'Cuenta'.
2. Presionar el botón 'Buscar'.

**Resultado esperado:**
El sistema muestra un mensaje de error indicando que faltan datos.

**Datos de prueba:**
{ "recaud": "", "urbrus": "U", "cuenta": "" }

---

## Caso de Uso 3: Error por tipo de predio inválido

**Descripción:** El usuario ingresa un valor no permitido en el campo 'Tipo de predio'.

**Precondiciones:**
El usuario está en la página de notificaciones.

**Pasos a seguir:**
1. Ingresar '001' en 'Recaud.'
2. Ingresar 'X' en 'Tipo de predio'.
3. Ingresar '12345' en 'Cuenta'.
4. Presionar el botón 'Buscar'.

**Resultado esperado:**
El sistema muestra un mensaje de error indicando que el tipo de predio es incorrecto.

**Datos de prueba:**
{ "recaud": "001", "urbrus": "X", "cuenta": "12345" }

---

