# Documentación Técnica: Rep_Tipos_Emp

## Análisis

# Documentación Técnica: Reporte de Tipos de Empresas (Rep_Tipos_Emp)

## Descripción General
Este módulo permite consultar e imprimir el catálogo de Tipos de Empresas, ordenado por número de control, tipo o descripción. La migración Delphi → Laravel + Vue.js + PostgreSQL implementa:

- Un endpoint API único `/api/execute` (patrón eRequest/eResponse)
- Un controlador Laravel que despacha la acción `getTiposEmpReport`
- Un componente Vue.js de página completa, sin tabs, con navegación y tabla de resultados
- Un stored procedure en PostgreSQL para obtener el catálogo ordenado

## Arquitectura

- **Backend**: Laravel Controller (`RepTiposEmpController`)
- **Frontend**: Vue.js Single Page Component (`RepTiposEmpPage.vue`)
- **Base de Datos**: PostgreSQL, tabla `ta_16_tipos_emp`, SP `sp_rep_tipos_empresas`
- **API**: `/api/execute` (POST), body `{ action: 'getTiposEmpReport', params: { order: 1|2|3 } }`

## Flujo de Datos
1. El usuario accede a la página de reporte de Tipos de Empresas
2. Selecciona el criterio de ordenamiento (Control, Tipo, Descripción)
3. Hace clic en "Vista Previa"
4. El frontend envía un POST a `/api/execute` con la acción y parámetros
5. El backend ejecuta el SP `sp_rep_tipos_empresas` con el parámetro de orden
6. El resultado se muestra en una tabla en la página

## Detalles Técnicos

### Stored Procedure PostgreSQL
- Nombre: `sp_rep_tipos_empresas`
- Parámetro: `p_order` (integer)
- Ordena por: 1=ctrol_emp, 2=tipo_empresa, 3=descripcion
- Devuelve: ctrol_emp, tipo_empresa, descripcion

### Laravel Controller
- Método principal: `execute(Request $request)`
- Acciones soportadas:
    - `getTiposEmpReport`: Llama al SP y retorna los datos
    - `getTiposEmpOptions`: Opciones de ordenamiento para el frontend
- Respuesta: JSON `{ success, data, message }`

### Vue.js Component
- Página completa, sin tabs
- Selector de ordenamiento
- Botón Vista Previa (llama a la API)
- Tabla de resultados
- Manejo de loading y errores

### Seguridad
- El endpoint debe estar protegido por autenticación (middleware Laravel)
- Validar el parámetro `order` (1,2,3)

### Extensibilidad
- El patrón eRequest/eResponse permite agregar más acciones sin cambiar el endpoint
- El SP puede extenderse para filtros adicionales si se requiere

## Requisitos de Integración
- Laravel >= 8.x
- Vue.js >= 2.x o 3.x
- Axios para llamadas HTTP
- PostgreSQL >= 12

## Ejemplo de Request
```json
{
  "action": "getTiposEmpReport",
  "params": { "order": 2 }
}
```

## Ejemplo de Response
```json
{
  "success": true,
  "data": [
    { "ctrol_emp": 1, "tipo_empresa": "PRIVADA", "descripcion": "Empresa Privada" },
    ...
  ],
  "message": ""
}
```


## Casos de Uso

# Casos de Uso - Rep_Tipos_Emp

**Categoría:** Form

## Caso de Uso 1: Consulta de Tipos de Empresas ordenado por Control

**Descripción:** El usuario desea visualizar el catálogo de Tipos de Empresas ordenado por número de control.

**Precondiciones:**
El usuario tiene acceso al sistema y permisos para consultar catálogos.

**Pasos a seguir:**
1. El usuario navega a la página 'Reporte Tipos de Empresas'.
2. Selecciona 'Control' en el selector de orden.
3. Hace clic en 'Vista Previa'.
4. El sistema muestra la tabla ordenada por número de control.

**Resultado esperado:**
La tabla muestra todos los tipos de empresa ordenados ascendentemente por el campo 'ctrol_emp'.

**Datos de prueba:**
Tipos de empresa: (1, 'PRIVADA', 'Empresa Privada'), (2, 'PUBLICA', 'Empresa Pública'), (3, 'MIXTA', 'Empresa Mixta')

---

## Caso de Uso 2: Consulta de Tipos de Empresas ordenado por Tipo

**Descripción:** El usuario desea visualizar el catálogo de Tipos de Empresas ordenado por tipo.

**Precondiciones:**
El usuario tiene acceso al sistema.

**Pasos a seguir:**
1. El usuario accede a la página de reporte.
2. Selecciona 'Tipo' en el selector de orden.
3. Hace clic en 'Vista Previa'.

**Resultado esperado:**
La tabla muestra los tipos de empresa ordenados alfabéticamente por 'tipo_empresa'.

**Datos de prueba:**
Tipos de empresa: (1, 'PRIVADA', ...), (2, 'MIXTA', ...), (3, 'PUBLICA', ...)

---

## Caso de Uso 3: Consulta de Tipos de Empresas ordenado por Descripción

**Descripción:** El usuario desea visualizar el catálogo de Tipos de Empresas ordenado por descripción.

**Precondiciones:**
El usuario está autenticado.

**Pasos a seguir:**
1. El usuario abre la página de reporte.
2. Selecciona 'Descripción' en el selector.
3. Hace clic en 'Vista Previa'.

**Resultado esperado:**
La tabla muestra los tipos de empresa ordenados alfabéticamente por 'descripcion'.

**Datos de prueba:**
Tipos de empresa: (1, 'PRIVADA', 'Empresa Privada'), (2, 'PUBLICA', 'Empresa Pública'), (3, 'MIXTA', 'Empresa Mixta')

---



## Casos de Prueba

# Casos de Prueba: Rep_Tipos_Emp

## Caso 1: Consulta por Control
- **Input:** { action: 'getTiposEmpReport', params: { order: 1 } }
- **Resultado esperado:** Lista de tipos de empresa ordenados por ctrol_emp ascendente.
- **Validación:** El primer registro debe tener el menor ctrol_emp.

## Caso 2: Consulta por Tipo
- **Input:** { action: 'getTiposEmpReport', params: { order: 2 } }
- **Resultado esperado:** Lista ordenada alfabéticamente por tipo_empresa.
- **Validación:** El primer registro debe tener el tipo_empresa alfabéticamente menor.

## Caso 3: Consulta por Descripción
- **Input:** { action: 'getTiposEmpReport', params: { order: 3 } }
- **Resultado esperado:** Lista ordenada alfabéticamente por descripcion.
- **Validación:** El primer registro debe tener la descripcion alfabéticamente menor.

## Caso 4: Parámetro inválido
- **Input:** { action: 'getTiposEmpReport', params: { order: 99 } }
- **Resultado esperado:** El sistema retorna la lista ordenada por ctrol_emp (default) o un error controlado.
- **Validación:** No debe haber error fatal, debe manejarse la excepción.

## Caso 5: Sin datos
- **Input:** { action: 'getTiposEmpReport', params: { order: 1 } } (con tabla vacía)
- **Resultado esperado:** El sistema retorna una lista vacía y mensaje informativo.
- **Validación:** El frontend muestra 'No hay datos para mostrar.'


