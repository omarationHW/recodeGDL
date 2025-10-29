# Casos de Uso - RptEmisionLocales

**Categoría:** Form

## Caso de Uso 1: Previsualizar emisión de recibos de locales

**Descripción:** El usuario desea ver la previsualización de los recibos a emitir para un mercado específico antes de grabar la emisión.

**Precondiciones:**
El usuario está autenticado y tiene permisos para emitir recibos.

**Pasos a seguir:**
1. El usuario accede a la página de Emisión de Recibos de Locales.
2. Selecciona la oficina, año, mes y mercado.
3. Presiona el botón 'Previsualizar'.
4. El sistema muestra la tabla con los locales, rentas, adeudos, recargos y meses adeudados.

**Resultado esperado:**
Se muestra una tabla con los datos de emisión calculados correctamente, sin grabar nada en la base de datos.

**Datos de prueba:**
{ oficina: 2, axo: 2024, periodo: 6, mercado: 5 }

---

## Caso de Uso 2: Emitir (grabar) la emisión de recibos de locales

**Descripción:** El usuario confirma la emisión y graba los adeudos correspondientes para el periodo/mercado/oficina/año seleccionados.

**Precondiciones:**
El usuario está autenticado y ha previsualizado la emisión.

**Pasos a seguir:**
1. El usuario revisa la previsualización.
2. Presiona el botón 'Emitir Recibos'.
3. El sistema ejecuta el proceso de grabado.
4. Se graban los adeudos para cada local que no tenga ya adeudo en ese periodo.

**Resultado esperado:**
Se graban los adeudos correctamente. Si algún local ya tenía adeudo, no se duplica.

**Datos de prueba:**
{ oficina: 2, axo: 2024, periodo: 6, mercado: 5, usuario_id: 10 }

---

## Caso de Uso 3: Consultar mercados disponibles para una oficina

**Descripción:** El usuario necesita seleccionar el mercado correcto para emitir recibos.

**Precondiciones:**
El usuario está autenticado.

**Pasos a seguir:**
1. El usuario selecciona una oficina.
2. El sistema consulta los mercados disponibles para esa oficina.
3. El usuario selecciona el mercado deseado.

**Resultado esperado:**
Se muestra la lista de mercados con tipo_emision = 'M' para la oficina seleccionada.

**Datos de prueba:**
{ oficina: 2 }

---

