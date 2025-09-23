# Casos de Uso - RecargosMntto

**Categoría:** Form

## Caso de Uso 1: Alta de un nuevo recargo de mantenimiento

**Descripción:** El usuario desea registrar un nuevo recargo para el año y periodo actual.

**Precondiciones:**
El usuario tiene permisos de alta. No existe ya un recargo para ese año y periodo.

**Pasos a seguir:**
1. El usuario accede a la página de Recargos de Mantenimiento.
2. Llena el formulario con año=2024, periodo=7, porcentaje=1.75.
3. Presiona el botón 'Agregar'.
4. El sistema valida que no exista ya un recargo para ese año y periodo.
5. El sistema inserta el registro y muestra mensaje de éxito.

**Resultado esperado:**
El recargo es insertado y aparece en la tabla de recargos. Se muestra mensaje 'Recargo insertado correctamente.'

**Datos de prueba:**
{ "axo": 2024, "periodo": 7, "porcentaje": 1.75, "id_usuario": 1 }

---

## Caso de Uso 2: Modificación de un recargo existente

**Descripción:** El usuario necesita actualizar el porcentaje de un recargo ya registrado.

**Precondiciones:**
Existe un recargo para año=2024, periodo=7.

**Pasos a seguir:**
1. El usuario accede a la página y localiza el recargo 2024-7 en la tabla.
2. Hace click en 'Editar'.
3. Cambia el porcentaje a 2.00.
4. Presiona 'Actualizar'.
5. El sistema valida existencia y actualiza el registro.

**Resultado esperado:**
El porcentaje se actualiza y la tabla refleja el nuevo valor. Mensaje: 'Recargo actualizado correctamente.'

**Datos de prueba:**
{ "axo": 2024, "periodo": 7, "porcentaje": 2.00, "id_usuario": 1 }

---

## Caso de Uso 3: Intento de alta duplicada

**Descripción:** El usuario intenta registrar un recargo para un año y periodo que ya existen.

**Precondiciones:**
Ya existe un recargo para año=2024, periodo=7.

**Pasos a seguir:**
1. El usuario llena el formulario con año=2024, periodo=7, porcentaje=1.5.
2. Presiona 'Agregar'.
3. El sistema detecta duplicado y rechaza la operación.

**Resultado esperado:**
No se inserta el registro. Mensaje: 'Ya existe un recargo para ese año y periodo.'

**Datos de prueba:**
{ "axo": 2024, "periodo": 7, "porcentaje": 1.5, "id_usuario": 1 }

---

