# Casos de Uso - FirmaElectronica

**Categoría:** Form

## Caso de Uso 1: Caso de Uso 1: Listar Folios a Firmar

**Descripción:** El usuario desea ver los folios pendientes de firma electrónica para un módulo y fecha determinada.

**Precondiciones:**
El usuario está autenticado y tiene permisos de firma.

**Pasos a seguir:**
1. El usuario accede a la página de Firma Electrónica.
2. Selecciona el módulo (ej: Estacionómetros) y la fecha de asignación.
3. Hace clic en 'PASO 1: Seleccionar folios a firmar'.
4. El sistema muestra la lista de folios disponibles.

**Resultado esperado:**
Se muestra una tabla con los folios pendientes de firma para el módulo y fecha seleccionados.

**Datos de prueba:**
{ "modulo": 14, "fecha": "2024-06-01" }

---

## Caso de Uso 2: Caso de Uso 2: Generar Firma Electrónica para Folios Seleccionados

**Descripción:** El usuario selecciona varios folios y ejecuta el proceso de firma electrónica.

**Precondiciones:**
Existen folios listados y el usuario tiene permisos.

**Pasos a seguir:**
1. El usuario selecciona varios folios de la lista.
2. Hace clic en 'PASO 2: Enviar datos a firma'.
3. Indica la fecha de proceso de firma.
4. Hace clic en 'PASO 3: Generar firma electrónica'.
5. El sistema procesa cada folio y muestra estadísticas.

**Resultado esperado:**
Los folios seleccionados quedan firmados electrónicamente y se actualizan las estadísticas.

**Datos de prueba:**
{ "modulo": 14, "fecha": "2024-06-01", "folios": [ { "folio": 123, "cvereq": 456, "diligencia": 1, "cadena1": "abc", "cadena2": "def" } ], "fecha_firma": "2024-06-02" }

---

## Caso de Uso 3: Caso de Uso 3: Insertar Firma Electrónica Manualmente

**Descripción:** Un proceso externo genera la firma y se requiere insertar el registro en la base de datos.

**Precondiciones:**
El proceso externo ha generado la firma y se cuenta con los datos necesarios.

**Pasos a seguir:**
1. El sistema externo llama a la API con los datos de la firma.
2. El backend ejecuta el SP de inserción.
3. Se retorna el resultado de la operación.

**Resultado esperado:**
La firma queda registrada en la base de datos y se retorna confirmación.

**Datos de prueba:**
{ "secuencia": 789, "digverificador": "XYZ12", "id_modulo": 456, "fecha_graba": "2024-06-02", "vigencia": "V", "firmante": "Juan Pérez", "cargo": "Director", "validez": "2024-06-02 2025-06-02", "fecha_firmado": "2024-06-02", "hash": "abcdef123456" }

---

