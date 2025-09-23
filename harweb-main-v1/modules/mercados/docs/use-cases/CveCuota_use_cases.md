# Casos de Uso - CveCuota

**Categoría:** Form

## Caso de Uso 1: Alta de nueva clave de cuota

**Descripción:** El usuario desea agregar una nueva clave de cuota al catálogo.

**Precondiciones:**
El usuario tiene permisos de administrador y la clave no existe.

**Pasos a seguir:**
1. El usuario accede a la página de Claves de Cuota.
2. Hace clic en 'Agregar'.
3. Ingresa el número de clave (ej: 5) y la descripción (ej: 'TRIMESTRAL').
4. Presiona 'Guardar'.

**Resultado esperado:**
La clave de cuota se agrega correctamente y aparece en la lista.

**Datos de prueba:**
{ "clave_cuota": 5, "descripcion": "TRIMESTRAL" }

---

## Caso de Uso 2: Modificación de descripción de clave de cuota

**Descripción:** El usuario edita la descripción de una clave de cuota existente.

**Precondiciones:**
La clave de cuota existe.

**Pasos a seguir:**
1. El usuario accede a la página de Claves de Cuota.
2. Hace clic en 'Editar' sobre la clave 2.
3. Cambia la descripción a 'BIMESTRAL ACTUALIZADO'.
4. Presiona 'Guardar'.

**Resultado esperado:**
La descripción de la clave de cuota se actualiza correctamente.

**Datos de prueba:**
{ "clave_cuota": 2, "descripcion": "BIMESTRAL ACTUALIZADO" }

---

## Caso de Uso 3: Consulta de claves de cuota

**Descripción:** El usuario consulta el listado de claves de cuota.

**Precondiciones:**
Existen registros en la tabla ta_11_cve_cuota.

**Pasos a seguir:**
1. El usuario accede a la página de Claves de Cuota.
2. El sistema muestra la lista de claves y descripciones.

**Resultado esperado:**
Se visualizan todas las claves de cuota existentes.

**Datos de prueba:**
N/A

---

