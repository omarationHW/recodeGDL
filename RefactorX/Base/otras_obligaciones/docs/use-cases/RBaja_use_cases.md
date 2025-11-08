# Casos de Uso - RBaja

**Categoría:** Form

## Caso de Uso 1: Baja exitosa de un local sin adeudos

**Descripción:** El usuario da de baja un local que no tiene adeudos vigentes ni posteriores.

**Precondiciones:**
El local existe y no tiene adeudos en el periodo seleccionado ni posteriores.

**Pasos a seguir:**
1. El usuario ingresa el número y letra del local.
2. Presiona 'Buscar'.
3. El sistema muestra los datos del local.
4. El usuario ingresa el año y mes de baja.
5. Presiona 'Aplicar Baja'.
6. El sistema verifica que no existan adeudos pasados ni posteriores.
7. El sistema ejecuta la baja y muestra mensaje de éxito.

**Resultado esperado:**
El local es dado de baja correctamente y se muestra mensaje de éxito.

**Datos de prueba:**
{ "numero": "123", "letra": "A", "aso": "2024", "mes": "06" }

---

## Caso de Uso 2: Intento de baja con adeudos vigentes

**Descripción:** El usuario intenta dar de baja un local que tiene adeudos vigentes.

**Precondiciones:**
El local existe y tiene adeudos en el periodo seleccionado o posteriores.

**Pasos a seguir:**
1. El usuario ingresa el número y letra del local.
2. Presiona 'Buscar'.
3. El sistema muestra los datos del local.
4. El usuario ingresa el año y mes de baja.
5. Presiona 'Aplicar Baja'.
6. El sistema detecta adeudos y muestra mensaje de error.

**Resultado esperado:**
El sistema no permite la baja y muestra mensaje de error indicando que existen adeudos.

**Datos de prueba:**
{ "numero": "456", "letra": "B", "aso": "2024", "mes": "06" }

---

## Caso de Uso 3: Intento de baja de local inexistente

**Descripción:** El usuario intenta dar de baja un local que no existe.

**Precondiciones:**
El local no existe en la base de datos.

**Pasos a seguir:**
1. El usuario ingresa un número y letra de local inexistente.
2. Presiona 'Buscar'.
3. El sistema muestra mensaje de error indicando que no existe el local.

**Resultado esperado:**
El sistema no permite continuar y muestra mensaje de error.

**Datos de prueba:**
{ "numero": "999", "letra": "Z" }

---

