# Casos de Uso - GNuevos

**Categoría:** Form

## Caso de Uso 1: Alta de Nuevo Local (GNuevos) - Caso Básico

**Descripción:** Un usuario administrativo da de alta un nuevo local en el sistema usando el formulario GNuevos.

**Precondiciones:**
El usuario está autenticado y tiene permisos de alta. El tipo de local y etiquetas están configurados.

**Pasos a seguir:**
1. El usuario accede a la página GNuevos.
2. Ingresa el número de local y letra (ej: 123-AB).
3. Llena los campos obligatorios: concesionario, ubicación, superficie, licencia, año y mes de inicio, recaudadora, sector, zona, tipo de local, nombre comercial, lugar, observaciones.
4. Presiona 'Aplicar'.
5. El sistema valida y envía los datos al endpoint /api/execute con action=GNuevos.create.
6. El backend ejecuta el stored procedure y responde.

**Resultado esperado:**
El registro se crea correctamente y se muestra un mensaje de éxito.

**Datos de prueba:**
{
  "par_tabla": 3,
  "par_control": "123-AB",
  "par_conces": "JUAN PEREZ",
  "par_ubica": "MERCADO CENTRAL",
  "par_sup": 10.5,
  "par_Axo_Ini": 2024,
  "par_Mes_Ini": 6,
  "par_ofna": 1,
  "par_sector": "A",
  "par_zona": 2,
  "par_lic": 123456,
  "par_Descrip": "INTERNO",
  "par_NomCom": "TIENDA JUAN",
  "par_Lugar": "LOCAL 5",
  "par_Obs": "NINGUNA",
  "par_usuario": "admin"
}

---

## Caso de Uso 2: Validación de Duplicidad de Control

**Descripción:** El usuario intenta dar de alta un local con un control ya existente.

**Precondiciones:**
Ya existe un registro en t34_datos con control='123-AB' y cve_tab=3.

**Pasos a seguir:**
1. El usuario accede a la página GNuevos.
2. Ingresa los mismos datos de control que un registro existente.
3. Presiona 'Aplicar'.
4. El sistema envía la petición al backend.

**Resultado esperado:**
El sistema muestra un mensaje de error: 'Ya existe un registro con ese control'.

**Datos de prueba:**
{
  "par_tabla": 3,
  "par_control": "123-AB",
  ... (resto igual al caso anterior)
}

---

## Caso de Uso 3: Validación de Campos Obligatorios Vacíos

**Descripción:** El usuario omite el campo concesionario y trata de guardar.

**Precondiciones:**
El usuario está en la página GNuevos.

**Pasos a seguir:**
1. El usuario deja el campo concesionario vacío.
2. Llena los demás campos.
3. Presiona 'Aplicar'.
4. El sistema valida en frontend y backend.

**Resultado esperado:**
El sistema muestra un mensaje de error: 'Falta el dato del CONCESIONARIO'.

**Datos de prueba:**
{
  "par_tabla": 3,
  "par_control": "124-AC",
  "par_conces": "",
  ... (resto de campos válidos)
}

---

