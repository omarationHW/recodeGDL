# Documentación Técnica: sQRptTipos_Empresas

## Análisis

# Documentación Técnica: Migración de Formulario sQRptTipos_Empresas

## 1. Descripción General
Este módulo corresponde a la migración del formulario Delphi `sQRptTipos_Empresas` al stack Laravel + Vue.js + PostgreSQL. El objetivo es mostrar un catálogo de tipos de empresas, permitiendo al usuario seleccionar el criterio de ordenamiento (por número de control, tipo o descripción).

## 2. Arquitectura
- **Backend:** Laravel expone un endpoint único `/api/execute` que recibe un `eRequest` y parámetros. La lógica de negocio y acceso a datos se delega a stored procedures en PostgreSQL.
- **Frontend:** Un componente Vue.js independiente, que consume el endpoint y muestra los datos en una tabla, permitiendo cambiar el criterio de ordenamiento.
- **Base de Datos:** Toda la lógica SQL se encapsula en stored procedures. El SP principal es `sp_get_tipos_empresas`.

## 3. API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Request:**
  ```json
  {
    "eRequest": "getTiposEmpresas",
    "params": { "opcion": 1 }
  }
  ```
- **Response:**
  ```json
  {
    "eResponse": {
      "success": true,
      "data": [ ... ],
      "message": ""
    }
  }
  ```

## 4. Stored Procedure
- **Nombre:** `sp_get_tipos_empresas`
- **Parámetro:** `opcion` (integer)
  - 1: Ordenar por `ctrol_emp`
  - 2: Ordenar por `tipo_empresa`
  - 3: Ordenar por `descripcion`
- **Retorno:** SETOF ta_16_tipos_emp (todas las columnas)

## 5. Frontend (Vue.js)
- Página independiente, con breadcrumb y tabla de resultados.
- Selector para cambiar el criterio de ordenamiento.
- Muestra la fecha/hora de impresión.

## 6. Seguridad
- El endpoint debe protegerse con autenticación (no incluida en este ejemplo, pero recomendable en producción).
- Validar que el parámetro `opcion` esté en el rango permitido.

## 7. Extensibilidad
- El patrón eRequest/eResponse permite agregar nuevos casos de uso sin modificar la ruta del endpoint.
- Los stored procedures pueden evolucionar sin afectar el frontend.

## 8. Consideraciones de Migración
- Los nombres de campos y tablas deben coincidir con la estructura original.
- El SP puede adaptarse si la tabla cambia de nombre o estructura.

## 9. Dependencias
- Laravel >= 8
- Vue.js >= 2.6 (o 3.x, según el proyecto)
- PostgreSQL >= 10

## 10. Pruebas
- Ver sección de casos de uso y casos de prueba.


## Casos de Uso

# Casos de Uso - sQRptTipos_Empresas

**Categoría:** Form

## Caso de Uso 1: Visualizar catálogo de tipos de empresas ordenado por número de control

**Descripción:** El usuario accede a la página del catálogo y visualiza la lista de tipos de empresas ordenada por el campo 'ctrol_emp'.

**Precondiciones:**
El usuario tiene acceso a la aplicación y existen registros en la tabla ta_16_tipos_emp.

**Pasos a seguir:**
1. El usuario navega a la página 'Catálogo de Tipos de Empresas'.
2. El sistema carga automáticamente la lista ordenada por número de control (opcion=1).
3. El usuario visualiza la tabla con los campos: Control, Tipo, Descripción.

**Resultado esperado:**
La tabla muestra todos los registros de tipos de empresas ordenados ascendentemente por el campo 'ctrol_emp'.

**Datos de prueba:**
ta_16_tipos_emp:
| ctrol_emp | tipo_empresa | descripcion         |
|-----------|--------------|--------------------|
| 1         | A            | Empresa Industrial |
| 2         | B            | Empresa Comercial  |

---

## Caso de Uso 2: Cambiar criterio de ordenamiento a 'Tipo'

**Descripción:** El usuario selecciona 'Tipo' en el selector de clasificación y la tabla se actualiza ordenada por el campo 'tipo_empresa'.

**Precondiciones:**
El usuario está en la página del catálogo y existen registros con diferentes valores en 'tipo_empresa'.

**Pasos a seguir:**
1. El usuario selecciona 'Tipo' en el selector de clasificación.
2. El sistema envía la petición con opcion=2.
3. La tabla se actualiza mostrando los registros ordenados por 'tipo_empresa'.

**Resultado esperado:**
La tabla muestra los registros ordenados ascendentemente por el campo 'tipo_empresa'.

**Datos de prueba:**
ta_16_tipos_emp:
| ctrol_emp | tipo_empresa | descripcion         |
|-----------|--------------|--------------------|
| 2         | B            | Empresa Comercial  |
| 1         | A            | Empresa Industrial |

---

## Caso de Uso 3: Manejo de tabla vacía

**Descripción:** El usuario accede a la página cuando no existen registros en la tabla ta_16_tipos_emp.

**Precondiciones:**
La tabla ta_16_tipos_emp está vacía.

**Pasos a seguir:**
1. El usuario navega a la página 'Catálogo de Tipos de Empresas'.
2. El sistema consulta la base de datos y no encuentra registros.
3. Se muestra un mensaje indicando que no hay registros.

**Resultado esperado:**
La tabla muestra una fila con el mensaje 'No hay registros para mostrar.'

**Datos de prueba:**
ta_16_tipos_emp: (sin registros)

---



## Casos de Prueba

# Casos de Prueba: Catálogo de Tipos de Empresas

## Caso 1: Visualización inicial ordenada por número de control
- **Precondición:** Existen al menos 2 registros en ta_16_tipos_emp con diferentes valores en ctrol_emp.
- **Acción:** Acceder a la página del catálogo.
- **Esperado:** La tabla muestra los registros ordenados por ctrol_emp ascendente.

## Caso 2: Cambio de ordenamiento a 'Tipo'
- **Precondición:** Existen registros con diferentes valores en tipo_empresa.
- **Acción:** Seleccionar 'Tipo' en el selector de clasificación.
- **Esperado:** La tabla se actualiza y muestra los registros ordenados por tipo_empresa ascendente.

## Caso 3: Cambio de ordenamiento a 'Descripción'
- **Precondición:** Existen registros con diferentes valores en descripcion.
- **Acción:** Seleccionar 'Descripción' en el selector de clasificación.
- **Esperado:** La tabla se actualiza y muestra los registros ordenados por descripcion ascendente.

## Caso 4: Tabla vacía
- **Precondición:** La tabla ta_16_tipos_emp no tiene registros.
- **Acción:** Acceder a la página del catálogo.
- **Esperado:** Se muestra el mensaje 'No hay registros para mostrar.'

## Caso 5: Error de comunicación con el backend
- **Precondición:** El backend no está disponible.
- **Acción:** Acceder a la página del catálogo.
- **Esperado:** Se muestra un mensaje de error al usuario.


