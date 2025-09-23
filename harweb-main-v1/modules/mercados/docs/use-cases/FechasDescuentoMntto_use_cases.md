# Casos de Uso - FechasDescuentoMntto

**Categoría:** Form

## Caso de Uso 1: Consulta de todas las fechas de descuento

**Descripción:** El usuario accede al módulo y visualiza la tabla con todos los meses y sus fechas de descuento y recargos.

**Precondiciones:**
El usuario está autenticado y tiene permisos de consulta.

**Pasos a seguir:**
1. El usuario navega a la página de Fechas de Descuento.
2. El frontend realiza una petición POST a /api/execute con action 'getAll'.
3. El backend retorna la lista de meses y fechas.

**Resultado esperado:**
Se muestra la tabla con los 12 meses y sus fechas correspondientes.

**Datos de prueba:**
No se requiere data específica, solo que existan registros en ta_11_fecha_desc.

---

## Caso de Uso 2: Actualización de la fecha de descuento y recargos para un mes

**Descripción:** El usuario edita la fecha de descuento y recargos del mes de mayo.

**Precondiciones:**
El usuario está autenticado y tiene permisos de edición.

**Pasos a seguir:**
1. El usuario hace clic en 'Editar' en la fila de mayo.
2. Se muestra el formulario con los datos actuales.
3. El usuario cambia la fecha de descuento a '2024-05-15' y la de recargos a '2024-05-23'.
4. El usuario guarda los cambios.
5. El frontend envía la petición POST a /api/execute con action 'update' y los datos.
6. El backend valida y actualiza.

**Resultado esperado:**
Las fechas se actualizan correctamente y la tabla se refresca.

**Datos de prueba:**
{ "mes": 5, "fecha_descuento": "2024-05-15", "fecha_recargos": "2024-05-23", "id_usuario": 2 }

---

## Caso de Uso 3: Validación de mes incorrecto en fechas

**Descripción:** El usuario intenta poner una fecha de descuento de junio para el mes de mayo.

**Precondiciones:**
El usuario está autenticado y tiene permisos de edición.

**Pasos a seguir:**
1. El usuario edita el mes de mayo.
2. Ingresa fecha_descuento '2024-06-01' y fecha_recargos '2024-05-23'.
3. Guarda los cambios.
4. El backend valida y rechaza la operación.

**Resultado esperado:**
Se muestra un mensaje de error: 'La fecha de descuento y recargos debe corresponder al mes seleccionado.'

**Datos de prueba:**
{ "mes": 5, "fecha_descuento": "2024-06-01", "fecha_recargos": "2024-05-23", "id_usuario": 2 }

---

