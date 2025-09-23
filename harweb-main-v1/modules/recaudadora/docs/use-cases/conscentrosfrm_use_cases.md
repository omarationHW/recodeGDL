# Casos de Uso - conscentrosfrm

**Categoría:** Form

## Caso de Uso 1: Consulta general de multas cobradas en centros de recaudación

**Descripción:** El usuario accede a la página y visualiza el listado completo de multas cobradas en centros de recaudación, sin aplicar ningún filtro.

**Precondiciones:**
El usuario tiene acceso al sistema y existen registros en la vista centros_recaudacion_view.

**Pasos a seguir:**
1. El usuario ingresa a la página de 'Multas cobradas en centros de Recaudación'.
2. No selecciona ningún filtro y presiona 'Buscar'.
3. El sistema envía una petición POST a /api/execute con action 'get_centros_list'.
4. El backend ejecuta el stored procedure correspondiente y retorna los datos.

**Resultado esperado:**
Se muestra la tabla con todas las multas cobradas, ordenadas por fecha y número de recibo descendente.

**Datos de prueba:**
Registros de ejemplo en centros_recaudacion_view con diferentes fechas, dependencias y actas.

---

## Caso de Uso 2: Filtrar por fecha específica

**Descripción:** El usuario desea ver sólo las multas cobradas en una fecha determinada.

**Precondiciones:**
El usuario tiene acceso y existen registros para la fecha seleccionada.

**Pasos a seguir:**
1. El usuario selecciona una fecha en el filtro.
2. Presiona 'Buscar'.
3. El sistema envía una petición POST a /api/execute con action 'get_centros_by_fecha' y el parámetro fecha.
4. El backend retorna sólo los registros de esa fecha.

**Resultado esperado:**
Se muestran únicamente las multas cobradas en la fecha seleccionada.

**Datos de prueba:**
Registros con fecha '2024-06-01' y otras fechas.

---

## Caso de Uso 3: Filtrar por dependencia y acta

**Descripción:** El usuario busca multas de una dependencia y acta específica.

**Precondiciones:**
El usuario conoce el id de la dependencia y el número/año de acta.

**Pasos a seguir:**
1. El usuario selecciona la dependencia y llena año y número de acta.
2. Presiona 'Buscar'.
3. El sistema envía una petición POST a /api/execute con action 'get_centros_by_acta' y los parámetros axo_acta y num_acta.
4. El backend retorna los registros coincidentes.

**Resultado esperado:**
Se muestran sólo las multas de la dependencia y acta especificada.

**Datos de prueba:**
Registros con id_dependencia=2, axo_acta=2024, num_acta=12345.

---

