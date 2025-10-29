# Casos de Uso - Etiquetas

**Categoría:** Form

## Caso de Uso 1: Consulta y edición de etiquetas para un rubro

**Descripción:** El usuario desea consultar y modificar las etiquetas asociadas al rubro 'Rastro'.

**Precondiciones:**
El usuario tiene acceso al sistema y permisos de edición.

**Pasos a seguir:**
1. Ingresa a la página de Catálogo de Etiquetas.
2. Selecciona '3 - Rastro' en el combo de tablas.
3. El sistema muestra los valores actuales de las etiquetas.
4. El usuario modifica el campo 'concesionario' y 'ubicacion'.
5. Presiona el botón 'Actualizar'.

**Resultado esperado:**
Las etiquetas se actualizan en la base de datos y el sistema muestra un mensaje de éxito.

**Datos de prueba:**
{ "cve_tab": "3", "concesionario": "Nuevo Concesionario", "ubicacion": "Nueva Ubicación" }

---

## Caso de Uso 2: Intento de actualización sin selección de tabla

**Descripción:** El usuario intenta actualizar etiquetas sin seleccionar una tabla.

**Precondiciones:**
El usuario está en la página pero no ha seleccionado ninguna tabla.

**Pasos a seguir:**
1. Ingresa a la página de Catálogo de Etiquetas.
2. No selecciona ninguna tabla.
3. Intenta presionar 'Actualizar'.

**Resultado esperado:**
El sistema no permite la actualización y muestra un mensaje de error.

**Datos de prueba:**
{ "cve_tab": "", ... }

---

## Caso de Uso 3: Visualización de etiquetas inexistentes

**Descripción:** El usuario selecciona una tabla que no tiene etiquetas asociadas.

**Precondiciones:**
Existe una tabla en t34_tablas sin registro en t34_etiq.

**Pasos a seguir:**
1. Selecciona la tabla sin etiquetas.
2. El sistema limpia el formulario y deshabilita el botón de actualización.

**Resultado esperado:**
No se muestran datos y no se puede actualizar.

**Datos de prueba:**
{ "cve_tab": "X" }

---

