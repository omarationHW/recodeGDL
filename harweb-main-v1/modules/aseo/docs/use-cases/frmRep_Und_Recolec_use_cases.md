# Casos de Uso - frmRep_Und_Recolec

**Categoría:** Form

## Caso de Uso 1: Consulta de Unidades de Recolección por Ejercicio y Orden

**Descripción:** El usuario desea visualizar el listado de unidades de recolección para el ejercicio 2024, ordenadas por descripción.

**Precondiciones:**
El usuario está autenticado y tiene permisos de consulta.

**Pasos a seguir:**
1. Accede a la página 'Unidades de Recolección'.
2. Selecciona el ejercicio 2024.
3. Selecciona 'Descripción' como criterio de orden.
4. Presiona 'Vista Previa'.

**Resultado esperado:**
Se muestra una tabla con todas las unidades de recolección del ejercicio 2024, ordenadas alfabéticamente por descripción.

**Datos de prueba:**
{ "ejercicio": 2024, "order": 3 }

---

## Caso de Uso 2: Intento de Eliminación de Unidad de Recolección Referenciada

**Descripción:** El usuario intenta eliminar una unidad de recolección que está referenciada en al menos un contrato.

**Precondiciones:**
Existe al menos un contrato que utiliza la unidad a eliminar.

**Pasos a seguir:**
1. Accede a la página de administración de unidades.
2. Selecciona la unidad referenciada.
3. Presiona 'Eliminar'.

**Resultado esperado:**
El sistema responde con un mensaje de error indicando que no se puede borrar porque existen contratos asociados.

**Datos de prueba:**
{ "ctrol": 101 }

---

## Caso de Uso 3: Alta de Nueva Unidad de Recolección

**Descripción:** El usuario da de alta una nueva unidad de recolección para el ejercicio 2025.

**Precondiciones:**
No existe una unidad con la misma clave para el ejercicio 2025.

**Pasos a seguir:**
1. Accede a la página de administración de unidades.
2. Ingresa los datos: ejercicio=2025, clave='Z', descripción='Zona Nueva', costo_unidad=150.00, costo_exed=200.00.
3. Presiona 'Guardar'.

**Resultado esperado:**
El sistema responde con éxito y la nueva unidad aparece en el listado.

**Datos de prueba:**
{ "ejercicio": 2025, "cve": "Z", "descripcion": "Zona Nueva", "costo_unidad": 150.00, "costo_exed": 200.00 }

---

