# Casos de Uso - ABC_Zonas

**Categoría:** Form

## Caso de Uso 1: Alta de Zona

**Descripción:** El usuario desea agregar una nueva zona al catálogo.

**Precondiciones:**
El usuario tiene acceso al módulo de zonas.

**Pasos a seguir:**
1. El usuario ingresa a la página de Catálogo de Zonas.
2. Hace clic en 'Agregar Zona'.
3. Llena los campos: Zona=10, Sub Zona=1, Descripción='Zona Industrial'.
4. Hace clic en 'Crear'.

**Resultado esperado:**
La zona se agrega correctamente y aparece en el listado.

**Datos de prueba:**
{ "zona": 10, "sub_zona": 1, "descripcion": "Zona Industrial" }

---

## Caso de Uso 2: Edición de Zona

**Descripción:** El usuario edita la descripción de una zona existente.

**Precondiciones:**
Existe una zona con ctrol_zona=5.

**Pasos a seguir:**
1. El usuario localiza la zona con ctrol_zona=5.
2. Hace clic en 'Editar'.
3. Cambia la descripción a 'Zona Centro Actualizada'.
4. Hace clic en 'Actualizar'.

**Resultado esperado:**
La descripción de la zona se actualiza correctamente.

**Datos de prueba:**
{ "ctrol_zona": 5, "zona": 1, "sub_zona": 2, "descripcion": "Zona Centro Actualizada" }

---

## Caso de Uso 3: Eliminación de Zona sin empresas relacionadas

**Descripción:** El usuario elimina una zona que no tiene empresas asociadas.

**Precondiciones:**
Existe una zona con ctrol_zona=8 y ninguna empresa la usa.

**Pasos a seguir:**
1. El usuario localiza la zona con ctrol_zona=8.
2. Hace clic en 'Eliminar'.
3. Confirma la eliminación.

**Resultado esperado:**
La zona se elimina correctamente del catálogo.

**Datos de prueba:**
{ "ctrol_zona": 8 }

---

