# Casos de Uso - Ctrol_Imp_Cat

**Categoría:** Form

## Caso de Uso 1: Vista previa del catálogo ordenado por número de control

**Descripción:** El usuario desea ver el catálogo de claves de operación ordenado por número de control.

**Precondiciones:**
El usuario está autenticado y tiene acceso al módulo.

**Pasos a seguir:**
1. El usuario accede a la página 'Impresión de Claves de Operación'.
2. Selecciona la opción 'Control' en el grupo de radio.
3. Presiona el botón 'Vista Previa'.

**Resultado esperado:**
Se muestra una tabla con el catálogo de claves de operación ordenado por el campo 'ctrol_operacion'.

**Datos de prueba:**
No se requiere data específica, pero la tabla ta_16_operacion debe tener registros.

---

## Caso de Uso 2: Vista previa del catálogo ordenado por clave

**Descripción:** El usuario desea ver el catálogo de claves de operación ordenado por clave.

**Precondiciones:**
El usuario está autenticado y tiene acceso al módulo.

**Pasos a seguir:**
1. El usuario accede a la página 'Impresión de Claves de Operación'.
2. Selecciona la opción 'Clave' en el grupo de radio.
3. Presiona el botón 'Vista Previa'.

**Resultado esperado:**
Se muestra una tabla con el catálogo de claves de operación ordenado por el campo 'cve_operacion'.

**Datos de prueba:**
No se requiere data específica, pero la tabla ta_16_operacion debe tener registros.

---

## Caso de Uso 3: Manejo de error por parámetro inválido

**Descripción:** El usuario o el frontend envía un parámetro de orden inválido.

**Precondiciones:**
El usuario está autenticado.

**Pasos a seguir:**
1. El frontend envía una petición con 'order' = 99.
2. El backend ejecuta el stored procedure.

**Resultado esperado:**
El backend retorna el catálogo ordenado por 'ctrol_operacion' (valor por defecto) o un mensaje de error si se implementa validación estricta.

**Datos de prueba:**
order = 99

---

