# Casos de Uso - ListadosLocales

**Categoría:** Form

## Caso de Uso 1: Consulta de Padrón de Locales

**Descripción:** El usuario desea obtener el padrón de locales de un mercado específico.

**Precondiciones:**
El usuario está autenticado y tiene permisos de consulta.

**Pasos a seguir:**
1. El usuario accede a la página de Listados de Mercados.
2. Selecciona 'Padrón de Locales'.
3. Selecciona una recaudadora y un mercado.
4. Presiona 'Buscar'.
5. El sistema muestra el listado de locales.

**Resultado esperado:**
Se muestra una tabla con los locales del mercado seleccionado, incluyendo datos de renta y estado.

**Datos de prueba:**
Recaudadora: 1 (Centro), Mercado: 5 (San Juan de Dios)

---

## Caso de Uso 2: Consulta de Movimientos de Locales

**Descripción:** El usuario requiere ver los movimientos de locales en un rango de fechas.

**Precondiciones:**
El usuario está autenticado y tiene permisos de consulta.

**Pasos a seguir:**
1. El usuario accede a la página de Listados de Mercados.
2. Selecciona 'Movimientos Locales'.
3. Selecciona la recaudadora y el rango de fechas.
4. Presiona 'Buscar'.
5. El sistema muestra los movimientos realizados en ese periodo.

**Resultado esperado:**
Se muestra una tabla con los movimientos, tipo, fecha y datos del local.

**Datos de prueba:**
Recaudadora: 2 (Olímpica), Fecha Desde: 2024-01-01, Fecha Hasta: 2024-01-31

---

## Caso de Uso 3: Consulta de Ingreso por Zonas

**Descripción:** El usuario desea ver el ingreso global por zonas en un periodo.

**Precondiciones:**
El usuario está autenticado y tiene permisos de consulta.

**Pasos a seguir:**
1. El usuario accede a la página de Listados de Mercados.
2. Selecciona 'Ingreso por Zonas'.
3. Selecciona el rango de fechas.
4. Presiona 'Buscar'.
5. El sistema muestra el ingreso por zona.

**Resultado esperado:**
Se muestra una tabla con las zonas y el importe pagado en el periodo.

**Datos de prueba:**
Fecha Desde: 2024-01-01, Fecha Hasta: 2024-01-31

---

