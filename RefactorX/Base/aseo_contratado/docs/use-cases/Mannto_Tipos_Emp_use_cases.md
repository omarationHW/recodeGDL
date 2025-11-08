# Casos de Uso - Mannto_Tipos_Emp

**Categoría:** Form

## Caso de Uso 1: Alta de Tipo de Empresa

**Descripción:** El usuario desea registrar un nuevo tipo de empresa en el catálogo.

**Precondiciones:**
El usuario tiene permisos de administrador y no existe un tipo de empresa con la clave indicada.

**Pasos a seguir:**
1. El usuario accede a la página de Tipos de Empresa.
2. Hace clic en 'Nuevo Tipo de Empresa'.
3. Ingresa 'B' como tipo y 'Bares y Restaurantes' como descripción.
4. Hace clic en 'Guardar'.

**Resultado esperado:**
El nuevo tipo de empresa aparece en la lista y se muestra un mensaje de éxito.

**Datos de prueba:**
{ "tipo_empresa": "B", "descripcion": "Bares y Restaurantes" }

---

## Caso de Uso 2: Intento de Eliminación con Empresas Asociadas

**Descripción:** El usuario intenta eliminar un tipo de empresa que tiene empresas asociadas.

**Precondiciones:**
Existe al menos una empresa con ctrol_emp=2.

**Pasos a seguir:**
1. El usuario accede a la página de Tipos de Empresa.
2. Hace clic en 'Eliminar' sobre el tipo con ctrol_emp=2.
3. El sistema verifica si puede eliminar.

**Resultado esperado:**
El sistema muestra un mensaje indicando que no se puede eliminar porque existen empresas asociadas.

**Datos de prueba:**
{ "ctrol_emp": 2 }

---

## Caso de Uso 3: Edición de Descripción de Tipo de Empresa

**Descripción:** El usuario edita la descripción de un tipo de empresa existente.

**Precondiciones:**
Existe un tipo de empresa con tipo_empresa='C'.

**Pasos a seguir:**
1. El usuario accede a la página de Tipos de Empresa.
2. Hace clic en 'Editar' sobre el tipo 'C'.
3. Cambia la descripción a 'Comercial Minorista'.
4. Hace clic en 'Guardar'.

**Resultado esperado:**
La descripción se actualiza correctamente y se muestra un mensaje de éxito.

**Datos de prueba:**
{ "tipo_empresa": "C", "descripcion": "Comercial Minorista" }

---

