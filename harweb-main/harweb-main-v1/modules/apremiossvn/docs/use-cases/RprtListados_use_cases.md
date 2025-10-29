# Casos de Uso - RprtListados

**Categoría:** Form

## Caso de Uso 1: Consulta de Requerimientos de Folios para Mercados

**Descripción:** El usuario desea obtener el listado de requerimientos de folios para el módulo de Mercados (modulo=11), en la zona 1, para los folios del 100 al 120, sin filtrar por clave ni vigencia.

**Precondiciones:**
El usuario tiene acceso al sistema y existen registros en la base de datos para los parámetros indicados.

**Pasos a seguir:**
- Acceder a la página de Listado de Requerimientos.
- Seleccionar Zona/Oficina: 1
- Seleccionar Módulo: Mercados (11)
- Ingresar Folio Inicial: 100
- Ingresar Folio Final: 120
- Seleccionar Clave Practicado: Todas
- Seleccionar Vigencia: Todas
- Hacer clic en 'Consultar'.

**Resultado esperado:**
Se muestra una tabla con los folios del 100 al 120 del módulo Mercados en la zona 1, con todos los campos y el campo 'datos' calculado para cada registro.

**Datos de prueba:**
{
  "vrec": 1,
  "vmod": 11,
  "vfol1": 100,
  "vfol2": 120,
  "vcve": "todas",
  "vvig": "todas",
  "vfdsd": null,
  "vfhst": null
}

---

## Caso de Uso 2: Consulta Filtrada por Clave Practicado y Fechas

**Descripción:** El usuario requiere ver los requerimientos del módulo Aseo (16) en la zona 2, folios 200-210, solo aquellos con clave 'P' y practicados entre 2024-01-01 y 2024-01-31.

**Precondiciones:**
Existen registros en la base de datos que cumplen con los filtros.

**Pasos a seguir:**
- Acceder a la página de Listado de Requerimientos.
- Seleccionar Zona/Oficina: 2
- Seleccionar Módulo: Aseo (16)
- Ingresar Folio Inicial: 200
- Ingresar Folio Final: 210
- Seleccionar Clave Practicado: P
- Ingresar Fecha Desde: 2024-01-01
- Ingresar Fecha Hasta: 2024-01-31
- Seleccionar Vigencia: Todas
- Hacer clic en 'Consultar'.

**Resultado esperado:**
Se muestran solo los registros con clave 'P' y fecha_practicado entre 2024-01-01 y 2024-01-31.

**Datos de prueba:**
{
  "vrec": 2,
  "vmod": 16,
  "vfol1": 200,
  "vfol2": 210,
  "vcve": "P",
  "vvig": "todas",
  "vfdsd": "2024-01-01",
  "vfhst": "2024-01-31"
}

---

## Caso de Uso 3: Consulta de Estacionamientos Exclusivos con Vigencia Pagada

**Descripción:** El usuario consulta los requerimientos del módulo Estacionamientos Exclusivos (28), zona 3, folios 300-305, solo con vigencia '2' (Pagada).

**Precondiciones:**
Existen registros con vigencia '2' o 'P' en el rango de folios y módulo especificados.

**Pasos a seguir:**
- Acceder a la página de Listado de Requerimientos.
- Seleccionar Zona/Oficina: 3
- Seleccionar Módulo: Estacionamientos Exclusivos (28)
- Ingresar Folio Inicial: 300
- Ingresar Folio Final: 305
- Seleccionar Clave Practicado: Todas
- Seleccionar Vigencia: 2 (Pagada)
- Hacer clic en 'Consultar'.

**Resultado esperado:**
Se muestran solo los registros con vigencia '2' o 'P' en el rango de folios y módulo indicados.

**Datos de prueba:**
{
  "vrec": 3,
  "vmod": 28,
  "vfol1": 300,
  "vfol2": 305,
  "vcve": "todas",
  "vvig": "2",
  "vfdsd": null,
  "vfhst": null
}

---

