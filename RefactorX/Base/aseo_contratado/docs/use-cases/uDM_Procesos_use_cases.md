# Casos de Uso - uDM_Procesos

**Categoría:** Form

## Caso de Uso 1: Consulta de Tipos de Aseo

**Descripción:** El usuario accede a la página de Procesos de Aseo y visualiza la lista de tipos de aseo disponibles.

**Precondiciones:**
El usuario tiene acceso al sistema y existen registros en la tabla ta_16_tipo_aseo.

**Pasos a seguir:**
1. El usuario navega a la página de Procesos de Aseo.
2. El frontend realiza una petición a /api/execute con operación 'get_tipo_aseo' y tipo=0.
3. El backend responde con la lista de tipos de aseo.

**Resultado esperado:**
Se muestra un combobox con todos los tipos de aseo disponibles (excepto ctrol_aseo=0).

**Datos de prueba:**
ta_16_tipo_aseo: [{ctrol_aseo: 1, descripcion: 'Doméstico'}, {ctrol_aseo: 2, descripcion: 'Industrial'}]

---

## Caso de Uso 2: Visualización de Dashboard de Procesos

**Descripción:** El usuario selecciona un tipo de aseo y visualiza el resumen de contratos y pagos.

**Precondiciones:**
Existen contratos y pagos asociados al tipo de aseo seleccionado.

**Pasos a seguir:**
1. El usuario selecciona un tipo de aseo del combobox.
2. El frontend calcula las fechas corte según la lógica Delphi.
3. El frontend consulta el día límite del mes actual.
4. El frontend llama a /api/execute con operación 'procesos_dashboard' y los parámetros calculados.
5. El backend responde con el resumen de contratos y pagos.

**Resultado esperado:**
Se muestra el resumen de contratos (total, vigentes, cancelados) y una tabla con los pagos por operación y status.

**Datos de prueba:**
ta_16_contratos y ta_16_pagos con datos para ctrol_aseo=1, pagos con ctrol_operacion=6,7,8 y status_vigencia='V','C','P','S'.

---

## Caso de Uso 3: Consulta de Contratos por Status

**Descripción:** El usuario (o proceso) consulta cuántos contratos existen para un tipo de aseo y status específico.

**Precondiciones:**
Existen contratos con diferentes status_vigencia.

**Pasos a seguir:**
1. El frontend o backend llama a /api/execute con operación 'get_contratos_count', ctrol=1, status='V'.
2. El backend ejecuta el SP correspondiente y responde con el conteo.

**Resultado esperado:**
Se recibe el número de contratos vigentes para el tipo de aseo seleccionado.

**Datos de prueba:**
ta_16_contratos: varios registros con ctrol_aseo=1 y status_vigencia='V'.

---

