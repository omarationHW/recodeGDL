# Casos de Uso - ValoresFrm

**Categoría:** Form

## Caso de Uso 1: Alta de un nuevo valor fiscal para una cuenta

**Descripción:** El usuario desea agregar un nuevo valor fiscal para el año y bimestre actual de una cuenta catastral.

**Precondiciones:**
El usuario está autenticado y tiene permisos de edición. La cuenta catastral existe y está activa.

**Pasos a seguir:**
- El usuario navega a la página de valores de la cuenta.
- Hace clic en 'Iniciar Transacción'.
- Llena los campos: Año de Efectos, Bimestre, Valor Fiscal, Tasa, Año Sobretasa (opcional), Observaciones.
- Hace clic en 'Agregar'.
- El valor aparece en la tabla de valores temporales.
- Hace clic en 'Aplicar Cambios'.

**Resultado esperado:**
El nuevo valor se guarda en la tabla principal y la cuenta se actualiza. El usuario ve un mensaje de éxito.

**Datos de prueba:**
{ "cvecuenta": 1001, "axoefec": 2024, "bimefec": 1, "valfiscal": 150000, "tasa": 0.002, "axosobre": 0, "estado": "N", "observacion": "Valor inicial 2024" }

---

## Caso de Uso 2: Modificación de un valor existente

**Descripción:** El usuario necesita corregir el valor fiscal de un registro existente para un bimestre específico.

**Precondiciones:**
El usuario está autenticado. Existe al menos un valor temporal para la cuenta.

**Pasos a seguir:**
- El usuario inicia transacción.
- Selecciona el valor a modificar y hace clic en 'Editar'.
- Cambia el campo 'Valor Fiscal'.
- Hace clic en 'Actualizar'.
- Hace clic en 'Aplicar Cambios'.

**Resultado esperado:**
El valor fiscal es actualizado en la base de datos y la cuenta refleja el nuevo valor.

**Datos de prueba:**
{ "id": 5, "valfiscal": 200000, "tasa": 0.002, "axosobre": 0, "estado": "M", "observacion": "Corrección por error de captura" }

---

## Caso de Uso 3: Eliminación de un valor temporal antes de aplicar

**Descripción:** El usuario agrega un valor por error y decide eliminarlo antes de aplicar los cambios.

**Precondiciones:**
El usuario está autenticado. Hay al menos un valor temporal no aplicado.

**Pasos a seguir:**
- El usuario inicia transacción.
- Agrega un valor temporal.
- Antes de aplicar, hace clic en 'Eliminar' sobre el registro.
- El registro desaparece de la tabla temporal.
- Hace clic en 'Aplicar Cambios'.

**Resultado esperado:**
El valor no deseado no se guarda en la tabla principal. Sólo los valores restantes se aplican.

**Datos de prueba:**
{ "id": 7 }

---

