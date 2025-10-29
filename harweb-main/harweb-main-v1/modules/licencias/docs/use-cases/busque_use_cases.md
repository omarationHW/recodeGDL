# Casos de Uso - busque

**Categoría:** Form

## Caso de Uso 1: Búsqueda por Nombre de Propietario

**Descripción:** El usuario busca cuentas catastrales ingresando el nombre completo del propietario.

**Precondiciones:**
El usuario tiene acceso al sistema y conoce el nombre completo o parcial del propietario.

**Pasos a seguir:**
1. El usuario accede a la página de búsqueda por nombre.
2. Ingresa 'JUAN PEREZ' en el campo de nombre.
3. Presiona el botón 'Buscar'.
4. El sistema envía un eRequest con action 'buscar_por_nombre' y params { nombre: 'JUAN PEREZ' }.
5. El backend ejecuta el SP correspondiente y retorna los resultados.

**Resultado esperado:**
Se muestra una tabla con todas las cuentas catastrales cuyo propietario coincide parcial o totalmente con 'JUAN PEREZ'.

**Datos de prueba:**
nombre: 'JUAN PEREZ'

---

## Caso de Uso 2: Búsqueda por Ubicación (Calle y Número)

**Descripción:** El usuario busca cuentas catastrales por dirección del predio.

**Precondiciones:**
El usuario conoce la calle y opcionalmente el número exterior.

**Pasos a seguir:**
1. El usuario accede a la página de búsqueda por ubicación.
2. Ingresa 'AV. JUAREZ' en el campo de calle y '123' en el campo de exterior.
3. Presiona 'Buscar'.
4. El sistema envía un eRequest con action 'buscar_por_ubicacion' y params { calle: 'AV. JUAREZ', exterior: '123' }.
5. El backend ejecuta el SP y retorna los resultados.

**Resultado esperado:**
Se muestran las cuentas catastrales que coinciden con la calle y número exterior indicados.

**Datos de prueba:**
calle: 'AV. JUAREZ', exterior: '123'

---

## Caso de Uso 3: Búsqueda por RFC

**Descripción:** El usuario busca cuentas catastrales por RFC del propietario.

**Precondiciones:**
El usuario conoce el RFC completo o parcial.

**Pasos a seguir:**
1. El usuario accede a la página de búsqueda por RFC.
2. Ingresa 'PEPJ800101' en el campo RFC.
3. Presiona 'Buscar'.
4. El sistema envía un eRequest con action 'buscar_por_rfc' y params { rfc: 'PEPJ800101' }.
5. El backend ejecuta el SP y retorna los resultados.

**Resultado esperado:**
Se muestran las cuentas catastrales cuyo propietario tiene el RFC indicado.

**Datos de prueba:**
rfc: 'PEPJ800101'

---

