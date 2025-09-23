# Casos de Uso - FechaDescuento

**Categoría:** Form

## Caso de Uso 1: Consulta de Fechas de Descuento

**Descripción:** El usuario accede a la página de Fechas de Descuento y visualiza la lista de meses con sus fechas de descuento y recargos.

**Precondiciones:**
El usuario está autenticado y tiene permisos de consulta.

**Pasos a seguir:**
1. El usuario navega a la página 'Fechas de Descuento'.
2. El sistema realiza una petición 'list' al endpoint /api/execute.
3. El backend retorna la lista de meses y fechas.
4. El frontend muestra la tabla con los datos.

**Resultado esperado:**
La tabla muestra los 12 meses con sus fechas actuales de descuento y recargos.

**Datos de prueba:**
No se requiere data específica, pero la tabla ta_11_fecha_desc debe tener datos para todos los meses.

---

## Caso de Uso 2: Modificación de Fecha de Descuento

**Descripción:** El usuario selecciona un mes y modifica la fecha de descuento y/o recargos.

**Precondiciones:**
El usuario está autenticado y tiene permisos de edición.

**Pasos a seguir:**
1. El usuario selecciona un mes en la tabla.
2. Hace clic en 'Modificar'.
3. Se abre el modal con los datos actuales.
4. El usuario cambia la fecha de descuento y/o recargos.
5. Hace clic en 'Guardar'.
6. El sistema envía una petición 'update' al endpoint /api/execute.
7. El backend actualiza la base de datos y retorna éxito.
8. El frontend refresca la tabla.

**Resultado esperado:**
La fecha de descuento y/o recargos del mes seleccionado se actualiza correctamente y se muestra el nuevo valor en la tabla.

**Datos de prueba:**
{ "mes": 6, "fecha_descuento": "2024-06-10", "fecha_recargos": "2024-06-20", "id_usuario": 2 }

---

## Caso de Uso 3: Intento de Modificar un Mes Inexistente

**Descripción:** El usuario intenta modificar un mes que no existe en la tabla.

**Precondiciones:**
El usuario está autenticado.

**Pasos a seguir:**
1. El usuario envía una petición 'update' con un mes inexistente (por ejemplo, mes=13).
2. El backend valida y detecta que el mes no existe.
3. El backend retorna un error.

**Resultado esperado:**
El sistema muestra un mensaje de error indicando que el mes no existe.

**Datos de prueba:**
{ "mes": 13, "fecha_descuento": "2024-06-10", "fecha_recargos": "2024-06-20", "id_usuario": 2 }

---

