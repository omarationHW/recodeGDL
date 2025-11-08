# Casos de Uso - Ejercicios_Ins

**Categoría:** Form

## Caso de Uso 1: Agregar un nuevo ejercicio fiscal

**Descripción:** El usuario desea agregar el ejercicio 2025 al sistema.

**Precondiciones:**
El usuario tiene permisos de administrador y el año 2025 no existe en la tabla.

**Pasos a seguir:**
1. El usuario accede a la página de Ejercicios.
2. Ingresa '2025' en el campo de nuevo ejercicio.
3. Presiona el botón 'Aceptar'.

**Resultado esperado:**
El sistema muestra mensaje de éxito y el año 2025 aparece en la lista.

**Datos de prueba:**
nuevoEjercicio = 2025

---

## Caso de Uso 2: Intentar agregar un ejercicio existente

**Descripción:** El usuario intenta agregar el año 2023, que ya existe.

**Precondiciones:**
El año 2023 ya está en la tabla ta_16_ejercicios.

**Pasos a seguir:**
1. El usuario accede a la página de Ejercicios.
2. Ingresa '2023' en el campo de nuevo ejercicio.
3. Presiona 'Aceptar'.

**Resultado esperado:**
El sistema muestra mensaje de error 'YA EXISTE EL EJERCICIO' y no agrega nada.

**Datos de prueba:**
nuevoEjercicio = 2023

---

## Caso de Uso 3: Validación de año fuera de rango

**Descripción:** El usuario intenta agregar el año 1800.

**Precondiciones:**
El usuario tiene acceso al formulario.

**Pasos a seguir:**
1. El usuario accede a la página de Ejercicios.
2. Ingresa '1800' en el campo de nuevo ejercicio.
3. Presiona 'Aceptar'.

**Resultado esperado:**
El sistema muestra mensaje de error de validación y no realiza ninguna acción.

**Datos de prueba:**
nuevoEjercicio = 1800

---

