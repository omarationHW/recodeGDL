# Casos de Uso - Unit5

**Categoría:** Form

## Caso de Uso 1: Registro de una nueva transmisión patrimonial

**Descripción:** El usuario ingresa todos los datos requeridos para registrar una transmisión patrimonial de un predio.

**Precondiciones:**
El usuario está autenticado y tiene permisos para registrar transmisiones. La cuenta catastral existe y está activa.

**Pasos a seguir:**
- El usuario accede a la página de captura de transmisión.
- Ingresa año de efectos (2024), bimestre (2), porcentaje (100).
- Selecciona notario y municipio.
- Ingresa número de escritura, fechas, naturaleza del acto.
- Ingresa valor de la operación y superficie según título.
- Da clic en 'Guardar'.

**Resultado esperado:**
La transmisión se registra correctamente en la base de datos. Se muestra mensaje de éxito.

**Datos de prueba:**
{
  "cvecuenta": 12345,
  "cveavaext": 678,
  "recaudadora": 1,
  "status": "D",
  "noescrituras": "1234",
  "fechaotorg": "2024-02-15",
  "fechafirma": "2024-02-16",
  "fechaadjudicacion": null,
  "documentosotros": "N/A",
  "valortransm": 1500000.00,
  "porcbase": 100,
  "axoefec": 2024,
  "bimefec": 2,
  "valfemi": 1450000.00,
  "tasaemi": "0.02",
  "idnotaria": 5,
  "lugotorg": 10,
  "naturaleza": 3,
  "areatitulo": 200.00
}

---

## Caso de Uso 2: Validación de año y bimestre fuera de rango

**Descripción:** El usuario intenta guardar una transmisión con año menor a 1960 y bimestre mayor a 6.

**Precondiciones:**
El usuario está autenticado.

**Pasos a seguir:**
- Ingresa año de efectos 1950 y bimestre 7.
- Da clic en 'Guardar'.

**Resultado esperado:**
El sistema muestra mensajes de error: 'Revise el año...' y 'Revise el bimestre...'. No se guarda el registro.

**Datos de prueba:**
{
  "axoefec": 1950,
  "bimefec": 7
}

---

## Caso de Uso 3: Carga dinámica de avaluos externos filtrados

**Descripción:** El usuario cambia el año de efectos y el sistema filtra los avaluos externos disponibles.

**Precondiciones:**
El usuario está autenticado. Existen avaluos externos para la cuenta.

**Pasos a seguir:**
- Ingresa año de efectos 2022.
- El sistema consulta y muestra solo los avaluos externos con axofolio >= 2022.

**Resultado esperado:**
La tabla de avaluos externos se actualiza mostrando solo los registros filtrados.

**Datos de prueba:**
{
  "cvecuenta": 12345,
  "axoefec": 2022
}

---

