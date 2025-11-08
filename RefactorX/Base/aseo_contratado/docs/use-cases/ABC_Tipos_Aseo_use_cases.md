# Casos de Uso - ABC_Tipos_Aseo

**Categoría:** Form

## Caso de Uso 1: Alta de un nuevo Tipo de Aseo

**Descripción:** El usuario desea agregar un nuevo tipo de aseo al catálogo.

**Precondiciones:**
El usuario tiene permisos de administrador. La cuenta de aplicación existe.

**Pasos a seguir:**
1. El usuario accede a la página de Tipos de Aseo.
2. Hace clic en 'Alta'.
3. Llena los campos: Tipo de Aseo (ej: 'X'), Descripción (ej: 'Aseo Experimental'), Cta. Aplicación (ej: 123456).
4. Hace clic en 'Guardar'.

**Resultado esperado:**
El nuevo tipo de aseo aparece en la lista y se muestra un mensaje de éxito.

**Datos de prueba:**
{ "tipo_aseo": "X", "descripcion": "Aseo Experimental", "cta_aplicacion": 123456, "usuario": 1 }

---

## Caso de Uso 2: Edición de un Tipo de Aseo existente

**Descripción:** El usuario edita la descripción y cuenta de aplicación de un tipo de aseo.

**Precondiciones:**
Existe un tipo de aseo con ctrol_aseo=5.

**Pasos a seguir:**
1. El usuario selecciona el registro con ctrol_aseo=5.
2. Hace clic en 'Editar'.
3. Modifica la descripción y/o cta_aplicacion.
4. Hace clic en 'Actualizar'.

**Resultado esperado:**
El registro se actualiza correctamente y se muestra un mensaje de éxito.

**Datos de prueba:**
{ "ctrol_aseo": 5, "tipo_aseo": "O", "descripcion": "Aseo Ordinario Modificado", "cta_aplicacion": 654321, "usuario": 1 }

---

## Caso de Uso 3: Eliminación de un Tipo de Aseo sin contratos asociados

**Descripción:** El usuario elimina un tipo de aseo que no tiene contratos asociados.

**Precondiciones:**
Existe un tipo de aseo con ctrol_aseo=10 y no tiene contratos.

**Pasos a seguir:**
1. El usuario selecciona el registro con ctrol_aseo=10.
2. Hace clic en 'Eliminar'.
3. Confirma la eliminación.

**Resultado esperado:**
El registro se elimina y se muestra un mensaje de éxito.

**Datos de prueba:**
{ "ctrol_aseo": 10, "usuario": 1 }

---

