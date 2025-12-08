# Documentación Técnica: Rep_Contratos

## Análisis

# Documentación Técnica: Migración Formulario Rep_Contratos (Delphi) a Laravel + Vue.js + PostgreSQL

## Arquitectura General
- **Backend**: Laravel 10+ (PHP 8), API RESTful, endpoint único `/api/execute`.
- **Frontend**: Vue.js 3 SPA, cada formulario es una página independiente.
- **Base de Datos**: PostgreSQL 13+, lógica de negocio en stored procedures.
- **Patrón API**: eRequest/eResponse, todas las acciones pasan por un solo endpoint.

## Flujo de Datos
1. **Frontend** solicita datos (empresas, tipos de aseo, recaudadoras) vía `/api/execute` con acción específica.
2. **Backend** recibe la acción, despacha a la función/stored procedure correspondiente.
3. **Stored Procedures** devuelven los datos filtrados y ordenados según los parámetros.
4. **Frontend** muestra los resultados en tablas, permite búsqueda y selección.

## Endpoints y Acciones
- `/api/execute` (POST)
  - Entrada: `{ eRequest: { action: ..., ...params } }`
  - Salida: `{ eResponse: { ... } }`

### Acciones Soportadas
- `listar_empresas`: Lista todas las empresas.
- `listar_tipo_aseo`: Lista todos los tipos de aseo.
- `listar_recaudadoras`: Lista todas las recaudadoras.
- `buscar_empresas`: Busca empresas por nombre.
- `buscar_contratos`: Busca contratos por filtros.
- `reporte_empresa_contratos`: Reporte empresa-contratos (cabecera/detalle).
- `reporte_contratos`: Reporte solo contratos.

## Seguridad
- Se recomienda implementar autenticación JWT o session-based.
- Validar y sanitizar todos los parámetros recibidos.

## Manejo de Errores
- Todos los errores se devuelven en `eResponse.error`.
- El frontend muestra mensajes de error amigables.

## Consideraciones de Migración
- Los combos y listas Delphi se migran a selects Vue.js.
- Los reportes Delphi (QuickReport) se migran a tablas HTML y pueden exportarse a PDF/Excel desde el frontend.
- El ordenamiento y filtrado se realiza en el backend vía stored procedures.
- El frontend es completamente desacoplado y no usa tabs.

## Estructura de Stored Procedures
- Todos los SPs devuelven TABLE (PostgreSQL setof record).
- Los parámetros pueden ser NULL para indicar "todos".
- El ordenamiento se parametriza vía string (ejemplo: 'ctrol_emp,num_empresa').

## Ejemplo de Llamada API
```json
{
  "eRequest": {
    "action": "reporte_contratos",
    "empresa_id": 123,
    "tipo_aseo_id": 4,
    "vigencia": "V",
    "recaudadora_id": 2,
    "orden": "ctrol_aseo,num_contrato"
  }
}
```

## Ejemplo de Respuesta
```json
{
  "eResponse": {
    "reporte": [
      { "num_contrato": 1, "ctrol_aseo": 4, ... },
      ...
    ]
  }
}
```

## Notas de Implementación
- El frontend puede paginar los resultados si el reporte es muy grande.
- El backend puede agregar paginación en los SPs si es necesario.
- El endpoint es extensible para futuras acciones.

# Migración de Lógica Delphi
- Los métodos de inicialización de combos se migran a llamadas a los SPs de catálogo.
- La lógica de armado de queries Delphi se traslada a los SPs de reporte.
- El filtro por empresa, tipo de aseo, vigencia y recaudadora se parametriza en los SPs.
- El frontend permite búsqueda por nombre de empresa mediante un modal.

# Pruebas y Validación
- Se recomienda probar todos los filtros combinados.
- Validar que los reportes coincidan con los resultados del sistema original.
- Probar casos de error (empresa inexistente, sin contratos, etc).


## Casos de Uso

# Casos de Uso - Rep_Contratos

**Categoría:** Form

## Caso de Uso 1: Consulta de Reporte Empresa-Contratos para Todas las Empresas

**Descripción:** El usuario desea obtener un reporte de todas las empresas y sus contratos vigentes, ordenados por tipo de empresa y número de empresa.

**Precondiciones:**
El usuario tiene acceso al sistema y existen empresas y contratos vigentes en la base de datos.

