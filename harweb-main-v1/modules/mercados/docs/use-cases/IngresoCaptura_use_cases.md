# Casos de Uso - IngresoCaptura

**Categoría:** Form

## Caso de Uso 1: Consulta de Ingreso Capturado para un Mercado y Fecha Específica

**Descripción:** El usuario desea consultar el resumen de pagos capturados para el mercado 34, en la oficina 2, caja 'A', operación 12345, en junio de 2024.

**Precondiciones:**
El usuario tiene acceso al sistema y existen pagos registrados para esos filtros.

**Pasos a seguir:**
1. Ingresar a la página 'Ingreso Captura'.
2. Ingresar '34' en Número de Mercado.
3. Seleccionar '2024-06-01' como Fecha Pago.
4. Ingresar '2' en Oficina Pago.
5. Ingresar 'A' en Caja Pago.
6. Ingresar '12345' en Operación Pago.
7. Presionar 'Buscar'.

**Resultado esperado:**
Se muestra una tabla con los pagos agrupados por fecha, caja y operación, mostrando el número de periodos y el importe total.

**Datos de prueba:**
{
  "num_mercado": 34,
  "fecha_pago": "2024-06-01",
  "oficina_pago": 2,
  "caja_pago": "A",
  "operacion_pago": 12345
}

---

## Caso de Uso 2: Validación de Parámetros Faltantes

**Descripción:** El usuario intenta consultar sin ingresar el campo 'operacion_pago'.

**Precondiciones:**
El usuario accede al formulario pero omite el campo operación.

**Pasos a seguir:**
1. Ingresar valores en todos los campos excepto 'Operación Pago'.
2. Presionar 'Buscar'.

**Resultado esperado:**
El sistema muestra un mensaje de error indicando que el campo es requerido.

**Datos de prueba:**
{
  "num_mercado": 34,
  "fecha_pago": "2024-06-01",
  "oficina_pago": 2,
  "caja_pago": "A"
}

---

## Caso de Uso 3: Consulta sin Resultados

**Descripción:** El usuario consulta un mercado, fecha, oficina, caja y operación para los cuales no existen pagos registrados.

**Precondiciones:**
No existen pagos para los filtros seleccionados.

**Pasos a seguir:**
1. Ingresar filtros que no correspondan a ningún pago registrado.
2. Presionar 'Buscar'.

**Resultado esperado:**
El sistema muestra un mensaje indicando que no hay resultados.

**Datos de prueba:**
{
  "num_mercado": 99,
  "fecha_pago": "2024-01-01",
  "oficina_pago": 9,
  "caja_pago": "Z",
  "operacion_pago": 99999
}

---

