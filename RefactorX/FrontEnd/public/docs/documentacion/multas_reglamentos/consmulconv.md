# Documentación: consmulconv

## Análisis Técnico

# Documentación Técnica: Consulta de Convenios de Multas

## Descripción General
Este módulo permite consultar los convenios asociados a multas municipales. La migración Delphi → Laravel + Vue.js + PostgreSQL implementa:
- Un endpoint API único `/api/execute` (patrón eRequest/eResponse)
- Un controlador Laravel con métodos para consultar convenios por id_multa, expediente o rango de fechas
- Un componente Vue.js como página independiente
- Stored Procedures en PostgreSQL para encapsular la lógica de consulta

## Arquitectura
- **Backend:** Laravel 10+, controlador `ConsMulConvController`
- **Frontend:** Vue.js 3+, componente `ConsultaConveniosMulta.vue`
- **Base de datos:** PostgreSQL, tabla `convenios` y stored procedures
- **API:** POST `/api/execute` con payload `{ action, params }`

## Flujo de Datos
1. El usuario accede a la página de consulta de convenios
2. Selecciona el tipo de búsqueda (por multa, expediente, rango de fechas)
3. El formulario envía un POST a `/api/execute` con el action y los parámetros
4. El controlador Laravel ejecuta el stored procedure correspondiente
5. El resultado se regresa en formato eResponse (JSON)
6. El frontend muestra los resultados en una tabla

## Detalles de Implementación
### Laravel Controller
- El método `execute` recibe el action y los params
- Valida los parámetros requeridos
- Llama al stored procedure adecuado usando DB::select
- Devuelve la respuesta estándar `{ success, data, message }`

### Vue.js Component
- Formulario reactivo para los 3 tipos de búsqueda
- Llama a `/api/execute` vía fetch
- Muestra resultados en tabla
- Maneja loading y errores

### Stored Procedures
- `sp_get_convenios_by_multa(id_multa)`
- `sp_get_convenios_by_expediente(letras_exp, axo_exp, numero_exp)`
- `sp_get_convenios_by_range(fecha_inicio, fecha_fin)`

### API Unificada
- Todas las acciones usan `/api/execute` con action y params
- Ejemplo de request:
```json
{
  "action": "get_convenios_by_multa",
  "params": { "id_multa": 123 }
}
```

### Seguridad
- Se recomienda proteger el endpoint con autenticación JWT o session
- Validar y sanear todos los parámetros

### Consideraciones de Migración
- El formulario Delphi usaba un grid vinculado a un DataSource; en Vue se usa una tabla HTML
- Los queries SQL se encapsulan en stored procedures para portabilidad y seguridad
- El endpoint es genérico y puede extenderse para otras acciones

## Estructura de la Tabla `convenios`
```sql
CREATE TABLE convenios (
    id_conv_diver SERIAL PRIMARY KEY,
    id_multa INTEGER,
    letras_exp VARCHAR(10),
    axo_exp INTEGER,
    numero_exp INTEGER,
    referencia VARCHAR(50),
    axo_desde INTEGER,
    bim_desde INTEGER,
    axo_hasta INTEGER,
    bim_hasta INTEGER,
    impuesto NUMERIC(12,2),
    recargos NUMERIC(12,2),
    gastos NUMERIC(12,2),
    multa NUMERIC(12,2),
    total NUMERIC(12,2),
    nombre VARCHAR(100),
    fecha_inicio DATE,
    fecha_venc DATE,
    vigencia VARCHAR(10)
);
```

## Ejemplo de Uso
- Buscar convenios por id_multa: POST `/api/execute` `{ action: 'get_convenios_by_multa', params: { id_multa: 123 } }`
- Buscar por expediente: `{ action: 'get_convenios_by_expediente', params: { letras_exp: 'A', axo_exp: 2022, numero_exp: 12345 } }`
- Buscar por rango: `{ action: 'get_convenios_by_range', params: { fecha_inicio: '2024-01-01', fecha_fin: '2024-12-31' } }`

## Extensibilidad
- Se pueden agregar más acciones y stored procedures siguiendo el mismo patrón
- El frontend puede extenderse para exportar resultados, imprimir, etc.

## Seguridad y Validación
- Validar tipos y rangos de fechas en el backend
- Limitar el tamaño de los resultados
- Auditar el acceso a convenios sensibles

## Casos de Uso

> ⚠️ Pendiente de documentar

## Casos de Prueba

> ⚠️ Pendiente de documentar

## Integración con Backend

> ⚠️ Pendiente de documentar