**Pasos a seguir:**
1. El usuario accede a la página de Reporte de Contratos.
2. Selecciona 'Todas las empresas' en el combo Empresa.
3. Selecciona 'Todos los tipos' en Tipo de Aseo.
4. Selecciona 'Vigentes' en Vigencia.
5. Selecciona 'Todas' en Recaudadora.
6. Selecciona 'Empresa - Contratos' como tipo de reporte.
7. Selecciona 'Tipo Emp, Num Emp' como orden.
8. Presiona 'Buscar'.

**Resultado esperado:**
Se muestra una tabla con todas las empresas y sus contratos vigentes, agrupados y ordenados por tipo de empresa y número de empresa.

**Datos de prueba:**
Empresas: varias con contratos vigentes y cancelados. Contratos: con diferentes tipos de aseo y recaudadoras.

---

## Caso de Uso 2: Búsqueda de Contratos por Nombre de Empresa

**Descripción:** El usuario busca contratos de una empresa específica usando el buscador por nombre.

**Precondiciones:**
El usuario tiene acceso y conoce parte del nombre de la empresa.

**Pasos a seguir:**
1. El usuario accede a la página de Reporte de Contratos.
2. Hace clic en 'Buscar por nombre'.
3. Escribe 'ALFA' en el campo de búsqueda y presiona Enter.
4. Selecciona la empresa 'ALFA S.A.' de la lista.
5. Selecciona 'Solo Contratos' como tipo de reporte.
6. Presiona 'Buscar'.

**Resultado esperado:**
Se muestra una tabla con todos los contratos de la empresa 'ALFA S.A.'.

**Datos de prueba:**
Empresa: 'ALFA S.A.' con varios contratos de diferentes tipos de aseo.

---

## Caso de Uso 3: Reporte de Contratos Filtrado por Tipo de Aseo y Recaudadora

**Descripción:** El usuario desea ver solo los contratos de tipo de aseo 'Hospitalario' y recaudadora 'Centro', sin importar la empresa.

**Precondiciones:**
Existen contratos con tipo de aseo 'Hospitalario' y recaudadora 'Centro'.

**Pasos a seguir:**
1. El usuario accede a la página de Reporte de Contratos.
2. Selecciona 'Todos' en Empresa.
3. Selecciona 'Hospitalario' en Tipo de Aseo.
4. Selecciona 'Todos' en Vigencia.
5. Selecciona 'Centro' en Recaudadora.
6. Selecciona 'Solo Contratos' como tipo de reporte.
7. Presiona 'Buscar'.

**Resultado esperado:**
Se muestra una tabla con todos los contratos de tipo 'Hospitalario' y recaudadora 'Centro'.

**Datos de prueba:**
Contratos: varios con ctrol_aseo=4 (Hospitalario), id_rec=1 (Centro).

---



## Casos de Prueba

# Casos de Prueba para Rep_Contratos

## Caso 1: Reporte Empresa-Contratos (Todos)
- **Entrada:**
  - empresa_id: null
  - tipo_aseo_id: null
  - vigencia: 'V'
  - recaudadora_id: null
  - tipoReporte: 'empresa_contratos'
  - orden: 'ctrol_emp,num_empresa'
- **Acción:** POST /api/execute
- **Esperado:**
  - eResponse.reporte contiene empresas y contratos vigentes, ordenados por tipo de empresa y número de empresa.

## Caso 2: Búsqueda por Nombre de Empresa
- **Entrada:**
  - action: 'buscar_empresas'
  - nombre: 'ALFA'
- **Acción:** POST /api/execute
- **Esperado:**
  - eResponse.empresas contiene empresas cuyo nombre incluye 'ALFA'.

## Caso 3: Reporte Solo Contratos, Filtro por Tipo de Aseo y Recaudadora
- **Entrada:**
  - empresa_id: null
  - tipo_aseo_id: 4
  - vigencia: 'T'
  - recaudadora_id: 1
  - tipoReporte: 'solo_contratos'
  - orden: 'ctrol_aseo,num_contrato'
- **Acción:** POST /api/execute
- **Esperado:**
  - eResponse.reporte contiene solo contratos de tipo aseo 4 y recaudadora 1.

## Caso 4: Error de Acción No Soportada
- **Entrada:**
  - action: 'accion_inexistente'
- **Acción:** POST /api/execute
- **Esperado:**
  - eResponse.error indica 'Acción no soportada'.

## Caso 5: Empresa sin Contratos
- **Entrada:**
  - empresa_id: 9999 (empresa sin contratos)
  - tipoReporte: 'solo_contratos'
- **Acción:** POST /api/execute
- **Esperado:**
  - eResponse.reporte es un arreglo vacío.


