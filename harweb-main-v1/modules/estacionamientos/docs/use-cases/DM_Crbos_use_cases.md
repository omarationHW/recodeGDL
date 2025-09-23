# Casos de Uso - DM_Crbos

**Categoría:** Form

## Caso de Uso 1: Consulta de Contrarecibos por Fecha

**Descripción:** El usuario consulta todos los contrarecibos ingresados en una fecha específica.

**Precondiciones:**
El usuario tiene acceso al sistema y existen contrarecibos en la fecha consultada.

**Pasos a seguir:**
1. El usuario accede a la página de Contrarecibos.
2. Selecciona la fecha '2024-06-01' en el campo de fecha.
3. Hace clic en 'Buscar'.
4. El sistema muestra el listado de contrarecibos y el total del día.

**Resultado esperado:**
Se muestra una tabla con los contrarecibos de la fecha seleccionada y el total de importes.

**Datos de prueba:**
{ "fecha": "2024-06-01" }

---

## Caso de Uso 2: Visualización de Detalle de Contrarecibo

**Descripción:** El usuario visualiza el detalle de un contrarecibo específico desde el listado.

**Precondiciones:**
El usuario ya realizó una búsqueda y hay resultados en pantalla.

**Pasos a seguir:**
1. El usuario hace clic en el botón 'Detalle' de un contrarecibo del listado.
2. El sistema consulta el detalle y lo muestra en pantalla.

**Resultado esperado:**
Se muestra la información completa del contrarecibo, incluyendo estado calculado.

**Datos de prueba:**
{ "contrarecibo": 123456 }

---

## Caso de Uso 3: Alta de Nuevo Contrarecibo

**Descripción:** El usuario registra un nuevo contrarecibo usando el formulario.

**Precondiciones:**
El usuario tiene permisos de alta y conoce los datos requeridos.

**Pasos a seguir:**
1. El usuario accede al formulario de alta.
2. Ingresa todos los datos requeridos.
3. Envía el formulario.
4. El sistema ejecuta el SP de alta y confirma la operación.

**Resultado esperado:**
El contrarecibo queda registrado y aparece en las consultas posteriores.

**Datos de prueba:**
{ "ejercicio": 2024, "procedencia": 1, "crbo": 999999, "feccrbo": "2024-06-01", "diasven": 30, "importe": 10000.00, "concepto": "Pago de servicios", "proveedor": 1, "doctos": 2, "fecingre": "2024-06-01", "fecvenci": "2024-07-01", "feccodi": null, "fecveri": null, "fecprog": null, "fecaja": null, "feccancel": null, "cvecheq": "A", "benef": "Juan Perez", "formapago": "E", "notas": "Ninguna", "param": 1, "num_ctrol_cheque": null, "clave_movimiento": null, "benef_cheque": null }

---

