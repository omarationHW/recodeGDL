# Casos de Uso - RprtListaxFec

**Categoría:** Form

## Caso de Uso 1: Consulta de Requerimientos por Fecha de Actualización (Mercados)

**Descripción:** El usuario desea obtener un listado de requerimientos del módulo Mercados filtrando por fecha de actualización en una zona específica.

**Precondiciones:**
El usuario tiene acceso al sistema y existen registros en la base de datos para la zona y fechas indicadas.

**Pasos a seguir:**
1. Ingresar a la página 'Listado de Requerimientos por Fecha'.
2. Seleccionar 'Mercados' como módulo.
3. Seleccionar 'Fecha de Actualización' como tipo de fecha.
4. Ingresar la zona/recaudadora deseada (por ejemplo, 1).
5. Ingresar el rango de fechas (ejemplo: 2024-01-01 a 2024-01-31).
6. Seleccionar 'todas' en vigencia y 'todos' en ejecutor.
7. Presionar 'Buscar'.

**Resultado esperado:**
Se muestra una tabla con los requerimientos de Mercados para la zona y fechas seleccionadas, incluyendo todos los campos relevantes.

**Datos de prueba:**
{
  "vrec": 1,
  "vmod": 11,
  "vcve": 1,
  "vfec1": "2024-01-01",
  "vfec2": "2024-01-31",
  "vvig": "todas",
  "veje": "todos"
}

---

## Caso de Uso 2: Consulta de Requerimientos por Fecha de Pago (Aseo) y Vigencia Vencida

**Descripción:** El usuario requiere ver los requerimientos del módulo Aseo filtrando por fecha de pago y solo aquellos con vigencia vencida.

**Precondiciones:**
El usuario tiene acceso y existen registros de Aseo con pagos y vigencia vencida.

**Pasos a seguir:**
1. Ingresar a la página 'Listado de Requerimientos por Fecha'.
2. Seleccionar 'Aseo' como módulo.
3. Seleccionar 'Fecha de Pago' como tipo de fecha.
4. Ingresar la zona/recaudadora correspondiente.
5. Ingresar el rango de fechas de pago.
6. Seleccionar '2' en vigencia (vencida).
7. Presionar 'Buscar'.

**Resultado esperado:**
Se muestra una tabla con los requerimientos de Aseo pagados en el rango y con vigencia vencida.

**Datos de prueba:**
{
  "vrec": 2,
  "vmod": 16,
  "vcve": 4,
  "vfec1": "2024-02-01",
  "vfec2": "2024-02-28",
  "vvig": "2",
  "veje": "todos"
}

---

## Caso de Uso 3: Consulta de Requerimientos por Fecha de Citatorio (Estacionamientos Públicos) para un Ejecutor Específico

**Descripción:** El usuario desea obtener los requerimientos de Estacionamientos Públicos filtrando por fecha de citatorio y un ejecutor específico.

**Precondiciones:**
El usuario tiene acceso y existen registros de Estacionamientos Públicos con citatorios y ejecutor indicado.

**Pasos a seguir:**
1. Ingresar a la página 'Listado de Requerimientos por Fecha'.
2. Seleccionar 'Estacionamientos Públicos' como módulo.
3. Seleccionar 'Fecha de Citatorio' como tipo de fecha.
4. Ingresar la zona/recaudadora.
5. Ingresar el rango de fechas de citatorio.
6. Seleccionar 'todas' en vigencia.
7. Ingresar el ID del ejecutor (ejemplo: 5).
8. Presionar 'Buscar'.

**Resultado esperado:**
Se muestra una tabla con los requerimientos de Estacionamientos Públicos para el ejecutor y fechas seleccionadas.

**Datos de prueba:**
{
  "vrec": 3,
  "vmod": 24,
  "vcve": 3,
  "vfec1": "2024-03-01",
  "vfec2": "2024-03-31",
  "vvig": "todas",
  "veje": "5"
}

---

