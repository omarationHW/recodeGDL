# Casos de Uso - ABC_Tipos_Emp

**Categoría:** Form

## Caso de Uso 1: Alta de un nuevo Tipo de Empresa

**Descripción:** El usuario desea agregar un nuevo tipo de empresa al catálogo.

**Precondiciones:**
El usuario tiene acceso al sistema y permisos para modificar el catálogo.

**Pasos a seguir:**
1. El usuario navega a la página de Tipos de Empresa.
2. Hace clic en 'Agregar Tipo'.
3. Llena los campos: Control=10, Tipo=P, Descripción=Privada.
4. Hace clic en 'Guardar'.

**Resultado esperado:**
El nuevo tipo de empresa aparece en la tabla y se muestra un mensaje de éxito.

**Datos de prueba:**
{ "ctrol_emp": 10, "tipo_empresa": "P", "descripcion": "Privada" }

---

## Caso de Uso 2: Edición de un Tipo de Empresa existente

**Descripción:** El usuario necesita modificar la descripción de un tipo de empresa.

**Precondiciones:**
Existe un tipo de empresa con ctrol_emp=10.

**Pasos a seguir:**
1. El usuario localiza el registro con Control=10.
2. Hace clic en 'Editar'.
3. Cambia la descripción a 'Privada Actualizada'.
4. Hace clic en 'Guardar'.

**Resultado esperado:**
El registro se actualiza y la tabla muestra la nueva descripción.

**Datos de prueba:**
{ "ctrol_emp": 10, "tipo_empresa": "P", "descripcion": "Privada Actualizada" }

---

## Caso de Uso 3: Intento de eliminar un Tipo de Empresa con empresas asociadas

**Descripción:** El usuario intenta eliminar un tipo de empresa que tiene empresas asociadas.

**Precondiciones:**
Existe un tipo de empresa con ctrol_emp=9 y al menos una empresa asociada.

**Pasos a seguir:**
1. El usuario localiza el registro con Control=9.
2. Hace clic en 'Eliminar'.
3. Confirma la eliminación.

**Resultado esperado:**
El sistema muestra un mensaje de error: 'No se puede eliminar: existen empresas asociadas a este tipo'.

**Datos de prueba:**
{ "ctrol_emp": 9 }

---

