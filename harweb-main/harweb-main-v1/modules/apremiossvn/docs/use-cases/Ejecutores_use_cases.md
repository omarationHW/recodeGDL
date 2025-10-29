# Casos de Uso - Ejecutores

**Categoría:** Form

## Caso de Uso 1: Consulta general de ejecutores activos

**Descripción:** El usuario accede a la página de ejecutores y visualiza la lista completa de ejecutores activos.

**Precondiciones:**
El usuario tiene acceso a la aplicación y existen ejecutores activos en la base de datos.

**Pasos a seguir:**
1. El usuario navega a la página 'Consulta del Ejecutor'.
2. No ingresa ningún filtro.
3. El sistema muestra la lista completa de ejecutores activos.

**Resultado esperado:**
Se muestra una tabla con todos los ejecutores activos ordenados por clave.

**Datos de prueba:**
Ejecutores en la tabla ta_15_ejecutores con oficio <> '' y vigencia = 'A'.

---

## Caso de Uso 2: Búsqueda de ejecutor por nombre parcial

**Descripción:** El usuario filtra ejecutores escribiendo parte del nombre en el campo correspondiente.

**Precondiciones:**
El usuario tiene acceso y existen ejecutores cuyos nombres contienen la cadena buscada.

**Pasos a seguir:**
1. El usuario ingresa 'JUAN' en el campo Nombre.
2. El sistema realiza la búsqueda parcial por nombre.
3. Se muestran solo los ejecutores cuyo nombre contiene 'JUAN' (insensible a mayúsculas/minúsculas y acentos).

**Resultado esperado:**
La tabla muestra únicamente los ejecutores cuyo nombre contiene la cadena ingresada.

**Datos de prueba:**
Ejecutores con nombres como 'JUAN PEREZ', 'JUANITA LOPEZ', 'LUIS JUAN'.

---

## Caso de Uso 3: Búsqueda de ejecutor por clave parcial

**Descripción:** El usuario filtra ejecutores escribiendo los primeros dígitos de la clave en el campo correspondiente.

**Precondiciones:**
El usuario tiene acceso y existen ejecutores con claves que inician con los dígitos ingresados.

**Pasos a seguir:**
1. El usuario ingresa '12' en el campo Cve Ejecutor.
2. El sistema realiza la búsqueda parcial por clave.
3. Se muestran solo los ejecutores cuya clave inicia con '12'.

**Resultado esperado:**
La tabla muestra únicamente los ejecutores cuya clave inicia con los dígitos ingresados.

**Datos de prueba:**
Ejecutores con cve_eje: 12001, 12345, 12999.

---

