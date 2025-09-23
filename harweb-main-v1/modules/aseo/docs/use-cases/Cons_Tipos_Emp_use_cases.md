# Casos de Uso - Cons_Tipos_Emp

**Categoría:** Form

## Caso de Uso 1: Consulta de Tipos de Empresa ordenados por Descripción

**Descripción:** El usuario desea ver todos los tipos de empresa ordenados alfabéticamente por descripción.

**Precondiciones:**
El usuario está autenticado y tiene permisos de consulta.

**Pasos a seguir:**
1. El usuario accede a la página de Consulta de Tipos de Empresa.
2. Selecciona 'Descripción' en el selector de orden.
3. El sistema envía una petición a /api/execute con action='list' y order='descripcion'.
4. El backend retorna la lista ordenada.

**Resultado esperado:**
La tabla muestra todos los tipos de empresa ordenados por descripción.

**Datos de prueba:**
Tipos existentes: [ctrol_emp:1, tipo_empresa:'P', descripcion:'Privada'], [ctrol_emp:2, tipo_empresa:'G', descripcion:'Gobierno']

---

## Caso de Uso 2: Alta de un nuevo Tipo de Empresa

**Descripción:** El usuario desea agregar un nuevo tipo de empresa llamado 'Mixto'.

**Precondiciones:**
El usuario está autenticado y tiene permisos de alta.

**Pasos a seguir:**
1. El usuario hace clic en 'Nuevo Tipo'.
2. Ingresa tipo_empresa='M', descripcion='Mixto'.
3. Hace clic en 'Crear'.
4. El sistema envía una petición a /api/execute con action='create'.
5. El backend ejecuta el SP y retorna el nuevo registro.

**Resultado esperado:**
El nuevo tipo de empresa aparece en la tabla.

**Datos de prueba:**
tipo_empresa: 'M', descripcion: 'Mixto'

---

## Caso de Uso 3: Intento de eliminación de Tipo de Empresa con empresas asociadas

**Descripción:** El usuario intenta eliminar un tipo de empresa que tiene empresas asociadas.

**Precondiciones:**
Existe al menos una empresa con ctrol_emp=1.

**Pasos a seguir:**
1. El usuario hace clic en eliminar sobre el tipo de empresa con ctrol_emp=1.
2. El sistema envía una petición a /api/execute con action='delete' y ctrol_emp=1.
3. El backend ejecuta el SP, detecta empresas asociadas y retorna error.

**Resultado esperado:**
El sistema muestra un mensaje de error: 'No se puede eliminar: existen empresas asociadas.'

**Datos de prueba:**
ctrol_emp: 1 (con empresas asociadas)

---

