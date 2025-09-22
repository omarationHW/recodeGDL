# Casos de Uso - CatastroDM

**Categoría:** Form

## Caso de Uso 1: Consulta de Derechos2 para Licencia

**Descripción:** El usuario desea consultar el valor de derechos2 para una licencia específica.

**Precondiciones:**
La licencia existe en la base de datos y tiene registros en detsal_lic.

**Pasos a seguir:**
1. El usuario ingresa el ID de la licencia en el formulario.
2. Selecciona la acción 'Consultar Derechos2'.
3. Presiona 'Ejecutar'.
4. El sistema envía la petición a /api/execute con action 'getDerechos2' y el parámetro id_licencia.

**Resultado esperado:**
El sistema retorna el valor de derechos2 correspondiente a la licencia.

**Datos de prueba:**
{ "id_licencia": 12345, "id_anuncio": 0 }

---

## Caso de Uso 2: Cálculo de Fecha de Resolución para Trámite Tipo B

**Descripción:** El usuario necesita saber la fecha de resolución considerando días no laborables para un trámite tipo B.

**Precondiciones:**
Existen registros de días no laborables en la tabla no_laboralesLic.

**Pasos a seguir:**
1. El usuario ingresa la fecha de trámite y selecciona tipo 'B'.
2. Selecciona la acción 'Calcular Fecha Resolución'.
3. Presiona 'Ejecutar'.
4. El sistema envía la petición a /api/execute con action 'calcFechaRes' y los parámetros correspondientes.

**Resultado esperado:**
El sistema retorna la fecha de resolución calculada correctamente.

**Datos de prueba:**
{ "fechaTram": "2024-06-01", "tipo": "B", "autoev": false }

---

## Caso de Uso 3: Autorización de Licencia para Trámite

**Descripción:** El usuario solicita la autorización de una licencia para un trámite específico.

**Precondiciones:**
El trámite existe y cumple con los requisitos para autorización.

**Pasos a seguir:**
1. El usuario ingresa el número de trámite.
2. Selecciona la acción 'Autorizar Licencia'.
3. Presiona 'Ejecutar'.
4. El sistema procesa la autorización y actualiza los registros necesarios.

**Resultado esperado:**
El sistema retorna 'OK' y la licencia queda autorizada.

**Datos de prueba:**
{ "noTramite": 98765 }

---

