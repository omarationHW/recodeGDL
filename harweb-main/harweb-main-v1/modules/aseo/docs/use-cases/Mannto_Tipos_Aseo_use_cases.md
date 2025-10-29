# Casos de Uso - Mannto_Tipos_Aseo

**Categoría:** Form

## Caso de Uso 1: Alta de un nuevo Tipo de Aseo

**Descripción:** El usuario desea registrar un nuevo tipo de aseo con clave 'H', descripción 'Hospitalario' y cuenta de aplicación existente.

**Precondiciones:**
El usuario tiene permisos de alta. La cuenta de aplicación 12345 existe.

**Pasos a seguir:**
- El usuario accede a la página de Tipos de Aseo
- Hace clic en 'Nuevo Tipo de Aseo'
- Llena el formulario: Tipo: 'H', Descripción: 'Hospitalario', Cta. Aplicación: 12345
- Presiona 'Guardar'

**Resultado esperado:**
El registro se crea, aparece en la tabla y se muestra mensaje de éxito.

**Datos de prueba:**
{ "tipo_aseo": "H", "descripcion": "Hospitalario", "cta_aplicacion": 12345 }

---

## Caso de Uso 2: Intento de eliminar un Tipo de Aseo con contratos asociados

**Descripción:** El usuario intenta eliminar un tipo de aseo que ya está en uso por contratos.

**Precondiciones:**
Existe un tipo de aseo 'O' con contratos asociados.

**Pasos a seguir:**
- El usuario accede a la página de Tipos de Aseo
- Hace clic en 'Eliminar' sobre el tipo 'O'
- Confirma la eliminación

**Resultado esperado:**
El sistema muestra un mensaje de error: 'Existen contratos con este tipo de aseo. No se puede eliminar.'

**Datos de prueba:**
{ "tipo_aseo": "O" }

---

## Caso de Uso 3: Validación de cuenta de aplicación inexistente

**Descripción:** El usuario intenta crear un tipo de aseo con una cuenta de aplicación que no existe.

**Precondiciones:**
La cuenta de aplicación 999999 no existe.

**Pasos a seguir:**
- El usuario accede a la página de Tipos de Aseo
- Hace clic en 'Nuevo Tipo de Aseo'
- Llena el formulario: Tipo: 'Z', Descripción: 'Zona X', Cta. Aplicación: 999999
- Presiona 'Guardar'

**Resultado esperado:**
El sistema muestra un mensaje de error: 'La cuenta de aplicación no existe'

**Datos de prueba:**
{ "tipo_aseo": "Z", "descripcion": "Zona X", "cta_aplicacion": 999999 }

---

