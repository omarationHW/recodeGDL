# Casos de Uso - sQRptUnd_Recolec

**Categoría:** Form

## Caso de Uso 1: Consulta del catálogo por número de control

**Descripción:** El usuario desea ver el catálogo de claves de recolección del ejercicio 2024, ordenado por número de control.

**Precondiciones:**
El usuario tiene acceso a la aplicación y existen registros para el ejercicio 2024.

**Pasos a seguir:**
1. Ingresar a la página 'Catálogo de Claves de Recolección'.
2. Seleccionar '2024' en el campo Ejercicio.
3. Seleccionar 'Número de Control' en Clasificación por.
4. Presionar el botón 'Consultar'.

**Resultado esperado:**
Se muestra una tabla con los registros del ejercicio 2024, ordenados por el campo 'Control'.

**Datos de prueba:**
Ejercicio: 2024
Clasificación: ctrol

---

## Caso de Uso 2: Consulta del catálogo por descripción

**Descripción:** El usuario desea ver el catálogo de claves de recolección del ejercicio 2023, ordenado alfabéticamente por descripción.

**Precondiciones:**
El usuario tiene acceso y existen registros para el ejercicio 2023.

**Pasos a seguir:**
1. Ingresar a la página 'Catálogo de Claves de Recolección'.
2. Seleccionar '2023' en Ejercicio.
3. Seleccionar 'Descripción' en Clasificación por.
4. Presionar 'Consultar'.

**Resultado esperado:**
Se muestra la tabla ordenada alfabéticamente por descripción.

**Datos de prueba:**
Ejercicio: 2023
Clasificación: descripcion

---

## Caso de Uso 3: Consulta sin resultados

**Descripción:** El usuario selecciona un ejercicio para el cual no existen registros.

**Precondiciones:**
El usuario tiene acceso. No existen registros para el ejercicio 2022.

**Pasos a seguir:**
1. Ingresar a la página.
2. Seleccionar '2022' en Ejercicio.
3. Seleccionar cualquier clasificación.
4. Presionar 'Consultar'.

**Resultado esperado:**
Se muestra un mensaje indicando que no se encontraron registros.

**Datos de prueba:**
Ejercicio: 2022
Clasificación: ctrol

---

