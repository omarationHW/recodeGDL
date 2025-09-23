# Casos de Uso - comprofrm

**Categoría:** Form

## Caso de Uso 1: Consulta de comprobantes por periodo sin filtros adicionales

**Descripción:** El usuario desea obtener todos los comprobantes capturados entre dos fechas, sin filtrar por movimiento, capturista ni departamento.

**Precondiciones:**
El usuario tiene acceso a la página de comprobantes y existen registros en la base de datos.

**Pasos a seguir:**
1. Ingresar fecha desde y fecha hasta.
2. No seleccionar ningún filtro adicional.
3. Hacer clic en 'Consultar'.

**Resultado esperado:**
Se muestra una tabla con todos los comprobantes capturados en el periodo seleccionado.

**Datos de prueba:**
{ "fecha_desde": "2024-01-01", "fecha_hasta": "2024-01-31" }

---

## Caso de Uso 2: Consulta de totales por día filtrando por movimiento y capturista

**Descripción:** El usuario desea ver el total de comprobantes capturados por día, filtrando por un movimiento específico y un capturista.

**Precondiciones:**
Existen movimientos y capturistas registrados.

**Pasos a seguir:**
1. Ingresar fecha desde y hasta.
2. Activar 'Filtrar movimiento' y seleccionar un movimiento.
3. Ingresar el nombre del capturista.
4. Activar 'Totales x día'.
5. Hacer clic en 'Consultar'.

**Resultado esperado:**
Se muestra una tabla con el total de comprobantes por día, solo para el movimiento y capturista seleccionados.

**Datos de prueba:**
{ "fecha_desde": "2024-02-01", "fecha_hasta": "2024-02-28", "filtrar_movimiento": true, "cvemov": 2, "capturista": "juanperez", "totales_dia": true }

---

## Caso de Uso 3: Consulta de comprobantes por departamento

**Descripción:** El usuario desea ver todos los comprobantes capturados por los usuarios de un departamento específico.

**Precondiciones:**
Existen departamentos y usuarios asociados.

**Pasos a seguir:**
1. Ingresar fecha desde y hasta.
2. Activar 'Filtrar departamento' y seleccionar un departamento.
3. Hacer clic en 'Consultar'.

**Resultado esperado:**
Se muestra una tabla con los comprobantes capturados por usuarios del departamento seleccionado.

**Datos de prueba:**
{ "fecha_desde": "2024-03-01", "fecha_hasta": "2024-03-31", "filtrar_departamento": true, "cvedepto": 5 }

---

