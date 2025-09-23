# Casos de Uso - RptListaxRegPub

**Categoría:** Form

## Caso de Uso 1: Consulta general de registros vigentes

**Descripción:** El usuario desea obtener el listado completo de registros de mercados con requerimientos cuya vigencia es 'Vigente'.

**Precondiciones:**
El usuario está autenticado y tiene acceso al reporte.

**Pasos a seguir:**
1. El usuario accede a la página de Listado de Registros Públicos.
2. Selecciona 'Vigente' en el filtro de Vigencia y deja los demás filtros en 'todas'.
3. Presiona el botón 'Buscar'.
4. El sistema muestra la tabla con los registros vigentes.

**Resultado esperado:**
Se muestra la lista de registros con vigencia '1' (Vigente), con totales y sumatorias correctas.

**Datos de prueba:**
{ "vigencia": "1", "clave_practicado": "todas", "numesta": "todas", "usuario_id_rec": 1 }

---

## Caso de Uso 2: Filtrado por clave_practicado específica

**Descripción:** El usuario desea ver únicamente los registros con una clave_practicado específica.

**Precondiciones:**
El usuario está autenticado.

**Pasos a seguir:**
1. Accede a la página del reporte.
2. Selecciona 'todas' en Vigencia y escribe 'ABC123' en Clave Practicado.
3. Presiona 'Buscar'.
4. El sistema filtra y muestra solo los registros con clave_practicado = 'ABC123'.

**Resultado esperado:**
Solo se muestran registros con clave_practicado igual a 'ABC123'.

**Datos de prueba:**
{ "vigencia": "todas", "clave_practicado": "ABC123", "numesta": "todas", "usuario_id_rec": 1 }

---

## Caso de Uso 3: Consulta por número de estacionamiento y vigencia pagada

**Descripción:** El usuario quiere ver los registros de un estacionamiento específico con vigencia 'Pagado'.

**Precondiciones:**
El usuario está autenticado.

**Pasos a seguir:**
1. Accede a la página del reporte.
2. Selecciona '2' (Pagado) en Vigencia y escribe '57' en No. Estacionamiento.
3. Presiona 'Buscar'.
4. El sistema muestra los registros correspondientes.

**Resultado esperado:**
Se muestran solo los registros del estacionamiento 57 con vigencia '2' o 'P'.

**Datos de prueba:**
{ "vigencia": "2", "clave_practicado": "todas", "numesta": "57", "usuario_id_rec": 1 }

---

