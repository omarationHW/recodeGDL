# Casos de Uso - Mannto_Zonas

**Categoría:** Form

## Caso de Uso 1: Alta de Zona Nueva

**Descripción:** El usuario desea registrar una nueva zona y sub-zona en el catálogo.

**Precondiciones:**
El usuario tiene permisos de acceso y la combinación zona/sub-zona no existe.

**Pasos a seguir:**
1. El usuario accede a la página de Catálogo de Zonas.
2. Hace clic en 'Nueva Zona'.
3. Ingresa los valores: Zona=10, Sub-Zona=1, Descripción='Zona Industrial Norte'.
4. Hace clic en 'Guardar'.

**Resultado esperado:**
La zona se crea correctamente y aparece en la lista. Se muestra mensaje de éxito.

**Datos de prueba:**
{ "zona": 10, "sub_zona": 1, "descripcion": "Zona Industrial Norte" }

---

## Caso de Uso 2: Intento de Alta Duplicada

**Descripción:** El usuario intenta registrar una zona/sub-zona que ya existe.

**Precondiciones:**
Ya existe una zona con Zona=10 y Sub-Zona=1.

**Pasos a seguir:**
1. El usuario accede a la página de Catálogo de Zonas.
2. Hace clic en 'Nueva Zona'.
3. Ingresa los valores: Zona=10, Sub-Zona=1, Descripción='Zona Industrial Norte'.
4. Hace clic en 'Guardar'.

**Resultado esperado:**
El sistema muestra un mensaje de error indicando que la zona/sub-zona ya existe.

**Datos de prueba:**
{ "zona": 10, "sub_zona": 1, "descripcion": "Zona Industrial Norte" }

---

## Caso de Uso 3: Eliminación de Zona con Dependencias

**Descripción:** El usuario intenta eliminar una zona que tiene empresas asociadas.

**Precondiciones:**
Existe una zona con ctrol_zona=5 y al menos una empresa con ctrol_zona=5.

**Pasos a seguir:**
1. El usuario accede a la página de Catálogo de Zonas.
2. Hace clic en 'Eliminar' en la fila de la zona con ctrol_zona=5.
3. Confirma la eliminación.

**Resultado esperado:**
El sistema muestra un mensaje de error indicando que existen empresas con esta zona y no se puede borrar.

**Datos de prueba:**
{ "ctrol_zona": 5 }

---

