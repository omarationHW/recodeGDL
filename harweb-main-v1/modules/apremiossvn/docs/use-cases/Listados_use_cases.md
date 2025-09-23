# Casos de Uso - Listados

**Categoría:** Form

## Caso de Uso 1: Consulta de Listados de Folios por Rango y Clave

**Descripción:** El usuario desea obtener un listado de folios de Mercados, entre los folios 100 y 200, con clave 'P' (Practicado) y vigencia '1' (Vigente), en la recaudadora 1.

**Precondiciones:**
El usuario tiene acceso al sistema y permisos para consultar Listados.

**Pasos a seguir:**
- Accede a la página Listados.
- Selecciona 'Mercados' como aplicación.
- Ingresa '100' en Folio Desde y '200' en Folio Hasta.
- Selecciona recaudadora '1'.
- Selecciona clave 'P'.
- Selecciona vigencia '1'.
- Da clic en 'Buscar'.

**Resultado esperado:**
Se muestra una tabla con los folios que cumplen los filtros, incluyendo datos de nombre, estado, importe pagado, etc.

**Datos de prueba:**
{ "id_rec": 1, "modulo": 11, "folio_desde": 100, "folio_hasta": 200, "clave": "P", "vigencia": "1", "fecha_prac_desde": null, "fecha_prac_hasta": null }

---

## Caso de Uso 2: Consulta de Listados de Estacionamientos Públicos con Todas las Claves y Vigencias

**Descripción:** El usuario desea obtener todos los folios de Estacionamientos Públicos entre los folios 500 y 600, sin filtrar por clave ni vigencia.

**Precondiciones:**
El usuario tiene acceso y permisos.

**Pasos a seguir:**
- Accede a la página Listados.
- Selecciona 'Estacionamientos Públicos'.
- Ingresa '500' en Folio Desde y '600' en Folio Hasta.
- Selecciona recaudadora '2'.
- Selecciona clave 'Todas'.
- Selecciona vigencia 'Todas'.
- Da clic en 'Buscar'.

**Resultado esperado:**
Se muestra la tabla con todos los folios de ese rango y módulo.

**Datos de prueba:**
{ "id_rec": 2, "modulo": 24, "folio_desde": 500, "folio_hasta": 600, "clave": "todas", "vigencia": "todas", "fecha_prac_desde": null, "fecha_prac_hasta": null }

---

## Caso de Uso 3: Consulta de Listados de Aseo con Filtro de Fecha de Practicado

**Descripción:** El usuario desea obtener folios de Aseo entre los folios 300 y 350, con clave 'P', vigencia '2', y solo los practicados entre 2024-01-01 y 2024-03-31.

**Precondiciones:**
El usuario tiene acceso y permisos.

**Pasos a seguir:**
- Accede a la página Listados.
- Selecciona 'Aseo'.
- Ingresa '300' en Folio Desde y '350' en Folio Hasta.
- Selecciona recaudadora '3'.
- Selecciona clave 'P'.
- Selecciona vigencia '2'.
- Ingresa fechas '2024-01-01' y '2024-03-31' en el filtro de fecha de practicado.
- Da clic en 'Buscar'.

**Resultado esperado:**
Se muestra la tabla con los folios de Aseo practicados en ese rango de fechas.

**Datos de prueba:**
{ "id_rec": 3, "modulo": 16, "folio_desde": 300, "folio_hasta": 350, "clave": "P", "vigencia": "2", "fecha_prac_desde": "2024-01-01", "fecha_prac_hasta": "2024-03-31" }

---

