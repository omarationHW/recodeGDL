# Casos de Uso - ImprimeOficio

**Categoría:** Form

## Caso de Uso 1: Búsqueda e impresión de oficio de convenio vigente

**Descripción:** El usuario busca un convenio vigente por letras, número, año y tipo, y genera el PDF del oficio.

**Precondiciones:**
El usuario está autenticado y tiene permisos para imprimir oficios.

**Pasos a seguir:**
1. El usuario accede a la página de ImprimeOficio.
2. Ingresa letras: 'ZC1', número: 123, año: 2024, tipo: 1.
3. Presiona 'Buscar'.
4. El sistema muestra los datos del convenio y habilita los botones de impresión.
5. El usuario presiona 'Imprimir Oficio'.
6. El sistema genera el PDF y lo muestra en pantalla.

**Resultado esperado:**
Se muestra el PDF del oficio con los datos correctos del convenio.

**Datos de prueba:**
{ "letras": "ZC1", "numero": 123, "axo": 2024, "tipo": 1 }

---

## Caso de Uso 2: Intento de impresión con convenio sin desglose de parcialidades

**Descripción:** El usuario intenta imprimir un oficio de un convenio que tiene parcialidades sin desglose de cuentas.

**Precondiciones:**
El usuario está autenticado. El convenio existe pero tiene parcialidades sin desglose.

**Pasos a seguir:**
1. El usuario accede a la página de ImprimeOficio.
2. Ingresa letras: 'ZO2', número: 456, año: 2023, tipo: 2.
3. Presiona 'Buscar'.
4. El sistema muestra un mensaje de error indicando que existen parcialidades sin desglose.

**Resultado esperado:**
El sistema no permite imprimir y muestra el mensaje de error correspondiente.

**Datos de prueba:**
{ "letras": "ZO2", "numero": 456, "axo": 2023, "tipo": 2 }

---

## Caso de Uso 3: Impresión de pagaré de convenio

**Descripción:** El usuario busca un convenio y genera el PDF del pagaré.

**Precondiciones:**
El usuario está autenticado y el convenio está vigente.

**Pasos a seguir:**
1. El usuario accede a la página de ImprimeOficio.
2. Ingresa letras: 'ZM4', número: 789, año: 2022, tipo: 3.
3. Presiona 'Buscar'.
4. El sistema muestra los datos del convenio.
5. El usuario presiona 'Imprimir Pagaré'.
6. El sistema genera el PDF y lo muestra en pantalla.

**Resultado esperado:**
Se muestra el PDF del pagaré con los datos correctos del convenio.

**Datos de prueba:**
{ "letras": "ZM4", "numero": 789, "axo": 2022, "tipo": 3 }

---

