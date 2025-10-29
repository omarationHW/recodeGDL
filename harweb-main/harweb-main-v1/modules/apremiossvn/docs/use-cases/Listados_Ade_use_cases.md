# Casos de Uso - Listados_Ade

**Categoría:** Form

## Caso de Uso 1: Consulta de Adeudos de Mercados por Rango

**Descripción:** El usuario desea obtener el listado de adeudos de mercados para la oficina 1, mercados del 1 al 5, locales del 1 al 50, sección 'A', año 2024, mes 6.

**Precondiciones:**
El usuario está autenticado y tiene permisos de consulta.

**Pasos a seguir:**
1. Acceder a la página Listados de Adeudos.
2. Seleccionar 'Mercados' como aplicación.
3. Ingresar oficina=1, num_mercado1=1, num_mercado2=5, local1=1, local2=50, seccion='A', axo=2024, mes=6.
4. Hacer clic en 'Consultar'.

**Resultado esperado:**
Se muestra una tabla con los adeudos de mercados filtrados según los parámetros.

**Datos de prueba:**
{ "oficina": 1, "num_mercado1": 1, "num_mercado2": 5, "local1": 1, "local2": 50, "seccion": "A", "axo": 2024, "mes": 6 }

---

## Caso de Uso 2: Consulta de Adeudos de Aseo por Tipo y Contrato

**Descripción:** El usuario desea consultar los adeudos de aseo para el tipo 'B', contratos del 100 al 200, recaudadora 2, año 2023, mes 12.

**Precondiciones:**
El usuario está autenticado y tiene permisos de consulta.

**Pasos a seguir:**
1. Acceder a la página Listados de Adeudos.
2. Seleccionar 'Aseo' como aplicación.
3. Ingresar tipo_aseo='B', contrato1=100, contrato2=200, id_rec=2, axo=2023, mes=12.
4. Hacer clic en 'Consultar'.

**Resultado esperado:**
Se muestra una tabla con los adeudos de aseo filtrados.

**Datos de prueba:**
{ "tipo_aseo": "B", "contrato1": 100, "contrato2": 200, "id_rec": 2, "axo": 2023, "mes": 12 }

---

## Caso de Uso 3: Consulta de Infracciones por Propietario y Rango de Adeudo

**Descripción:** El usuario busca infracciones de estacionómetros para el propietario 'JUAN PEREZ', años 2020 a 2024, adeudo entre 1000 y 5000.

**Precondiciones:**
El usuario está autenticado y tiene permisos de consulta.

**Pasos a seguir:**
1. Acceder a la página Listados de Adeudos.
2. Seleccionar 'Estacionómetros' como aplicación.
3. Ingresar propietario='JUAN PEREZ', axo1=2020, axo2=2024, impd=1000, imph=5000.
4. Hacer clic en 'Consultar'.

**Resultado esperado:**
Se muestra una tabla con las infracciones filtradas por propietario y rango de adeudo.

**Datos de prueba:**
{ "propietario": "JUAN PEREZ", "axo1": 2020, "axo2": 2024, "impd": 1000, "imph": 5000 }

---

