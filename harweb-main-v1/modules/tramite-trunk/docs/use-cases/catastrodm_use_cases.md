# Casos de Uso - catastrodm

**Categoría:** Form

## Caso de Uso 1: Consulta de Cuenta Catastral y Propietarios

**Descripción:** El usuario ingresa los datos de recaudadora, tipo (urbano/rústico) y número de cuenta para consultar la información completa de la cuenta catastral, incluyendo propietarios y saldos.

**Precondiciones:**
El usuario está autenticado y tiene permisos de consulta.

**Pasos a seguir:**
1. El usuario accede a la página Catastro.
2. Ingresa recaudadora, tipo y cuenta.
3. Presiona 'Buscar'.
4. El sistema consulta la API con action 'getConvctaByCuenta'.
5. Si existe, consulta catastro, regprop y saldos.
6. Muestra la información en pantalla.

**Resultado esperado:**
Se muestra la información completa de la cuenta, propietarios y saldos.

**Datos de prueba:**
{ "recaud": 1, "urbrus": "U", "cuenta": 123456 }

---

## Caso de Uso 2: Exentar Saldos de una Cuenta

**Descripción:** El usuario con permisos selecciona una cuenta y marca como exento un bimestre/año, recalculando los saldos.

**Precondiciones:**
El usuario está autenticado y tiene permisos de exención.

**Pasos a seguir:**
1. El usuario consulta una cuenta.
2. Presiona 'Exentar'.
3. Selecciona bimestre y año.
4. Confirma la acción.
5. El frontend llama a la API con action 'callStoredProcedure', sp 'sp_exento_en_saldos', y los parámetros correspondientes.
6. El backend ejecuta el SP y recalcula los saldos.

**Resultado esperado:**
El saldo del bimestre/año seleccionado aparece como exento y los totales se actualizan.

**Datos de prueba:**
{ "sp": "sp_exento_en_saldos", "sp_params": { "p_cvecuenta": 123456, "p_bim": 2, "p_anio": 2024, "p_exento": "S" } }

---

## Caso de Uso 3: Modificar Propietario de Cuenta

**Descripción:** El usuario edita los datos de un propietario (nombre, porcentaje, exento, etc.) y guarda los cambios.

**Precondiciones:**
El usuario está autenticado y tiene permisos de edición.

**Pasos a seguir:**
1. El usuario consulta una cuenta.
2. Presiona 'Modificar Propietario'.
3. Edita los datos del propietario.
4. Presiona 'Guardar'.
5. El frontend llama a la API con action 'insertRegprop' o 'updateRegprop'.
6. El backend actualiza la base de datos.

**Resultado esperado:**
Los datos del propietario se actualizan y se reflejan en la consulta.

**Datos de prueba:**
{ "cvereg": 1, "cvecont": 1001, "cvecuenta": 123456, "cveregprop": 2, "encabeza": "S", "porcentaje": 100, "exento": "N", "vigencia": "V" }

---

