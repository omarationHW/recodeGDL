# Casos de Uso - multas400frm

**Categoría:** Form

## Caso de Uso 1: Consulta de multa federal por acta

**Descripción:** El usuario desea consultar una multa federal específica usando dependencia, año y número de acta.

**Precondiciones:**
El registro existe en la tabla multas_fed_400.

**Pasos a seguir:**
1. Ingresar 'dependencia' (ej: 'DIRECCION1').
2. Ingresar 'año de acta' (ej: 2023).
3. Ingresar 'número de acta' (ej: 12345).
4. Seleccionar 'Multas Federales'.
5. Presionar 'Por Acta'.

**Resultado esperado:**
Se muestra el registro correspondiente en la tabla de resultados.

**Datos de prueba:**
{ "dependencia": "DIRECCION1", "anioActa": 2023, "numActa": 12345 }

---

## Caso de Uso 2: Búsqueda de multas municipales por nombre

**Descripción:** El usuario busca todas las multas municipales asociadas a un nombre.

**Precondiciones:**
Existen registros en multas_mpal_400 con el nombre buscado.

**Pasos a seguir:**
1. Seleccionar 'Multas Municipales'.
2. Ingresar 'nombre' (ej: 'JUAN PEREZ').
3. Presionar 'Por Nombre'.

**Resultado esperado:**
Se listan todas las multas municipales cuyo nombre coincida.

**Datos de prueba:**
{ "nombre": "JUAN PEREZ" }

---

## Caso de Uso 3: Búsqueda de multas federales por domicilio inexistente

**Descripción:** El usuario busca multas federales por un domicilio que no existe.

**Precondiciones:**
No existen registros con ese domicilio.

**Pasos a seguir:**
1. Seleccionar 'Multas Federales'.
2. Ingresar 'ubicación' (ej: 'CALLE FALSA 123').
3. Presionar 'Por Domicilio'.

**Resultado esperado:**
Se muestra mensaje de 'No se encontraron resultados'.

**Datos de prueba:**
{ "ubicacion": "CALLE FALSA 123" }

---

