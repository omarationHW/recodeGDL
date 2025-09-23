# Casos de Uso - RprtListaxRegEstacionometro

**Categoría:** Form

## Caso de Uso 1: Consulta de registros vigentes por colonia específica

**Descripción:** El usuario desea obtener todos los registros de estacionómetros con requerimientos vigentes en la colonia 'INSURGENTES'.

**Precondiciones:**
La colonia 'INSURGENTES' existe en la base de datos y hay registros con vigencia '1'.

**Pasos a seguir:**
1. El usuario accede a la página de Listado x Reg. Estacionómetro.
2. Selecciona 'Vigente' en el filtro de Vigencia.
3. Deja 'Clave Practicado' en 'todas'.
4. Escribe 'INSURGENTES' en el campo Colonia.
5. Deja Oficina vacío o en 2.
6. Presiona 'Buscar'.

**Resultado esperado:**
Se muestra una tabla con todos los registros vigentes de la colonia 'INSURGENTES', con totales y sumatorias correctas.

**Datos de prueba:**
{ "vigencia": "1", "clave_practicado": "todas", "colonia": "INSURGENTES", "oficina": 2 }

---

## Caso de Uso 2: Consulta filtrando por clave_practicado y vigencia pagada

**Descripción:** El usuario filtra los registros por una clave_practicado específica y vigencia '2' (pagado).

**Precondiciones:**
Existen registros con la clave_practicado 'ABC123' y vigencia '2' o 'P' en la colonia 'CENTRO'.

**Pasos a seguir:**
1. Accede a la página.
2. Selecciona 'Pagado' en Vigencia.
3. Escribe 'ABC123' en Clave Practicado.
4. Escribe 'CENTRO' en Colonia.
5. Presiona 'Buscar'.

**Resultado esperado:**
Se muestran solo los registros con clave_practicado 'ABC123' y vigencia '2' o 'P' en la colonia 'CENTRO'.

**Datos de prueba:**
{ "vigencia": "2", "clave_practicado": "ABC123", "colonia": "CENTRO", "oficina": 2 }

---

## Caso de Uso 3: Consulta por oficina específica

**Descripción:** El usuario desea ver los registros de una oficina (recaudadora) específica.

**Precondiciones:**
Existen registros en la colonia 'OBRERA' asociados a la oficina 3.

**Pasos a seguir:**
1. Accede a la página.
2. Selecciona 'Todas' en Vigencia.
3. Deja Clave Practicado en 'todas'.
4. Escribe 'OBRERA' en Colonia.
5. Escribe '3' en Oficina.
6. Presiona 'Buscar'.

**Resultado esperado:**
Se muestran los registros de la colonia 'OBRERA' asociados a la oficina 3.

**Datos de prueba:**
{ "vigencia": "todas", "clave_practicado": "todas", "colonia": "OBRERA", "oficina": 3 }

---

