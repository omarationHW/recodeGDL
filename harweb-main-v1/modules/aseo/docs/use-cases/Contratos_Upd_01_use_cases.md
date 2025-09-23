# Casos de Uso - Contratos_Upd_01

**Categoría:** Form

## Caso de Uso 1: Cambio de Domicilio de un Contrato

**Descripción:** El usuario desea actualizar el domicilio de un contrato existente.

**Precondiciones:**
El contrato debe existir y estar vigente.

**Pasos a seguir:**
1. El usuario ingresa el número de contrato y selecciona el tipo de aseo.
2. Presiona 'Buscar'.
3. Selecciona la opción 'Domicilio'.
4. Ingresa los nuevos datos de domicilio (calle, número, colonia).
5. Ingresa el documento probatorio y descripción.
6. Presiona 'Ejecutar'.

**Resultado esperado:**
El domicilio del contrato se actualiza y se muestra un mensaje de éxito.

**Datos de prueba:**
{ "num_contrato": 1234, "ctrol_aseo": 9, "domicilio": "Av. Reforma 100 Int. 2 Col. Centro", "docto": "DR/14/2024", "descrip": "Cambio por mudanza" }

---

## Caso de Uso 2: Cambio de Empresa Asociada al Contrato

**Descripción:** El usuario desea cambiar la empresa ligada a un contrato.

**Precondiciones:**
El contrato debe existir y la nueva empresa debe estar registrada.

**Pasos a seguir:**
1. El usuario ingresa el número de contrato y tipo de aseo.
2. Presiona 'Buscar'.
3. Selecciona la opción 'Empresa'.
4. Busca la nueva empresa por nombre y la selecciona.
5. Ingresa el documento probatorio y descripción.
6. Presiona 'Ejecutar'.

**Resultado esperado:**
La empresa asociada al contrato se actualiza correctamente.

**Datos de prueba:**
{ "num_contrato": 5678, "ctrol_aseo": 8, "num_emp": 200, "ctrol_emp": 9, "docto": "DR/15/2024", "descrip": "Cambio por fusión empresarial" }

---

## Caso de Uso 3: Desligar una Licencia de Giro de un Contrato

**Descripción:** El usuario desea eliminar la relación entre una licencia de giro y un contrato.

**Precondiciones:**
La licencia debe estar relacionada al contrato.

**Pasos a seguir:**
1. El usuario busca el contrato y selecciona la opción 'Licencias de Giro'.
2. Visualiza las licencias relacionadas.
3. Selecciona la licencia y elige la acción 'Desligar/Eliminar'.
4. Presiona 'Aplica'.

**Resultado esperado:**
La licencia se elimina de la relación y se muestra un mensaje de éxito.

**Datos de prueba:**
{ "opc": "D", "licencia_giro": 12345, "control_contrato": 1001 }

---

