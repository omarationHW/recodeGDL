# Casos de Uso - IngresoLib

**Categoría:** Form

## Caso de Uso 1: Consulta de Ingresos del Mercado Libertad para un Mes

**Descripción:** El usuario desea consultar todos los ingresos registrados para el Mercado Libertad en el mes de marzo de 2024.

**Precondiciones:**
El usuario tiene acceso al sistema y existen registros de pagos para el Mercado Libertad en marzo 2024.

**Pasos a seguir:**
- El usuario accede a la página de Ingreso Mercado Libertad.
- Selecciona el mes '3' (marzo) y el año '2024'.
- Selecciona el mercado '001 - Mercado Libertad'.
- Hace clic en 'Procesar'.

**Resultado esperado:**
Se muestran las tablas con los ingresos por fecha y caja, los totales por caja y los totales globales para el Mercado Libertad en marzo 2024.

**Datos de prueba:**
{ mes: 3, anio: 2024, mercado_id: 1 }

---

## Caso de Uso 2: Validación de Parámetros Inválidos

**Descripción:** El usuario intenta consultar ingresos sin seleccionar un mercado.

**Precondiciones:**
El usuario accede a la página pero no selecciona ningún mercado.

**Pasos a seguir:**
- El usuario deja el campo 'Mercado' vacío.
- Hace clic en 'Procesar'.

**Resultado esperado:**
El sistema muestra un mensaje de error indicando que el campo 'Mercado' es obligatorio.

**Datos de prueba:**
{ mes: 3, anio: 2024, mercado_id: null }

---

## Caso de Uso 3: Consulta de Totales por Caja

**Descripción:** El usuario desea ver el desglose de pagos por cada caja para el Mercado Libertad en abril 2024.

**Precondiciones:**
Existen registros de pagos en diferentes cajas para el Mercado Libertad en abril 2024.

**Pasos a seguir:**
- El usuario selecciona mes '4', año '2024', mercado '001'.
- Hace clic en 'Procesar'.
- Observa la tabla de 'Totales por Caja'.

**Resultado esperado:**
La tabla muestra una fila por cada caja con el total de pagos y el total de renta pagada.

**Datos de prueba:**
{ mes: 4, anio: 2024, mercado_id: 1 }

---

