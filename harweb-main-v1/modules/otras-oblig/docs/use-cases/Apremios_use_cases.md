# Casos de Uso - Apremios

**Categoría:** Form

## Caso de Uso 1: Consulta de Apremios Existente

**Descripción:** El usuario accede a la página de Apremios y consulta los datos de un apremio existente junto con sus periodos requeridos.

**Precondiciones:**
Existe al menos un registro de apremio con modulo=1 y control_otr=1 en la base de datos.

**Pasos a seguir:**
1. El usuario navega a la página /apremios.
2. El sistema envía eRequest 'get_apremios' con par_modulo=1 y par_control=1.
3. El backend retorna los datos del apremio y el frontend los muestra en el formulario.
4. El sistema envía eRequest 'get_periodos_by_control' con id_control del apremio.
5. El frontend muestra los periodos requeridos en la tabla.

**Resultado esperado:**
El formulario se llena con los datos del apremio y la tabla muestra los periodos requeridos.

**Datos de prueba:**
{ "par_modulo": 1, "par_control": 1 }

---

## Caso de Uso 2: Creación de Nuevo Apremio

**Descripción:** El usuario llena el formulario de apremio y guarda un nuevo registro.

**Precondiciones:**
No existe apremio con modulo=2 y control_otr=5.

**Pasos a seguir:**
1. El usuario navega a la página /apremios.
2. El usuario llena todos los campos requeridos del formulario.
3. El usuario presiona 'Guardar'.
4. El frontend envía eRequest 'create_apremio' con los datos del formulario.
5. El backend crea el registro y retorna el nuevo apremio.

**Resultado esperado:**
El nuevo apremio se guarda y el formulario se actualiza con los datos guardados.

**Datos de prueba:**
{ "zona": 2, "folio": 1005, "diligencia": "A", "importe_global": 5000.00, "importe_multa": 500.00, "importe_recargo": 100.00, "importe_gastos": 50.00, "zona_apremio": 2, "fecha_emision": "2024-06-01", "clave_practicado": "P", "fecha_practicado": "2024-06-02", "hora_practicado": "10:00:00", "fecha_entrega1": "2024-06-03", "fecha_entrega2": "2024-06-04", "fecha_citatorio": "2024-06-05", "hora": "11:00:00", "ejecutor": 1, "clave_secuestro": 1, "clave_remate": "R", "fecha_remate": "2024-06-10", "porcentaje_multa": 10, "observaciones": "Test", "modulo": 2, "control_otr": 5 }

---

## Caso de Uso 3: Actualización de Apremio Existente

**Descripción:** El usuario edita un apremio existente y guarda los cambios.

**Precondiciones:**
Existe un apremio con id_control=3.

**Pasos a seguir:**
1. El usuario navega a la página /apremios y selecciona el apremio con id_control=3.
2. El usuario modifica el campo 'importe_multa'.
3. El usuario presiona 'Guardar'.
4. El frontend envía eRequest 'update_apremio' con los datos modificados.
5. El backend actualiza el registro y retorna el apremio actualizado.

**Resultado esperado:**
El apremio se actualiza correctamente y el formulario muestra los nuevos datos.

**Datos de prueba:**
{ "id_control": 3, "importe_multa": 999.99, ...otros campos sin cambios... }

---

