# Casos de Uso - Pagos_Cons_ContAsc

**Categoría:** Form

## Caso de Uso 1: Consulta de pagos de un contrato específico

**Descripción:** El usuario desea consultar todos los pagos asociados a un contrato a partir de un número dado y un tipo de aseo.

**Precondiciones:**
El usuario tiene acceso al sistema y existen contratos y pagos en la base de datos.

**Pasos a seguir:**
1. El usuario accede a la página 'Pagos por Contrato Ascendente'.
2. Ingresa el número de contrato '1803'.
3. Selecciona el tipo de aseo '8 - O - Ordinario'.
4. Presiona 'Buscar'.
5. El sistema muestra los contratos encontrados.
6. El usuario presiona 'Ver Pagos' en el contrato deseado.
7. El sistema muestra la lista de pagos asociados.

**Resultado esperado:**
Se muestran los pagos del contrato 1803, tipo de aseo 8, con todos los campos relevantes.

**Datos de prueba:**
contrato: 1803, ctrol_aseo: 8

---

## Caso de Uso 2: Validación de contrato inexistente

**Descripción:** El usuario intenta buscar un contrato que no existe.

**Precondiciones:**
El usuario tiene acceso al sistema.

**Pasos a seguir:**
1. El usuario accede a la página.
2. Ingresa el número de contrato '999999'.
3. Selecciona cualquier tipo de aseo.
4. Presiona 'Buscar'.

**Resultado esperado:**
El sistema muestra un mensaje de error indicando que no se encontraron contratos.

**Datos de prueba:**
contrato: 999999, ctrol_aseo: 8

---

## Caso de Uso 3: Consulta de pagos sin pagos registrados

**Descripción:** El usuario busca un contrato válido pero que no tiene pagos con status 'P'.

**Precondiciones:**
El contrato existe pero no tiene pagos con status 'P'.

**Pasos a seguir:**
1. El usuario accede a la página.
2. Ingresa el número de contrato correspondiente.
3. Selecciona el tipo de aseo.
4. Presiona 'Buscar'.
5. El usuario presiona 'Ver Pagos'.

**Resultado esperado:**
El sistema muestra un mensaje indicando que no se encontraron pagos.

**Datos de prueba:**
contrato: 1804, ctrol_aseo: 8 (suponiendo que no tiene pagos 'P')

---

