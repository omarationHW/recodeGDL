# Casos de Uso - CveDiferMntto

**Categoría:** Form

## Caso de Uso 1: Alta de nueva clave de diferencia

**Descripción:** El usuario desea registrar una nueva clave de diferencia por cobrar.

**Precondiciones:**
El usuario tiene permisos de administrador y conoce la cuenta de ingreso.

**Pasos a seguir:**
1. Accede a la página de Mantenimiento de Claves de Diferencias.
2. Da clic en 'Agregar'.
3. Ingresa el número de clave, la descripción y selecciona la cuenta de ingreso.
4. Ingresa su id_usuario (o se autocompleta).
5. Da clic en 'Agregar'.

**Resultado esperado:**
La clave se inserta correctamente y aparece en la lista. Se muestra mensaje de éxito.

**Datos de prueba:**
{ "clave_diferencia": 200, "descripcion": "DIFERENCIA POR AJUSTE", "cuenta_ingreso": 44502, "id_usuario": 1 }

---

## Caso de Uso 2: Modificación de clave de diferencia existente

**Descripción:** El usuario necesita actualizar la descripción y cuenta de ingreso de una clave existente.

**Precondiciones:**
Existe una clave de diferencia registrada.

**Pasos a seguir:**
1. Busca la clave en la tabla.
2. Da clic en 'Editar'.
3. Modifica la descripción y/o la cuenta de ingreso.
4. Da clic en 'Actualizar'.

**Resultado esperado:**
La clave se actualiza correctamente y la lista se refresca. Se muestra mensaje de éxito.

**Datos de prueba:**
{ "clave_diferencia": 200, "descripcion": "DIFERENCIA POR REDONDEO", "cuenta_ingreso": 44503, "id_usuario": 1 }

---

## Caso de Uso 3: Validación de campos obligatorios

**Descripción:** El usuario intenta guardar una clave sin descripción o sin cuenta de ingreso.

**Precondiciones:**
El usuario está en el formulario de alta o edición.

**Pasos a seguir:**
1. Deja vacío el campo descripción o cuenta de ingreso.
2. Da clic en 'Agregar' o 'Actualizar'.

**Resultado esperado:**
El sistema muestra un mensaje de error indicando el campo faltante y no realiza la operación.

**Datos de prueba:**
{ "clave_diferencia": 201, "descripcion": "", "cuenta_ingreso": "", "id_usuario": 1 }

---

