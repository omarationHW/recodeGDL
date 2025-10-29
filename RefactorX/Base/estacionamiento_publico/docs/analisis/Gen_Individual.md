# Documentación Técnica: Migración Formulario Gen_Individual (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo permite la generación de remesas individuales de folios, permitiendo buscar por placa, placa+folio o año+folio, registrar los resultados en una tabla de datos municipales, ejecutar la remesa (registrando en bitácora), y generar un archivo de texto plano con los datos de la remesa.

## 2. Arquitectura
- **Frontend**: Vue.js (Single Page Component, ruta independiente)
- **Backend**: Laravel Controller con endpoint único `/api/execute` (patrón eRequest/eResponse)
- **Base de Datos**: PostgreSQL, lógica encapsulada en stored procedures

## 3. Flujo de Operación
1. **Inicialización**: El frontend solicita el número de remesa siguiente y las fechas de corte.
2. **Búsqueda y Adición**: El usuario selecciona el tipo de búsqueda (placa, placa+folio, año+folio), ingresa los datos y añade los registros a la remesa.
3. **Ejecución**: Se graba la remesa en la bitácora y se actualizan los contadores de pagos normales y cancelaciones.
4. **Generación de Archivo**: Se genera un archivo de texto plano con los datos de la remesa, listo para descarga.
5. **Consulta**: Se pueden consultar los registros de la remesa en cualquier momento.

## 4. API Backend
- **Endpoint**: `/api/execute`
- **Método**: POST
- **Entrada**: `{ eRequest: { action: string, params: {...} } }`
- **Salida**: `{ eResponse: { success: bool, data: ..., message: ... } }`

### Acciones soportadas:
- `init`: Inicializa la pantalla, retorna número de remesa y fechas
- `add`: Añade registros a la remesa según búsqueda
- `execute`: Ejecuta la remesa (graba en bitácora)
- `generate_file`: Genera archivo de texto plano de la remesa
- `consult`: Consulta los registros de la remesa
- `delete_remesa`: Elimina la remesa actual

## 5. Stored Procedures
- **sp_gen_individual_add**: Busca y añade registros a la remesa
- **sp_gen_individual_execute**: Ejecuta la remesa y graba en bitácora
- **sp_gen_individual_generate_file**: Devuelve los datos de la remesa en formato para archivo plano

## 6. Frontend (Vue.js)
- Página independiente, sin tabs
- Permite seleccionar tipo de búsqueda, ingresar datos, añadir registros, ejecutar, consultar y generar archivo
- Muestra tabla de registros de la remesa y contadores
- Permite descargar el archivo generado

## 7. Seguridad
- Todas las operaciones pasan por el backend y stored procedures
- Validación de parámetros en backend y frontend
- El archivo generado se almacena en un directorio seguro y se expone sólo para descarga

## 8. Consideraciones
- El campo `folio` puede ser una lista separada por comas
- El archivo generado es plano, campos separados por '|', codificación UTF-8
- El endpoint es unificado para facilitar integración y pruebas

## 9. Errores y Manejo de Excepciones
- Todos los errores se devuelven en el campo `message` de la respuesta
- El frontend muestra alertas en caso de error

## 10. Pruebas y Casos de Uso
- Ver sección de Casos de Uso y Casos de Prueba
