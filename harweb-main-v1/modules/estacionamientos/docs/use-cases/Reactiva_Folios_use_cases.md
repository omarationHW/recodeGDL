# Casos de Uso - Reactiva_Folios

**Categoría:** Form

## Caso de Uso 1: Reactivar folio por Placa y Folio (caso exitoso)

**Descripción:** El usuario desea reactivar un folio existente proporcionando la placa y el folio.

**Precondiciones:**
Existe un registro en ta14_folios_histo con placa 'ABC1234' y folio 1001.

**Pasos a seguir:**
1. El usuario selecciona 'Por Placa y Folio'.
2. Ingresa 'ABC1234' en Placa y '1001' en Folio.
3. Presiona 'APLICA'.
4. El sistema busca el folio y lo encuentra.
5. El sistema ejecuta la reactivación, migrando el registro y eliminando los históricos.

**Resultado esperado:**
Mensaje de éxito: 'Se GRABÓ el Adeudo y se ELIMINÓ el Histórico'. El registro ya no existe en ta14_folios_histo ni ta14_condonado, y aparece en ta14_folios_adeudo.

**Datos de prueba:**
{ "opcion": 0, "placa": "ABC1234", "folio": 1001 }

---

## Caso de Uso 2: Intentar reactivar folio inexistente por Año y Folio

**Descripción:** El usuario intenta reactivar un folio que no existe usando año y folio.

**Precondiciones:**
No existe ningún registro en ta14_folios_histo con axo=2022 y folio=9999.

**Pasos a seguir:**
1. El usuario selecciona 'Por Año y Folio'.
2. Ingresa '2022' en Año y '9999' en Folio.
3. Presiona 'APLICA'.
4. El sistema busca el folio y no lo encuentra.

**Resultado esperado:**
Mensaje de error: 'No existe registro como adeudo'. No se realiza ninguna modificación en la base de datos.

**Datos de prueba:**
{ "opcion": 1, "axo": 2022, "folio": 9999 }

---

## Caso de Uso 3: Error de base de datos al reactivar folio

**Descripción:** Se simula un error de base de datos (por ejemplo, violación de llave única en ta14_folios_adeudo).

**Precondiciones:**
El folio a reactivar ya existe en ta14_folios_adeudo.

**Pasos a seguir:**
1. El usuario selecciona el tipo de búsqueda y proporciona los datos de un folio que ya existe en ta14_folios_adeudo.
2. Presiona 'APLICA'.
3. El sistema intenta insertar el registro y ocurre un error de base de datos.

**Resultado esperado:**
Mensaje de error: 'Error al grabar EN ADEUDO y borrar HISTÓRICO: ...'. No se elimina el registro de ta14_folios_histo ni ta14_condonado.

**Datos de prueba:**
{ "opcion": 0, "placa": "XYZ9999", "folio": 2002 }

---

