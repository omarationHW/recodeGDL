# Documentación Técnica: Prueba

## Análisis

# Documentación Técnica: Migración Formulario Prueba (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo corresponde a la migración del formulario "Prueba" de Delphi a una arquitectura moderna basada en Laravel (backend/API), Vue.js (frontend SPA), y PostgreSQL (base de datos y stored procedures). El objetivo es mantener la lógica funcional original, pero adaptada a mejores prácticas web y desacoplamiento frontend-backend.

## 2. Arquitectura
- **Backend**: Laravel API, endpoint único `/api/execute` que recibe peticiones eRequest/eResponse.
- **Frontend**: Vue.js SPA, componente de página independiente para el formulario Prueba.
- **Base de Datos**: PostgreSQL, lógica de negocio encapsulada en stored procedures.

## 3. Flujo de Datos
1. El usuario ingresa un valor de control (`parCtrol`) y envía el formulario.
2. El frontend llama a `/api/execute` con `{ action: 'prueba_query', params: { parCtrol } }`.
3. El backend ejecuta el stored procedure `sp_prueba_query` y retorna los resultados.
4. Para cada resultado, el usuario puede consultar la licencia de giro asociada, lo que dispara otra llamada a `/api/execute` con `{ action: 'licencia_giro_f1', params: { p_tipo, p_numero } }`.
5. El backend ejecuta el stored procedure `sp16_licenciagiro_f1` y retorna el resultado.

## 4. API Unificada
- **Endpoint**: `POST /api/execute`
- **Entrada**:
  - `action`: Nombre de la acción a ejecutar (string)
  - `params`: Parámetros específicos de la acción (object)
- **Salida**:
  - `status`: 'success' | 'error'
  - `message`: Mensaje informativo
  - `data`: Datos de respuesta (array/object)

## 5. Stored Procedures
- Toda la lógica SQL se encapsula en stored procedures para desacoplar la lógica de negocio de la aplicación.
- Los procedimientos devuelven tablas (TABLE) para facilitar el consumo desde Laravel.

## 6. Vue.js Frontend
- El componente es una página completa, no un tab.
- Incluye navegación breadcrumb.
- Permite consultar y mostrar resultados, así como consultar información adicional por fila.
- El memo muestra el JSON de resultados para depuración.

## 7. Seguridad
- El endpoint `/api/execute` debe estar protegido por autenticación (middleware Laravel, no incluido aquí).
- Validación de parámetros en backend.

## 8. Extensibilidad
- El patrón eRequest/eResponse permite agregar nuevas acciones sin modificar el endpoint.
- Los stored procedures pueden evolucionar sin cambiar la API.

## 9. Pruebas
- Se proveen casos de uso y escenarios de prueba para asegurar la funcionalidad.

## 10. Notas de Migración
- El formulario original usaba componentes visuales y lógica procedural. En la migración, la lógica se desacopla y se orienta a servicios.
- El stored procedure de licencia de giro es una simulación; debe adaptarse a la lógica real de negocio si es necesario.


## Casos de Uso

# Casos de Uso - Prueba

**Categoría:** Form

## Caso de Uso 1: Consulta de Contratos por Control de Aseo

**Descripción:** El usuario ingresa un valor de control de aseo y obtiene la lista de contratos y tipos de aseo asociados.

**Precondiciones:**
El usuario tiene acceso a la aplicación y permisos para consultar.

**Pasos a seguir:**
1. El usuario accede a la página Prueba.
2. Ingresa el valor '9' en el campo Control Aseo.
3. Presiona el botón 'Consultar'.

**Resultado esperado:**
Se muestra una tabla con los contratos cuyo ctrol_aseo=9 y num_contrato>=2120.

**Datos de prueba:**
parCtrol: 9

---

## Caso de Uso 2: Consulta de Licencia de Giro para un Contrato

**Descripción:** El usuario consulta la licencia de giro asociada a un contrato específico desde la tabla de resultados.

**Precondiciones:**
Se ha realizado una consulta previa y hay resultados en la tabla.

**Pasos a seguir:**
1. El usuario presiona el botón 'Consultar Licencia' en la fila deseada.

**Resultado esperado:**
Se muestra el resultado del stored procedure (mensaje de éxito o error según si existe relación de licencia).

**Datos de prueba:**
p_tipo: 'O', p_numero: 2125

---

## Caso de Uso 3: Error por Falta de Parámetro

**Descripción:** El usuario intenta consultar sin ingresar el parámetro requerido.

**Precondiciones:**
El usuario accede a la página Prueba.

**Pasos a seguir:**
1. El usuario deja el campo Control Aseo vacío.
2. Presiona el botón 'Consultar'.

**Resultado esperado:**
Se muestra un mensaje de error indicando que falta el parámetro.

**Datos de prueba:**
parCtrol: ''

---



## Casos de Prueba

# Casos de Prueba para Formulario Prueba

## Caso 1: Consulta exitosa de contratos
- **Entrada:** parCtrol = 9
- **Acción:** POST /api/execute { action: 'prueba_query', params: { parCtrol: 9 } }
- **Resultado esperado:** status: 'success', data: array con contratos ctrol_aseo=9 y num_contrato>=2120

## Caso 2: Consulta de licencia de giro existente
- **Entrada:** p_tipo = 'O', p_numero = 2125 (asumiendo existe relación)
- **Acción:** POST /api/execute { action: 'licencia_giro_f1', params: { p_tipo: 'O', p_numero: 2125 } }
- **Resultado esperado:** status: 'success', data: [{ status_licencias: 0, concepto_licencias: 'Licencia relacionada encontrada' }]

## Caso 3: Consulta de licencia de giro inexistente
- **Entrada:** p_tipo = 'X', p_numero = 9999 (no existe relación)
- **Acción:** POST /api/execute { action: 'licencia_giro_f1', params: { p_tipo: 'X', p_numero: 9999 } }
- **Resultado esperado:** status: 'success', data: [{ status_licencias: 1, concepto_licencias: 'No existe relación de licencia para este contrato' }]

## Caso 4: Error por falta de parámetro
- **Entrada:** parCtrol = null
- **Acción:** POST /api/execute { action: 'prueba_query', params: { } }
- **Resultado esperado:** status: 'error', message: 'Falta parámetro parCtrol'

## Caso 5: Acción no soportada
- **Entrada:** action = 'no_existente'
- **Acción:** POST /api/execute { action: 'no_existente', params: { } }
- **Resultado esperado:** status: 'error', message: 'Acción no soportada: no_existente'


