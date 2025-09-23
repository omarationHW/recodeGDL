# Casos de Uso - PasoPagos

**Categoría:** Form

## Caso de Uso 1: Carga de Pagos de Contratos AS/400

**Descripción:** El usuario carga un archivo plano de pagos de contratos provenientes de AS/400, revisa los registros y los graba en la base de datos.

**Precondiciones:**
El usuario tiene acceso al módulo PasoPagos y cuenta con el archivo plano en formato correcto.

**Pasos a seguir:**
[
  "El usuario ingresa a la página PasoPagos.",
  "Selecciona la opción 'Contratos D.S.'.",
  "Carga el archivo plano de pagos.",
  "Presiona 'Procesar Archivo' y revisa los registros en pantalla.",
  "Presiona 'Grabar' para guardar los pagos.",
  "El sistema muestra mensaje de éxito."
]

**Resultado esperado:**
Los pagos se graban correctamente en la tabla temporal y el usuario recibe confirmación.

**Datos de prueba:**
Archivo plano con 3 registros de pagos de contratos, formato fijo.

---

## Caso de Uso 2: Carga de Pagos de Convenios Generales

**Descripción:** El usuario carga un archivo plano de pagos de convenios generales, revisa los registros y los graba en la base de datos.

**Precondiciones:**
El usuario tiene acceso al módulo PasoPagos y cuenta con el archivo plano de convenios.

**Pasos a seguir:**
[
  "El usuario ingresa a la página PasoPagos.",
  "Selecciona la opción 'Convenios Gral.'.",
  "Carga el archivo plano de pagos de convenios.",
  "Presiona 'Procesar Archivo' y revisa los registros.",
  "Presiona 'Grabar' para guardar los pagos.",
  "El sistema muestra mensaje de éxito."
]

**Resultado esperado:**
Los pagos de convenios se graban correctamente y el usuario recibe confirmación.

**Datos de prueba:**
Archivo plano con 2 registros de pagos de convenios, formato fijo.

---

## Caso de Uso 3: Consulta de Estatus de Carga DS

**Descripción:** El usuario consulta el estatus de la carga de pagos de contratos DS para verificar cuántos registros fueron grabados, modificados o inconsistentes.

**Precondiciones:**
El usuario ya realizó una carga de pagos.

**Pasos a seguir:**
[
  "El usuario ingresa a la página PasoPagos.",
  "Presiona 'Consultar Estatus DS'.",
  "El sistema muestra el número de registros grabados, modificados, inconsistentes y el total."
]

**Resultado esperado:**
El usuario visualiza el resumen de la carga de pagos.

**Datos de prueba:**
Carga previa de 5 registros, 4 grabados, 1 inconsistente.

---

