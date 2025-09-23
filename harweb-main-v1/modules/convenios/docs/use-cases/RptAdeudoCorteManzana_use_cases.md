# Casos de Uso - RptAdeudoCorteManzana

**Categoría:** Form

## Caso de Uso 1: Consulta de Reporte de Adeudo Corte Manzana (Vigentes)

**Descripción:** El usuario desea consultar el reporte de adeudos vigentes para un subtipo específico y un rango de fechas.

**Precondiciones:**
El usuario tiene acceso al sistema y permisos para consultar reportes.

**Pasos a seguir:**
- Acceder a la página 'Reporte de Adeudo Corte por Manzana'.
- Seleccionar el subtipo deseado (ejemplo: 'Subtipo 1').
- Ingresar la fecha desde y hasta (ejemplo: 2024-01-01 a 2024-06-30).
- Seleccionar 'Vigentes' como estado.
- Seleccionar 'Adeudos' como tipo de reporte.
- Hacer clic en 'Consultar'.

**Resultado esperado:**
Se muestra una tabla con los adeudos agrupados por manzana, mostrando costo total, pagos, recargos y saldo.

**Datos de prueba:**
{
  "subtipo": 1,
  "fechadsd": "2024-01-01",
  "fechahst": "2024-06-30",
  "rep": 1,
  "est": "A"
}

---

## Caso de Uso 2: Exportar Reporte a Excel

**Descripción:** El usuario desea exportar el reporte de corte de manzana a un archivo Excel.

**Precondiciones:**
El usuario ya realizó una consulta exitosa del reporte.

**Pasos a seguir:**
- En la página del reporte, hacer clic en el botón 'Exportar Excel'.

**Resultado esperado:**
Se descarga un archivo Excel con los datos del reporte.

**Datos de prueba:**
{
  "subtipo": 1,
  "fechadsd": "2024-01-01",
  "fechahst": "2024-06-30",
  "rep": 1,
  "est": "A",
  "tipo": "excel"
}

---

## Caso de Uso 3: Consulta de Reporte de Saldos a Favor

**Descripción:** El usuario consulta el reporte para ver los contratos con saldo a favor.

**Precondiciones:**
El usuario tiene permisos de consulta.

**Pasos a seguir:**
- Acceder a la página del reporte.
- Seleccionar el subtipo deseado.
- Ingresar fechas.
- Seleccionar 'Saldos a Favor' como tipo de reporte.
- Hacer clic en 'Consultar'.

**Resultado esperado:**
Se muestra la tabla con los contratos que tienen saldo a favor.

**Datos de prueba:**
{
  "subtipo": 2,
  "fechadsd": "2024-01-01",
  "fechahst": "2024-06-30",
  "rep": 2,
  "est": "A"
}

---

