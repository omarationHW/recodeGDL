# Casos de Uso - Cons_his

**Categoría:** Form

## Caso de Uso 1: Consulta de Folio de Apremios Existente

**Descripción:** El usuario accede a la página de consulta de folio de apremios e ingresa un número de control válido para visualizar toda la información relacionada.

**Precondiciones:**
El folio de apremios con el control especificado existe en la base de datos.

**Pasos a seguir:**
1. El usuario navega a /cons-his/123
2. El sistema realiza una petición a /api/execute con eRequest 'getConsHis' y control=123
3. El sistema obtiene la información principal y la muestra.
4. El sistema realiza una petición a /api/execute con eRequest 'getConsHisDetails' y control_otr correspondiente.
5. El sistema muestra los detalles en tabla.
6. Si el módulo es 16 o 11, se consulta la referencia de aseo o mercado y se muestra.

**Resultado esperado:**
Se visualiza toda la información del folio, incluyendo datos generales, importes, fechas, observaciones y detalles de periodos.

**Datos de prueba:**
{ "control": 123 }

---

## Caso de Uso 2: Consulta de Folio de Apremios con Referencia de Mercado

**Descripción:** El usuario consulta un folio de apremios cuyo módulo es 11 (Mercado), y espera ver la referencia del local asociada.

**Precondiciones:**
Existe un folio con módulo=11 y control_otr apunta a un local válido.

**Pasos a seguir:**
1. El usuario navega a /cons-his/456
2. El sistema consulta la información principal (getConsHis).
3. El sistema consulta los detalles (getConsHisDetails).
4. El sistema detecta módulo=11 y consulta getMercadoReference.
5. Se muestra la referencia del mercado en la sección de datos generales.

**Resultado esperado:**
La referencia del mercado se muestra correctamente junto con el resto de la información.

**Datos de prueba:**
{ "control": 456 }

---

## Caso de Uso 3: Consulta de Folio de Apremios Inexistente

**Descripción:** El usuario intenta consultar un folio de apremios con un número de control que no existe.

**Precondiciones:**
No existe ningún registro con el control especificado.

**Pasos a seguir:**
1. El usuario navega a /cons-his/99999
2. El sistema realiza la petición getConsHis.
3. El sistema no encuentra información y muestra un mensaje de error.

**Resultado esperado:**
Se muestra un mensaje indicando que no se encontró información para el control especificado.

**Datos de prueba:**
{ "control": 99999 }

---

