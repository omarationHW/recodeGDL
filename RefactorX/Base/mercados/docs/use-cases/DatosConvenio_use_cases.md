# Casos de Uso - DatosConvenio

**Categoría:** Form

## Caso de Uso 1: Consulta de Convenio Existente

**Descripción:** El usuario consulta el detalle de un convenio existente desde la página de convenios.

**Precondiciones:**
El usuario está autenticado y tiene permisos de consulta. Existe un convenio con id_conv=123.

**Pasos a seguir:**
1. El usuario navega a /convenios/123
2. El frontend solicita /api/execute con action=getConvenioById y id_conv=123
3. El backend retorna los datos generales del convenio
4. El frontend solicita /api/execute con action=getConvenioParciales y id_conv=123
5. El backend retorna la lista de parcialidades
6. El usuario visualiza toda la información en la página

**Resultado esperado:**
Se muestran todos los datos del convenio y la tabla de parcialidades correctamente.

**Datos de prueba:**
{ "id_conv": 123 }

---

## Caso de Uso 2: Consulta de Convenio Inexistente

**Descripción:** El usuario intenta consultar un convenio que no existe.

**Precondiciones:**
El usuario está autenticado. No existe un convenio con id_conv=9999.

**Pasos a seguir:**
1. El usuario navega a /convenios/9999
2. El frontend solicita /api/execute con action=getConvenioById y id_conv=9999
3. El backend retorna null o error
4. El frontend muestra mensaje de error

**Resultado esperado:**
Se muestra un mensaje de 'Convenio no encontrado' o similar.

**Datos de prueba:**
{ "id_conv": 9999 }

---

## Caso de Uso 3: Visualización de Estado y Periodos Calculados

**Descripción:** El usuario verifica que los campos calculados (estado, tipodesc, periodos, peradeudos, convenio) se muestran correctamente según los datos.

**Precondiciones:**
El usuario está autenticado. El convenio tiene diferentes valores de vigencia y tipo_pago.

**Pasos a seguir:**
1. El usuario navega a /convenios/124
2. El frontend solicita /api/execute con action=getConvenioById y id_conv=124
3. El backend retorna los datos con campos calculados
4. El usuario verifica los valores en la interfaz

**Resultado esperado:**
Los campos calculados muestran los valores correctos según la lógica de negocio.

**Datos de prueba:**
{ "id_conv": 124 }

---

