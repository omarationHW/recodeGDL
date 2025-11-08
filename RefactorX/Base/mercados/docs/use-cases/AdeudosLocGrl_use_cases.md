# Casos de Uso - AdeudosLocGrl

**Categoría:** Form

## Caso de Uso 1: Consulta de Adeudos Generales por Mercado y Periodo

**Descripción:** El usuario desea consultar los adeudos generales de un mercado específico hasta un periodo determinado.

**Precondiciones:**
El usuario tiene acceso al sistema y permisos para consultar adeudos.

**Pasos a seguir:**
1. Ingresa a la página de Adeudos Generales.
2. Selecciona la recaudadora (ejemplo: 2).
3. Selecciona el mercado (ejemplo: 5).
4. Selecciona el año (ejemplo: 2024) y mes (ejemplo: 6).
5. Da clic en 'Buscar'.

**Resultado esperado:**
Se muestra la tabla con los adeudos generales del mercado 5 de la recaudadora 2 hasta junio 2024, incluyendo meses y folios de requerimientos.

**Datos de prueba:**
{ "id_rec": 2, "num_mercado": 5, "axo": 2024, "mes": 6 }

---

## Caso de Uso 2: Consulta de Adeudos Generales de Todos los Mercados de una Recaudadora

**Descripción:** El usuario desea ver el reporte global de adeudos de todos los mercados de una recaudadora.

**Precondiciones:**
El usuario tiene acceso al sistema.

**Pasos a seguir:**
1. Ingresa a la página de Adeudos Generales.
2. Selecciona la recaudadora (ejemplo: 1).
3. Deja el campo mercado en '000-TODOS LOS MERCADOS'.
4. Selecciona el año y mes deseados.
5. Da clic en 'Buscar'.

**Resultado esperado:**
Se muestra la tabla con los adeudos de todos los mercados de la recaudadora 1 hasta el periodo seleccionado.

**Datos de prueba:**
{ "id_rec": 1, "num_mercado": null, "axo": 2024, "mes": 5 }

---

## Caso de Uso 3: Exportación a Excel (No Implementado)

**Descripción:** El usuario intenta exportar el reporte a Excel.

**Precondiciones:**
El usuario ha realizado una búsqueda de adeudos.

**Pasos a seguir:**
1. Realiza una búsqueda de adeudos.
2. Da clic en 'Exportar Excel'.

**Resultado esperado:**
Se muestra un mensaje indicando que la exportación a Excel no está implementada.

**Datos de prueba:**
N/A

---

